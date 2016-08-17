--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.3
-- Dumped by pg_dump version 9.5.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: job_posts_search_trigger(); Type: FUNCTION; Schema: public; Owner: rafael
--

CREATE FUNCTION job_posts_search_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  new.tsv :=
    setweight(to_tsvector(coalesce(new.details->>'title','')), 'A') || setweight(to_tsvector(coalesce(new.details->>'tags','')), 'B') || setweight(to_tsvector(coalesce(new.details->>'description','')), 'C') || setweight(to_tsvector(coalesce(new.details->>'requirements','')), 'D') || setweight(to_tsvector(coalesce(new.details->>'qualifications','')), 'D');
  return new;
end
$$;


ALTER FUNCTION public.job_posts_search_trigger() OWNER TO rafael;

--
-- Name: profiles_search_trigger(); Type: FUNCTION; Schema: public; Owner: rafael
--

CREATE FUNCTION profiles_search_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  new.tsv :=
    setweight(to_tsvector(coalesce(new.profile->>'skills','')), 'A') || setweight(to_tsvector(coalesce(pin,'')), 'B') || setweight(to_tsvector(coalesce(new.profile->>'status','')), 'C')  || setweight(to_tsvector(coalesce(new.profile->'personal'->>'city','')), 'A');
  return new;
end
$$;


ALTER FUNCTION public.profiles_search_trigger() OWNER TO rafael;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: chrs
--

CREATE TABLE accounts (
    pin text NOT NULL,
    email_address text NOT NULL,
    password text NOT NULL,
    usertype text DEFAULT 'candidate'::text
);


ALTER TABLE accounts OWNER TO chrs;

--
-- Name: accounts_others; Type: TABLE; Schema: public; Owner: chrs
--

CREATE TABLE accounts_others (
    pin text,
    currencies_pk integer,
    languages_pk integer
);


ALTER TABLE accounts_others OWNER TO chrs;

--
-- Name: admired_candidates; Type: TABLE; Schema: public; Owner: chrs
--

CREATE TABLE admired_candidates (
    pk integer NOT NULL,
    pin text,
    admired_pin text,
    datecreated timestamp with time zone DEFAULT now()
);


ALTER TABLE admired_candidates OWNER TO chrs;

--
-- Name: admired_candidates_pk_seq; Type: SEQUENCE; Schema: public; Owner: chrs
--

CREATE SEQUENCE admired_candidates_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE admired_candidates_pk_seq OWNER TO chrs;

--
-- Name: admired_candidates_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chrs
--

ALTER SEQUENCE admired_candidates_pk_seq OWNED BY admired_candidates.pk;


--
-- Name: admired_companies; Type: TABLE; Schema: public; Owner: chrs
--

CREATE TABLE admired_companies (
    pk integer NOT NULL,
    pin text,
    companies_pk integer,
    datecreated timestamp with time zone DEFAULT now()
);


ALTER TABLE admired_companies OWNER TO chrs;

--
-- Name: admired_companies_pk_seq; Type: SEQUENCE; Schema: public; Owner: chrs
--

CREATE SEQUENCE admired_companies_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE admired_companies_pk_seq OWNER TO chrs;

--
-- Name: admired_companies_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chrs
--

ALTER SEQUENCE admired_companies_pk_seq OWNED BY admired_companies.pk;


--
-- Name: admired_job_posts; Type: TABLE; Schema: public; Owner: chrs
--

CREATE TABLE admired_job_posts (
    pk integer NOT NULL,
    pin text,
    job_posts_pk integer,
    datecreated timestamp with time zone DEFAULT now()
);


ALTER TABLE admired_job_posts OWNER TO chrs;

--
-- Name: admired_job_posts_pk_seq; Type: SEQUENCE; Schema: public; Owner: chrs
--

CREATE SEQUENCE admired_job_posts_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE admired_job_posts_pk_seq OWNER TO chrs;

--
-- Name: admired_job_posts_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chrs
--

