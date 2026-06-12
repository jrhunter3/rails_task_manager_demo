class Project < ApplicationRecord
  belongs_to :owner, class_name: "User", inverse_of: :owned_projects

  has_many :project_memberships, dependent: :destroy
  has_many :members, through: :project_memberships, source: :user

  validates :name, presence: true
end
