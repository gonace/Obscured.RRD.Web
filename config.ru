ENV['RACK_ENV'] = ENV['OBSCURED_ENV']

require File.expand_path('lib', File.dirname(__FILE__))
require File.expand_path('init', File.dirname(__FILE__))

Obscured.load_config!
Obscured::Logger.info "Starting, env: #{ENV['RACK_ENV']}"
use Rack::Deflater

# map the controllers to routes
map('/') do
  use Rack::Static, urls: %w[/graphs /images /robots.txt], root: 'public',
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

map '/assets' do
  env = Sprockets::Environment.new
  #env.js_compressor  = :uglify
  env.css_compressor = :scss
  env.append_path 'assets/scripts'
  env.append_path 'assets/styles'
  run env

  puts "Sprockets.root           => #{env.root}"
  puts "Sprockets.paths          => #{env.paths}"
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
