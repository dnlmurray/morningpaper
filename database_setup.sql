SELECT 'CREATE DATABASE morningpaper'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'morningpaper')\gexec

\connect morningpaper

CREATE TABLE IF NOT EXISTS users (
	id serial NOT NULL,
	user_id bigint NOT NULL,
	preferred_time time,
	locations_id integer,
	CONSTRAINT users_pk PRIMARY KEY (id),
    CONSTRAINT unique_uid UNIQUE (user_id)
);

CREATE TABLE IF NOT EXISTS news (
	id serial NOT NULL,
	heading varchar(280) NOT NULL,
	summary varchar(1000),
	author varchar(30),
	sources_id integer,
	link varchar(100),
	"timestamp" timestamp,
	topics_id integer,
	CONSTRAINT news_pk PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS topics (
	id serial NOT NULL,
	name varchar(30) NOT NULL,
	CONSTRAINT topics_pk PRIMARY KEY (id)
);

ALTER TABLE topics DROP CONSTRAINT IF EXISTS  unique_name;
ALTER TABLE topics ADD CONSTRAINT unique_name UNIQUE (name);

CREATE TABLE IF NOT EXISTS sources (
	id serial NOT NULL,
	name varchar(30) NOT NULL,
	link varchar(80),
	CONSTRAINT sources_pk PRIMARY KEY (id)
);

ALTER TABLE news DROP CONSTRAINT IF EXISTS fk_sources;
ALTER TABLE news ADD CONSTRAINT fk_sources FOREIGN KEY (sources_id)
REFERENCES sources (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;

CREATE TABLE IF NOT EXISTS users_topics (
	users_id integer NOT NULL,
	topics_id integer NOT NULL,
	CONSTRAINT users_topics_pk PRIMARY KEY (users_id,topics_id)
);

ALTER TABLE users_topics DROP CONSTRAINT IF EXISTS fk_users;
ALTER TABLE users_topics ADD CONSTRAINT fk_users FOREIGN KEY (users_id)
REFERENCES users (id) MATCH FULL
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE users_topics DROP CONSTRAINT IF EXISTS fk_topics;
ALTER TABLE users_topics ADD CONSTRAINT fk_topics FOREIGN KEY (topics_id)
REFERENCES topics (id) MATCH FULL
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE news DROP CONSTRAINT IF EXISTS fk_topics;
ALTER TABLE news ADD CONSTRAINT fk_topics FOREIGN KEY (topics_id)
REFERENCES topics (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;

CREATE TABLE IF NOT EXISTS weather (
	id serial NOT NULL,
	temperature real,
	cloudiness smallint,
	precipitation real,
	"timestamp" timestamp,
	locations_id integer,
	CONSTRAINT weather_pk PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS locations (
	id serial NOT NULL,
	location varchar(30),
	lat real NOT NULL,
	lon real NOT NULL,
	CONSTRAINT locations_pk PRIMARY KEY (id)
);

ALTER TABLE weather DROP CONSTRAINT IF EXISTS fk_locations;
ALTER TABLE weather ADD CONSTRAINT fk_locations FOREIGN KEY (locations_id)
REFERENCES locations (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE users DROP CONSTRAINT IF EXISTS fk_locations;
ALTER TABLE users ADD CONSTRAINT fk_locations FOREIGN KEY (locations_id)
REFERENCES locations (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;

CREATE TABLE IF NOT EXISTS currencies (
	id serial NOT NULL,
	name varchar(30),
	abbreviation varchar(3),
	CONSTRAINT currencies_pk PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS exchange_rates (
	id serial NOT NULL,
	base integer,
	target integer,
	rate money,
	"timestamp" timestamp,
	CONSTRAINT exchange_rates_pk PRIMARY KEY (id)
);

ALTER TABLE exchange_rates DROP CONSTRAINT IF EXISTS currencies_fk;
ALTER TABLE exchange_rates ADD CONSTRAINT currencies_fk FOREIGN KEY (base)
REFERENCES currencies (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE exchange_rates DROP CONSTRAINT IF EXISTS currencies_fk1;
ALTER TABLE exchange_rates ADD CONSTRAINT currencies_fk1 FOREIGN KEY (target)
REFERENCES currencies (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;

CREATE TABLE IF NOT EXISTS users_currencies (
	users_id integer,
	base integer,
	target_one integer,
	target_two integer
);

ALTER TABLE users_currencies DROP CONSTRAINT IF EXISTS users_fk;
ALTER TABLE users_currencies ADD CONSTRAINT users_fk FOREIGN KEY (users_id)
REFERENCES users (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE users_currencies DROP CONSTRAINT IF EXISTS users_currencies_uq;
ALTER TABLE users_currencies ADD CONSTRAINT users_currencies_uq UNIQUE (users_id);

ALTER TABLE users_currencies DROP CONSTRAINT IF EXISTS currencies_fk;
ALTER TABLE users_currencies ADD CONSTRAINT currencies_fk FOREIGN KEY (target_one)
REFERENCES currencies (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE users_currencies DROP CONSTRAINT IF EXISTS currencies_fk1;
ALTER TABLE users_currencies ADD CONSTRAINT currencies_fk1 FOREIGN KEY (target_two)
REFERENCES currencies (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE users_currencies DROP CONSTRAINT IF EXISTS currencies_fk2;
ALTER TABLE users_currencies ADD CONSTRAINT currencies_fk2 FOREIGN KEY (base)
REFERENCES currencies (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;

CREATE OR REPLACE VIEW aggregated_news AS
SELECT
    news.id,
    news.heading,
    news.summary,
    news.author,
    sources.name AS source,
    news.link,
    news.timestamp,
    topics.name AS topic
FROM news
    JOIN topics ON news.topics_id = topics.id
    JOIN sources ON news.sources_id = sources.id;

CREATE OR REPLACE VIEW aggregated_exchange_rates AS
SELECT
       exchange_rates.id,
       base_currency.abbreviation as base,
       target_currency.abbreviation as target,
       exchange_rates.rate,
       exchange_rates.timestamp
FROM exchange_rates
    JOIN currencies AS base_currency ON exchange_rates.base = base_currency.id
    JOIN currencies AS target_currency ON exchange_rates.target = target_currency.id;

INSERT INTO topics (name) VALUES ('business'),
                                 ('entertainment'),
                                 ('general'),
                                 ('health'),
                                 ('science'),
                                 ('sports'),
                                 ('technology')
ON CONFLICT DO NOTHING;
