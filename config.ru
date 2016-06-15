ENV['RACK_ENV'] = ENV['OBSCURED_ENV']

require File.expand_path('lib', File.dirname(__FILE__))
require File.expand_path('init', File.dirname(__FILE__))

Obscured.load_config!
Obscured::Logger.info "Starting, env: #{ENV['RACK_ENV']}"


# map the controllers to routes
map('/') {
  use Rack::Static, :urls => %w(/graphs /images /script /styles), :root => 'public'
  run HomeController
}

map('/error') {
  run ErrorController
}

map('/metric') {
  run MetricController
}

map('/metrics') {
  run MetricsController
}


at_exit do
  Obscured::Logger.warn 'Shutting down'
end