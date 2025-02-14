require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) { FactoryBot.create(:user) }
  let(:project) { FactoryBot.create(:project) }
  let(:valid_attributes) { { content: "This is a valid comment" } }
  let(:invalid_attributes) { { content: "" } }

  before do
    sign_in user
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates a new comment for the project" do
        expect {
          post :create, params: { project_id: project.id, comment: valid_attributes }
        }.to change(project.comments, :count).by(1)
      end

      it "redirects to the project show page with a notice" do
        post :create, params: { project_id: project.id, comment: valid_attributes }
        expect(response).to redirect_to(project)
        expect(flash[:notice]).to eq("Comment added successfully.")
      end
    end

    context "with invalid attributes" do
      it "does not create a new comment" do
        expect {
          post :create, params: { project_id: project.id, comment: invalid_attributes }
        }.not_to change(project.comments, :count)
      end

      it "redirects to the project show page with an alert" do
        post :create, params: { project_id: project.id, comment: invalid_attributes }
        expect(response).to redirect_to(project)
        expect(flash[:alert]).not_to be_empty
      end
    end
  end
end
