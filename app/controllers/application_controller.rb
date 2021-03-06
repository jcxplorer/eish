# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Authentication
  helper :all # include all helpers, all the time
  
  before_filter :login_from_cookie

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '8573d4179016a43b27870a1f91bd5aae'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  filter_parameter_logging :password, :current_password, :password_confirmation
  
  RedclothCoderay.coderay_options :line_numbers => :table, :tab_width => 4
  
  protected  
    def require_https
      redirect_to :protocol => "https://" unless (request.ssl? or local_request?)
    end
    
    def require_http
      redirect_to :protocol => "http://" if (request.ssl?)
    end
end
