class ProjectPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    admin? || member?
  end

  def create?
    true
  end

  def new?
    create?
  end

  def update?
    admin? || project_admin?
  end

  def edit?
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
        scope.joins(:project_memberships).where(project_memberships: { user_id: user.id })
      end
    end
  end

  private

  def admin?
    user.admin?
  end

  def project_admin?
    record.project_memberships.exists?(user: user, role: :admin)
  end

  def member?
    record.project_memberships.exists?(user: user)
  end
end
