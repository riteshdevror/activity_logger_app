class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: %i[show edit update destroy]

  def index
    @projects = Project.all
  end

  def show
    @conversation = fetch_conversation_logs
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      redirect_to @project, notice: "Project created successfully."
    else
      render :new
    end
  end

  def edit; end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: "Project updated successfully."
    else
      render :edit
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path, notice: "Project deleted successfully."
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:title, :description, :status)
  end

  def fetch_conversation_logs
    status_logs = fetch_status_logs
    comment_logs = fetch_comment_logs
    (status_logs + comment_logs).sort_by { |entry| entry[:created_at] }.reverse
  end

  def fetch_status_logs
    ActivityLogger
      .where(trackable_type: "Project", trackable_id: @project.id, field_name: "status")
      .order(:created_at)
      .map do |log|
        {
          type: "status",
          action: log.action,
          previous_value: log.previous_value,
          new_value: log.new_value,
          created_at: log.created_at
        }
      end
  end

  def fetch_comment_logs
    comment_ids = @project.comments.pluck(:id)
    ActivityLogger
      .where(trackable_type: "Comment", trackable_id: comment_ids, field_name: "content")
      .order(:created_at)
      .map do |log|
        {
          type: "comment",
          content: log.new_value,
          created_at: log.created_at
        }
      end
  end
end
