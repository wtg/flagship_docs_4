class Group < ActiveRecord::Base

  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :categories

  def is_member?(user_id)
    return true if !memberships.find_by(group_id: id, user_id: user_id, level: 1).nil?
    return false
  end

  def is_leader?(user_id)
    return true if !memberships.find_by(group_id: id, user_id: user_id, level: 9).nil?
    return false
  end

  def leaders
    memberships = Membership.group_leaders(id)
    memberships.to_a.map! {|member| member.user}
  end

  def members
    regular_members = Membership.group_members(id)
    regular_members.to_a.map! {|member| member.user}
  end

  def leader_names
    names = Array.new
    leaders.each { |leader| names << leader.username }
    names.join(", ")
  end

  def member_names
    names = Array.new
    members.each { |member| names << member.username }
    names.join(", ")
  end

  def category_names
    names = Array.new
    categories.each { |cat| names << cat.name }
    names.join(", ")
  end

  def documents 
    documents = Array.new
    categories = Category.where(group_id: id)
    categories.each do |cat| 
      cat.documents.each do |doc|
        documents << doc
      end
    end
    documents
  end

end