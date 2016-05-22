module Obscured
  extend self
  def env
    ENV['OBSCURED_ENV'] || 'local'
  end

  def cfg_file
    '../config/%s.config.yml' % env
  end

  def prod?
    env == 'prod'
  end

  def stage?
    env == 'stage'
  end

  def clear_config!
    @config = nil
  end

  def load_config!
    raise LoadError, 'Configuration is already loaded!' if @config
    env_cfg = File.expand_path(cfg_file, File.dirname(__FILE__))
    raise ArgumentError unless File.exists?(env_cfg)
    @config = YAML.load_file(env_cfg)
    raise ArgumentError if @config.nil?
    @config
  rescue => e
    Obscured::Logger.debug e.backtrace.join("\n")
    raise ArgumentError, "Unable to load configuration from: #{env_cfg}, env: #{env}"
  end

  def append_config!(*files)
    raise LoadError, 'Configuration is not loaded!' unless @config
    cfg = files.inject({}) { |merged, file| merged.merge(YAML.load_file(file)[env]) }
    @config.merge!(cfg)
    raise ArgumentError if @config.nil?
    @config
  rescue => e
    Obscured::Logger.debug e.backtrace.join("\n")
    raise ArgumentError, "Unable to append configuration from files: #{files}, env: #{env}"
  end

  def load_specific_config!(*files)
    env = ENV['TULO_ENV'] || 'prod'
    raise LoadError, 'Configuration is already loaded!' if @config
    @config = files.inject({}) { |merged, file| merged.merge(YAML.load_file(file)[env]) }
    raise ArgumentError if @config.nil?
    @config
  rescue => e
    Obscured::Logger.debug e.backtrace.join("\n")
    raise ArgumentError, "Unable to load configuration from files: #{files}, env: #{env}"
  end

  def config(key, subst={})
    raise LoadError, 'Configuration is not loaded, please do that before using!' unless @config
    get_config_value(key, subst)
  rescue => e
    Obscured::Logger.debug e.backtrace.join("\n")
    raise KeyError, "Unable to find configuration with key: #{key}. Please check your configuration!"
  end

  def self.get_config_value(key, subst={})
    if override.has_key?(key.to_sym)
      return override[key.to_sym]
    end
    val = key.to_s.split('.').inject(@config) { |h, k| h[k] }
    return subst.inject(val) {|result, (key, sub)| result.gsub("%{#{key}}", sub)}
  end

  def config_key_exists(key)
    raise LoadError, 'Configuration is not loaded, please do that before using!' unless @config
    begin
      return false if get_config_value(key).blank?
    rescue
      return false
    end
    true
  end

  alias_method :c, :config
end