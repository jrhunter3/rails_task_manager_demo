# Rails Task Manager Demo

A Ruby on Rails project management / task tracker demonstration application.

## Prerequisites

- **Ruby 3.4.6** (installed via rbenv)
- **Rails 8.1.3**
- **PostgreSQL 14** (server running on localhost)
- **Redis 7+** — required for Sidekiq background jobs
- **Chromium** (or Chrome) — required for system tests with JavaScript (`sudo apt-get install chromium-browser`)
- **Bundler** (comes with Ruby)

## Setup

```bash
# 1. Install dependencies
bundle install

# 2. Create the PostgreSQL role for your system user (if not exists)
sudo -u postgres createuser -s $(whoami)

# 3. Create and migrate databases
rails db:create
rails db:migrate

# 4. Seed the database (if available)
rails db:seed

# 5. Verify the app boots
rails runner "puts 'OK'"
```

## Running the App

```bash
bin/dev
```

This starts the Rails server along with any background processes defined in `Procfile.dev`.
Visit `http://localhost:3000` in your browser.

### Background Jobs (Sidekiq)

Sidekiq processes background jobs (e.g., notification emails). Start it in a separate terminal:

```bash
bundle exec sidekiq
```

Jobs are enqueued into Redis. Without Sidekiq running, jobs will queue but not execute.
For testing, the test environment uses the `:test` adapter (no Redis needed).

### Authentication

The app uses Devise for authentication. Sign up at `/users/sign_up`.
Roles: **member** (default) and **admin** (assign manually via console).

## Features (by Phase)

| Phase | Feature | Key Gems |
|-------|---------|----------|
| 1 | Rails scaffold, PostgreSQL, RSpec setup | rspec-rails, factory_bot_rails |
| 2 | Authentication (sign-up, sign-in, roles) | Devise |
| 3 | Authorization (role-based policies) | Pundit, pundit-matchers |
| 4 | Project CRUD, team memberships | shoulda-matchers |
| 5 | Task model with state machine | AASM |
| 6 | Nested comments with rich text | Action Text |
| 7 | Background jobs & email notifications | Sidekiq, Redis |
| 8 | Search & pagination | Ransack, Pagy |
| 9 | File attachments | Active Storage |
| 10 | API (JSON, bearer token auth) | — |
| 11 | System tests (Capybara, Selenium) | Capybara, selenium-webdriver |
| 12 | Pre-deployment audit: security, coverage, error handling | rack-attack, sentry-ruby, simplecov |

## Testing

The project uses **RSpec**, **FactoryBot**, **shoulda-matchers**, and **pundit-matchers** for testing.
Tests and factories are created alongside every feature phase.

### Running Tests

```bash
# Full suite
bundle exec rspec

# By type
bundle exec rspec spec/models           # model specs
bundle exec rspec spec/requests         # request specs
bundle exec rspec spec/policies         # policy specs
bundle exec rspec spec/mailers          # mailer specs
bundle exec rspec spec/jobs             # job specs
bundle exec rspec spec/system           # system specs (slower)

# A single file
bundle exec rspec spec/models/user_spec.rb

# Verbose output
bundle exec rspec --format documentation
```


### What's Covered

| Type            | Scope                                                     |
|-----------------|-----------------------------------------------------------|
| Model specs     | Validations, associations, enums, state machine, factories|
| Request specs   | CRUD, auth enforcement, role-based access, 404s, rescues |
| Policy specs    | Permissions for every role + scoping                      |
| Mailer specs    | Email rendering, headers, body content, I18n              |
| Job specs       | Job enqueuing, recipient targeting                        |
| Helper specs    | View helpers (task state events)                          |
| System specs    | Browser-level flows (auth, CRUD, comments)                |

### Coverage

Run `bundle exec rspec` to generate a coverage report under `/coverage/`.
Open `coverage/index.html` in a browser to view.

### Policy

- Every phase includes specs and factories alongside new code.
- Authorization-heavy phases include policy specs.
- Error handling (404, unauthorized, validation errors, rescue handlers) is built in.
- All specs must pass (0 failures, 0 deprecation warnings) before work is presented for review.

## What Was Installed

| Tool       | Version | Method        |
|------------|---------|---------------|
| Ruby       | 3.4.6   | rbenv         |
| Rails      | 8.1.3   | gem install   |
| PostgreSQL | 14      | apt           |
| Node.js    | 24.x    | nvm           |
| Redis      | 7+      | apt           |

## Project Structure

```
app/
  models/            — User, Project, ProjectMembership, Task, Comment
  controllers/       — Web + API::V1, concerns (SetProject)
  policies/          — ApplicationPolicy, ProjectPolicy, TaskPolicy, CommentPolicy
  views/             — ERB templates (I18n'd), notification mailer templates (I18n'd)
  mailers/           — NotificationMailer
  jobs/              — CommentNotificationJob, TaskStateChangeJob, ApplicationJob
  helpers/           — ApplicationHelper (task_state_events, pagy frontend)
  views/
    comments/        — Comment partial and form
    devise/          — Devise views (sign-up, sign-in)
    projects/        — Project CRUD views
    tasks/           — Task CRUD views, state transitions
    notification_mailer/ — Email templates (HTML + text)
config/
  routes.rb          — Resources: projects > tasks > comments, API namespace
  initializers/      — Devise, Pundit, rack-attack, Sentry, CSP, session_store
db/
  migrate/           — Schema migrations
spec/
  factories/         — FactoryBot definitions
  models/            — Model specs
  requests/          — Request specs (web + API, rescue handlers)
  policies/          — Policy specs
  mailers/           — Mailer specs
  jobs/              — Job specs
  system/            — System specs (Capybara)
  helpers/           — Helper specs
  support/           — Support files (Capybara config)
```

## Key Gems

- **Devise** — Authentication (sign-up, sign-in, roles, paranoid mode, timeoutable, lockable)
- **Pundit** — Authorization (role-based policies)
- **AASM** — State machine for task lifecycle
- **Sidekiq** — Background job processing
- **Ransack** — Search/filtering
- **Pagy** — Pagination
- **rack-attack** — Rate limiting (sign-in 10/min, API 60/min)
- **sentry-ruby / sentry-rails** — Error monitoring
- **RSpec Rails** — Testing framework
- **FactoryBot** — Test data factories
- **shoulda-matchers** — One-liner model specs
- **pundit-matchers** — One-liner policy specs
- **simplecov** — Code coverage (target 90%, branch coverage enabled)
- **Action Text** — Rich text for comments
- **Active Storage** — File attachments (content-type + size validation)
- **Turbo Rails** — Hotwire (real-time updates)
- **Stimulus** — JavaScript framework
- **Importmap** — JavaScript bundling (no Node required)
