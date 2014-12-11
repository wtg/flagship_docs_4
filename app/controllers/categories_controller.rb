class CategoriesController < ApplicationController

  before_filter :admin?, except: [:index, :show]

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
    @category = Category.find params[:id]
    @subcategories = @category.children.sort_by {|c| c.name}
    
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
    @categories = Category.all.map {|cat| [cat.name, cat.id]}
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

  def edit
    @category = Category.find_by_id(params[:id])
    # Get categories and groups for selection dropdowns
    @categories = Category.all.map {|cat| [cat.name, cat.id]}
    @categories.delete([@category.name, @category.id])
    @groups = Group.all.map {|group| [group.name, group.id]}
  end

  def update
    @category = Category.find_by_id(params[:id])
    @category.update_attributes(category_params)
    redirect_to edit_category_path(@category)
  end

  def destroy
    @category = Category.find_by_id(params[:id]).destroy
    redirect_to manage_categories_path
  end

  def manage
    @categories = Category.all.order("name asc").page(params[:page])
  end

  def subcategories
    @subcategories = Category.find(params[:id]).children.sort_by{|c| c.name}
    @subcategories = @subcategories.map{|c| c.subcategories_json}

    render json: @subcategories 
  end

  private
    def category_params
      params.require(:category).permit(:name, :description,
        :group_id, :is_featured, :is_private, :is_writable)
    end
end
