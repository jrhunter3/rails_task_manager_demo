# Rails Task Manager Demo

A Ruby on Rails project management and task tracker demonstration.  
Users create projects, invite team members, track tasks through a workflow (backlog → in progress → in review → done), discuss with rich-text comments, and receive email notifications.

## Before You Start

You need **one** thing installed on your computer:

- **Docker Desktop** (includes Docker Engine and Docker Compose)  
  Download from [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/)

That's it. You do **not** need to install Ruby, Rails, PostgreSQL, Redis, Node.js, or any other dependency on your host machine. Everything runs inside Docker containers.

### Verify Docker is installed

Open a terminal and run:

```bash
docker --version
docker compose version
```

You should see version numbers for both commands. If not, install Docker Desktop first, then reopen your terminal.

## Getting the Code

Clone the repository:

```bash
git clone <repository-url>
cd rails_task_manager_demo
```

Replace `<repository-url>` with the actual Git URL of this project (SSH or HTTPS, as provided by your Git hosting service).

## Getting the Secrets

The application needs a **master key** to decrypt Rails credentials (session cookies, API secret base, etc.).

Your project administrator or the person who set up the repository will have a file called `config/master.key`. You need to create this file locally:

```bash
# Create the file with the key provided to you
echo "your-rails-master-key-here" > config/master.key
```

Replace `your-rails-master-key-here` with the actual key value.

> **Security note**: `config/master.key` is listed in `.gitignore` and will never be committed to Git. Anyone with this key can decrypt the application's credentials.

### Environment Variables

Copy the environment template:

```bash
cp .env.example .env
```

Open `.env` in a text editor. You must set at least these two values:

- `RAILS_MASTER_KEY` — paste the same key you put in `config/master.key`
- `RAILS_TASK_MANAGER_DEMO_DATABASE_PASSWORD` — choose a password for the database (e.g., `my-dev-password-123`)

The other variables have sensible defaults and can be left as-is for local development.

## Starting the Application

### Production Mode

Build and start all services (PostgreSQL, Redis, Rails):

```bash
docker compose up -d
```

- `-d` means "detached" — runs in the background. Remove it to see logs in your terminal.
- The first run will download images and build the application; this takes 1–3 minutes.

### Development Mode (Live Code Reloading)

If you plan to edit code and see changes immediately, use the development override:

```bash
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d
```

This runs the Rails development server on port 3000 instead of Thruster (production HTTP server). Your local project files are mounted into the container, so changes to `.rb`, `.erb`, `.css`, etc. take effect on the next page refresh — no rebuild needed.

## Setting Up the Database

Create the databases and run migrations:

```bash
docker compose exec app bin/rails db:prepare
```

(In dev mode, use the same command — `docker compose -f ... exec app ...`)

`db:prepare` creates the database if it doesn't exist, runs all pending migrations, and loads the schema. It is safe to run multiple times.

## Seeding Sample Data

Load sample projects, tasks, and users:

```bash
docker compose exec app bin/rails db:seed
```

This creates:
- An admin user: `admin@example.com` / `password123`
- A regular user: `member@example.com` / `password123`
- Two sample projects with sample tasks

## Accessing the Application

Open your browser:

