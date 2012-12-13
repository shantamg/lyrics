require 'sinatra'
require 'mechanize'

get '/' do
  @lyrics = {}
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
  @lyrics = Hash.new { |l, k| l[k] = Hash.new(&l.default_proc) }
  i = 0
  chunks.each do |chunk|
    l = 0
    n = Nokogiri::HTML(chunk)
    n.content.lines.each do |line|
      @lyrics[i][l] = line.strip unless line.include? 'metrolyrics' || line.strip.empty?
      l += 1
    end
    i += 1
  end
  haml :index
end

get '/views/style.css' do
  sass :style
end
