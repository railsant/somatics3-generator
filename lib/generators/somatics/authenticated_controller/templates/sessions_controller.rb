class <%= namespace_class %>::<%= model_name %>SessionsController < Devise::SessionsController
  layout 'admin'
  
  def after_sign_out_path_for(resource)
    new_<%= name %>_session_url
  end
end