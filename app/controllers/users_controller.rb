class UsersController < ApplicationController
  skip_before_filter :authorize
  
  def login
    if request.post?
      login_with_credentials(params[:username], params[:password], params[:remember_me])
        
      respond_to do |format|
        format.html { redirect_to(:root) }
        format.js
      end
    end
  end

  def logout
    User.find(session[:user_id]).forget_me
    session[:user_id] = nil
    flash[:login_notice] = "Logged out."
    redirect_to :root
  end

  def profile
    @user = User.find(session[:user_id])
  end
  
  def show
    @user = User.find_by_username(params[:username])
  end
  
  def register
    @user = User.new
    
    respond_to do |format|
      format.html
      format.xml { render :xml => @user }
    end
  end
  
  def create
    @user = User.new(params[:user])
    @user.role_id = 5
    saved = RCC_ENABLED ? validate_recap(params, @user.errors) && @user.save : @user.save
    
    respond_to do |format|
      if saved
        session[:user_id] = @user.id
        flash[:notice] = "User #{@user.username} was successfully created."
        format.html { redirect_to :root }
        format.xml { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "register" }
        format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def update
    @user = User.find(session[:user_id])
    current_hashed_password = User.encrypted_password(params[:user][:current_password], @user.salt)

    respond_to do |format|
      if current_hashed_password == @user.hashed_password
        if @user.update_attributes(params[:user])
          flash[:notice] = "User #{@user.username} was successfully updated."
          format.html { redirect_to :action => "profile" }
          format.xml  { head :ok }
        else
          format.html { render :action => "profile" }
          format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        end
      else
        flash[:error] = "Old password is incorrect."
        format.html { redirect_to :action => "profile" }
      end
    end
  end
  
  def remove
    @user = User.find(session[:user_id])
  end
  
  def destroy
    user = User.find(session[:user_id])
    current_hashed_password = User.encrypted_password(params[:user][:current_password], user.salt)
    
    respond_to do |format|
      if current_hashed_password == user.hashed_password
        if user.safe_destroy
          session[:user_id] = nil
          flash[:notice] = "Your account was deleted successfully."
          format.html { redirect_to :root }
        else
          flash[:error] = "We weren't able to delete your account. Please contact an administrator about this."
          format.html { redirect_to :controller => "users", :action => "remove" }
        end
      else
        flash[:error] = "The password you entered is incorrect."
        format.html { redirect_to :controller => "users", :action => "remove" }
      end
    end
  end
  
  def request_credentials
    respond_to do |format|
      if session[:user_id].nil?
        format.html
      else
        format.html { redirect_to :root }
      end
    end
  end
  
  def send_credentials
    user = User.find_by_email(params[:email])
    user.generate_reset_hash
    
    respond_to do |format|
      if user.nil?
        flash[:error] = "The email you entered is not associated with any user."
        format.html { redirect_to :action => "request_credentials" }
      else
        if Mailer.deliver_credentials(user, request.host_with_port)
          flash[:notice] = "The credentials were sent to your email."
          format.html { redirect_to :root }
        else
          flash[:error] = "We could not send the email. Please try again later."
          format.html { redirect_to :action => "request_credentials" }
        end
      end
    end
  end
  
  def password_reset
    @user = User.find_by_username(params[:username])
    @reset_hash = params[:reset_hash]
  end
  
  def update_password
    user = User.find_by_username(params[:username])
    
    respond_to do |format|
      if params[:password] == params[:password_confirmation]
        if user.reset_password(params[:password], params[:reset_hash])
          flash[:notice] = "The password reset was successful. You may now log in."
        else
          flash[:error] = "The reset hash was either wrong or expired."
        end
        format.html { redirect_to :root }
      else
        flash[:error] = "The password do not match. Please try again."
      end
    end
  end
end
