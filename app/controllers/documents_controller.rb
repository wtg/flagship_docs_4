class DocumentsController < ApplicationController

  def show 
    @document = Document.find_by_id(params[:id])

    if can_view_document(@document)
      @revisions = @document.revisions
      @category = Category.find(@document.category_id)
      @children_categories = @category.children
    else
      flash[:error] = "You do not have permission to view this document."
      redirect_to "/"
    end
  end

  def search
    # Use Sunspot Solr to search for documents based on the search query
    begin
      @documents = Document.search do
        fulltext params[:query], highlight: true
      end
    rescue
      @documents ||= nil
    end
  end

  def download
    @document = Document.find_by_id(params[:id])
    if !@document.nil?
      # Get the most recent revision when downloading a document
      @document = @document.current_revision
      # Increment download count
      @document.increment!(:download_count)

      if @document.file_upload?
        # Send file binary data to user's browser
        send_data(@document.file_data, :type => @document.file_type, :filename => @document.file_name, :disposition => "inline")
      elsif @document.external_link?
        # Redirect to external document
        redirect_to @document.doc_link
      end
    else
      flash[:error] = "Could not find requested document"
      link_to root_path
    end
  end

  def create

    if !revision_params.nil?
      # Create our new document
      @document = Document.new(document_params)
      @document.user_id = current_user.id

      category = Category.find_by_id(@document.category_id)
      if !@document.save
        flash[:error] = "Unable to upload document"
      else
        # Create the initial revision of the new document 
        #  either via file upload or external link
        if revision_params.is_a?(Hash)
          @revision = Revision.create_using_upload(revision_params, @document, current_user)
          extract_text = true
        elsif revision_params.is_a?(String)
          @revision = Revision.create_using_link(revision_params, @document, current_user)
          extract_text = false
        end

        if !@revision.save
          @document.destroy
          flash[:error] = "Unable to upload revision"
        else
          # Extract text from file to provide search engine with searchable content
          @revision.extract_text if extract_text
          @revision.save
        end
      end
    end

    if !category.nil?
      redirect_to category_path(category, view_style: params[:view_style])
    else
      redirect_to root_path
    end
  end

  def update
    @document = Document.find(params[:id])
    # Check if the current user is allowed to edit this document
    if !can_edit_document(@document)
      flash[:error] = "You are not allowed to edit this document."
      redirect_to "/"
    end
    # Check if document attributes have successfully saved
    if @document.update_attributes(document_params)
      flash[:success] = "Document updated!"
      redirect_to @document
    else
      flash[:error] = "Document failed to update: #{@document.errors.full_messages.to_sentence}" 
      redirect_to @document
    end
  end

  def destroy 
    @document = Document.find(params[:id])
    @category = @document.category
    @document.destroy
    redirect_to @category
  end

  private
    def document_params
      params.require(:document).permit(:title, :description, 
        :category_id, :is_writable, :is_private)
    end

    def revision_params
        return params[:document][:revision][:file] if !params[:document][:revision][:file].blank?
        return params[:document][:revision][:doc_link] if params[:document][:revision][:file].blank?
    end
end