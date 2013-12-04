module Sinatra::RoleUtils
  def current_scope
    # Determine the user's current scope, either by existing cookies or API user info
    if cookies[:scope_id] && !cookies[:scope_id].empty? && cookies[:scope_name] && !cookies[:scope_name].empty? && cookies[:scope_type] && !cookies[:scope_type].empty?
      scope = { :id => cookies[:scope_id], :name => (CGI::unescape cookies[:scope_name]), :type => cookies[:scope_type], :institution => cookies[:scope_institution], :position => cookies[:scope_position] }
    else
      user = get_user
      if user && !user['administrator_institutions'].empty?
        scope = {
          id: user['administrator_institutions'].first['administrator_institution']['id'],
          name: user['administrator_institutions'].first['administrator_institution']['name'],
          type: 'institution',
          institution: user['administrator_institutions'].first['administrator_institution']['id'],
          position: '' }
      elsif user && !user['administrator_functional_units'].empty?
        scope = {
          id: user['administrator_functional_units'].first['administrator_functional_unit']['id'],
          name: user['administrator_functional_units'].first['administrator_functional_unit']['name'],
          type: 'functional_unit',
          institution: user['administrator_functional_units'].first['administrator_functional_unit']['ancestor_institution_id'],
          position: "" }
      elsif user && !user['committee_manager_functional_units'].empty?
        scope = {
          id: user['committee_manager_functional_units'].first['committee_manager_functional_unit']['id'],
          name: user['committee_manager_functional_units'].first['committee_manager_functional_unit']['name'],
          type: 'functional_unit',
          institution: user['committee_manager_functional_units'].first['committee_manager_functional_unit']['ancestor_institution_id'],
          position: "" }
      elsif user && !user['eeo_officer_functional_units'].empty?
        scope = {
          id: user['eeo_officer_functional_units'].first['eeo_officer_functional_unit']['id'],
          name: user['eeo_officer_functional_units'].first['eeo_officer_functional_unit']['name'],
          type: 'functional_unit',
          institution: user['eeo_officer_functional_units'].first['eeo_officer_functional_unit']['ancestor_institution_id'],
          position: "" }
      elsif user && !position_roles(user, 'administrator_positions').empty?
        scope = {
          position: position_roles(user, 'administrator_positions').first['id'],
          id: position_roles(user, 'administrator_positions').first['functional_unit_id'],
          institution: (user['administrator_functional_units'].select { |unit| unit['administrator_functional_unit']['id'] === position_roles(user, 'administrator_positions').first['functional_unit_id'] }).first['administrator_functional_unit']['ancestor_institution_id'],
          name: position_roles(user, 'administrator_positions').first['name'] || "Untitled Position",
          type: 'position' }
      elsif user && !position_roles(user, 'committee_manager_positions').empty?
        scope = {
          position: position_roles(user, 'committee_manager_positions').first['id'],
          institution: (user['committee_manager_functional_units'].select { |unit| unit['committee_manager_functional_unit']['id'] === position_roles(user, 'committee_manager_positions').first['functional_unit_id'] }).first['committee_manager_functional_unit']['ancestor_institution_id'],
          id: position_roles(user, 'committee_manager_positions').first['functional_unit_id'],
          name: position_roles(user, 'committee_manager_positions').first['name'] || "Untitled Position",
          type: 'position' }
      elsif user && !user['committee_manager_functional_units'].empty?
        scope = {
          id: user['committee_manager_functional_units'].first['committee_manager_functional_unit']['id'],
          name: user['committee_manager_functional_units'].first['committee_manager_functional_unit']['name'],
          type: 'functional_unit',
          institution: user['committee_manager_functional_units'].first['committee_manager_functional_unit']['ancestor_institution_id'],
          position: "" }
      elsif user && !position_roles(user, 'eeo_officer_positions').empty?
        scope = {
          position: position_roles(user, 'eeo_officer_positions').first['id'],
          institution: (user['eeo_officer_functional_units'].select { |unit| unit['eeo_officer_functional_unit']['id'] === position_roles(user, 'eeo_officer_positions').first['functional_unit_id'] }).first['eeo_officer_functional_units']['ancestor_institution_id'],
          id: position_roles(user, 'eeo_officer_positions').first['functional_unit_id'],
          name: position_roles(user, 'eeo_officer_positions').first['name'] || "Untitled Position",
          type: 'position' }
      elsif user && !position_roles(user, 'evaluator_positions').empty?
        scope = {
          position: position_roles(user, 'evaluator_positions').first['id'],
          institution: 0,
          id: 0,
          name: 'Evaluator Positions',
          type: 'position' }
      else
        scope = {
          id: 0,
          name: '',
          type: 'functional_unit',
          institution: 0,
          position: '' }
      end
      scope = {
        id: scope[:id].to_s,
        name: scope[:name].to_s,
        type: scope[:type].to_s,
        institution: scope[:institution].to_s,
        position: scope[:position].to_s }
      set_current_scope( scope[:id], scope[:name], scope[:type], scope[:institution], scope[:position] )
    end
    scope
  end

  def set_current_scope(id, name = "", type = "functional_unit", institution = "", position = "")
    cookies[:scope_id] = id
    cookies[:scope_type] = type
    cookies[:scope_name] = name
    cookies[:scope_institution] = institution
    cookies[:scope_position] = position
  end

  def has_multiple_roles(user)
    if user
      role_count = user['administrator_institution_ids'].length + user['administrator_functional_unit_ids'].length + user['eeo_officer_functional_unit_ids'].length + position_roles(user, 'administrator_positions').length + position_roles(user, 'committee_manager_functional_units').length
      if role_count > 0
        role_count += position_roles(user, 'committee_manager_positions').length + position_roles(user, 'evaluator_positions').length
      end
    else
      role_count = 0
    end
    role_count > 1
  end

  def get_all_units(user)
    # Return an array of LFUs in the user's current scope (institution, BFU, LFU, etc.)
    ids = []
    return unless user.present?
    if current_scope[:type] === 'institution'
      user['administrator_little_functional_units'].each do |unit|
        unit = unit['administrator_little_functional_unit']
        if matches_current_scope(unit['ancestor_institution_id'].to_i, current_scope[:id].to_i)
          ids.push unit['id'].to_i
        end
      end
    elsif is_cm?(user)
      ids.push current_scope[:id].to_i
    elsif is_eeo?(user)
      ids.push find_child_unit_ids(user, 'eeo_officer_functional_units')
    else
      ids.push find_child_unit_ids(user, 'administrator_functional_units')
    end
    ids.flatten
  end

  def find_child_unit_ids(user, units)
    # @param[user]
    # @param[units] - String: a type of functional_unit (e.g., 'eeo_officer_functional_units')
    #   Represents a key in the user's json and returns
    #   the user's eeo_officer_functional_units objects

    # Because of the extra layer between the 'units' and the individual unit attributes,
    # we create this 'matcher' variable which is just the singular version of the 'units' param
    # Example:
    #   find_child_unit_ids(user, 'eeo_officer_functional_units')
    #
    #   user[units] returns an array and is the
    #   same as user['eeo_officer_functional_units']
    #
    #   If you iterate over the array, you can use
    #   the 'matcher' to skip over the extra abstraction layer to
    #   get to the attributes of each individual unit:
    #
    #   user[units].each do |unit|
    #     // Looks like unit['eeo_officer_functional_unit']['id']
    #     unit[matcher]['id']
    #   end
    #
    matcher = units.singularize
    current = user[units].find { |unit| matches_current_scope(unit[matcher]['id'].to_i, current_scope[:id].to_i) }

    if current && current[matcher]['child_unit_ids'].present?
      current[matcher]['child_unit_ids']
    else
      current_scope[:id].to_i
    end
  end

  def matches_current_scope(id_to_match, current_scope_id)
    # @param[id_to_match] - Id you want to match against current_scope[:id]
    # @param[current_scope_id] - current_scope[:id]
    # Returns true or false
    # More for convenience. Not a fancy method but reads nice and
    # serves to explain the purpose of what we're doing with the params
    id_to_match == current_scope_id
  end

  def is_admin?(user)
    # Is the user an administrator of an institution or unit?
    # Returns true if they have either institutions or functional_units
    if user
      user['administrator_institutions'].present? ||
      user['administrator_functional_units'].present?
    end
  end

  def is_cm?(user)
    # Is the user a committee manager for the current scope's unit?
    # Returns true if the user has committee_manager_functional_unit_ids AND
    # those id's include the current_scope[:id]
    if user
      user['committee_manager_functional_unit_ids'].present? &&
      user['committee_manager_functional_unit_ids'].map{|id| id.to_s}.include?(current_scope[:id])
    end
  end

  def is_eval?(user)
    # Is the user currently in an evaluator role?
    current_scope[:name] === "Evaluator Positions"
  end

  def is_eeo?(user)
    # Is the user an administrator of an institution or unit?
    # Returns true if the user has eeo_officer_functional_unit_ids AND
    # those id's include the current_scope[:id]
    if user
      user['eeo_officer_functional_unit_ids'].present? &&
      user['eeo_officer_functional_unit_ids'].map{|id| id.to_s}.include?(current_scope[:id])
    end
  end

  def is_ia?(user)
    # Is the user an institutional admin for the current scope's institution?
    # Returns true if the user has administrator_institution_ids AND
    # those id's include the current_scope[:institution]
    if user
      user['administrator_institution_ids'].present? &&
      user['administrator_institution_ids'].map{|id| id.to_s }.include?(current_scope[:institution])
    end
  end

  def is_super?(user)
    # Returns true if key 'superuser' exists in the API and
    # it is set to true
    user.has_key?('superuser') && user['superuser']
  end

  def position_roles(user, role)
    # Returns *unarchived* positions by @param [role] in alphabetical order
    # ** Positions returned whose 'archived' flag returns false
    # Example output:
    # [
    #    {
    #       "id"                 => 1,
    #       "name"               => "Bigwig",
    #       "functional_unit_id" => 6,
    #       "archived"           => false
    #    },
    #    {
    #       "id"                 => 3481,
    #       "name"               => "Closed - Flag",
    #       "functional_unit_id" => 9477,
    #       "archived"           => false
    #    },
    #    {
    #       "id"                 => 14,
    #       "name"               => "DOSS APP TEST",
    #       "functional_unit_id" => 6,
    #       "archived"           => false
    #    }
    # ]
    user[role].select { |unit| !unit["archived"] }.sort_by { |unit| unit["name"] || "Untitled Position" }
  end

  def admin_positions(user, unit_id)
    content = ""
    positions = position_roles(user, 'administrator_positions').select { |position| position["functional_unit_id"].to_i === unit_id.to_i }.sort_by { |position| position["name"] || 'Untitled Position' }
    unless positions.empty?
      content = '<a class="show-admin-positions">Positions&nbsp;<i class="icon-chevron-right"><!-- icon --></i></a><ul class="position-admin-list dropdown-menu"><li class="dropdown-caret"><!-- caret --></li><li class="dropdown-caret-shadow"><!-- caret --></li>'
      positions.each { |position| content += "<li class=\"scope scope-target\" data-position=\"#{position["id"]}\" data-id=\"#{position["functional_unit_id"]}\" data-type=\"position\" data-name=\"#{position["name"]}\" data-institution=\"#{(user['administrator_functional_units'].select { |unit| unit["administrator_functional_unit"]["id"] === unit_id }).first["administrator_functional_unit"]["ancestor_institution_id"]}\">#{position["name"] || 'Untitled Position'}</li>" }
      content += '</ul>'
    end
    content
  end

  def sort_hierarchy(units)
    # Used to sort a user's administrator_hierarchy
    # alphabetically by the name of the unit. Also
    # sorts all units' child_units by name.
    units = units.sort_by { |unit| unit["unit"]["name"] }
    units.each do |unit|
      if unit["unit"]["child_units"].length
        unit["unit"]["child_units"] = sort_hierarchy unit["unit"]["child_units"]
      end
    end
  end

  def cm_institution(user, id)
    units = user['committee_manager_functional_units'].select { |unit| unit["committee_manager_functional_unit"]["id"] === id }
    if !units.empty?
      institution = units.first["committee_manager_functional_unit"]["ancestor_institution_id"]
    else
      units = user['administrator_functional_units'].select { |unit| unit["administrator_functional_unit"]["id"] === id }
      institution = units.empty? ? '0' : units.first["administrator_functional_unit"]["ancestor_institution_id"]
    end
    institution
  end

end
