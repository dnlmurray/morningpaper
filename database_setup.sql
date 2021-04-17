CREATE DATABASE morningpaper;

\connect morningpaper

CREATE TABLE users (
	id serial NOT NULL,
	uid bigint NOT NULL,
	preferred_time time,
	locations_id integer,
	CONSTRAINT users_pk PRIMARY KEY (id)
);


CREATE TABLE news (
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

CREATE TABLE topics (
	id serial NOT NULL,
	name varchar(30) NOT NULL,
	CONSTRAINT topics_pk PRIMARY KEY (id)
);

CREATE TABLE sources (
	id serial NOT NULL,
	name varchar(30) NOT NULL,
	link varchar(80),
	CONSTRAINT sources_pk PRIMARY KEY (id)
);

ALTER TABLE news ADD CONSTRAINT fk_sources FOREIGN KEY (sources_id)
REFERENCES sources (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;

CREATE TABLE many_users_has_many_topics (
	users_id integer NOT NULL,
	id_topics integer NOT NULL,
	CONSTRAINT many_users_has_many_topics_pk PRIMARY KEY (users_id,id_topics)
);

ALTER TABLE many_users_has_many_topics ADD CONSTRAINT fk_users FOREIGN KEY (users_id)
REFERENCES users (id) MATCH FULL
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE many_users_has_many_topics ADD CONSTRAINT fk_topics FOREIGN KEY (id_topics)
REFERENCES topics (id) MATCH FULL
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE news ADD CONSTRAINT fk_topics FOREIGN KEY (topics_id)
REFERENCES topics (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;

CREATE TABLE weather (
	id serial NOT NULL,
	temperature real,
	cloudiness smallint,
	precipitation real,
	"timestamp" timestamp,
	locations_id integer,
	CONSTRAINT weather_pk PRIMARY KEY (id)
);

CREATE TABLE locations (
	id serial NOT NULL,
	location varchar(30),
	lat real NOT NULL,
	lon real NOT NULL,
	CONSTRAINT locations_pk PRIMARY KEY (id)
);

ALTER TABLE weather ADD CONSTRAINT fk_locations FOREIGN KEY (locations_id)
REFERENCES locations (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE users ADD CONSTRAINT fk_locations FOREIGN KEY (locations_id)
REFERENCES locations (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;

CREATE TABLE currencies (
	id serial NOT NULL,
	name varchar(30),
	abbreviation varchar(3),
	CONSTRAINT currencies_pk PRIMARY KEY (id)
);

CREATE TABLE exchange_rates (
	id serial NOT NULL,
	base integer,
	target integer,
	rate money,
	CONSTRAINT exchange_rates_pk PRIMARY KEY (id)
);

ALTER TABLE exchange_rates ADD CONSTRAINT currencies_fk FOREIGN KEY (base)
REFERENCES currencies (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE exchange_rates ADD CONSTRAINT currencies_fk1 FOREIGN KEY (target)
REFERENCES currencies (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;

CREATE TABLE users_currencies (
	users_id integer,
	base integer,
	target_one integer,
	target_two integer
);

ALTER TABLE users_currencies ADD CONSTRAINT users_fk FOREIGN KEY (users_id)
REFERENCES users (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE users_currencies ADD CONSTRAINT users_currencies_uq UNIQUE (users_id);

ALTER TABLE users_currencies ADD CONSTRAINT currencies_fk FOREIGN KEY (target_one)
REFERENCES currencies (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE users_currencies ADD CONSTRAINT currencies_fk1 FOREIGN KEY (target_two)
REFERENCES currencies (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE users_currencies ADD CONSTRAINT currencies_fk2 FOREIGN KEY (base)
REFERENCES currencies (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;


INSERT INTO topics (name) VALUES ('business'), ('entertainment'), ('general'), ('health'), ('science'), ('sports'), ('technology');
