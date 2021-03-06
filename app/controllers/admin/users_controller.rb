class Admin::UsersController < AdministrationController
  before_filter :check_for_admin

  def index
    @users = User.all_current_users

    respond_to do |format|
      format.html
    end
  end
  
  def show
    redirect_to :action => "edit"
  end
  
  def new
    @user = User.new

    respond_to do |format|
      format.html
    end
  end
  
  def edit
    @user = User.find_by_username(params[:id])
  end
  
  def create
    @user = User.new(params[:user])
    
    respond_to do |format|
      if @user.save
        flash[:notice] = "User #{@user.username} was successfully created."
        format.html { redirect_to(:action => :index) }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def update
    @user = User.find_by_username(params[:id])
    @user.role_id = params[:user][:role_id] unless @user.role.can_administer?
    
    respond_to do |format|
      if @user.role.can_administer? && @user.id != current_user_id
        flash[:error] = "Cannot update another administrator."
        format.html { redirect_to(:action=>:index) }
      elsif @user.update_attributes(params[:user])
        flash[:notice] = "User #{@user.username} was successfully updated."
        format.html { redirect_to(:action=>:index) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def action
    user = User.find(params[:user])
    
    case params[:actions]
      when "delete"
        if user.role.can_administer?
          flash[:error] = "Cannot delete an administrator."
        else
          user.safe_destroy
        end
      when "make_contactable"
        user.update_attribute("contactable", true)
      when "make_uncontactable"
        user.update_attribute("contactable", false)
    end
    
    respond_to do |format|
      format.html { redirect_to :action => "index" }
    end
  end
end
