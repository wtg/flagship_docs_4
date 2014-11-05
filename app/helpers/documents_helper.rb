module DocumentsHelper

  def document_icon(extension)
    case extension
      when "pdf" then "icon_pdf.png"
      when "doc" then "icon_doc.png"
      when "ppt" then "icon_ppt.png"
      when "xls" then "icon_xls.png"
      when "odt" then "icon_odt.png"
      when "ods" then "icon_ods.png"
      else "icon_other.png"
    end
  end

  def small_document_icon(extension)
    document_icon(extension).gsub(/(.png)/, "") + "_40.png"
  end

end
