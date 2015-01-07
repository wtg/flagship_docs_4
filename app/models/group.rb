class Group < ActiveRecord::Base

  validates :name, presence: true, uniqueness: true

  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :categories
  has_many :documents, through: :categories

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
  end

  def members
    regular_members = Membership.group_members(id)
  end

  def leader_names
    names = Array.new
    leaders.each { |leader| names << leader.user.username }
    names.join(", ")
  end

  def member_names
    names = Array.new
    members.each { |member| names << member.user.username }
    names.join(", ")
  end

  def category_names
    names = Array.new
    categories.each { |cat| names << cat.name }
    names.join(", ")
  end

end