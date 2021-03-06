class FeedController < ApplicationController
  def show
    @posts = current_site.posts.published.order_by_recent.preload(:categories).limit(20)

    render formats: :xml
  end
end
