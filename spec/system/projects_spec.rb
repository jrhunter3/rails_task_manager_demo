require "rails_helper"

RSpec.describe "Projects", type: :system do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  it "creates, views, edits, and deletes a project" do
    visit projects_path
    click_link "New Project"

    fill_in "Name", with: "My Project"
    fill_in "Description", with: "A test project"
    click_button "Create Project"

    expect(page).to have_text "Project created."
    expect(page).to have_text "My Project"
    expect(page).to have_text "A test project"

    click_link "Edit"

    fill_in "Name", with: "Updated Project"
    click_button "Update Project"

    expect(page).to have_text "Project updated."
    expect(page).to have_text "Updated Project"

    click_link "Back"

    expect(page).to have_text "Updated Project"

    page.driver.delete(project_path(Project.last))
    visit projects_path

    expect(page).to have_text "Project deleted."
    expect(page).to have_no_text "Updated Project"
  end

  it "shows validation errors" do
    visit new_project_path
    click_button "Create Project"

    expect(page).to have_text "Name can't be blank"
  end

  it "requires authentication" do
    sign_out user
    visit projects_path

    expect(page).to have_text "You need to sign in or sign up before continuing."
  end
end
