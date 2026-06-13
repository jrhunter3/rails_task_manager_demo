class CommentPolicy < ApplicationPolicy
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
    admin? || author? || project_admin?
  end

  def edit?
    update?
  end

  def destroy?
    admin? || author? || project_admin?
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins("INNER JOIN tasks ON tasks.id = comments.commentable_id AND comments.commentable_type = 'Task'")
             .joins("INNER JOIN project_memberships ON project_memberships.project_id = tasks.project_id")
             .where(project_memberships: { user_id: user.id })
      end
    end
  end

  private

  def author?
    record.user == user
  end

  def member_of_project?
    record.commentable.is_a?(Task) &&
      record.commentable.project.project_memberships.exists?(user: user)
  end

  def project_admin?
    record.commentable.is_a?(Task) &&
      record.commentable.project.project_memberships.exists?(user: user, role: :admin)
  end

  def admin?
    user.admin?
  end
end
