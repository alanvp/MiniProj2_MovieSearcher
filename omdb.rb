require 'sinatra'
require 'sinatra/reloader'
require 'typhoeus'
require 'json'

get '/' do
  @page_title = "Search Movies"
  erb :index
end

# Pull the results of the search and put them into an array
post '/result' do
  @page_title = "Movie Results"
  search_str = params[:movie]
  response = Typhoeus.get("www.omdbapi.com", :params => {:s => search_str})
  result = JSON.parse(response.body)
  @arr = result["Search"].sort{|el1, el2| el1["Year"] <=> el2["Year"]}
  
  get_poster_links()
  erb :result
end

# Pull all the poster image URLs for the results and put them in an array @urls
def get_poster_links()
  i = 0
  @urls = []
  while i < @arr.size.to_i do
    imdb_id2 = @arr[i]["imdbID"]
    response2 = Typhoeus.get("www.omdbapi.com/?i=#{imdb_id2}")
    hash2 = JSON.parse(response2.body)
  
    @urls[i] = hash2["Poster"]
    if @urls[i] == "N/A"
      @urls[i]="http://pottymouthecards.com/ecard/images/no_image.png"
    end
    i += 1
  end
end

# Pull the clicked-on movie info
get '/poster/:imdb' do |imdb_id|
  @page_title = "Poster Page"
  response = Typhoeus.get("www.omdbapi.com/?i=#{imdb_id}") 
  ID_hash = JSON.parse(response.body)
  @url = ID_hash["Poster"]
  @plot = ID_hash["Plot"]
  @released = ID_hash["Released"]
  @rated = ID_hash["Rated"]
  @runtime = ID_hash["Runtime"]
  @genre = ID_hash["Genre"]
  @director = ID_hash["Director"]
  @actors = ID_hash["Actors"]
  erb :poster
end