ALTER SEQUENCE admired_job_posts_pk_seq OWNED BY admired_job_posts.pk;


--
-- Name: companies; Type: TABLE; Schema: public; Owner: chrs
--

CREATE TABLE companies (
    pk integer NOT NULL,
    name text NOT NULL,
    logo text
);


ALTER TABLE companies OWNER TO chrs;

--
-- Name: companies_pk_seq; Type: SEQUENCE; Schema: public; Owner: chrs
--

CREATE SEQUENCE companies_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE companies_pk_seq OWNER TO chrs;

--
-- Name: companies_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chrs
--

ALTER SEQUENCE companies_pk_seq OWNED BY companies.pk;


--
-- Name: currencies; Type: TABLE; Schema: public; Owner: chrs
--

CREATE TABLE currencies (
    pk integer NOT NULL,
    currency text DEFAULT 'PHP'::text NOT NULL,
    archived boolean DEFAULT false
);


ALTER TABLE currencies OWNER TO chrs;

--
-- Name: currencies_pk_seq; Type: SEQUENCE; Schema: public; Owner: chrs
--

CREATE SEQUENCE currencies_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE currencies_pk_seq OWNER TO chrs;

--
-- Name: currencies_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chrs
--

ALTER SEQUENCE currencies_pk_seq OWNED BY currencies.pk;


--
-- Name: email_notifications; Type: TABLE; Schema: public; Owner: chrs
--

CREATE TABLE email_notifications (
    code text NOT NULL,
    email json NOT NULL,
    date_created timestamp with time zone DEFAULT now()
);


ALTER TABLE email_notifications OWNER TO chrs;

--
-- Name: job_posts; Type: TABLE; Schema: public; Owner: chrs
--

CREATE TABLE job_posts (
    pk integer NOT NULL,
    pin text,
    type text NOT NULL,
    details jsonb NOT NULL,
    date_created timestamp with time zone DEFAULT now(),
    archived boolean DEFAULT false,
    tsv tsvector
);


ALTER TABLE job_posts OWNER TO chrs;

--
-- Name: job_posts_pk_seq; Type: SEQUENCE; Schema: public; Owner: chrs
--

CREATE SEQUENCE job_posts_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE job_posts_pk_seq OWNER TO chrs;

--
-- Name: job_posts_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chrs
--

ALTER SEQUENCE job_posts_pk_seq OWNED BY job_posts.pk;


--
-- Name: languages; Type: TABLE; Schema: public; Owner: chrs
--

CREATE TABLE languages (
    pk integer NOT NULL,
    code text NOT NULL,
    language text NOT NULL,
    archived boolean DEFAULT false
);


ALTER TABLE languages OWNER TO chrs;

--
-- Name: languages_pk_seq; Type: SEQUENCE; Schema: public; Owner: chrs
--

CREATE SEQUENCE languages_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE languages_pk_seq OWNER TO chrs;

--
-- Name: languages_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chrs
--

ALTER SEQUENCE languages_pk_seq OWNED BY languages.pk;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: chrs
--

CREATE TABLE messages (
    pk integer NOT NULL,
    sender text,
    subject text NOT NULL,
    message text NOT NULL,
    date_created timestamp with time zone DEFAULT now(),
    archived boolean DEFAULT false
);


ALTER TABLE messages OWNER TO chrs;

--
-- Name: messages_pk_seq; Type: SEQUENCE; Schema: public; Owner: chrs
--

CREATE SEQUENCE messages_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE messages_pk_seq OWNER TO chrs;

--
-- Name: messages_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chrs
--

ALTER SEQUENCE messages_pk_seq OWNED BY messages.pk;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: chrs
--

CREATE TABLE notifications (
    pk integer NOT NULL,
    notification text NOT NULL,
    pin text,
    table_name text NOT NULL,
    table_pk integer NOT NULL,
    datecreated timestamp with time zone DEFAULT now()
);


ALTER TABLE notifications OWNER TO chrs;

