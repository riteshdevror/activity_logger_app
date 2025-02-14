require 'rails_helper'

RSpec.describe ProjectsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) { FactoryBot.create(:user) }
  let(:project_attributes) { { title: "Test Project", description: "Test description", status: "open" } }
  let(:project) { FactoryBot.create(:project, project_attributes) }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "assigns all projects to @projects" do
      project
      get :index
      expect(assigns(:projects)).to eq([project])
    end
  end

  describe "GET #show" do
    before do
      @status_log = ActivityLogger.create!(
        trackable: project,
        action: "update",
        field_name: "status",
        previous_value: "open",
        new_value: "in_progress",
        created_at: 2.hours.ago
      )
      comment = FactoryBot.create(:comment, project: project, user: user, content: "Test comment")
      @comment_log = ActivityLogger.create!(
        trackable: comment,
        action: "create",
        field_name: "content",
        previous_value: nil,
        new_value: "Test comment",
        created_at: 1.hour.ago
      )
    end

    it "assigns the requested project to @project" do
      get :show, params: { id: project.id }
      expect(assigns(:project)).to eq(project)
    end

    it "assigns conversation logs to @conversation with the latest first" do
      get :show, params: { id: project.id }
      conversation = assigns(:conversation)
      expect(conversation.first[:type]).to eq("comment")
      expect(conversation.last[:type]).to eq("status")
      expect(conversation.first[:created_at]).to be > conversation.last[:created_at]
    end
  end

  describe "GET #new" do
    it "assigns a new project to @project" do
      get :new
      expect(assigns(:project)).to be_a_new(Project)
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates a new project and redirects to the project page" do
        expect {
          post :create, params: { project: project_attributes }
        }.to change(Project, :count).by(1)
        expect(response).to redirect_to(Project.last)
        expect(flash[:notice]).to eq("Project created successfully.")
      end
    end

    context "with invalid attributes" do
      it "does not create a new project and re-renders new" do
        expect {
          post :create, params: { project: { title: "", description: "Invalid", status: "open" } }
        }.not_to change(Project, :count)
        expect(response).to render_template(:new)
      end
    end
  end

  describe "GET #edit" do
    it "assigns the requested project to @project" do
      get :edit, params: { id: project.id }
      expect(assigns(:project)).to eq(project)
    end
  end

  describe "PATCH #update" do
    context "with valid attributes" do
      it "updates the project and redirects" do
        patch :update, params: { id: project.id, project: { title: "Updated Title" } }
        project.reload
        expect(project.title).to eq("Updated Title")
        expect(response).to redirect_to(project)
        expect(flash[:notice]).to eq("Project updated successfully.")
      end
    end

    context "with invalid attributes" do
      it "does not update the project and re-renders edit" do
        patch :update, params: { id: project.id, project: { title: "" } }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "DELETE #destroy" do
    it "deletes the project and redirects to projects index" do
      project
      expect {
        delete :destroy, params: { id: project.id }
      }.to change(Project, :count).by(-1)
      expect(response).to redirect_to(projects_path)
      expect(flash[:notice]).to eq("Project deleted successfully.")
    end
  end
end
