class User < ActiveRecord::Base
  include SharedModelMethods

  has_many :tokens, dependent: :destroy

  before_save { email.downcase! }
  before_destroy :delete_folder

  #  mount_uploader :avatar, ForAvatarUploader

  VALID_EMAIL_BEFORE_DOG = '\A[a-z\d]+((\.|-)[a-z\d]+)*'
  VALID_EMAIL_AFTER_DOG = '[a-z\d]+((\.|-)[a-z\d]+)*\z'
  DOG = '@'
  FULL_EMAIL = Regexp.new(VALID_EMAIL_BEFORE_DOG + DOG +
                          VALID_EMAIL_AFTER_DOG, 'i')

  validates :name, presence: true, length: { maximum: 48 }
  validates :email, length: { maximum: 100 },
                    format: { with: FULL_EMAIL },
                    uniqueness: { case_sensitive: false }

  has_secure_password validations: false
  validates :password, length: { minimum: 8 }, confirmation: true, on: :create
  validates :password, confirmation: true, length: { minimum: 8 },
                       if: :password_present?, on: :update

  def admin?
    if access == 'I am admin!'
      return true
    else
      return false
    end
  end

  private

  # For has_secure_password validations: false and validation at all.
  def password_present?
    !password.nil? || password_confirmation != ''
  end

  def delete_folder
    FileUtils.rm_rf "#{Rails.root}/private/photo_galleries/human_#{id}"
    FileUtils.rm_rf "#{Rails.root}/private/avatars/human_#{id}"
  end
end
