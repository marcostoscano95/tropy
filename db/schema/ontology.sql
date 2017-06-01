--
-- This file is auto-generated by executing all current
-- migrations. Instead of editing this file, please create
-- migrations to incrementally modify the database, and
-- then regenerate this schema file.
--
-- To create a new empty migration, run:
--   node scripts/db migration -- ontology [name] [sql|js]
--
-- To re-generate this file, run:
--   node scripts/db migrate
--

-- Save the current migration number
PRAGMA user_version=1705231144;

-- Load sqlite3 .dump
PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE vocabularies (
  vocabulary_id   TEXT     NOT NULL PRIMARY KEY,
  prefix          TEXT,
  created         NUMERIC  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  deleted         NUMERIC,

  title           TEXT,
  description     TEXT,
  comment         TEXT,
  see_also        TEXT,

  CHECK (vocabulary_id != '' AND prefix != ''),
  UNIQUE (prefix)
);
CREATE TABLE properties (
  property_id     TEXT NOT NULL PRIMARY KEY,
  vocabulary_id   TEXT NOT NULL REFERENCES vocabularies ON DELETE CASCADE,
  domain          TEXT,
  range           TEXT,
  parent          TEXT,

  description     TEXT,
  comment         TEXT,

  CHECK (property_id != '')
);
CREATE TABLE classes (
  class_id        TEXT NOT NULL PRIMARY KEY,
  vocabulary_id   TEXT NOT NULL REFERENCES vocabularies ON DELETE CASCADE,
  parent          TEXT,

  description     TEXT,
  comment         TEXT,

  CHECK (class_id != '')
);
CREATE TABLE labels (
  id        TEXT NOT NULL,
  language  TEXT COLLATE NOCASE,
  label     TEXT NOT NULL,

  PRIMARY KEY (id, language),

  CHECK (id != '' AND label != ''),
  CHECK (
    language IS NULL OR (language != '' AND language = trim(lower(language)))
  )
) WITHOUT ROWID;
CREATE TABLE templates (
  template_id    TEXT     NOT NULL PRIMARY KEY,
  template_type  TEXT     NOT NULL DEFAULT 'item',
  protected      BOOLEAN  NOT NULL DEFAULT FALSE,
  created        NUMERIC  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  modified       NUMERIC  NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CHECK (template_id != ''),
  CHECK (template_type IN ('item', 'photo', 'selection'))
);
CREATE TABLE template_classes (
  template_id   TEXT     NOT NULL REFERENCES templates ON DELETE CASCADE,
  class_id      TEXT     NOT NULL REFERENCES classes,
  position      INTEGER
);
CREATE TABLE template_fields (
  field_id      INTEGER  PRIMARY KEY,
  template_id   TEXT     NOT NULL REFERENCES templates ON DELETE CASCADE,
  property_id   TEXT     NOT NULL REFERENCES properties,
  position      INTEGER
);
COMMIT;
PRAGMA foreign_keys=ON;