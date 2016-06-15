module Obscured
  module Metric
    def generate(options = {})
      raise ArgumentError, 'No node was provided!' unless options[:node]
      raise ArgumentError, 'No offsets was provided!' unless options[:offsets]

      options[:offsets].each do |offset|
        options[:node]['metrics'].each do |metric|
          case metric['type']
            when :cpu
              if metric['files'].kind_of?(Array)
                metric['files'].each do |file|
                  Obscured::Metrics::CPU.generate(:name => options[:node]['name'].downcase, :offset => offset, :file => file, :metric => metric, :graph_root => options[:graph_root])
                end
              else
                Obscured::Metrics::CPU.generate(:name => options[:node]['name'].downcase, :offset => offset, :metric => metric, :graph_root => options[:graph_root])
              end
            when :disk
              if metric['files'].kind_of?(Array)
                metric['files'].each do |file|
                  Obscured::Metrics::Disk.generate(:name => options[:node]['name'].downcase, :offset => offset, :file => file, :metric => metric, :graph_root => options[:graph_root])
                end
              else
                Obscured::Metrics::Disk.generate(:name => options[:node]['name'].downcase, :offset => offset, :metric => metric, :graph_root => options[:graph_root])
              end
            when :memory
              if metric['files'].kind_of?(Array)
                metric['files'].each do |file|
                  Obscured::Metrics::Memory.generate(:name => options[:node]['name'].downcase, :offset => offset, :file => file, :metric => metric, :graph_root => options[:graph_root])
                end
              else
                Obscured::Metrics::Memory.generate(:name => options[:node]['name'].downcase, :offset => offset, :metric => metric, :graph_root => options[:graph_root])
              end
            when :temperature
              if metric['files'].kind_of?(Array)
                metric['files'].each do |file|
                  Obscured::Metrics::Temperature.generate(:name => options[:node]['name'].downcase, :offset => offset, :file => file, :metric => metric, :graph_root => options[:graph_root])
                end
              else
                Obscured::Metrics::Temperature.generate(:name => options[:node]['name'].downcase, :offset => offset, :metric => metric, :graph_root => options[:graph_root])
              end
            when :traffic
              if metric['files'].kind_of?(Array)
                metric['files'].each do |file|
                  Obscured::Metrics::Traffic.generate(:name => options[:node]['name'].downcase, :offset => offset, :file => file, :metric => metric, :graph_root => options[:graph_root])
                end
              else
               Obscured::Metrics::Traffic.generate(:name => options[:node]['name'].downcase, :offset => offset, :metric => metric, :graph_root => options[:graph_root])
              end
            when :packages
            when :temperature
                if metric['files'].kind_of?(Array)
                  metric['files'].each do |file|
                    Obscured::Metrics::Temperature.generate(:name => options[:node]['name'].downcase, :offset => offset, :file => file, :metric => metric, :graph_root => options[:graph_root])
                  end
                else
                  Obscured::Metrics::Temperature.generate(:name => options[:node]['name'].downcase, :offset => offset, :metric => metric, :graph_root => options[:graph_root])
                end
            when :load
            when :uptime
              if metric['files'].kind_of?(Array)
                metric['files'].each do |file|
                  Obscured::Metrics::Uptime.generate(:name => options[:node]['name'].downcase, :offset => offset, :file => file, :metric => metric, :graph_root => options[:graph_root])
                end
              else
                Obscured::Metrics::Uptime.generate(:name => options[:node]['name'].downcase, :offset => offset, :metric => metric, :graph_root => options[:graph_root])
              end
            else
              raise ArgumentError, "Traffic type not supported (#{metric['type']})"
          end
        end
      end
    end

    module_function :generate
  end
end