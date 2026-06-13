require "rails_helper"

RSpec.describe "Tasks", type: :system do
  let(:user) { create(:user) }
  let(:project) { create(:project, owner: user) }

  before do
    sign_in user
  end

  it "creates, views, edits, and deletes a task" do
    visit project_tasks_path(project)
    click_link "New Task"

    fill_in "Title", with: "My Task"
    fill_in "Description", with: "A test task"
    select "High", from: "Priority"
    fill_in "Due date", with: Date.tomorrow
    click_button "Create Task"

    expect(page).to have_text "Task created."
    expect(page).to have_text "My Task"
    expect(page).to have_text "A test task"

    click_link "Edit"

    fill_in "Title", with: "Updated Task"
    click_button "Update Task"

    expect(page).to have_text "Task updated."
    expect(page).to have_text "Updated Task"

    page.driver.delete(project_task_path(project, Task.last))
    visit project_tasks_path(project)

    expect(page).to have_text "Task deleted."
    expect(page).to have_no_text "Updated Task"
  end

  it "transitions a task through states" do
    task = create(:task, project: project, status: :backlog)

    visit project_task_path(project, task)

    expect(page).to have_text "Backlog"

    click_button "Start"
    expect(page).to have_text "In progress"

    click_button "Submit for review"
    expect(page).to have_text "Review"

    click_button "Complete"
    expect(page).to have_text "Done"

    click_button "Reopen"
    expect(page).to have_text "In progress"
  end

  it "shows validation errors" do
    visit new_project_task_path(project)
    click_button "Create Task"

    expect(page).to have_text "Title can't be blank"
  end

  it "requires authentication" do
    sign_out user
    visit project_tasks_path(project)

    expect(page).to have_text "You need to sign in or sign up before continuing."
  end
end
