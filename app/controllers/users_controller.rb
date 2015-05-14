class UsersController < ApplicationController

  before_filter :admin?, except: [:show, :edit, :manage_groups]

  def index
    @users = User.order("username ASC").all.page(params[:page])
    @users_json = @users.to_json
  end

  def show
    @user = User.find_by_id(params[:id])
    @documents = @user.documents.page(params[:page])
  end

  def edit
    @user = User.find_by_id(params[:id])
    # users can only edit their own pages unless an admin
    if current_user != @user
      unless current_user.is_admin?
        redirect_to "/"
      end
    end
  end

  def update
    @user = User.find_by_id(params[:id])

    if @user.update(user_params)
      flash[:success] = "User updated successfully"
    else
      flash[:error] = "Error updating user"
    end

    redirect_to root_path
  end

  def destroy
    if @user = User.find_by_id(params[:id])
      @user.destroy
    end
    redirect_to users_path
  end

  def manage_groups 
  end

  def admin_status
    @user = User.find_by_id(params[:id])
    if @user 
      if !@user.is_admin?
        @user.is_admin = true
      else
        @user.is_admin = false
      end
      @user.save
      redirect_to users_path
    end
  end

  private
    def user_params
      params.require(:user).permit(:username, :email, :full_name)
    end

end