| Mode | URL |
|------|-----|
| Production | [http://localhost](http://localhost) (port 80) |
| Development | [http://localhost:3000](http://localhost:3000) |

Sign up at `/users/sign_up` or use the seeded accounts above.

## Running Tests

```bash
docker compose exec -e RAILS_ENV=test app bin/rails db:prepare
docker compose exec -e RAILS_ENV=test app bundle exec rspec
```

Breakdown:

1. **`docker compose exec`** — runs a command inside the running `app` container
2. **`-e RAILS_ENV=test`** — sets the environment to `test` (the app container normally runs in production/development)
3. **`bundle exec rspec`** — runs the full test suite

You can also run individual test files:

```bash
docker compose exec -e RAILS_ENV=test app bundle exec rspec spec/models/user_spec.rb
```

Expected output: **0 failures** with **high line and branch coverage**.

### Running Tests in Development Mode

If you started with the dev override:

```bash
docker compose -f docker-compose.yml -f docker-compose.dev.yml exec -e RAILS_ENV=test app bin/rails db:prepare
docker compose -f docker-compose.yml -f docker-compose.dev.yml exec -e RAILS_ENV=test app bundle exec rspec
```

## Viewing Logs

```bash
# All services
docker compose logs -f

# Just the app
docker compose logs -f app

# Last 50 lines
docker compose logs --tail=50 app
```

Press `Ctrl+C` to stop following logs.

## Stopping the Application

```bash
# Stop containers (data persists in volumes)
docker compose down

# Stop and delete all data (database, Redis, uploaded files)
docker compose down -v
```

Use `down -v` with caution — it destroys your database and you would need to re-run `db:prepare` and `db:seed`.

## Making Code Changes

1. Stop the app if running in production mode
2. Start in dev mode: `docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d`
3. Edit files on your host machine (in the `rails_task_manager_demo/` directory)
4. Refresh your browser — changes are reflected immediately

The dev override mounts your project directory into the container at `/rails`. Any file you change on your host is instantly visible inside the container. Rails development mode handles hot-reloading of templates, controllers, and models on each request.

### When to Rebuild

You only need to rebuild the dev image when `Gemfile` or `Gemfile.lock` changes (i.e., when gems are added, removed, or updated):

```bash
docker compose -f docker-compose.yml -f docker-compose.dev.yml build app
```

## Resetting Your Environment

If something goes wrong or you want a clean slate:

```bash
# 1. Stop and delete everything (including database volumes)
docker compose down -v

# 2. Rebuild images (pulls latest base images, re-installs gems)
docker compose build
# or for dev:
docker compose -f docker-compose.yml -f docker-compose.dev.yml build app

# 3. Start fresh
docker compose up -d
# or for dev:
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# 4. Set up database
docker compose exec app bin/rails db:prepare db:seed
```

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| `rake aborted! Rails::Credentials::InvalidError` | Missing `config/master.key` or wrong `RAILS_MASTER_KEY` | Check the file exists and matches the `.env` value |
| `FATAL: password authentication failed for user` | Wrong database password in `.env` | Check `RAILS_TASK_MANAGER_DEMO_DATABASE_PASSWORD` matches between `.env` and the `postgres` service |
| Port 80 already in use | Another service (e.g., Apache, Nginx) is using port 80 | Set `PORT=8080` in `.env` to use a different port |
| Port 3000 already in use | Another Rails app or Node service is using port 3000 | Set `DEV_PORT=3001` in `.env` |
| `docker compose` command not found | Older Docker installation | Use `docker-compose` (with hyphen) instead, or upgrade to Docker Desktop |
| Changes not showing in browser | Running in production mode (no live reload) | Switch to dev mode with `-f docker-compose.dev.yml` |
| `Gem::LoadError` about missing gem | `Gemfile` changed without rebuild | Rebuild the dev image |

## Architecture

The application runs as three Docker containers:

```
┌─────────────┐     ┌──────────────┐     ┌──────────────┐
│  PostgreSQL  │     │    Redis     │     │  Rails App   │
│   (port 5432)│◄────│  (port 6379) │◄────│ (port 80/3000)│
│             │     │              │     │              │
│  Database   │     │ Sidekiq queue│     │ Thruster*    │
│  Solid Cache│     │              │     │ Solid Queue  │
│  Solid Queue│     │              │     │ Solid Cable  │
└─────────────┘     └──────────────┘     └──────────────┘
```

*In production: Thruster (HTTP caching/compression) sits in front of Puma.  
In development: Rails server runs directly on port 3000.

### Key Design Decisions

- **Solid Queue** (database-backed) is the production job queue — no Redis dependency in production
- **Sidekiq** (Redis-backed) is available for development and can be enabled in production via `REDIS_URL`
- **Authorization** is role-based (member / admin) enforced by Pundit policies on every action
- **API authentication** uses bearer tokens hashed with SHA256 (raw token shown once on creation, stored as digest)
- **System tests** use `:rack_test` driver — no browser required, runs in milliseconds
- **Rate limiting** via Rack::Attack: 10 requests/min for sign-in, 60/min for API
- **Error monitoring** via Sentry (configure via `SENTRY_DSN`)

## Features

- **Authentication** — Devise (sign-up, sign-in, 30-minute timeout, account lockout after 10 failed attempts)
- **Authorization** — Pundit (member / admin roles per project)
- **Projects** — Create, edit, delete with team membership management
- **Tasks** — State machine (backlog → in progress → in review → done) enforced by AASM
- **Comments** — Nested rich-text discussions via Action Text (Trix editor)
- **File Attachments** — Upload images/documents with content-type and size validation
- **Email Notifications** — Sent when comments are added or task state changes
- **Search** — Filter projects and tasks by name/description/state using Ransack
- **Pagination** — Paginated index pages via Pagy
- **REST API** — JSON API v1 with scoped routes under `/api/v1/`
- **Security** — CSP headers, forced SSL (production), host header validation, rate limiting

## CI/CD

Every push or pull request to `main` runs via GitHub Actions:

| Step | Tool | Current Status |
|------|------|---------------|
| Test suite | `rspec` | 0 failures |
| Code style | `rubocop` | 0 offenses |
| Static security | `brakeman` | 0 warnings |
| Gem vulnerabilities | `bundler-audit` | 0 vulnerabilities |

## Project Structure

```
rails_task_manager_demo/
├── Dockerfile              # Production image (multi-stage, Thruster, jemalloc)
├── Dockerfile.dev          # Development image (all gems, code mounted as volume)
├── docker-compose.yml      # Production services (PostgreSQL, Redis, Rails)
├── docker-compose.dev.yml  # Development overrides (live reload, port 3000)
├── .env.example            # Environment variable template
├── Gemfile                 # Ruby dependencies
│
├── app/
│   ├── models/             # User, Project, ProjectMembership, Task, Comment
│   ├── controllers/        # Web + API::V1 controllers
│   ├── policies/           # Pundit authorization policies
│   ├── mailers/            # NotificationMailer
│   ├── jobs/               # Background jobs (Sidekiq)
│   ├── helpers/            # View helpers
│   └── views/              # ERB templates, mailer templates
│
├── config/
│   ├── routes.rb           # Route definitions
│   ├── database.yml        # PostgreSQL connection config
│   ├── environments/       # Per-environment settings
│   └── initializers/       # Devise, Pundit, rack-attack, Sentry, CSP, etc.
│
├── db/
│   └── migrate/            # Schema migrations
│
├── spec/
│   ├── factories/          # Test data factories (FactoryBot)
│   ├── models/             # Model unit tests
│   ├── requests/           # Web + API integration tests
│   ├── policies/           # Authorization policy tests
│   ├── mailers/            # Mailer tests
│   ├── jobs/               # Job tests
│   ├── system/             # Browser simulation tests
│   └── helpers/            # Helper tests
│
└── .github/workflows/      # CI pipeline
```
