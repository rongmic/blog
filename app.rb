# app.rb
require "sinatra"
require "sinatra/activerecord"

set :database, "sqlite3:///blog.db"

class Post < ActiveRecord::Base
  validates :title, :presence => true, :length => {minimum: 3}
  validates :body, :presence => true
end

# Get all of our routes
get "/" do
  @posts = Post.order("created_at DESC")
  erb :"posts/index"
end

get "/about" do
  @title = "About Me"
  erb :"pages/about"
end

post '/posts' do
  @post = Post.new(params[:post])
  if @post.save
    redirect "posts/#{@post.id}"
  else
    erb :"posts/new"
  end
end

get "/posts/new" do
  @title = "New Post"
  @post = Post.new
  erb :"posts/new"
end

# Get the individual page of the post with the ID
get "/posts/:id" do
  @post = Post.find(params[:id])
  @title = @post.title
  erb :"posts/show"
end

get "/posts/:id/edit" do
  @post = Post.find(params[:id])
  @title = "Edit Post"
  erb :"posts/edit"
end

put "/posts/:id" do
  @post = Post.find(params[:id])
  if @post.update_attributes(params[:post])
    redirect "/posts/#{@post.id}"
  else
    erb :"posts/edit"
  end
end

delete "/posts/:id" do
  @post = Post.find(params[:id]).destroy
  redirect "/"
end

helpers do
  def title
    if @title
      "#{@title} -- My Blog"
    else
      "My Blog"
    end
  end

  def format_date(time)
    time.strftime("%d %b %Y")
  end

  def post_show_page?
    request.path_info =~ /\/posts\/\d+$/
  end

  def delete_post_button(post_id)
    erb :_delete_post_button, :locals => { :post_id => post_id }
  end
end
