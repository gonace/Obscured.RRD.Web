module Obscured
  module Metrics
    module Cisco
      module Temperature
        class << self
          def generate(options = {})
            raise ArgumentError, 'No node name provided!' unless options[:name]
            raise ArgumentError, 'No graph root path provided!' unless options[:graph_root]
            raise ArgumentError, 'No metric object provided!' unless options[:name]


            rrd_path = "#{File.dirname(__FILE__)}/../../../data/#{options[:name]}"
            rrd_file = "#{rrd_path}/#{options[:file] ? options[:file] : options[:metric]['files']}"
            graph_path = "#{options[:graph_root]}/#{options[:name]}"
            graph_title = options[:metric]['title']

            Dir.glob(rrd_file) do |file|
              generate_graph :file => file, :offset => options[:offset], :graph_title => graph_title, :graph_path => graph_path, :metric => options[:metric]
            end
          end

          private
          def generate_graph(options = {})
            raise ArgumentError, 'No rrd file provided!' unless options[:file]
            raise ArgumentError, 'No graph path provided!' unless options[:graph_path]


            path_rrd = options[:file]
            path_graph = "#{options[:graph_path]}/"
            graph_type = (!options[:type].blank?) ? options[:type] : Obscured.c('metrics.types').select {|e| e['type'] == :temperature}.first
            graph_offset = (!options[:offset].blank?) ? options[:offset] : Obscured.c('graph.offsets.weekly').first
            graph_name = (path_rrd.split('/').last)
            graph_name.slice! '.rrd'
            graph_name += "-#{graph_offset['name']}.png"
            graph_title = (!options[:graph_title].blank?) ? options[:graph_title] % { :i => 0, :suffix => graph_type['suffix'] } : graph_type['title'] % { :i => 0, :suffix => graph_type['suffix'] }

            RRD.graph("#{path_graph}#{graph_name}",
                      :start => Time.now - eval(graph_offset['offset']).to_i, :end => Time.now, :step => eval(graph_offset['step']).to_i,
                      :height => Obscured.c('graph.height'), :width => Obscured.c('graph.width'),
                      :color => %w(FONT#000000 BACK#FFFFFF), :border => '0', :font => ['DEFAULT:8:Courier', 'LEGEND:9:', 'TITLE:10:', 'AXIS:10:' 'WATERMARK:8:'], 'vertical-label' => graph_title, :watermark => Obscured.c('graph.watermark')) do

              for_rrd_data 'in', :ds0 => :average, :from => path_rrd
              for_rrd_data 'min', :ds0 => :max, :from => path_rrd
              for_rrd_data 'out', :ds1 => :average, :from => path_rrd
              for_rrd_data 'mout', :ds1 => :max, :from => path_rrd

              using_calculated_data 'uin', :calc => 'in,UN,0,in,IF'
              using_calculated_data 'pin', :calc => 'uin,100,/,100,*,1,/'
              using_calculated_data 'umin', :calc => 'min,UN,0,min,IF'
              using_calculated_data 'pmin', :calc => 'umin,100,/,100,*,1,/'
              using_calculated_data 'uout', :calc => 'out,UN,0,out,IF'
              using_calculated_data 'pout', :calc => 'uout,100,/,100,*,1,/'
              using_calculated_data 'umout', :calc => 'mout,UN,0,mout,IF'
              using_calculated_data 'pmout', :calc => 'umout,100,/,100,*,1,/'


              draw_area :data => 'mout', :color => '#FF3348', :label => ''
              draw_line :data => 'mout', :color => '#B30000', :label => ''
              draw_area :data => 'uout', :color => '#ff7e4d', :label => 'Exhaust\t'
              draw_line :data => 'uout', :color => '#cc1800', :label => ''
              print_value 'uout:LAST', :format => 'Cur\: %5.0lf %s°C'
              print_value 'uout:AVERAGE', :format => 'Avg\: %5.0lf %s°C'
              print_value 'umout:MAX', :format => 'Max\: %5.0lf %s°C\n'

              draw_area :data => 'min', :color => '#339937', :label => ''
              draw_line :data => 'min', :color => '#004D00', :label => ''
              draw_area :data => 'uin', :color => '#99ff9D', :label => 'Intake\t'
              draw_line :data => 'uin', :color => '#009900', :label => ''
              print_value 'uin:LAST', :format => 'Cur\: %5.0lf %s°C'
              print_value 'uin:AVERAGE', :format => 'Avg\: %5.0lf %s°C'
              print_value 'umin:MAX', :format => 'Max\: %5.0lf %s°C\n'
            end
          end
        end
      end
    end
  end
end