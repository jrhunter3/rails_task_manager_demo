module ApplicationHelper
  include Pagy::Frontend

  def task_state_events(task)
    task.aasm.events(permitted: true)
  end
end
