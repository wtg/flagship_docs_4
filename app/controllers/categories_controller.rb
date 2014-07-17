class CategoriesController < ApplicationController

  # GET /categories
  def index
    @categories = Category.roots
    @featured = Category.featured
    @latest_docs = Document.latest_docs
  end

  def show
    @category = Category.find params[:id]
    @subcategories = @category.children
    @documents = Document.where(category_id: @category.id).page(params[:page])
    
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
    @categories = Category.all.map {|cat| [cat.name, cat.id]}
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to @category
    else
      redirect_to "/"
    end
  end   

  private
    def category_params
      params.require(:category).permit(:name, :description, 
        :group_id, :parent_id, :is_featured, :is_private, :is_writable)
    end 

end