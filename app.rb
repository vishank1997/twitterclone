require 'sinatra'
require 'data_mapper'

DataMapper.setup(:default, "sqlite:///#{Dir.pwd}/data.db")

set :sessions, true

class User
	include DataMapper::Resource
	property :id, Serial
	property :name, String
	property :email, String
	property :password, String
end

class Tweet
	include DataMapper::Resource
	property :content, String
	property :id, Serial
	property :user_id, Integer
	property :likes, Integer
end

class Follow 						#the '1' against the name of data variable is for follower
	include DataMapper::Resource	#the '2' against the name of data variable is for following 
	property :name1, String			#now if user1 clicks on the button to follow user2
	property :email1, String		#his id shall be saved in the variable user_id1
	property :id, Serial			#the id of the following person will be saved in user_id2
	property :user_id1, Integer 	
	property :name2, String
	property :email2, String
	property :user_id2, Integer
end

DataMapper.finalize
User.auto_upgrade!
Tweet.auto_upgrade!
Follow.auto_upgrade!


get '/' do
	if session[:user_id]
		user = User.get(session[:user_id])
	else
		redirect '/signin'
	end
		tweet = Tweet.all
		user1 = User.all
		follow = Follow.all(user_id1: session[:user_id]) 
	erb :index, locals: {user: user, tweet: tweet, user1: user1, follow: follow}
end

get '/profile' do
	id = params[:id]
	user = User.get(id)
	tweet = Tweet.all(user_id: id)
	erb :profile, locals: {user: user, tweet: tweet}
end

post '/follow' do 
	id1 = session[:user_id] 
	id2 = params[:id]
	follow = Follow.new
	user1 = User.get(id1)
	user2 = User.get(id2)
	follow.user_id1 = id1
	follow.user_id2= id2
	follow.name1 = user1.name
	follow.name2 = user2.name
	follow.email1 = user1.email
	follow.email2 = user2.email
	follow.save
	redirect '/'
end


get '/signin' do
	erb :signin
end

post '/signin' do 
	email = params[:email]
	user = User.all(email: email).first
	if user
		if user.password == params[:password]
			session[:user_id] = user.id
		else
			redirect '/signin'
		end
	else
		redirect '/signup'
	end
	redirect '/'
end

get '/signup' do
	erb :signup
end

post '/signup' do 
email = params[:email]
user = User.all(:email => email).first
	if user
		redirect'/signup'
	else	
		user = User.new
		user.email = params[:email]
		user.password = params[:password]
		user.name = params[:email]
		user.save
		session[:user_id] = user.id
		redirect '/'
	end	
end

post '/logout' do
	session[:user_id] = nil
	redirect '/'
end

post '/newtweet' do
	tweet = Tweet.new
	tweet.content = params[:content]
	tweet.user_id = session[:user_id]
	tweet.save
	redirect '/'
end

post '/deletetweet' do
	Tweet.get(params[:id]).destroy
	redirect '/'
end	

post '/edittweet' do
	id = params[:id]
	tweet = Tweet.get(id)
	tweet.content = params[:content]
	tweet.save
	redirect '/'
end