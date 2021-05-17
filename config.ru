ENV['RACK_ENV'] = ENV['OBSCURED_ENV']

require File.expand_path('lib', File.dirname(__FILE__))
require File.expand_path('init', File.dirname(__FILE__))

Obscured.load_config!
Obscured::Logger.info "Starting, env: #{ENV['RACK_ENV']}"


# map the controllers to routes
map('/') do
  use Rack::Static, urls: %w[/graphs /images /script /styles], root: 'public',
                    header_rules: [
                      # Cache all static files in public caches (e.g. Rack::Cache)
                      #  as well as in the browser
                      [:all, { 'Cache-Control' => 'public, max-age=31536000' }],

                      # Provide web fonts with cross-origin access-control-headers
                      #  Firefox requires this when serving assets using a Content Delivery Network
                      [:fonts, { 'Access-Control-Allow-Origin' => '*' }]
                    ]
  run HomeController
end

map('/error') do
  run ErrorController
end

map('/metric') do
  run MetricController
end

map('/metrics') do
  run MetricsController
end


at_exit do
  Obscured::Logger.warn 'Shutting down'
end
