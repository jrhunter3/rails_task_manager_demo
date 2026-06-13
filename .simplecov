SimpleCov.start "rails" do
  add_filter "/spec/"
  add_filter "/config/"
  enable_coverage :branch
  minimum_coverage 90
end
