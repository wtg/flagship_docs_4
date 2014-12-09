class Membership < ActiveRecord::Base

  belongs_to :group
  belongs_to :user

  validates :user_id, uniqueness: {scope: [:level, :group_id]}
  validates_presence_of :user_id

  LEVELS = {
    regular: 1,
    leader: 9
  }

  scope :regular_member, -> {where(level: Membership::LEVELS[:regular])}
  scope :leader, -> {where(level: Membership::LEVELS[:leader])}

  def self.group_members(group_id)
    where(level: Membership::LEVELS[:regular], group_id: group_id)
  end 

  def self.group_leaders(group_id)
    where(level: Membership::LEVELS[:leader], group_id: group_id)
  end

  def member_level
    return "Member" if LEVELS[:regular] == level
    return "Leader" if LEVELS[:leader] == level
  end

end
