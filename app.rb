require 'sinatra'
require 'haml'

get '/' do
  @lyrics = []
  haml :index
end

post '/' do
  query = "lyrics site:metrolyrics.com #{params[:query]}"
  agent = Mechanize::new
  page = agent.get("http://www.google.com")
  google_form = page.form('f')
  google_form.q = query
  page = agent.submit(google_form, google_form.buttons.first)
  page = agent.get(page.at('#ires ol a').attribute('href'))
  @title = page.title
  chunks = page.at('#lyrics-body').to_html.split '<br>'
  @lyrics = []
  chunks.each do |chunk|
    n = Nokogiri::HTML(chunk)
    n.content.lines.each do |line|
      if !line.strip.empty?
        @lyrics << line.strip unless line.include? 'metrolyrics'
      end
    end
  end
  haml :index
end

get '/views/style.css' do
  sass :style
end
