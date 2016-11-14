--
-- This file is auto-generated by executing all current
-- migrations. Instead of editing this file, please create
-- migrations to incrementally modify the database, and
-- then regenerate this schema file.
--
-- To create a new empty migration, run:
--   npm run db -- migration -- [name] [sql|js]
--
-- To re-generate this file, run:
--   npm run db -- migrate
--

-- Save the current migration number
PRAGMA user_version=1610181540;

-- Load sqlite3 .dump
PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE project (
  project_id  TEXT     NOT NULL PRIMARY KEY,
  name        TEXT     NOT NULL,
  settings             NOT NULL DEFAULT '{}',
  created_at  NUMERIC  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  NUMERIC  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  opened_at   NUMERIC  NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CHECK (project_id != ''),
  CHECK (name != '')

) WITHOUT ROWID;
CREATE TABLE subjects (
  id           INTEGER  PRIMARY KEY,
  template     TEXT     NOT NULL DEFAULT 'https://schema.tropy.org/v1/templates/core',
  created_at   NUMERIC  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   NUMERIC  NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE images (
  id      INTEGER  PRIMARY KEY REFERENCES subjects ON DELETE CASCADE,
  width   INTEGER  NOT NULL DEFAULT 0,
  height  INTEGER  NOT NULL DEFAULT 0
) WITHOUT ROWID;
CREATE TABLE items (
  id              INTEGER  PRIMARY KEY REFERENCES subjects ON DELETE CASCADE,
  cover_image_id  INTEGER  REFERENCES images ON DELETE SET NULL
) WITHOUT ROWID;
CREATE TABLE metadata_types (
  type_name    TEXT  NOT NULL PRIMARY KEY COLLATE NOCASE,
  type_schema  TEXT  NOT NULL UNIQUE,

  CHECK (type_schema != ''),
  CHECK (type_name != '')

) WITHOUT ROWID;
INSERT INTO "metadata_types" VALUES('boolean','https://schema.org/Boolean');
INSERT INTO "metadata_types" VALUES('datetime','https://schema.org/DateTime');
INSERT INTO "metadata_types" VALUES('location','https://schema.org/GeoCoordinates');
INSERT INTO "metadata_types" VALUES('number','https://schema.org/Number');
INSERT INTO "metadata_types" VALUES('text','https://schema.org/Text');
INSERT INTO "metadata_types" VALUES('url','https://schema.org/URL');
INSERT INTO "metadata_types" VALUES('date','https://schema.tropy.org/v1/types/date');
INSERT INTO "metadata_types" VALUES('name','https://schema.tropy.org/v1/types/name');
CREATE TABLE metadata (
  id          INTEGER  NOT NULL REFERENCES subjects ON DELETE CASCADE,
  --item_id     INTEGER  NOT NULL REFERENCES items ON DELETE CASCADE,
  property    TEXT     NOT NULL,
  value_id    INTEGER  NOT NULL REFERENCES metadata_values,
  language    TEXT,
  --position    INTEGER  NOT NULL DEFAULT 0,
  created_at  NUMERIC  NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CHECK (
    language IS NULL OR language != '' AND language = trim(lower(language))
  ),

  --UNIQUE (id, position),
  --UNIQUE (item_id, id, property),
  PRIMARY KEY (id, property)
) WITHOUT ROWID;
CREATE TABLE metadata_values (
  value_id   INTEGER  PRIMARY KEY,
  type_name  TEXT     NOT NULL REFERENCES metadata_types ON UPDATE CASCADE,
  value      TEXT     NOT NULL,
  struct              NOT NULL DEFAULT '{}',

  UNIQUE (type_name, value)
);
CREATE TABLE notes (
  note_id      INTEGER  PRIMARY KEY,
  id           INTEGER  REFERENCES subjects ON DELETE CASCADE,
  position     INTEGER  NOT NULL DEFAULT 0,
  text         TEXT     NOT NULL,
  language     TEXT     NOT NULL DEFAULT 'en',
  created_at   NUMERIC  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   NUMERIC  NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CHECK (
    language != '' AND language = trim(lower(language))
  ),

  UNIQUE (id, position)
);
CREATE TABLE lists (
  list_id         INTEGER  PRIMARY KEY,
  name            TEXT     NOT NULL COLLATE NOCASE,
  parent_list_id  INTEGER  DEFAULT 0 REFERENCES lists ON DELETE CASCADE,
  position        INTEGER,
  created_at      NUMERIC  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      NUMERIC  NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CHECK (list_id != parent_list_id),
  CHECK (name != ''),

  UNIQUE (parent_list_id, name)
);
INSERT INTO "lists" VALUES(0,'ROOT',NULL,NULL,'2016-11-14 16:35:46','2016-11-14 16:35:46');
CREATE TABLE list_items (
  id       INTEGER REFERENCES items ON DELETE CASCADE,
  list_id  INTEGER REFERENCES lists ON DELETE CASCADE,
  position INTEGER NOT NULL DEFAULT 0,

  PRIMARY KEY (id, list_id),
  UNIQUE (id, list_id, position)
) WITHOUT ROWID;
CREATE TABLE tags (
  tag_id      INTEGER  PRIMARY KEY,
  name        TEXT     NOT NULL COLLATE NOCASE,
  color,
  visible     BOOLEAN  NOT NULL DEFAULT 1,
  created_at  NUMERIC  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  NUMERIC  NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CHECK (name != ''),
  UNIQUE (visible, name)
);
CREATE TABLE taggings (
  id         INTEGER  NOT NULL REFERENCES subjects ON DELETE CASCADE,
  tag_id     INTEGER  NOT NULL REFERENCES tags ON DELETE CASCADE,
  tagged_at  NUMERIC  NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id, tag_id)
) WITHOUT ROWID;
CREATE TABLE trash (
  id          INTEGER  PRIMARY KEY REFERENCES items ON DELETE CASCADE,
  deleted_at  NUMERIC  NOT NULL DEFAULT CURRENT_TIMESTAMP
) WITHOUT ROWID;
CREATE TABLE photos (
  id           INTEGER  PRIMARY KEY REFERENCES images ON DELETE CASCADE,
  item_id      INTEGER  REFERENCES items ON DELETE CASCADE,
  path         TEXT     NOT NULL,
  protocol     TEXT     NOT NULL DEFAULT 'file',
  mimetype     TEXT     NOT NULL,
  checksum     TEXT     NOT NULL,
  orientation  INTEGER  NOT NULL DEFAULT 1,
  exif                  NOT NULL DEFAULT '{}'
) WITHOUT ROWID;
CREATE TABLE selections (
  id        INTEGER  PRIMARY KEY REFERENCES images ON DELETE CASCADE,
  photo_id  INTEGER  NOT NULL REFERENCES photos ON DELETE CASCADE,
  quality   TEXT     NOT NULL DEFAULT 'default' REFERENCES image_qualities,
  x         NUMERIC  NOT NULL DEFAULT 0,
  y         NUMERIC  NOT NULL DEFAULT 0,
  pct       BOOLEAN  NOT NULL DEFAULT 0
) WITHOUT ROWID;
CREATE TABLE image_scales (
  id      INTEGER  PRIMARY KEY REFERENCES selections ON DELETE CASCADE,
  x       NUMERIC  NOT NULL DEFAULT 0,
  y       NUMERIC  NOT NULL DEFAULT 0,
  factor  NUMERIC  NOT NULL,
  fit     BOOLEAN  NOT NULL DEFAULT 0
) WITHOUT ROWID;
CREATE TABLE image_rotations (
  id      INTEGER  PRIMARY KEY REFERENCES selections ON DELETE CASCADE,
  angle   NUMERIC  NOT NULL DEFAULT 0,
  mirror  BOOLEAN  NOT NULL DEFAULT 0
) WITHOUT ROWID;
CREATE TABLE image_qualities (
  quality  TEXT  NOT NULL PRIMARY KEY
) WITHOUT ROWID;
INSERT INTO "image_qualities" VALUES('bitonal');
INSERT INTO "image_qualities" VALUES('color');
INSERT INTO "image_qualities" VALUES('default');
INSERT INTO "image_qualities" VALUES('gray');
PRAGMA writable_schema=ON;
INSERT INTO sqlite_master(type,name,tbl_name,rootpage,sql)VALUES('table','ft_metadata','ft_metadata',0,'CREATE VIRTUAL TABLE ft_metadata USING fts5(
  id UNINDEXED,
  title,
  names,
  other
)');
CREATE TABLE 'ft_metadata_data'(id INTEGER PRIMARY KEY, block BLOB);
INSERT INTO "ft_metadata_data" VALUES(1,X'');
INSERT INTO "ft_metadata_data" VALUES(10,X'00000000000000');
CREATE TABLE 'ft_metadata_idx'(segid, term, pgno, PRIMARY KEY(segid, term)) WITHOUT ROWID;
CREATE TABLE 'ft_metadata_content'(id INTEGER PRIMARY KEY, c0, c1, c2, c3);
CREATE TABLE 'ft_metadata_docsize'(id INTEGER PRIMARY KEY, sz BLOB);
CREATE TABLE 'ft_metadata_config'(k PRIMARY KEY, v) WITHOUT ROWID;
INSERT INTO "ft_metadata_config" VALUES('version',4);
INSERT INTO sqlite_master(type,name,tbl_name,rootpage,sql)VALUES('table','ft_notes','ft_notes',0,'CREATE VIRTUAL TABLE ft_notes USING fts5(
  id UNINDEXED,
  text,
  content=''notes''
)');
CREATE TABLE 'ft_notes_data'(id INTEGER PRIMARY KEY, block BLOB);
INSERT INTO "ft_notes_data" VALUES(1,X'');
INSERT INTO "ft_notes_data" VALUES(10,X'00000000000000');
CREATE TABLE 'ft_notes_idx'(segid, term, pgno, PRIMARY KEY(segid, term)) WITHOUT ROWID;
CREATE TABLE 'ft_notes_docsize'(id INTEGER PRIMARY KEY, sz BLOB);
CREATE TABLE 'ft_notes_config'(k PRIMARY KEY, v) WITHOUT ROWID;
INSERT INTO "ft_notes_config" VALUES('version',4);
CREATE INDEX metadata_values_index ON metadata_values (value ASC);
CREATE TRIGGER insert_tags_trim_name
  AFTER INSERT ON tags
  BEGIN
    UPDATE tags SET name = trim(name)
      WHERE tag_id = NEW.tag_id;
  END;