--
-- Name: notifications_pk_seq; Type: SEQUENCE; Schema: public; Owner: chrs
--

CREATE SEQUENCE notifications_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE notifications_pk_seq OWNER TO chrs;

--
-- Name: notifications_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chrs
--

ALTER SEQUENCE notifications_pk_seq OWNED BY notifications.pk;


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: chrs
--

CREATE TABLE profiles (
    pin text,
    profile jsonb NOT NULL,
    archived boolean DEFAULT false,
    tsv tsvector,
    date_created timestamp with time zone DEFAULT now(),
    statuses_pk integer
);


ALTER TABLE profiles OWNER TO chrs;

--
-- Name: profiles_logs; Type: TABLE; Schema: public; Owner: chrs
--

CREATE TABLE profiles_logs (
    pin text NOT NULL,
    log text NOT NULL,
    datecreated timestamp with time zone
);


ALTER TABLE profiles_logs OWNER TO chrs;

--
-- Name: statuses; Type: TABLE; Schema: public; Owner: chrs
--

CREATE TABLE statuses (
    pk integer NOT NULL,
    status text NOT NULL,
    seq integer NOT NULL,
    archived boolean DEFAULT false
);


ALTER TABLE statuses OWNER TO chrs;

--
-- Name: statuses_pk_seq; Type: SEQUENCE; Schema: public; Owner: chrs
--

CREATE SEQUENCE statuses_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE statuses_pk_seq OWNER TO chrs;

--
-- Name: statuses_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chrs
--

ALTER SEQUENCE statuses_pk_seq OWNED BY statuses.pk;


--
-- Name: pk; Type: DEFAULT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY admired_candidates ALTER COLUMN pk SET DEFAULT nextval('admired_candidates_pk_seq'::regclass);


--
-- Name: pk; Type: DEFAULT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY admired_companies ALTER COLUMN pk SET DEFAULT nextval('admired_companies_pk_seq'::regclass);


--
-- Name: pk; Type: DEFAULT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY admired_job_posts ALTER COLUMN pk SET DEFAULT nextval('admired_job_posts_pk_seq'::regclass);


--
-- Name: pk; Type: DEFAULT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY companies ALTER COLUMN pk SET DEFAULT nextval('companies_pk_seq'::regclass);


--
-- Name: pk; Type: DEFAULT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY currencies ALTER COLUMN pk SET DEFAULT nextval('currencies_pk_seq'::regclass);


--
-- Name: pk; Type: DEFAULT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY job_posts ALTER COLUMN pk SET DEFAULT nextval('job_posts_pk_seq'::regclass);


--
-- Name: pk; Type: DEFAULT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY languages ALTER COLUMN pk SET DEFAULT nextval('languages_pk_seq'::regclass);


--
-- Name: pk; Type: DEFAULT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY messages ALTER COLUMN pk SET DEFAULT nextval('messages_pk_seq'::regclass);


--
-- Name: pk; Type: DEFAULT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY notifications ALTER COLUMN pk SET DEFAULT nextval('notifications_pk_seq'::regclass);


--
-- Name: pk; Type: DEFAULT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY statuses ALTER COLUMN pk SET DEFAULT nextval('statuses_pk_seq'::regclass);


--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: chrs
--

COPY accounts (pin, email_address, password, usertype) FROM stdin;
1234-JJ	rpascual0812@gmail.com	c4ca4238a0b923820dcc509a6f75849b	candidate
JJ-1234-JJ	rpascual.chrs@gmail.com	c4ca4238a0b923820dcc509a6f75849b	recruiter
1235-JJ	rpascual1235@gmail.com	c4ca4238a0b923820dcc509a6f75849b	candidate
2574-ZQ	luffy.monkey@gmail.com	f25a2fc72690b780b2a14e140ef6a9e0	candidate
8907-AQ	sanji.vinsmoke@gmail.com	c4ca4238a0b923820dcc509a6f75849b	candidate
\.


