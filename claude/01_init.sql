-- This file runs automatically on first container startup.
-- Place any additional .sql files in the ./init/ directory.

CREATE TABLE IF NOT EXISTS example (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
