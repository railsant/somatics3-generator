class <%= namespace_class %>::<%= class_name %>SessionsController < Devise::SessionsController
  layout '<%= options.namespace %>'
  
  def after_sign_in_path_for(resource)
    <%= options.namespace %>_root_url
  end  
  
  def after_sign_out_path_for(resource)
    new_<%= name %>_session_url
  end
end