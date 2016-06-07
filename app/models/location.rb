class Location < ActiveRecord::Base
  validates :user_id,:name,:address, presence: true

  belongs_to :user
end
