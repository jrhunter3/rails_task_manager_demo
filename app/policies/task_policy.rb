class TaskPolicy < ApplicationPolicy
  def index?
    admin? || member_of_project?
  end

  def show?
    admin? || member_of_project?
  end

  def create?
    admin? || member_of_project?
  end

  def new?
    create?
  end

  def update?
    admin? || member_of_project?
  end

  def edit?
    update?
  end

  def transition?
    update?
  end

  def destroy?
    admin? || project_admin?
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(project: :project_memberships)
             .where(project_memberships: { user_id: user.id })
      end
    end
  end

  private

  def member_of_project?
    record.project.project_memberships.exists?(user: user)
  end

  def admin?
    user.admin?
  end

  def project_admin?
    record.project.project_memberships.exists?(user: user, role: :admin)
  end
end
