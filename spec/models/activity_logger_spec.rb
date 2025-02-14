require 'rails_helper'

RSpec.describe ActivityLogger, type: :model do
  describe "associations" do
    it "belongs to a polymorphic trackable" do
      association = described_class.reflect_on_association(:trackable)
      expect(association).not_to be_nil
      expect(association.options[:polymorphic]).to eq(true)
    end
  end

  describe "creating an activity log" do
    let(:project) { FactoryBot.create(:project) }
    let(:activity_logger) do
      ActivityLogger.create!(
        trackable: project,
        action: "create",
        field_name: "status",
        previous_value: nil,
        new_value: project.status
      )
    end

    it "saves the activity log correctly" do
      expect(activity_logger).to be_persisted
      expect(activity_logger.trackable).to eq(project)
      expect(activity_logger.trackable_type).to eq("Project")
      expect(activity_logger.action).to eq("create")
      expect(activity_logger.field_name).to eq("status")
      expect(activity_logger.new_value).to eq(project.status)
    end
  end
end
