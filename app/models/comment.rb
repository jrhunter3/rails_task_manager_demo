class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true

  has_rich_text :content

  validates :content, presence: true
  validate :content_must_not_be_empty

  scope :ordered, -> { order(created_at: :asc) }

  private

  def content_must_not_be_empty
    return if content.body.blank?
    stripped = content.body.to_plain_text.strip
    if stripped.empty?
      errors.add(:content, "can't be blank")
    end
  end
end
