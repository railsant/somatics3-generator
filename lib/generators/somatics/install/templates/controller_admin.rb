# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class Admin::AdminController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  layout Proc.new { |c| c.request.format.js? ? false : 'admin' }
  before_filter :authenticate_user!

  uses_tiny_mce :options => {
    :theme => 'advanced',
    :theme_advanced_resizing => true,
    :theme_advanced_resize_horizontal => false,
    :plugins => %w{ table fullscreen }
  }
end
