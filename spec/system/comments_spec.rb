require "rails_helper"

RSpec.describe "Comments", type: :system do
  let(:user) { create(:user) }
  let(:project) { create(:project, owner: user) }
  let(:task) { create(:task, project: project) }

  describe "authenticated" do
    before do
      sign_in user
    end

    it "adds a comment to a task" do
      visit project_task_path(project, task)

      expect(page).to have_text task.title

      hidden_input = find('input[type="hidden"][name="comment[content]"]', visible: false)
      hidden_input.set("<div>This is a test comment</div>")
      click_on "Post Comment"

      expect(page).to have_text "Comment added."
      expect(page).to have_text "This is a test comment"
    end

    it "deletes a comment" do
      comment = create(:comment, commentable: task, user: user)

      visit project_task_path(project, task)

      expect(page).to have_text comment.content.to_plain_text

      page.driver.delete(project_task_comment_path(project, task, comment))
      visit project_task_path(project, task)

      expect(page).to have_text "Comment deleted."
      expect(page).to have_no_text comment.content.to_plain_text
    end
  end

  describe "unauthenticated" do
    it "requires authentication" do
      visit project_task_path(project, task)

      expect(page).to have_text "You need to sign in or sign up before continuing."
    end
  end
end
