class MetricsController < BaseController
  set :views, settings.root + '/../views/metrics'

  get '/:group/:name' do
    raise ArgumentError, 'No server name provided' unless params[:name]
    raise ArgumentError, 'No group id provided' unless params[:group]

    render_time = Time.now
    name_server = params[:name]
    name_group = params[:group]

    begin
      graph_root = settings.root + '/../public/graphs'
      group = Obscured.c('data.sources.groups').find{|a| a['name'] == name_group}
      node = group['nodes'].find {|n| n['name'] == name_server.capitalize}
      offsets = [Obscured.c('graph.offsets.weekly')]

      if !Dir.exists? graph_root + "/#{name_server}"
        Dir.mkdir graph_root + "/#{name_server}"
      end
      Obscured::Metric.generate(:node => node, :offsets => offsets, :graph_root => graph_root)

      metrics = []
      node['metrics'].each do |metric|
        unless metrics.any? {|m| m.name == metric['category'].to_s.capitalize}
          metrics.push Obscured::Entities::Category.new(metric['category'].to_s.capitalize)
        end

        metric_file = (!metric['aggregated'].blank? and metric['aggregated'] == true or metric['files'].kind_of?(Array)) ? "#{metric['name']}.rrd" : metric['files']
        metric_image = (!metric['aggregated'].blank? and metric['aggregated'] == true or metric['files'].kind_of?(Array)) ? "#{metric['name']}-weekly.png" : (metric['files'].sub '.rrd', '-weekly.png')
        metric_type = Obscured.c('metrics.types').select {|e| e['type'] == metric['type']}.first
        metric_title = (!metric['title'].blank?) ? (metric['title'].to_s % { :suffix => metric_type['suffix'] }) : (metric_type['title'].to_s % { :suffix => metric_type['suffix'] })

        index_category = metrics.find_index {|m| m.name == metric['category'].to_s.capitalize}
        if index_category >= 0
          metrics[index_category].graphs.push Obscured::Entities::Graph.new(metric_file, metric_title, metric_image, metric_type)
        end
      end
    rescue ArgumentError => e
      flash[:metrics_error] = "I'm sad to say that he found an error: #{e.message}"
    end

    haml :index, :locals => {:render_time => render_time,
                             :title => name_server.capitalize,
                             :name_server => name_server,
                             :name_group => name_group,
                             :metrics => metrics,
                             :expression => 'homer-excited'}
  end
end