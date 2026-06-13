FactoryBot.define do
  factory :comment do
    user
    association :commentable, factory: :task
    content { "A sample comment" }
  end
end
