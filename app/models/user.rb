class User < ActiveRecord::Base

  validates :username, uniqueness: true

  has_many :documents, dependent: :destroy
  has_many :revisions, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :groups, through: :memberships

  def name
    return full_name if !full_name.nil?
    return username
  end

  def member_of(group_id)
    # check if user is a member of specific group
    memberships.each do |membership|
      if membership.group_id == group_id
        return true
      end
    end
    return false
  end

  def leader_of(group_id)
    memberships.each do |membership|
      if membership.group_id == group_id and membership.member_level == "Leader"
        return true
      end
    end
    return false
  end

  def writable_categories
    categories = []
    Category.all.each do |category|
      # check if category is private or unwritable
      if !category.is_writable or category.is_private
        # if user is a member of the controlling group
        #  they have permission to upload to the private / unwritable category
        if member_of(category.group_id)
          categories << category
        end
      else
        # No restrictions on this group, anyone can upload
        #  as long as they are logged in
        categories << category
      end
    end
    return categories.sort! { |a,b| a.name.downcase <=> b.name.downcase }
  end
end
