require "rails_helper"

RSpec.describe "Authentication", type: :system do
  it "signs up, signs in, and signs out" do
    visit root_path
    first(:link, "Sign up").click

    fill_in "Email", with: "alice@example.com"
    fill_in "Password", with: "password"
    fill_in "Password confirmation", with: "password"
    click_button "Sign up"

    expect(page).to have_text "Welcome! You have signed up successfully."
    expect(page).to have_text "alice@example.com"

    page.driver.delete(destroy_user_session_path)
    visit new_user_session_path

    expect(page).to have_text "Signed out successfully."
    expect(page).to have_no_text "alice@example.com"

    click_link "Sign in"

    fill_in "Email", with: "alice@example.com"
    fill_in "Password", with: "password"
    click_button "Log in"

    expect(page).to have_text "Signed in successfully."
    expect(page).to have_text "alice@example.com"
  end

  it "shows error on invalid sign in" do
    visit new_user_session_path
    fill_in "Email", with: "wrong@example.com"
    fill_in "Password", with: "wrong"
    click_button "Log in"

    expect(page).to have_text /Invalid/i
  end
end
