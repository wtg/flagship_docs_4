class CategoriesController < ApplicationController

  before_filter :user_admin?, except: [:index, :show, :create_subcategory]

  # GET /categories
  def index
    # Get all viewable categories
    @categories = Category.roots.order(name: :asc).reject { |c| !category_viewable?(c) and c.is_private }

    # Get featured categories and recently uploaded documents
    #  making sure to hide private docs and categories
    @featured = Category.featured
  end

  # GET /categories/:id
  def show
    # Get category and its subcategories
    @category = Category.find params[:category_id]
    @subcategories = @category.children.sort_by {|c| c.name}
    @groups = Group.order(:name).all.map {|group| [group.name, group.id]}
    
    # Check if category is restricted to group members only
    if @category.is_private
      if !category_viewable?(@category)
        flash[:error] = "Sorry, you are unauthorized to access this category."
        redirect_to "/"
      end
    end

    # Get all documents associated with this category
    @documents = Document.where(category_id: @category.id).order("updated_at desc").page(params[:page])

    # Check if a view style (list or grid) is specified
    if params.key?(:view_style)
      @view_style = params[:view_style]
    else
      # Default to list view
      @view_style = "grid"
    end

    respond_to do |format|
      format.html {}
    end
  end

  def new
    @category = Category.new
    # Get categories and groups for selection dropdowns
    @groups = Group.all.map {|group| [group.name, group.id]}
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to @category
    else
      flash[:error] = "Unable to save category: #{@category.errors.full_messages.to_sentence}"
      redirect_to "/"
    end
  end

  def create_subcategory
    # Get parent category the new subcategory will be under
    @parent_category = Category.find_by_id(params[:category_id])

    # Check hidden field value for invalid parent category
    if @parent_category.nil? 
      redirect_to "/"
    end

    # Check if user is logged in / an admin, or a leader of the parent group
    if admin? or current_user.leader_of(@parent_category.group_id)
      # Create subcategory using parent attributes for group id, writability, and visibility
      if Category.create_using_parent_attributes(subcategory_params)
        flash[:success] = "Subcategory successfully created."
      else
        # Error saving subcategory
        flash[:error] = "Unable to create subcategory."
      end
    else
      # Permissions error
      flash[:error] = "Unable to create subcategory. You do not have the required permissions."
    end

    redirect_to category_path(@parent_category)
  end

  def edit
    @category = Category.find_by_id(params[:category_id])
    # Get categories and groups for selection dropdowns
    @categories = Category.all.map {|cat| [cat.name, cat.id]}
    @categories.delete([@category.name, @category.id])
    @groups = Group.all.map {|group| [group.name, group.id]}
  end

  def update
    @category = Category.find_by_id(params[:category_id])
    @category.update_attributes(category_params)
    redirect_to edit_category_path(@category)
  end

  def destroy
    @category = Category.find_by_id(params[:category_id]).destroy
    redirect_to manage_categories_path
  end

  def manage
    @categories = Category.all.order("name asc").page(params[:page])
  end

  def subcategories
    @subcategories = Category.find(params[:category_id]).children.sort_by{|c| c.name}
    @subcategories = @subcategories.map{|c| c.subcategories_json}
    render json: @subcategories 
  end

  private
    def category_params
      params.require(:category).permit(:name, :description,
        :group_id, :is_featured, :is_private, :is_writable)
    end

    def subcategory_params
      params.require(:category).permit(:name, :description, 
        :is_featured, :group_id, :parent_id)
    end
end
