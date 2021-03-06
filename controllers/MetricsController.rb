class MetricsController < BaseController
  set :views, settings.root + '/../views/metrics'

  get '/:group/:path' do
    raise ArgumentError, 'No group id provided' unless params[:group]
    raise ArgumentError, 'No server name provided' unless params[:path]

    render_time = Time.now
    server_group = params[:group]
    server_path = params[:path]
    server_name = ''

    begin
      graph_root = settings.root + '/../public/graphs'
      graph_offsets = [Obscured.c('graph.offsets.weekly')]
      group = Obscured.c('data.sources.groups').find { |a| a['name'] == server_group }

      redirect '/error/404' if group.blank? || group.empty?
      node = group['nodes'].find { |n| n['path'] == server_path }
      redirect '/error/404' if node.blank? || node.empty?
      server_name = node['name']

      unless Dir.exist? graph_root + "/#{server_path}"
        Dir.mkdir graph_root + "/#{server_path}"
      end
      Obscured::Metric.generate(node: node, offsets: graph_offsets, graph_root: graph_root)

      metrics = []
      node['metrics'].each do |metric|
        unless metrics.any? { |m| m.name == metric['category'].to_s.capitalize }
          metrics.push Obscured::Entities::Category.new(metric['category'].to_s.capitalize)
        end

        metric_file = !metric['aggregated'].blank? && (metric['aggregated']) || metric['files'].is_a?(Array) ? "#{metric['name']}.rrd" : metric['files']
        metric_image = !metric['aggregated'].blank? && (metric['aggregated']) || metric['files'].is_a?(Array) ? "#{metric['name']}-weekly.png" : (metric['files'].sub '.rrd', '-weekly.png')
        metric_type = Obscured.c('metrics.types').select { |e| e['type'] == metric['type'] }.first
        metric_title = !metric['title'].blank? ? format(metric['title'].to_s, suffix: metric_type['suffix']) : format(metric_type['title'].to_s, suffix: metric_type['suffix'])

        index_category = metrics.find_index { |m| m.name == metric['category'].to_s.capitalize }
        if index_category >= 0
          metrics[index_category].graphs.push Obscured::Entities::Graph.new(metric_file, metric_title, metric_image, metric_type, Obscured::Entities::Node.new(node['name'], node['path'], group['name'], node['type'].to_s))
        end
      end
    rescue ArgumentError => e
      flash[:metrics_error] = "I'm sad to say that a problem was found: #{e.message}"
    end

    haml :index, locals: {
      render_time: render_time,
      title: server_name,
      server_name: server_name,
      metrics: metrics,
      expression: 'homer-excited'
    }
  end
end
