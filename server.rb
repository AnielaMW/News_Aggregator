require 'sinatra'
require 'sinatra/flash'
require 'pry'
require 'csv'

enable :sessions

get '/articles' do
  @articles = CSV.foreach('data.csv', headers: true)
  erb :index
end

get '/articles/new' do
  erb :form
end

post '/articles/new' do
  article = params.values
  @articles = CSV.foreach('data.csv', headers: true)

  if params[:title] == "" || params[:url] == "" || params[:description] == ""
    flash.now[:error] = "Sometihng was let blank. Please try again."
    erb :form
    # flash is a hash that is porvided by Sinatra that controls user notifications
    # must gem install sinatra-flash, add gem 'sinatra-flash' to the gemfile, require 'sinatra/flash' at the top of the server file, and enable :sessions
  elsif url_invalid?(params[:url])
    #maybe checkout regular expressions
    flash.now[:error] = "Invalid URL entered."
    erb :form
  elsif url_repeat?(params[:url])
    flash.now[:error] = "That article already exists."
    erb :form
  elsif description_too_short?(params[:description])
    flash.now[:error] = "Your description must be at least 20 char. in length."
    erb :form
  else
    CSV.open('data.csv', 'a') do |csv|
      csv.puts(article)
    end
    redirect '/articles'
  end
end

def url_invalid?(url)
  !url.start_with?("http")
end

def url_repeat?(url)
  urls_array = []
  @articles.each do |article|
    urls_array << article[1]
  end
  urls_array.include?(url)
end

def description_too_short?(description)
  description.length <= 20
end
