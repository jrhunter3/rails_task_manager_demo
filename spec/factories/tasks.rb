FactoryBot.define do
  factory :task do
    project
    sequence(:title) { |n| "Task #{n}" }
    description { "A sample task" }
    priority { :medium }

    trait :high_priority do
      priority { :high }
    end

    trait :in_progress do
      status { "in_progress" }
    end

    trait :done do
      status { "done" }
    end
  end
end
