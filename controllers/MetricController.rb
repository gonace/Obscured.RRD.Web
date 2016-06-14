class MetricController < BaseController
  set :views, settings.root + '/../views/metrics'

  get '/:group/:name/:file' do
    raise ArgumentError, 'No server name provided' unless params[:name]
    raise ArgumentError, 'No group id provided' unless params[:group]
    raise ArgumentError, 'No metric file provided' unless params[:file]


    render_time = Time.now
    name_server = params[:name]
    name_group = params[:group]
    file_metric = params[:file]

    begin
      graph_root = settings.root + '/../public/graphs'
      group = Obscured.c('data.sources.groups').find{|a| a['name'] == name_group}
      node = group['nodes'].find {|n| n['name'] == name_server.capitalize}
      metric = node['metrics'].find {|n| n['files'] == file_metric}
      metric_type = Obscured.c('metrics.types').select {|e| e['type'] == metric['type']}.first
      name_metric = metric['type'].to_s
      offsets = [Obscured.c('graph.offsets.daily'), Obscured.c('graph.offsets.weekly'), Obscured.c('graph.offsets.monthly'), Obscured.c('graph.offsets.yearly'), Obscured.c('graph.offsets.triennium')]

      Obscured::Metric.generate(:node => node, :offsets => offsets, :graph_root => graph_root)

      metrics = []
      offsets.each do |offset|
        unless metrics.any? {|m| m.name == name_metric.to_s.capitalize}
          metrics.push Obscured::Entities::Category.new(name_metric.to_s.capitalize)
        end
        metric_image = (!metric['aggregated'].blank? and metric['aggregated'] == true or metric['files'].kind_of?(Array)) ? "-#{offset['name']}.png" : (metric['files'].sub '.rrd', "-#{offset['name']}.png")
        metric_type = Obscured.c('metrics.types').select {|e| e['type'] == metric['type']}.first
        metric_title = (!metric['title'].blank?) ? (metric['title'].to_s % { :suffix => metric_type['suffix'] }) : (metric_type['title'].to_s % { :suffix => metric_type['suffix'] })

        index_category = metrics.find_index {|m| m.name == name_metric.to_s.capitalize}
        if index_category >= 0
          metrics[index_category].graphs.push Obscured::Entities::Graph.new(file_metric, metric_title, metric_image, metric_type)
        end
      end
    rescue ArgumentError => e
      flash[:metrics_error] = "I'm sad to say that he found an error: #{e.message}"
    end

    haml :metric, :locals => {:render_time => render_time,
                              :title => name_server.capitalize,
                              :name_server => name_server,
                              :name_metric => name_metric,
                              :metrics => metrics,
                              :expression => 'homer-excited'}
  end
end