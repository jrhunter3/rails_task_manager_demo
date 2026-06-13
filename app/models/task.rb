class Task < ApplicationRecord
  include AASM

  belongs_to :project

  has_many :comments, as: :commentable, dependent: :destroy
  has_many_attached :files

  enum :priority, { low: 0, medium: 1, high: 2 }

  aasm column: :status do
    state :backlog, initial: true
    state :in_progress
    state :review
    state :done

    event :start do
      transitions from: :backlog, to: :in_progress
    end

    event :submit_for_review do
      transitions from: :in_progress, to: :review
    end

    event :request_changes do
      transitions from: :review, to: :in_progress
    end

    event :complete do
      transitions from: :review, to: :done
    end

    event :reopen do
      transitions from: :done, to: :in_progress
    end
  end

  validates :title, presence: true

  validate :validate_file_content_type
  validate :validate_file_sizes

  scope :ordered, -> { order(created_at: :desc) }

  def self.ransackable_attributes(auth_object = nil)
    %w[title description status priority]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[project]
  end

  private

  ALLOWED_CONTENT_TYPES = %w[image/png image/jpeg image/gif application/pdf text/plain].freeze

  def validate_file_content_type
    files.each do |file|
      type = content_type_for(file)
      unless type.in?(ALLOWED_CONTENT_TYPES)
        errors.add(:files, "#{file.filename.sanitized} has an invalid type")
      end
    end
  end

  def content_type_for(file)
    Marcel::MimeType.for(file.download, name: file.filename.to_s)
  rescue StandardError
    file.content_type
  end

  def validate_file_sizes
    files.each do |file|
      if file.byte_size > 10.megabytes
        errors.add(:files, "#{file.filename.sanitized} exceeds the 10MB limit")
      end
    end
  end
end
