class Revision < ActiveRecord::Base

  belongs_to :document
  belongs_to :user

  validates_presence_of :file_type
  # only validate file name and data if this is a file upload
  validates_presence_of :file_name, :file_data, :if => :file_upload?
  # only validate doc link if document is an external link
  validates_presence_of :doc_link, :if => :external_link?

  def file_upload?
    !file_data.nil?
  end

  def external_link?
    !doc_link.nil?
  end

  def extension_type
    ext = case file_type
      # PDF Files
      when "application/pdf" then "pdf"
      when "application/msword" then "doc"
      when "application/vnd.oasis.opendocument.text" then "odt"
      when "external_link" then "doc"
      else "other"
    end
    ext
  end

  def extract_text
    # Create a temporary file to read from 
    tempfile = Tempfile.new(file_name, :encoding => 'ascii-8bit')
    tempfile.write(file_data)
    tempfile.close

    # Try extracting the contents of the file depending on the content type
    begin
      contents = Textractor.text_from_path(tempfile.path, :content_type => file_type)
    rescue
      logger.error("Unable to extract text from file. Revision id = #{id}, File name = #{filename}")
      contents = nil
    end
    tempfile.unlink

    # Get rid of utf-8 control characters 
    contents.gsub!(/\P{ASCII}/, '') if !contents.blank?
    # Redundant line breaks are useless to us
    self.search_text = contents.gsub(/(\r?\n)+/,"\n") if !contents.blank?
  end


  def self.create_using_upload(revision_params, document, user)
    # Create first revision using a file upload
    revision = Revision.new(file_name: revision_params.original_filename,
      file_type: revision_params.content_type,
      file_data: revision_params.read,
      document_id: document.id,
      user_id: user.id,
      position: 0
    )
  end

  def self.create_using_link(revision_params, document, user)
    # Create first revision using an external link to a document
    revision = Revision.new(doc_link: revision_params,
      file_type: "external_link",
      document_id: document.id,
      user_id: user.id,
      position: 0
    )
  end

end
