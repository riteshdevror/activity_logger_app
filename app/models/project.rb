class Project < ApplicationRecord
  include ActivityAudit
  activity_attr :status

  has_many :comments, dependent: :destroy

  enum status: { open: 0, in_progress: 1, closed: 2 }

  validates :title, :description, :status, presence: true
end
