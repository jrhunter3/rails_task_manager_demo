class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :timeoutable, :lockable

  enum :role, { member: 0, admin: 1 }

  has_many :owned_projects, class_name: "Project", foreign_key: :owner_id, dependent: :destroy
  has_many :project_memberships, dependent: :destroy
  has_many :projects, through: :project_memberships

  validates :role, presence: true

  attr_accessor :raw_api_token

  before_create :generate_api_token

  private

  def generate_api_token
    self.raw_api_token = SecureRandom.hex(32)
    self.api_token = Digest::SHA256.hexdigest(raw_api_token)
  end
end
