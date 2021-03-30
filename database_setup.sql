-- Database generated with pgModeler (PostgreSQL Database Modeler).
-- pgModeler  version: 0.9.3
-- PostgreSQL version: 13.0
-- Project Site: pgmodeler.io
-- Model Author: ---

-- Database creation must be performed outside a multi lined SQL file. 
-- These commands were put in this file only as a convenience.
-- 
-- object: morningpaper | type: DATABASE --
-- DROP DATABASE IF EXISTS morningpaper;
CREATE DATABASE morningpaper;
-- ddl-end --


-- object: public.users | type: TABLE --
-- DROP TABLE IF EXISTS public.users CASCADE;
CREATE TABLE public.users (
	id serial NOT NULL,
	uid bigint NOT NULL,
	preferred_time time,
	CONSTRAINT users_pk PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE public.users OWNER TO postgres;
-- ddl-end --

-- object: public.news | type: TABLE --
-- DROP TABLE IF EXISTS public.news CASCADE;
CREATE TABLE public.news (
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
-- ddl-end --
ALTER TABLE public.news OWNER TO postgres;
-- ddl-end --

-- object: public.topics | type: TABLE --
-- DROP TABLE IF EXISTS public.topics CASCADE;
CREATE TABLE public.topics (
	id serial NOT NULL,
	name varchar(30) NOT NULL,
	CONSTRAINT topics_pk PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE public.topics OWNER TO postgres;
-- ddl-end --

-- object: public.sources | type: TABLE --
-- DROP TABLE IF EXISTS public.sources CASCADE;
CREATE TABLE public.sources (
	id serial NOT NULL,
	name varchar(30) NOT NULL,
	link varchar(80),
	CONSTRAINT sources_pk PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE public.sources OWNER TO postgres;
-- ddl-end --

-- object: fk_sources | type: CONSTRAINT --
-- ALTER TABLE public.news DROP CONSTRAINT IF EXISTS fk_sources CASCADE;
ALTER TABLE public.news ADD CONSTRAINT fk_sources FOREIGN KEY (sources_id)
REFERENCES public.sources (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: public.many_users_has_many_topics | type: TABLE --
-- DROP TABLE IF EXISTS public.many_users_has_many_topics CASCADE;
CREATE TABLE public.many_users_has_many_topics (
	users_id integer NOT NULL,
	id_topics integer NOT NULL,
	CONSTRAINT many_users_has_many_topics_pk PRIMARY KEY (users_id,id_topics)

);
-- ddl-end --

-- object: fk_users | type: CONSTRAINT --
-- ALTER TABLE public.many_users_has_many_topics DROP CONSTRAINT IF EXISTS fk_users CASCADE;
ALTER TABLE public.many_users_has_many_topics ADD CONSTRAINT fk_users FOREIGN KEY (users_id)
REFERENCES public.users (id) MATCH FULL
ON DELETE RESTRICT ON UPDATE CASCADE;
-- ddl-end --

-- object: fk_topics | type: CONSTRAINT --
-- ALTER TABLE public.many_users_has_many_topics DROP CONSTRAINT IF EXISTS fk_topics CASCADE;
ALTER TABLE public.many_users_has_many_topics ADD CONSTRAINT fk_topics FOREIGN KEY (id_topics)
REFERENCES public.topics (id) MATCH FULL
ON DELETE RESTRICT ON UPDATE CASCADE;
-- ddl-end --

-- object: fk_topics | type: CONSTRAINT --
-- ALTER TABLE public.news DROP CONSTRAINT IF EXISTS fk_topics CASCADE;
ALTER TABLE public.news ADD CONSTRAINT fk_topics FOREIGN KEY (topics_id)
REFERENCES public.topics (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: public.weather | type: TABLE --
-- DROP TABLE IF EXISTS public.weather CASCADE;
CREATE TABLE public.weather (
	id serial NOT NULL,
	temperature real,
	cloudiness smallint,
	precipitation real,
	"timestamp" timestamp,
	locations_id integer,
	CONSTRAINT weather_pk PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE public.weather OWNER TO postgres;
-- ddl-end --

-- object: public.locations | type: TABLE --
-- DROP TABLE IF EXISTS public.locations CASCADE;
CREATE TABLE public.locations (
	id serial NOT NULL,
	location varchar(30),
	lat real NOT NULL,
	lon real NOT NULL,
	CONSTRAINT locations_pk PRIMARY KEY (id)

);
-- ddl-end --
ALTER TABLE public.locations OWNER TO postgres;
-- ddl-end --

-- object: public.many_users_has_many_locations | type: TABLE --
-- DROP TABLE IF EXISTS public.many_users_has_many_locations CASCADE;
CREATE TABLE public.many_users_has_many_locations (
	users_id integer NOT NULL,
	locations_id integer NOT NULL,
	CONSTRAINT pk_many_users_has_many_locations PRIMARY KEY (users_id,locations_id)

);
-- ddl-end --

-- object: fk_users | type: CONSTRAINT --
-- ALTER TABLE public.many_users_has_many_locations DROP CONSTRAINT IF EXISTS fk_users CASCADE;
ALTER TABLE public.many_users_has_many_locations ADD CONSTRAINT fk_users FOREIGN KEY (users_id)
REFERENCES public.users (id) MATCH FULL
ON DELETE RESTRICT ON UPDATE CASCADE;
-- ddl-end --

-- object: fk_locations | type: CONSTRAINT --
-- ALTER TABLE public.many_users_has_many_locations DROP CONSTRAINT IF EXISTS fk_locations CASCADE;
ALTER TABLE public.many_users_has_many_locations ADD CONSTRAINT fk_locations FOREIGN KEY (locations_id)
REFERENCES public.locations (id) MATCH FULL
ON DELETE RESTRICT ON UPDATE CASCADE;
-- ddl-end --

-- object: fk_locations | type: CONSTRAINT --
-- ALTER TABLE public.weather DROP CONSTRAINT IF EXISTS fk_locations CASCADE;
ALTER TABLE public.weather ADD CONSTRAINT fk_locations FOREIGN KEY (locations_id)
REFERENCES public.locations (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --


-- Appended SQL commands --
INSERT INTO news_types (type) VALUES ('news'), ('weather'), ('currency'); 
INSERT INTO topics (name) VALUES ('business'), ('entertainment'), ('general'), ('health'), ('science'), ('sports'), ('technology');
-- ddl-end --