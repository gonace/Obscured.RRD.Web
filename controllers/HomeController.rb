class HomeController < BaseController
  set :views, settings.root + '/../views/home'

  get '/' do
    render_time = Time.now

    begin
      groups = Obscured.c('data.sources.groups')

      puts '#################'
      puts '###   DEBUG   ###'
      puts '#################'

      metrics = []
      groups.each do |group|
        group['nodes'].each do |node|
          node['metrics'].each do |metric|
            if metric['highlighted']
              unless metrics.any? {|m| m.name == metric['category'].to_s.capitalize}
                metrics.push Obscured::Entities::Category.new(metric['category'].to_s.capitalize)
              end
              metric_file = (!metric['aggregated'].blank? and metric['aggregated'] == true or metric['files'].kind_of?(Array)) ? "#{metric['name']}.rrd" : metric['files']
              metric_image = (!metric['aggregated'].blank? and metric['aggregated'] == true or metric['files'].kind_of?(Array)) ? "#{metric['name']}-weekly.png" : (metric['files'].sub '.rrd', '-weekly.png')
              metric_type = Obscured.c('metrics.types').select {|e| e['type'] == metric['type']}.first
              metric_title = (!metric['title'].blank?) ? ("#{node['name']}: " + metric['title'].to_s % { :suffix => metric_type['suffix'] }) : ("#{node['name']}: " + metric_type['title'].to_s % { :suffix => metric_type['suffix'] })

              index_category = metrics.find_index {|m| m.name == metric['category'].to_s.capitalize}
              if index_category >= 0
                metrics[index_category].graphs.push Obscured::Entities::Graph.new(metric_file, metric_title, metric_image, metric_type, Obscured::Entities::Node.new(node['name'], node['path'].downcase, group['name'], node['type'].to_s))
              end
            end
          end
        end
      end
      pp metrics
      puts '#################'
    rescue ArgumentError => e
      flash[:metrics_error] = "I'm sad to say that he found an error: #{e.message}"
    end

    haml :index, :locals => {:render_time => render_time,
                             :title => 'Highlighted metrics',
                             :metrics => metrics,
                             :expression => 'homer-excited'}
  end
end