-- FitLyfe initial schema (PostgreSQL)
-- Applied by the db-migrate Kubernetes Job on every deploy.

CREATE TABLE IF NOT EXISTS app_feedback (
  id SERIAL PRIMARY KEY,
  feedback_text TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