--
-- Data for Name: accounts_others; Type: TABLE DATA; Schema: public; Owner: chrs
--

COPY accounts_others (pin, currencies_pk, languages_pk) FROM stdin;
\.


--
-- Data for Name: admired_candidates; Type: TABLE DATA; Schema: public; Owner: chrs
--

COPY admired_candidates (pk, pin, admired_pin, datecreated) FROM stdin;
\.


--
-- Name: admired_candidates_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: chrs
--

SELECT pg_catalog.setval('admired_candidates_pk_seq', 1, false);


--
-- Data for Name: admired_companies; Type: TABLE DATA; Schema: public; Owner: chrs
--

COPY admired_companies (pk, pin, companies_pk, datecreated) FROM stdin;
\.


--
-- Name: admired_companies_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: chrs
--

SELECT pg_catalog.setval('admired_companies_pk_seq', 1, false);


--
-- Data for Name: admired_job_posts; Type: TABLE DATA; Schema: public; Owner: chrs
--

COPY admired_job_posts (pk, pin, job_posts_pk, datecreated) FROM stdin;
\.


--
-- Name: admired_job_posts_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: chrs
--

SELECT pg_catalog.setval('admired_job_posts_pk_seq', 1, false);


--
-- Data for Name: companies; Type: TABLE DATA; Schema: public; Owner: chrs
--

COPY companies (pk, name, logo) FROM stdin;
1	sadjf	\N
2	askjdfk	\N
3	sfaskdjfkl	\N
\.


--
-- Name: companies_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: chrs
--

SELECT pg_catalog.setval('companies_pk_seq', 3, true);


--
-- Data for Name: currencies; Type: TABLE DATA; Schema: public; Owner: chrs
--

COPY currencies (pk, currency, archived) FROM stdin;
1	PHP	f
2	USD	f
\.


--
-- Name: currencies_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: chrs
--

SELECT pg_catalog.setval('currencies_pk_seq', 2, true);


--
-- Data for Name: email_notifications; Type: TABLE DATA; Schema: public; Owner: chrs
--

COPY email_notifications (code, email, date_created) FROM stdin;
28fzdpuli5k8zhq7ccqe	{"to_email":"luffy.monkey@gmail.com","to_name":"Luffy Monkey","return_url":"localhost\\/employer\\/#\\/manual_log\\/confirm\\/","template":"candidate_registration"}	2016-08-02 17:31:52.341679+08
d0nn02piae7z55y3d3ty	{"to_email":"sanji.vinsmoke@gmail.com","to_name":"Sanji Vinsmoke","return_url":"localhost\\/employer\\/#\\/manual_log\\/confirm\\/","template":"candidate_registration"}	2016-08-02 17:35:27.887372+08
\.


--
-- Data for Name: job_posts; Type: TABLE DATA; Schema: public; Owner: chrs
--

COPY job_posts (pk, pin, type, details, date_created, archived, tsv) FROM stdin;
9	JJ-1234-JJ	ads	{"tags": [{"text": "Python-2.7"}, {"text": "Linux"}, {"text": "Shell-Scripting"}, {"text": "GIT"}], "title": "Back-end Developer", "commission_type": "monetary", "commission_value": "5000", "years_experience": "2"}	2016-08-03 17:40:20.903639+08	f	'-2.7':7B 'back':2A 'back-end':1A 'develop':4A 'end':3A 'git':15B 'linux':9B 'python':6B 'script':13B 'shell':12B 'shell-script':11B 'text':5B,8B,10B,14B
10	JJ-1234-JJ	video	{"tags": [{"text": "Javascript"}, {"text": "Node-JS"}], "title": "Node JS Developer", "description": "Awesome skills in Javascript"}	2016-08-03 17:40:52.122893+08	f	'awesom':10C 'develop':3A 'javascript':5B,13C 'js':2A,9B 'node':1A,8B 'node-j':7B 'skill':11C 'text':4B,6B
11	JJ-1234-JJ	video	{"link": "http://www.google.com", "tags": [{"text": "Javascript"}, {"text": "Node-JS"}], "title": "Node JS Developer", "description": "Awesome skills in Javascript"}	2016-08-03 17:41:02.281681+08	f	'awesom':10C 'develop':3A 'javascript':5B,13C 'js':2A,9B 'node':1A,8B 'node-j':7B 'skill':11C 'text':4B,6B
12	JJ-1234-JJ	job	{"tags": [{"text": "Maya"}, {"text": "3D-SMAX"}], "title": "Game Developer", "requirements": "Maya and 3D SMAX", "qualifications": "Game Development", "years_experience": "5"}	2016-08-03 17:41:53.743814+08	f	'3d':7B,11 '3d-smax':6B 'develop':2A,14 'game':1A,13 'maya':4B,9 'smax':8B,12 'text':3B,5B
\.


