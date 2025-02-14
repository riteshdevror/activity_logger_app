require 'rails_helper'

RSpec.describe Comment, type: :model do
  subject { FactoryBot.build(:comment) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    it "is not valid without content" do
      subject.content = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:content]).to include("can't be blank")
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:user) }
  end

  describe "activity logging", :aggregate_failures do
    before do
      ActivityLogger.delete_all
    end

    context "on create" do
      it "logs a create activity for content" do
        expect {
          subject.save!
        }.to change(ActivityLogger, :count).by(2)

        activity = ActivityLogger.last
        expect(activity.trackable_type).to eq("Comment")
        expect(activity.trackable_id).to eq(subject.id)
        expect(activity.action).to eq("create")
        expect(activity.field_name).to eq("content")
        expect(activity.previous_value).to be_nil
        expect(activity.new_value).to eq(subject.content)
      end
    end

    context "on update" do
      before do
        subject.save!
        ActivityLogger.delete_all
      end

      it "logs an update activity when content changes" do
        original_content = subject.content
        new_content = "Updated comment content"

        expect {
          subject.update!(content: new_content)
        }.to change(ActivityLogger, :count).by(1)

        activity = ActivityLogger.last
        expect(activity.trackable_type).to eq("Comment")
        expect(activity.trackable_id).to eq(subject.id)
        expect(activity.action).to eq("update")
        expect(activity.field_name).to eq("content")
        expect(activity.previous_value).to eq(original_content)
        expect(activity.new_value).to eq(new_content)
      end

      it "does not log an update activity if content is unchanged" do
        expect {
          subject.update!(content: subject.content)
        }.not_to change(ActivityLogger, :count)
      end
    end

    context "on destroy" do
      before do
        subject.save!
        ActivityLogger.delete_all
      end

      it "logs a delete activity for content" do
        comment_id = subject.id
        current_content = subject.content

        expect {
          subject.destroy
        }.to change(ActivityLogger, :count).by(1)

        activity = ActivityLogger.last
        expect(activity.trackable_type).to eq("Comment")
        expect(activity.trackable_id).to eq(comment_id)
        expect(activity.action).to eq("delete")
        expect(activity.field_name).to eq("content")
        expect(activity.previous_value).to eq(current_content)
        expect(activity.new_value).to be_nil
      end
    end
  end
end
