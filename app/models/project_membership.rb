class ProjectMembership < ApplicationRecord
  belongs_to :user
  belongs_to :project

  enum :role, { member: 0, admin: 1 }

  validates :user, presence: true
  validates :project, presence: true
  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :project_id, message: "has already been taken" }
end
