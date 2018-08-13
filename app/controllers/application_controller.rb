class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  def recommend_users
# user_followers_count
    users = User.all
    users.each do |user|
      user.followers_count = user.followers.count
      user.save
    end
# user_tweets_count
    users = User.all
    users.each do |user|
      user.tweets_count = user.tweets.count
      user.save
  end
# user_tweets_favireted_count
    users = User.all
    users.each do |user|
      tweet_ids = user.tweets.ids
      favorite_count = []
      tweet_ids.each do |tweet_id|
        favorites = Favorite.where(tweet_id: tweet_id)
        favorite_count << favorites.count
      end
      user.favorited_count = favorite_count.inject(:+)
      user.save
    end

    candidates = User.where.not(id: current_user.id).where.not(id: current_user.following.ids)

    select_candidates = rand(3)
    if select_candidates == 0
      @recommends = candidates.order("favorited_count DESC").limit(5)
    elsif select_candidates == 1
      @recommends = candidates.order("followers_count DESC").limit(5)
    else
      @recommends = candidates.order("tweets_count DESC").limit(5)
    end

  end

    protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :username])
  end

  def after_sign_out_path_for(resource)
    new_user_session_path
  end

  def tagscount
    tags = Tag.all
    tags.each do |tag|
      tag.tags_count = tag.tweets.count
      tag.save
    end
    @trend = Tag.order("tags_count DESC")
  end

end