--
-- Name: job_posts_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: chrs
--

SELECT pg_catalog.setval('job_posts_pk_seq', 12, true);


--
-- Data for Name: languages; Type: TABLE DATA; Schema: public; Owner: chrs
--

COPY languages (pk, code, language, archived) FROM stdin;
\.


--
-- Name: languages_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: chrs
--

SELECT pg_catalog.setval('languages_pk_seq', 1, false);


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: chrs
--

COPY messages (pk, sender, subject, message, date_created, archived) FROM stdin;
\.


--
-- Name: messages_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: chrs
--

SELECT pg_catalog.setval('messages_pk_seq', 1, false);


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: chrs
--

COPY notifications (pk, notification, pin, table_name, table_pk, datecreated) FROM stdin;
\.


--
-- Name: notifications_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: chrs
--

SELECT pg_catalog.setval('notifications_pk_seq', 1, false);


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: chrs
--

COPY profiles (pin, profile, archived, tsv, date_created, statuses_pk) FROM stdin;
JJ-1234-JJ	{"personal": {"last_name": "Martin", "first_name": "Coco"}, "confirmed": "true"}	f	'-1234':2B 'jj':1B,3B	2016-07-25 16:03:53.343307+08	\N
1235-JJ	{"skills": ["PHP", "Angular JS", "Bootstrap", "CSS"], "status": "Currently Exploring", "personal": {"city": "Pasig City", "last_name": "Pascual", "first_name": "Rafael"}, "confirmed": "true", "statuses_pk": 3}	f	'1235':6B 'angular':2A 'bootstrap':4A 'citi':11 'css':5A 'current':8C 'explor':9C 'jj':7B 'js':3A 'pasig':10 'php':1A	2016-07-31 13:03:27.009784+08	\N
2574-ZQ	{"personal": {"last_name": "Monkey", "first_name": "Luffy"}}	f	\N	2016-08-02 17:31:52.341679+08	\N
8907-AQ	{"work": {"dateto": "2016-01-14T16:00:00.000Z", "company": "Acquire BPO", "datefrom": "2011-05-02T16:00:00.000Z", "position": "Software Applications Programmer"}, "personal": {"last_name": "Vinsmoke", "first_name": "Sanji"}, "education": {"model": "BS in Information Technology", "dateto": "2007-02-28T16:00:00.000Z", "school": "UP", "datefrom": "2003-05-31T16:00:00.000Z"}, "achievements": {"textarea": "Best in P.E."}, "personal_info": {"name": "Sanji Vinsmoke", "email": "sanji.vinsmoke@gmail.com", "number": "09950899977", "address": "Mandaluyong City"}}	f	\N	2016-08-02 17:35:27.887372+08	\N
1234-JJ	{"skills": ["PHP", "JQuery", "CSS"], "status": "Currently Exploring", "personal": {"city": "Mandaluyong City", "last_name": "Pascual", "first_name": "Rafael"}, "confirmed": "true", "statuses_pk": 3, "achievements": {"achievements": "skldafaksd"}, "personal_info": {"name": "Luffy Monkey", "email": "luffy.monkey@gmail.com", "number": "09950899977", "address": "4828. V. Baltzar St. Pinagbuhatan Pasig City"}}	f	'1234':4B 'citi':9 'css':3A 'current':6C 'explor':7C 'jj':5B 'jqueri':2A 'mandaluyong':8 'php':1A	2016-07-25 16:03:53.343307+08	\N
\.


