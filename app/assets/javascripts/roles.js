(function($) {
  // POST a scope change when a new role is selected
  $(document).on('click', '.change-role .scope-target', function(event) {
    event.preventDefault();
    $('.change-role').addClass('disabled');
    var el = this;
    $.post('/scope/' + $(this).data('id'),
           {    'scopeType' : $(this).data('type'),
             'scopeName' : $(this).data('name'),
             'scopeInstitution' : $(this).data('institution'),
             'scopePosition' : ($(this).data('position') || '') },
             function() { $(el).data('name') === "Evaluator Positions" ? window.location = '/positions' : location.reload(); });
  });
  $(document).on('click', '.show-admin-positions', function(event) {
    event.preventDefault();
    event.stopPropagation();
    var link = $(event.target);
    var currentMenu = link.siblings('.position-admin-list');
    $('.position-admin-list').not(currentMenu).hide();
    currentMenu.fadeToggle('fast');
  });
  $(document).on('click', ':not(.show-admin-positions, .position-admin-list)', function(event) {
    $('.position-admin-list').hide();
  });
})(jQuery);
