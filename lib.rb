$LOAD_PATH << File.dirname(__FILE__)


###
# Gems
##
require 'dalli'
require 'haml'
require 'json'
require 'pp'
require 'rack/cache'
require 'sinatra/config_file'
require 'sinatra/cookies'
require 'sinatra/flash'
require 'sinatra/json'
require 'sinatra/partial'


###
# Controllers
##
require 'controllers/BaseController'
require 'controllers/ErrorsController'
require 'controllers/HomeController'
require 'controllers/MetricController'


###
# Helpers
###
require 'helpers/config'
require 'helpers/logger'