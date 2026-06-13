class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM", "noreply@taskmanager.demo")
  layout "mailer"
end
