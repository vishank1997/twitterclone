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

class Follower
	include DataMapper::Resource
	property :name, String
	property :email, String
	property :id, Serial
	property :user_id, Integer 
end

class Following
	include DataMapper::Resource
	property :name, String
	property :email, String
	property :id, Serial
	property :user_id, Integer
end


DataMapper.finalize
User.auto_upgrade!
Tweet.auto_upgrade!
Follower.auto_upgrade!
Following.auto_upgrade!


get '/' do
	if session[:user_id]
		user = User.get(session[:user_id])
	else
		redirect '/signin'
	end
		tweet = Tweet.all
		user1 = User.all
		follower = Follower.all(user_id: session[:user_id]) 
	erb :index, locals: {user: user, tweet: tweet, user1: user1, follower: follower}
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
	following = Following.new
	follower = Follower.new
	user1 = User.get(id1)
	user2 = User.get(id2)
	following.user_id = id1
	follower.user_id = id2
	following.name = user1.name
	follower.name = user2.name
	following.email = user1.email
	follower.email = user2.email
	following.save
	follower.save
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