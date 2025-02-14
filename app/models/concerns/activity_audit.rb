module ActivityAudit
  extend ActiveSupport::Concern

  included do
    class_attribute :tracked_attributes
    self.tracked_attributes = []

    after_create  :log_create_activity
    after_update  :log_update_activity
    before_destroy :log_delete_activity
  end

  class_methods do
    def activity_attr(*attrs)
      self.tracked_attributes = attrs.map(&:to_s)
    end
  end

  private

  def log_create_activity
    log_activity(:create, tracked_attributes)
  end

  def log_update_activity
    log_activity(:update, saved_changes.keys & tracked_attributes)
  end

  def log_delete_activity
    log_activity(:delete, tracked_attributes)
  end

  def log_activity(action, changed_fields)
    return if changed_fields.empty?

    changed_fields.each do |field|
      ::ActivityLogger.create(
        trackable: self,
        action: action,
        field_name: field,
        previous_value: value_for(:previous, field, value_type),
        new_value: value_for(:new, field, value_type)
      )
    end
  end

  def value_for(action, field, value_type)
    mapping = {
      previous: {
        create: -> { nil },
        update: -> { saved_changes.dig(field, 0) },
        delete: -> { self[field] }
      },
      new: {
        create: -> { self[field] },
        update: -> { saved_changes.dig(field, 1) },
        delete: -> { nil }
      }
    }
    mapping.fetch(value_type, {}).fetch(action, -> { nil }).call
  end
end
