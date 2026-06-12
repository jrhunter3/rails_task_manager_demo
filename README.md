# Rails Task Manager Demo

A Ruby on Rails project management / task tracker demonstration application.

## Prerequisites

- **Ruby 3.4.6** (installed via rbenv)
- **Rails 8.1.3**
- **PostgreSQL 14** (server running on localhost)
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

### Authentication

The app uses Devise for authentication. Sign up at `/users/sign_up`.  
Roles: **member** (default) and **admin** (assign manually via console).

## Testing

The project uses **RSpec**, **FactoryBot**, and **shoulda-matchers** for testing.  
Tests and factories are created alongside every feature phase.

### Running Tests

```bash
# Full suite
bundle exec rspec

# By type
bundle exec rspec spec/models           # model specs
bundle exec rspec spec/requests         # request specs
bundle exec rspec spec/policies         # policy specs

# A single file
bundle exec rspec spec/models/user_spec.rb

# Verbose output
bundle exec rspec --format documentation
```

### What's Covered

| Type            | Scope                                      |
|-----------------|--------------------------------------------|
| Model specs     | Validations, associations, enums, factories|
| Request specs   | CRUD, auth enforcement, role-based access  |
| Policy specs    | Permissions for every role + scoping       |
| System specs    | Browser-level integration (planned)        |

### Policy

- Every phase includes specs and factories alongside new code.
- Authorization-heavy phases include policy specs.
- Error handling (404, unauthorized, validation errors) is built in.
- All specs must pass (0 failures) before work is presented for review.

## What Was Installed

| Tool       | Version | Method        |
|------------|---------|---------------|
| Ruby       | 3.4.6   | rbenv         |
| Rails      | 8.1.3   | gem install   |
| PostgreSQL | 14      | apt           |
| Node.js    | 24.x    | nvm           |

## Project Structure

- `app/models/` — ActiveRecord models (User, Project, ProjectMembership, etc.)
- `app/controllers/` — Controllers
- `app/views/` — ERB templates
- `spec/` — RSpec tests

## Key Gems

- **Devise** — Authentication
- **Pundit** — Authorization (role-based policies)
- **RSpec Rails** — Testing framework
- **FactoryBot** — Test data factories
- **Turbo Rails** — Hotwire (real-time updates)
- **Stimulus** — JavaScript framework
- **Importmap** — JavaScript bundling (no Node required)
