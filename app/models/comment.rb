class Comment < ApplicationRecord
  include ActivityAudit
  activity_attr :content

  belongs_to :project
  belongs_to :user

  validates :content, presence: true
end
