class ContactController < ApplicationController
  skip_before_filter :authorize
  
  def index
    @contacts = User.find_all_by_contactable(true)
  end
  
  def send_email
    recipient = User.find(params[:user][:user_id]).email
    logged_in = !session[:user_id].nil?
    user = logged_in ? User.find(session[:user_id]) : User.new(:first_name => params[:name], :email => params[:email])
    
    respond_to do |format|
      if Mailer.deliver_contact(recipient, user, params[:subject], params[:message], request.remote_ip, request.env["HTTP_USER_AGENT"])
        flash[:notice] = "Your email was sent successfully."
      else
        flash[:error] = "We weren't able to send your email. Please try again later."
      end
      format.html { redirect_to :controller => "contact" }
    end
  end
end
