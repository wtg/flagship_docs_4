class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :permitted_categories
  after_filter :cache_page

  helper_method :prev_page

  # Add permission methods for documents and categories
  include Permissions

  # Selection of categories the current user can view in the tree navigation
  def permitted_categories
    @permitted_categories = upload_permitted_categories
  end

  # Store the last page our user has visited
  def cache_page
    return "/" if session[:prev_page].nil?
    if request.original_url.match("[\/](categories)[\/][0-9][\/](subcategories)")
      session[:prev_page]
    else
      session[:prev_page] = request.original_url
    end
  end

  # Get the previous page from our session store
  def prev_page 
    session[:prev_page]
  end

end 