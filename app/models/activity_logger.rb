class ActivityLogger < ApplicationRecord
  belongs_to :trackable, polymorphic: true
end
