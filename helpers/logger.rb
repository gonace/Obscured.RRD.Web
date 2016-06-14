module Obscured
  module Logger
    def call(msg, type=:info)
      case type
        when :info
          self.info(msg)
        when :debug
          self.debug(msg)
        when :warning
          self.debug(msg)
        when :error
          self.debug(msg)
        else
          self.info(msg)
      end
    end

    def info(msg)
      puts "I, [#{datetime} ##{Process.pid}]  (OBSCURED) INFO -- : #{msg}"
    end

    def debug(msg, object=nil)
      if !msg.blank?
        puts "D, [#{datetime} ##{Process.pid}]  (OBSCURED) DEBUG -- : #{msg}"
      end

      if (!object.nil?)
        puts '#################'
        puts '###   DEBUG   ###'
        puts '#################'
        pp object
        puts '#################'
      end
    end

    def warning(msg)
      puts "W, [#{datetime} ##{Process.pid}]  (OBSCURED) WARNING -- : #{msg}"
    end

    def error(msg)
      puts "E, [#{datetime} ##{Process.pid}]  (OBSCURED) ERROR -- : #{msg}"
    end

    private
    def self.datetime
      DateTime.now.strftime('%Y-%M-%dT%H:%M:%S.%6N')
    end

    alias_method :warn, :warning
    module_function :info, :debug, :warning, :warn, :error
  end
end