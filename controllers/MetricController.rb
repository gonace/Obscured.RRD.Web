class MetricController < BaseController
  set :views, settings.root + '/../views/metrics'

  get '/:group/:path/:file' do
    raise ArgumentError, 'No group id provided' unless params[:group]
    raise ArgumentError, 'No server name provided' unless params[:path]
    raise ArgumentError, 'No metric file provided' unless params[:file]


    render_time = Time.now
    server_path = params[:path]
    server_group = params[:group]
    file_metric = params[:file]
    server_name = ''
    metric_name = ''

    begin
      offsets = [Obscured.c('graph.offsets.daily'), Obscured.c('graph.offsets.weekly'), Obscured.c('graph.offsets.monthly'), Obscured.c('graph.offsets.yearly'), Obscured.c('graph.offsets.triennium')]
      graph_root = settings.root + '/../public/graphs'
      group = Obscured.c('data.sources.groups').find{|a| a['name'] == server_group}

      if (group.blank? or group.empty?) or (node.blank? or group.empty?)
        redirect ('/error/404')
      end

      node = group['nodes'].find {|n| n['path'] == server_path}
      metric = node['metrics'].find {|n| n['files'] == file_metric}
      metric_type = Obscured.c('metrics.types').select {|e| e['type'] == metric['type']}.first
      server_name = node['name']
      metric_name = metric['type'].to_s

      Obscured::Metric.generate(:node => node, :offsets => offsets, :graph_root => graph_root)

      metrics = []
      offsets.each do |offset|
        unless metrics.any? {|m| m.name == metric_name.to_s.capitalize}
          metrics.push Obscured::Entities::Category.new(metric_name.to_s.capitalize)
        end
        metric_image = (!metric['aggregated'].blank? and metric['aggregated'] == true or metric['files'].kind_of?(Array)) ? "-#{offset['name']}.png" : (metric['files'].sub '.rrd', "-#{offset['name']}.png")
        metric_type = Obscured.c('metrics.types').select {|e| e['type'] == metric['type']}.first
        metric_title = (!metric['title'].blank?) ? (metric['title'].to_s % { :suffix => metric_type['suffix'] }) : (metric_type['title'].to_s % { :suffix => metric_type['suffix'] })

        index_category = metrics.find_index {|m| m.name == metric_name.to_s.capitalize}
        if index_category >= 0
          metrics[index_category].graphs.push Obscured::Entities::Graph.new(file_metric, metric_title, metric_image, metric_type, Obscured::Entities::Node.new(node['name'], node['path'], group['name'], node['type'].to_s))
        end
      end
    rescue ArgumentError => e
      flash[:metrics_error] = "I'm sad to say that he found an error: #{e.message}"
    end

    haml :metric, :locals => {:render_time => render_time,
                              :title => server_name,
                              :server_name => server_name,
                              :metric_name => metric_name,
                              :metrics => metrics}
  end
end