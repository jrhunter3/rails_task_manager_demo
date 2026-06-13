require 'rails_helper'

RSpec.describe "Api::V1::Pagination", type: :request do
  let(:user) { create(:user) }
  let(:token) { user.raw_api_token }
  let(:headers) { { "Authorization" => "Bearer #{token}" } }

  describe "empty collection" do
    it "returns empty array for projects when user has none" do
      create(:project)

      get api_v1_projects_path, headers: headers

      expect(response.parsed_body).to eq([])
    end

    it "returns empty array for tasks when project has none" do
      project = create(:project)
      create(:project_membership, user: user, project: project)

      get api_v1_project_tasks_path(project), headers: headers

      expect(response.parsed_body).to eq([])
    end
  end
end
