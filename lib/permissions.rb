module Permissions
  # ====================
  # Permission Helpers 
  # ====================

  # Return the current logged in user
  def current_user
    @current_user = User.find_by_id(session[:user_id])
  end

  # Check if the current logged in user is an admin
  #  used as a before_filter for controller security
  def admin?
    current_user.is_admin? if !current_user.nil?
  end

  # ====================
  # Category Permissions
  # ====================

  # Check if the current user can upload documents to the specified category
  def can_upload_documents(category)
    # No category specified
    return false if category.nil?
    # No user logged in
    return false if current_user.nil?
    # Allow admins unrestricted uploads
    return true if current_user.is_admin?
    # Check if category is writable - a writable category allows users to 
    #  upload documents even if they are not a member of the controlling group
    return current_user.member_of(category.group_id) if !category.is_writable
    # Category is writable, any logged in user can submit documents
    return true
  end

  # Check if user is able to view a specific category
  def category_viewable?(category)
    # no user in session
    if current_user.nil? 
      if category.is_private?
        return false
      else
        return true
      end
    end
    # current user in session
    if category.is_private? 
      if current_user.is_admin? or current_user.member_of(category.group_id)
        return true
      else
        return false
      end
    else
      # category is not private, anyone can view it
      return true
    end
  end

  # Check if the current user can upload documents to the specified category
  def upload_permitted_categories
    # Return all categories the current user can upload to
    return nil if current_user.nil?
    permitted_categories = Category.order(:name).all if current_user.is_admin?
    permitted_categories ||= current_user.writable_categories
  end

  # ====================
  # Document Permissions
  # ====================

  # Check if the current user can revise a specific document
  def can_revise_document(document)
    # deny user if not logged in
    return false if current_user.nil?
    # current user is an admin
    return true if current_user.is_admin?
    # current user is a member of the category's
    #   group for a document that is write protected
    unless document.category.group.nil? and document.is_writable?
      return current_user.member_of(document.category.group.id)
    end
    return document.is_writable?
  end

  # Check if the current user can view a specific document
  def can_view_document(document)
    # allow access if user is logged in
    return true if !current_user.nil? and current_user.is_admin?
    # current user is a member of the category's
    #   group for a document that is private
    unless document.category.group.nil? or current_user.nil?
      return current_user.member_of(document.category.group.id) if document.is_private?
    end
    return !document.is_private?
  end

  # Check if the current user can edit a specific document
  def can_edit_document(document)
    # deny user if not logged in
    return false if current_user.nil?
    # current user is an admin
    return true if current_user.is_admin?
    # current user is a member of the category's group
    return current_user.member_of(document.category.group.id) if !document.category.group.nil?
    # User is not an admin and not a member of the category's group
    return false
  end

end