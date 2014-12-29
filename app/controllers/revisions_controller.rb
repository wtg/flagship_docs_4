class RevisionsController < ApplicationController 

  def download
    # Get the request document revision
    @revision = Revision.find(params[:revision_id])

    if !@revision.nil?
      # Increment the download count on this revision
      @revision.increment!(:download_count)

      if @revision.file_upload?
        # Send file binary data to the user's browser
        send_data(@revision.file_data, 
          type: @revision.file_type, 
          filename: @revision.file_name,
          disposition: "inline")
      elsif @revision.external_link?
        # Redirect to external document
        redirect_to @revision.doc_link
      end
    else
      flash[:error] = "Could not find the requested document"
      redirect_to root_path
    end
  end

  def create
    if !revision_params.nil? 

      @document = Document.find(params[:document_id])

      if revision_params.is_a?(ActionDispatch::Http::UploadedFile)
        @revision = Revision.create_using_upload(revision_params, @document, current_user)
      elsif revision_params.is_a?(String)
        @revision = Revision.create_using_link(revision_params, @document, current_user)
      end

      # Increase the position of all previous revisions
      #  to move them down in the document's history
      @document.revisions.each do |revision|
        revision.position += 1
        revision.save
      end

      if !@revision.save
        flash[:error] = "Unable to upload revision"
        redirect_to document_path(@document)
      else
        # Our revision has been saved
        #  extract it's contents for the search engine
        @revision.extract_text
        redirect_to document_path(@document)
      end

    else
      redirect_to root_path
    end
  end

  private 
    def revision_params
      return params[:revision][:file] if !params[:revision][:file].blank?
      return params[:revision][:doc_link] if params[:revision][:file].blank?
    end

end
