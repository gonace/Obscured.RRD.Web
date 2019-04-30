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
      graph_offsets = [Obscured.c('graph.offsets.daily'), Obscured.c('graph.offsets.weekly'), Obscured.c('graph.offsets.monthly'), Obscured.c('graph.offsets.yearly'), Obscured.c('graph.offsets.triennium')]
      graph_root = settings.root + '/../public/graphs'
      group = Obscured.c('data.sources.groups').find { |a| a['name'] == server_group }

      redirect('/error/404') if group.blank? || group.empty?
      node = group['nodes'].find { |n| n['path'] == server_path }
      redirect('/error/404') if node.blank? || group.empty?
      metric = node['metrics'].find { |n| n['files'] == file_metric }
      redirect('/error/404') if metric.blank? || metric.empty?

      metric_type = Obscured.c('metrics.types').select { |e| e['type'] == metric['type'] }.first
      server_name = node['name']
      metric_name = metric['type'].to_s
      Obscured::Metric.generate(file: file_metric, node: node, offsets: graph_offsets, graph_root: graph_root)

      metrics = []
      graph_offsets.each do |offset|
        unless metrics.any? { |m| m.name == metric_name.to_s.capitalize }
          metrics.push Obscured::Entities::Category.new(metric_name.to_s.capitalize)
        end
        metric_image = !metric['aggregated'].blank? && (metric['aggregated']) || metric['files'].is_a?(Array) ? "-#{offset['name']}.png" : (metric['files'].sub '.rrd', "-#{offset['name']}.png")
        metric_type = Obscured.c('metrics.types').select { |e| e['type'] == metric['type'] }.first
        metric_title = !metric['title'].blank? ? format(metric['title'].to_s, suffix: metric_type['suffix']) : format(metric_type['title'].to_s, suffix: metric_type['suffix'])

        index_category = metrics.find_index { |m| m.name == metric_name.to_s.capitalize }
        if index_category >= 0
          metrics[index_category].graphs.push Obscured::Entities::Graph.new(file_metric, metric_title, metric_image, metric_type, Obscured::Entities::Node.new(node['name'], node['path'], group['name'], node['type'].to_s))
        end
      end
    rescue ArgumentError => e
      flash[:metrics_error] = "I'm sad to say that a problem was found: #{e.message}"
    end

    haml :metric, locals: {
      render_time: render_time,
      title: server_name,
      server_name: server_name,
      metric_name: metric_name,
      metrics: metrics
    }
  end
end