CREATE TRIGGER update_tags_trim_name
  AFTER UPDATE OF name ON tags
  BEGIN
    UPDATE tags SET name = trim(name)
      WHERE tag_id = NEW.tag_id;
  END;
CREATE TRIGGER insert_lists_trim_name
  AFTER INSERT ON lists
  BEGIN
    UPDATE lists SET name = trim(name)
      WHERE list_id = NEW.list_id;
  END;
CREATE TRIGGER update_lists_trim_name
  AFTER UPDATE OF name ON lists
  BEGIN
    UPDATE lists SET name = trim(name)
      WHERE list_id = NEW.list_id;
  END;
CREATE TRIGGER update_lists_cycle_check
  BEFORE UPDATE OF parent_list_id ON lists
  FOR EACH ROW WHEN NEW.parent_list_id NOT NULL
  BEGIN
    SELECT CASE (
        WITH RECURSIVE
          ancestors(id) AS (
            SELECT parent_list_id
              FROM lists
              WHERE list_id = OLD.list_id
            UNION
            SELECT parent_list_id
              FROM lists, ancestors
              WHERE lists.list_id = ancestors.id
          )
          SELECT count(*) FROM ancestors WHERE id = OLD.list_id LIMIT 1
      )
      WHEN 1 THEN
        RAISE(ABORT, 'Lists may not contain cycles')
      END;
  END;
CREATE TRIGGER ai_notes_index
  AFTER INSERT ON notes
  BEGIN
    INSERT INTO ft_notes (rowid, id, text)
      VALUES (NEW.note_id, NEW.id, NEW.text);
  END;
CREATE TRIGGER ad_notes_index
  AFTER DELETE ON notes
  BEGIN
    INSERT INTO ft_notes (ft_notes, rowid, id, text)
      VALUES ('delete', OLD.note_id, OLD.id, OLD.text);
  END;
CREATE TRIGGER au_notes_index
  AFTER UPDATE ON notes
  BEGIN
    INSERT INTO ft_notes (fts_notes, rowid, id, text)
      VALUES ('delete', OLD.note_id, OLD.id, OLD.text);
    INSERT INTO ft_notes (rowid, id, text)
      VALUES (NEW.note_id, NEW.id, NEW.text);
  END;
PRAGMA writable_schema=OFF;
COMMIT;
PRAGMA foreign_keys=ON;