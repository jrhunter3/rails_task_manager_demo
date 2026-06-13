class Project < ApplicationRecord
  belongs_to :owner, class_name: "User", inverse_of: :owned_projects

  has_many :project_memberships, dependent: :destroy
  has_many :members, through: :project_memberships, source: :user
  has_many :tasks, dependent: :destroy

  validates :name, presence: true
  validates :owner, presence: true

  after_create :add_owner_as_admin

  private

  def add_owner_as_admin
    project_memberships.create!(user: owner, role: :admin)
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name description]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[owner]
  end
end