--
-- Data for Name: profiles_logs; Type: TABLE DATA; Schema: public; Owner: chrs
--

COPY profiles_logs (pin, log, datecreated) FROM stdin;
\.


--
-- Data for Name: statuses; Type: TABLE DATA; Schema: public; Owner: chrs
--

COPY statuses (pk, status, seq, archived) FROM stdin;
1	Unemployed, willing to start ASAP	1	f
2	Happily employed	2	f
3	Currently exploring	3	f
4	Looking for part-time jobs only	4	f
5	Looking for internship	5	f
6	Willing to consider new job offers	6	f
7	Looking for home-based jobs	7	f
8	Looking for oversees jobs	8	f
9	Looking for project-based jobs	9	f
10	Looking for commission-based jobs	10	f
11	Looking for consultancy jobs	11	f
12	Looking for freelance jobs	12	f
13	Looking for working student jobs	13	f
\.


--
-- Name: statuses_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: chrs
--

SELECT pg_catalog.setval('statuses_pk_seq', 13, true);


--
-- Name: accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (pin);


--
-- Name: admired_candidates_pkey; Type: CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY admired_candidates
    ADD CONSTRAINT admired_candidates_pkey PRIMARY KEY (pk);


--
-- Name: admired_companies_pkey; Type: CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY admired_companies
    ADD CONSTRAINT admired_companies_pkey PRIMARY KEY (pk);


--
-- Name: admired_job_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY admired_job_posts
    ADD CONSTRAINT admired_job_posts_pkey PRIMARY KEY (pk);


--
-- Name: companies_pkey; Type: CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (pk);


--
-- Name: currencies_pkey; Type: CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY currencies
    ADD CONSTRAINT currencies_pkey PRIMARY KEY (pk);


--
-- Name: email_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY email_notifications
    ADD CONSTRAINT email_notifications_pkey PRIMARY KEY (code);


--
-- Name: job_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY job_posts
    ADD CONSTRAINT job_posts_pkey PRIMARY KEY (pk);


--
-- Name: languages_pkey; Type: CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (pk);


--
-- Name: messages_pkey; Type: CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (pk);


--
-- Name: notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (pk);


--
-- Name: statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY statuses
    ADD CONSTRAINT statuses_pkey PRIMARY KEY (pk);


--
-- Name: accounts_email_address; Type: INDEX; Schema: public; Owner: chrs
--

CREATE UNIQUE INDEX accounts_email_address ON accounts USING btree (email_address);


--
-- Name: accounts_others_idx; Type: INDEX; Schema: public; Owner: chrs
--

CREATE UNIQUE INDEX accounts_others_idx ON accounts_others USING btree (pin);


--
-- Name: accounts_pin; Type: INDEX; Schema: public; Owner: chrs
--

CREATE UNIQUE INDEX accounts_pin ON accounts USING btree (pin);


--
-- Name: companies_name; Type: INDEX; Schema: public; Owner: chrs
--

CREATE UNIQUE INDEX companies_name ON companies USING btree (name);


--
-- Name: currencies_currency; Type: INDEX; Schema: public; Owner: chrs
--

CREATE UNIQUE INDEX currencies_currency ON currencies USING btree (currency);


--
-- Name: email_notifications_idx; Type: INDEX; Schema: public; Owner: chrs
--

CREATE UNIQUE INDEX email_notifications_idx ON email_notifications USING btree (code);


--
-- Name: languages_code; Type: INDEX; Schema: public; Owner: chrs
--

CREATE UNIQUE INDEX languages_code ON languages USING btree (code);


