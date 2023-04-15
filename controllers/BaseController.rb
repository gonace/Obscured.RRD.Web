class BaseController < Sinatra::Base
  register Sinatra::ConfigFile
  register Sinatra::Flash

  set :dump_errors, true
  set :raise_errors, true
  if :environment == :local || :environment == :development
    set :show_exceptions, true
  else
    set :show_exceptions, false
  end

  configure do
    config_file settings.root + '/../../config/local.config.yml'
  end

  not_found do
    redirect('/error/404')
  end

  error 401 do
    redirect('/error/401')
  end

  error 403 do
    redirect('/error/403')
  end

  error 408 do
    redirect('/error/408')
  end

  error 502 do
    redirect('/error/502')
  end

  error 503 do
    redirect('/error/503')
  end

  error 504 do
    redirect('/error/504')
  end

  error 500 do
    flash[:error_type] = request.env['sinatra.error'].class.name
    flash[:error_message] = request.env['sinatra.error'].to_s
    redirect('/error/500')
  end
end