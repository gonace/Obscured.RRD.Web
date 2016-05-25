class MetricsController < BaseController
  set :views, settings.root + '/../views/metrics'

  get '/:group/:name' do
    raise ArgumentError, 'No server name provided' unless params[:name]
    raise ArgumentError, 'No group id provided' unless params[:group]

    render_time = Time.now
    name_server = params[:name]
    name_group = params[:group]

    #begin
      graph_root = settings.root + '/../public/graphs'
      graph_height = 450
      graph_width = 950
      daily = 24.hours
      weekly = 12000.minutes
      monthly = 800.hours
      yearly = 400.days
      decade = 125.months
      watermark = Obscured.c('graph.watermark')

      puts '#################'
      puts '###   DEBUG   ###'
      puts '#################'
      groups = Obscured.c('data.sources.groups')
      group = groups.find{|a| a['name'] == name_group}
      node = group['nodes'].find {|n| n['name'] == name_server.capitalize}
      puts '########'
      pp node
      puts '#################'
    #rescue ArgumentError => e
    #  flash[:metrics_error] = "Homer is sad to say that he found an error: #{e.message}"
    #end

    haml :index, :locals => {:render_time => render_time,
                             :title => name_server.capitalize,
                             :name => name_server,
                             :expression => 'homer-excited'}
  end
end