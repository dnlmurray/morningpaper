CREATE DATABASE morningpaper;

CREATE TABLE public.users (
	id serial NOT NULL,
	uid bigint NOT NULL,
	preferred_time time,
	locations_id integer,
	CONSTRAINT users_pk PRIMARY KEY (id)
);

ALTER TABLE public.users OWNER TO postgres;


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
ALTER TABLE public.news OWNER TO postgres;

CREATE TABLE public.topics (
	id serial NOT NULL,
	name varchar(30) NOT NULL,
	CONSTRAINT topics_pk PRIMARY KEY (id)

);
ALTER TABLE public.topics OWNER TO postgres;

CREATE TABLE public.sources (
	id serial NOT NULL,
	name varchar(30) NOT NULL,
	link varchar(80),
	CONSTRAINT sources_pk PRIMARY KEY (id)

);
ALTER TABLE public.sources OWNER TO postgres;

ALTER TABLE public.news ADD CONSTRAINT fk_sources FOREIGN KEY (sources_id)
REFERENCES public.sources (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;

CREATE TABLE public.many_users_has_many_topics (
	users_id integer NOT NULL,
	id_topics integer NOT NULL,
	CONSTRAINT many_users_has_many_topics_pk PRIMARY KEY (users_id,id_topics)

);

ALTER TABLE public.many_users_has_many_topics ADD CONSTRAINT fk_users FOREIGN KEY (users_id)
REFERENCES public.users (id) MATCH FULL
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE public.many_users_has_many_topics ADD CONSTRAINT fk_topics FOREIGN KEY (id_topics)
REFERENCES public.topics (id) MATCH FULL
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE public.news ADD CONSTRAINT fk_topics FOREIGN KEY (topics_id)
REFERENCES public.topics (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;

CREATE TABLE public.weather (
	id serial NOT NULL,
	temperature real,
	cloudiness smallint,
	precipitation real,
	"timestamp" timestamp,
	locations_id integer,
	CONSTRAINT weather_pk PRIMARY KEY (id)

);
ALTER TABLE public.weather OWNER TO postgres;

CREATE TABLE public.locations (
	id serial NOT NULL,
	location varchar(30),
	lat real NOT NULL,
	lon real NOT NULL,
	CONSTRAINT locations_pk PRIMARY KEY (id)

);
ALTER TABLE public.locations OWNER TO postgres;

ALTER TABLE public.weather ADD CONSTRAINT fk_locations FOREIGN KEY (locations_id)
REFERENCES public.locations (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE public.users ADD CONSTRAINT fk_locations FOREIGN KEY (locations_id)
REFERENCES public.locations (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;

CREATE TABLE public.currencies (
	id serial NOT NULL,
	name varchar(30),
	abbreviation varchar(3),
	CONSTRAINT currencies_pk PRIMARY KEY (id)

);
ALTER TABLE public.currencies OWNER TO postgres;

CREATE TABLE public.exchange_rates (
	id serial NOT NULL,
	base integer,
	target integer,
	rate money,
	CONSTRAINT exchange_rates_pk PRIMARY KEY (id)

);
ALTER TABLE public.exchange_rates OWNER TO postgres;

ALTER TABLE public.exchange_rates ADD CONSTRAINT currencies_fk FOREIGN KEY (base)
REFERENCES public.currencies (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE public.exchange_rates ADD CONSTRAINT currencies_fk1 FOREIGN KEY (target)
REFERENCES public.currencies (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;

CREATE TABLE public.users_currencies (
	users_id integer,
	base integer,
	target_one integer,
	target_two integer
);
ALTER TABLE public.users_currencies OWNER TO postgres;

ALTER TABLE public.users_currencies ADD CONSTRAINT users_fk FOREIGN KEY (users_id)
REFERENCES public.users (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE public.users_currencies ADD CONSTRAINT users_currencies_uq UNIQUE (users_id);

ALTER TABLE public.users_currencies ADD CONSTRAINT currencies_fk FOREIGN KEY (target_one)
REFERENCES public.currencies (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE public.users_currencies ADD CONSTRAINT currencies_fk1 FOREIGN KEY (target_two)
REFERENCES public.currencies (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE public.users_currencies ADD CONSTRAINT currencies_fk2 FOREIGN KEY (base)
REFERENCES public.currencies (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;


INSERT INTO topics (name) VALUES ('business'), ('entertainment'), ('general'), ('health'), ('science'), ('sports'), ('technology');
