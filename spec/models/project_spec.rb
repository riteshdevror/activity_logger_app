require 'rails_helper'

RSpec.describe Project, type: :model do
  subject { FactoryBot.build(:project) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    it "is not valid without a title" do
      subject.title = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:title]).to include("can't be blank")
    end

    it "is not valid without a description" do
      subject.description = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:description]).to include("can't be blank")
    end

    it "is not valid without a status" do
      subject.status = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:status]).to include("can't be blank")
    end
  end

  describe "enum" do
    it "defines the correct status values" do
      expect(Project.statuses).to eq({ "open" => 0, "in_progress" => 1, "closed" => 2 })
    end

    it "responds to status predicate methods" do
      expect(subject).to respond_to(:open?)
      expect(subject).to respond_to(:in_progress?)
      expect(subject).to respond_to(:closed?)
    end
  end

  describe "activity logging", :aggregate_failures do
    before do
      ActivityLogger.delete_all
    end

    context "on create" do
      it "logs a create activity for status" do
        expect {
          subject.save!
        }.to change(ActivityLogger, :count).by(1)

        activity = ActivityLogger.last
        expect(activity.trackable).to eq(subject)
        expect(activity.action).to eq("create")
        expect(activity.field_name).to eq("status")
        expect(activity.previous_value).to be_nil
        expect(activity.new_value).to eq(subject.status)
      end
    end

    context "on update" do
      before do
        subject.save!
        ActivityLogger.delete_all
      end

      it "logs an update activity when the status changes" do
        expect {
          subject.update!(status: "closed")
        }.to change(ActivityLogger, :count).by(1)

        activity = ActivityLogger.last
        expect(activity.trackable).to eq(subject)
        expect(activity.action).to eq("update")
        expect(activity.field_name).to eq("status")
        expect(activity.previous_value).to eq("open")
        expect(activity.new_value).to eq("closed")
      end

      it "does not log an activity if a non-tracked attribute is updated" do
        expect {
          subject.update!(title: "Updated Title")
        }.not_to change(ActivityLogger, :count)
      end
    end

    context "on destroy" do
      before do
        subject.save!
        ActivityLogger.delete_all
      end

      it "logs a delete activity for status" do
        project_id = subject.id
        current_status = subject.status
        expect {
          subject.destroy
        }.to change(ActivityLogger, :count).by(1)

        activity = ActivityLogger.last
        expect(activity.trackable_type).to eq("Project")
        expect(activity.trackable_id).to eq(project_id)
        expect(activity.action).to eq("delete")
        expect(activity.field_name).to eq("status")
        expect(activity.previous_value).to eq(current_status)
        expect(activity.new_value).to be_nil
      end
    end
  end
end
