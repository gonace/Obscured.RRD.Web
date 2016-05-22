class HomeController < BaseController
  set :views, settings.root + '/../views/home'

  get '/' do
    render_time = Time.now

    haml :index, :locals => {:render_time => render_time,
                             :title => 'Title',
                             :expression => 'homer-excited'}
  end
end