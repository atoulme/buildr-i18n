
# This file is in charge of defining the backend server that renders the textile templates in the browser.

post '/update_value/:key/:locale/:country' do
  new_value = request.body
end

get '/get_value/:key/:locale/:country' do
  
end