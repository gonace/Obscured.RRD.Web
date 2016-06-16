module Obscured
  module Metrics
    module Traffic
      class << self
        def generate(options = {})
          raise ArgumentError, 'No node name provided!' unless options[:name]
          raise ArgumentError, 'No graph root path provided!' unless options[:graph_root]
          raise ArgumentError, 'No metric object provided!' unless options[:name]


          rrd_path = "#{File.dirname(__FILE__)}/../../data/#{options[:name]}"
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
          graph_type = (!options[:type].blank?) ? options[:type] : Obscured.c('metrics.types').select {|e| e['type'] == :traffic}.first
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

            using_calculated_data 'pin', :calc => 'in,125000000,/,100,*,1,/'
            using_calculated_data 'pmin', :calc => 'min,125000000,/,100,*,1,/'
            using_calculated_data 'pout', :calc => 'out,125000000,/,100,*,1,/'
            using_calculated_data 'pmout', :calc => 'mout,125000000,/,100,*,1,/'
            using_calculated_data 'nout', :calc => 'out,-1,*'
            using_calculated_data 'nmout', :calc => 'mout,-1,*'

            draw_area :data => 'nmout', :color => '#FFA64D', :label => ''
            draw_line :data => 'nmout', :color => '#FF5900', :label => ''
            draw_area :data => 'nout', :color => '#ffe000', :label => 'Outgoing\t'
            draw_line :data => 'nout', :color => '#ccb300', :label => '', :width => 1
            print_value 'out:LAST', :format => 'Cur\: %5.3lf %s'
            print_value 'pout:LAST', :format => '(%2.2lf%%)'
            print_value 'out:AVERAGE', :format => 'Avg\: %5.3lf %s'
            print_value 'pout:AVERAGE', :format => '(%2.2lf%%)'
            print_value 'mout:MAX', :format => 'Max\: %5.3lf %s'
            print_value 'pmout:MAX', :format => '(%2.2lf%%)\n'

            draw_area :data => 'min', :color => '#339933', :label => ''
            draw_line :data => 'min', :color => '#003300', :label => ''
            draw_area :data => 'in', :color => '#66cc66', :label => 'Incoming\t'
            draw_line :data => 'in', :color => '#008300', :label => '', :width => 1
            print_value 'in:LAST', :format => 'Cur\: %5.3lf %s'
            print_value 'pin:LAST', :format => '(%2.2lf%%)'
            print_value 'in:AVERAGE', :format => 'Avg\: %5.3lf %s'
            print_value 'pin:AVERAGE', :format => '(%2.2lf%%)'
            print_value 'min:MAX', :format => 'Max\: %5.3lf %s'
            print_value 'pmin:MAX', :format => '(%2.2lf%%)\n'
          end
        end
      end
    end
  end
end