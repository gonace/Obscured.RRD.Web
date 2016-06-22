module Obscured
  module Metric
    class << self
      def generate(options = {})
        raise ArgumentError, 'No node was provided!' unless options[:node]
        raise ArgumentError, 'No offsets was provided!' unless options[:offsets]


        options[:offsets].each do |offset|
          options[:node]['metrics'].each do |metric|
            if (defined? metric['os'])
              options[:os] = metric['os']
            end
            options[:files] = metric['files']
            options[:offset] = offset
            options[:metric] = metric

            if(!options[:file].blank?)
              if (metric['files'] == options[:file])
                generate_type options
              end
            else
              if options[:files].kind_of?(Array)
                options[:files].each do |file|
                  options[:files] = file
                  generate_type options
                end
              else
                generate_type options
              end
            end
          end
        end
      end


      private
      def generate_type(options = {})
        raise ArgumentError, 'No node was provided!' unless options[:node]
        raise ArgumentError, 'No offsets was provided!' unless options[:offsets]
        raise ArgumentError, 'No metric was provided!' unless options[:metric]


        case options[:metric]['type']
          when :cpu
            if(!options[:os].blank? and options[:os] == :linux)
              Obscured::Metrics::Linux::CPU.generate(:name => options[:node]['path'], :offset => options[:offset], :metric => options[:metric], :graph_root => options[:graph_root])
            else
              Obscured::Metrics::CPU.generate(:name => options[:node]['path'], :offset => options[:offset], :metric => options[:metric], :graph_root => options[:graph_root])
            end
          when :disk
            Obscured::Metrics::Disk.generate(:name => options[:node]['path'], :offset => options[:offset], :metric => options[:metric], :graph_root => options[:graph_root])
          when :load
            if(!options[:os].blank? and options[:os] == :linux)
              Obscured::Metrics::Linux::Load.generate(:name => options[:node]['path'], :offset => options[:offset], :metric => options[:metric], :graph_root => options[:graph_root])
            end
          when :memory
            if(!options[:os].blank? and options[:os] == :linux)
              Obscured::Metrics::Linux::Memory.generate(:name => options[:node]['path'], :offset => options[:offset], :metric => options[:metric], :graph_root => options[:graph_root])
            else
              Obscured::Metrics::Memory.generate(:name => options[:node]['path'], :offset => options[:offset], :metric => options[:metric], :graph_root => options[:graph_root])
            end
          when :packets
            if(!options[:os].blank? and options[:os] == :cisco)
              Obscured::Metrics::Cisco::Packets.generate(:name => options[:node]['path'], :offset => options[:offset], :metric => options[:metric], :graph_root => options[:graph_root])
            end
          when :processes
            if(!options[:os].blank? and options[:os] == :linux)
              Obscured::Metrics::Linux::Processes.generate(:name => options[:node]['path'], :offset => options[:offset], :metric => options[:metric], :graph_root => options[:graph_root])
            elsif(!options[:os].blank? and options[:os] == :windows)
              Obscured::Metrics::Windows::Processes.generate(:name => options[:node]['path'], :offset => options[:offset], :metric => options[:metric], :graph_root => options[:graph_root])
            else
              Obscured::Metrics::Processes.generate(:name => options[:node]['path'], :offset => options[:offset], :metric => options[:metric], :graph_root => options[:graph_root])
            end
          when :temperature
            if(!options[:os].blank? and options[:os] == :cisco)
              Obscured::Metrics::Cisco::Temperature.generate(:name => options[:node]['path'], :offset => options[:offset], :metric => options[:metric], :graph_root => options[:graph_root])
            else
              Obscured::Metrics::Temperature.generate(:name => options[:node]['path'], :offset => options[:offset], :metric => options[:metric], :graph_root => options[:graph_root])
            end
          when :traffic
            Obscured::Metrics::Traffic.generate(:name => options[:node]['path'], :offset => options[:offset], :metric => options[:metric], :graph_root => options[:graph_root])
          when :temperature
            Obscured::Metrics::Temperature.generate(:name => options[:node]['path'], :offset => options[:offset], :metric => options[:metric], :graph_root => options[:graph_root])
          when :uptime
            Obscured::Metrics::Uptime.generate(:name => options[:node]['path'], :offset => options[:offset], :metric => options[:metric], :graph_root => options[:graph_root])
          else
            raise ArgumentError, "Metric type not supported (#{options[:metric]['type']})"
        end
      end
    end
  end
end