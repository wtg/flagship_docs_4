class GroupsController < ApplicationController

  before_filter :admin?, except: [:show]

  def index
    @groups = Group.all.page(params[:page])
  end

  def show
    @group = Group.find_by_id params[:id]
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    if @group.save
      redirect_to @group
    else 
      redirect_to "/"
    end
  end

  def edit
    @group = Group.find_by_id(params[:id])
  end

  def update
    @group = Group.find_by_id(params[:id])
    @group.update_attributes(group_params)
    redirect_to @group
  end

  def add_member
    # return existing membership
    member = Membership.where(
        user_id: membership_params[:user_id],
        group_id: params[:id]
      ).first

    if !member.nil?
      # edit existing membership with new level
      member.update_attributes(level: membership_params[:level])
    else
      # create new membership 
      member = Membership.new(membership_params)
      member.group_id = params[:id]
    end

    if member.save
      flash[:success] = "New member added"
    else
      flash[:error] = "Member already exists or could not be saved"
    end

    redirect_to edit_group_path(params[:id])
  end

  def destroy
    group = Group.find_by_id(params[:id])
    group.destroy
    redirect_to groups_path
  end

  private
    def group_params
      params.require(:group).permit(:name)
    end

    def membership_params
      params.require(:membership).permit(:user_id, :level)
    end

end
