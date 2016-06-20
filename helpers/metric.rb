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

            generate_type options
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
            if options[:files].kind_of?(Array)
              options[:files].each do |file|
                Obscured::Metrics::CPU.generate(:name => options[:node]['path'], :offset => options[:offset], :file => file, :metric => options[:metric], :graph_root => options[:graph_root])
              end
            else
              if(!options[:os].blank?)
              else
                Obscured::Metrics::CPU.generate(:name => options[:node]['path'], :offset => options[:offset], :metric => options[:metric], :graph_root => options[:graph_root])
              end
            end
          when :disk
            if options[:files].kind_of?(Array)
              options[:files].each do |file|
                Obscured::Metrics::Disk.generate(:name => options[:node]['path'], :offset => options[:offset], :file => file, :metric => options[:metric], :graph_root => options[:graph_root])
              end
            else
              Obscured::Metrics::Disk.generate(:name => options[:node]['path'], :offset => options[:offset], :metric => options[:metric], :graph_root => options[:graph_root])
            end
          when :memory
            if options[:files].kind_of?(Array)
              options[:files].each do |file|
                Obscured::Metrics::Memory.generate(:name => options[:node]['path'], :offset => options[:offset], :file => file, :metric => options[:metric], :graph_root => options[:graph_root])
              end
            else
              Obscured::Metrics::Memory.generate(:name => options[:node]['path'], :offset => options[:offset], :metric => options[:metric], :graph_root => options[:graph_root])
            end
          when :processes
            if options[:files].kind_of?(Array)
              options[:files].each do |file|
                if(!options[:os].blank?)
                  if(options[:os] == :linux)
                    Obscured::Metrics::Linux::Processes.generate(:name => options[:node]['path'], :offset => options[:offset], :file => file, :metric => options[:metric], :graph_root => options[:graph_root])
                  elsif(options[:os] == :windows)
                    Obscured::Metrics::Windows::Processes.generate(:name => options[:node]['path'], :offset => options[:offset], :file => file, :metric => options[:metric], :graph_root => options[:graph_root])
                  end
                else
                  Obscured::Metrics::Processes.generate(:name => options[:node]['path'], :offset => options[:offset], :file => file, :metric => options[:metric], :graph_root => options[:graph_root])
                end
              end
            else
              if(!options[:os].blank?)
                Obscured::Metrics::Linux::Processes.generate(:name => options[:node]['path'], :offset => options[:offset], :metric => options[:metric], :graph_root => options[:graph_root])
              elsif(options[:os] == :windows)
                Obscured::Metrics::Windows::Processes.generate(:name => options[:node]['path'], :offset => options[:offset], :metric => options[:metric], :graph_root => options[:graph_root])
              else
                Obscured::Metrics::Processes.generate(:name => options[:node]['path'], :offset => options[:offset], :metric => options[:metric], :graph_root => options[:graph_root])
              end
            end
          when :temperature
            if options[:files].kind_of?(Array)
              options[:files].each do |file|
                Obscured::Metrics::Temperature.generate(:name => options[:node]['path'], :offset => options[:offset], :file => file, :metric => options[:metric], :graph_root => options[:graph_root])
              end
            else
              Obscured::Metrics::Temperature.generate(:name => options[:node]['path'], :offset => options[:offset], :metric => options[:metric], :graph_root => options[:graph_root])
            end
          when :traffic
            if options[:files].kind_of?(Array)
              options[:files].each do |file|
                Obscured::Metrics::Traffic.generate(:name => options[:node]['path'], :offset => options[:offset], :file => file, :metric => options[:metric], :graph_root => options[:graph_root])
              end
            else
              Obscured::Metrics::Traffic.generate(:name => options[:node]['path'], :offset => options[:offset], :metric => options[:metric], :graph_root => options[:graph_root])
            end
          when :temperature
            if options[:files].kind_of?(Array)
              options[:files].each do |file|
                Obscured::Metrics::Temperature.generate(:name => options[:node]['path'], :offset => options[:offset], :file => file, :metric => options[:metric], :graph_root => options[:graph_root])
              end
            else
              Obscured::Metrics::Temperature.generate(:name => options[:node]['path'], :offset => options[:offset], :metric => options[:metric], :graph_root => options[:graph_root])
            end
          when :uptime
            if options[:files].kind_of?(Array)
              options[:files].each do |file|
                Obscured::Metrics::Uptime.generate(:name => options[:node]['path'], :offset => options[:offset], :file => file, :metric => options[:metric], :graph_root => options[:graph_root])
              end
            else
              Obscured::Metrics::Uptime.generate(:name => options[:node]['path'], :offset => options[:offset], :metric => options[:metric], :graph_root => options[:graph_root])
            end
          else
            raise ArgumentError, "Metric type not supported (#{options[:metric]['type']})"
        end
      end
    end
  end
end