--
-- Name: languages_language; Type: INDEX; Schema: public; Owner: chrs
--

CREATE UNIQUE INDEX languages_language ON languages USING btree (language);


--
-- Name: profiles_pin; Type: INDEX; Schema: public; Owner: chrs
--

CREATE UNIQUE INDEX profiles_pin ON profiles USING btree (pin);


--
-- Name: seq_idx; Type: INDEX; Schema: public; Owner: chrs
--

CREATE UNIQUE INDEX seq_idx ON statuses USING btree (seq);


--
-- Name: status_idx; Type: INDEX; Schema: public; Owner: chrs
--

CREATE UNIQUE INDEX status_idx ON statuses USING btree (status);


--
-- Name: tsv_idx; Type: INDEX; Schema: public; Owner: chrs
--

CREATE INDEX tsv_idx ON job_posts USING gin (tsv);


--
-- Name: job_posts_tsvectorupdate; Type: TRIGGER; Schema: public; Owner: chrs
--

CREATE TRIGGER job_posts_tsvectorupdate BEFORE INSERT OR UPDATE ON job_posts FOR EACH ROW EXECUTE PROCEDURE job_posts_search_trigger();


--
-- Name: profiles_tsvectorupdate; Type: TRIGGER; Schema: public; Owner: chrs
--

CREATE TRIGGER profiles_tsvectorupdate BEFORE INSERT OR UPDATE ON profiles FOR EACH ROW EXECUTE PROCEDURE profiles_search_trigger();


--
-- Name: accounts_others_currencies_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY accounts_others
    ADD CONSTRAINT accounts_others_currencies_pk_fkey FOREIGN KEY (currencies_pk) REFERENCES currencies(pk);


--
-- Name: accounts_others_languages_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY accounts_others
    ADD CONSTRAINT accounts_others_languages_pk_fkey FOREIGN KEY (languages_pk) REFERENCES languages(pk);


--
-- Name: accounts_others_pin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY accounts_others
    ADD CONSTRAINT accounts_others_pin_fkey FOREIGN KEY (pin) REFERENCES accounts(pin);


--
-- Name: admired_candidates_admired_pin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY admired_candidates
    ADD CONSTRAINT admired_candidates_admired_pin_fkey FOREIGN KEY (admired_pin) REFERENCES accounts(pin);


--
-- Name: admired_candidates_pin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY admired_candidates
    ADD CONSTRAINT admired_candidates_pin_fkey FOREIGN KEY (pin) REFERENCES accounts(pin);


--
-- Name: admired_companies_companies_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY admired_companies
    ADD CONSTRAINT admired_companies_companies_pk_fkey FOREIGN KEY (companies_pk) REFERENCES companies(pk);


--
-- Name: admired_companies_pin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY admired_companies
    ADD CONSTRAINT admired_companies_pin_fkey FOREIGN KEY (pin) REFERENCES accounts(pin);


--
-- Name: admired_job_posts_pin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY admired_job_posts
    ADD CONSTRAINT admired_job_posts_pin_fkey FOREIGN KEY (pin) REFERENCES accounts(pin);


--
-- Name: job_posts_pin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY job_posts
    ADD CONSTRAINT job_posts_pin_fkey FOREIGN KEY (pin) REFERENCES accounts(pin);


--
-- Name: messages_sender_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_sender_fkey FOREIGN KEY (sender) REFERENCES accounts(pin);


--
-- Name: notifications_pin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_pin_fkey FOREIGN KEY (pin) REFERENCES accounts(pin);


--
-- Name: profiles_pin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY profiles
    ADD CONSTRAINT profiles_pin_fkey FOREIGN KEY (pin) REFERENCES accounts(pin);


--
-- Name: profiles_statuses_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY profiles
    ADD CONSTRAINT profiles_statuses_pk_fkey FOREIGN KEY (statuses_pk) REFERENCES statuses(pk);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

