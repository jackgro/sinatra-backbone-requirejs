require 'sinatra/base'
require 'sinatra/cookies'
require 'sinatra/content_for'
require 'sinatra/config_file'
require 'sinatra/reloader'
require 'sinatra/asset_pipeline'
require 'active_support/all'
require 'better_errors'
require 'json'
require 'uglifier'
require 'sass'
require 'rest-client'
require 'openssl'
require 'pry'
require 'tempfile'
require './app/lib/file_utils'
require './app/lib/api_utils'
require './app/lib/http_utils'
require './app/lib/role_utils'
# require './helpers/reports_helper'
# require './helpers/javascripts'

class Starter < Sinatra::Base
  helpers Sinatra::Cookies
  helpers Sinatra::ContentFor
  helpers Sinatra::FileUtils
  helpers Sinatra::ApiUtils
  helpers Sinatra::HttpUtils
  helpers Sinatra::RoleUtils
  # helpers Sinatra::ReportsHelper
  # helpers Sinatra::Javascripts
  set :root, File.dirname(__FILE__)


  set :assets_precompile, %w(*.js app.css)
  set :assets_prefix, %w(app/assets app/bower_components)
  set :assets_css_compressor, :sass
  set :assets_js_compressor, :uglifier

  register Sinatra::AssetPipeline

  register Sinatra::ConfigFile
  set :environments, %w{development test production sandbox}
  set :views, 'app/views'
  config_file 'config/config.yml'

  configure :development do
    # Reloader
    register Sinatra::Reloader
    also_reload './app'
    # also_reload './helpers/*'
    # also_reload './lib/*'

    # Better Errors
    use BetterErrors::Middleware
    BetterErrors.application_root = './'
  end

  # Allow <% -%> syntax
  set :erb, :trim => '-'
  # .interfolio.com cookies expire in 40 minutes
  # set(:cookie_options) do
  #   { :expires => Time.now + 60*40, :domain => ".interfolio.com" }
  # end

  get '/' do
    erb :index
  end
end

