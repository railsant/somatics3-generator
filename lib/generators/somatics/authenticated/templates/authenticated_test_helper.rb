module <%= class_name %>AuthenticatedTestHelper
  # Sets the current <%= file_name %> in the session from the <%= file_name %> fixtures.
  def login_as(<%= file_name %>)
    @request.session[:<%= file_name %>_id] = <%= file_name %> ? (<%= file_name %>.is_a?(<%= file_name.camelize %>) ? <%= file_name %>.id : <%= table_name %>(<%= file_name %>).id) : nil
  end

  def authorize_as(<%= file_name %>)
    @request.env["HTTP_AUTHORIZATION"] = <%= file_name %> ? ActionController::HttpAuthentication::Basic.encode_credentials(<%= table_name %>(<%= file_name %>).login, 'monkey') : nil
  end
  
end
