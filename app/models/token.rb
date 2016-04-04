# Token model
class Token < ActiveRecord::Base
  belongs_to :user

  VALID_MAC = Regexp.new('\A([0-9A-Fa-f]{2}[:]){5}([0-9A-Fa-f]{2})\z')
  validates :name, presence: true, length: { maximum: 25 }
  validates :MAC, format: { with: VALID_MAC },
                  uniqueness: { case_sensitive: false }
end
