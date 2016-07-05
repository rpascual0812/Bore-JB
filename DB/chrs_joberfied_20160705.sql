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

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: chrs
--

CREATE TABLE accounts (
    pin text NOT NULL,
    password text NOT NULL
);


ALTER TABLE accounts OWNER TO chrs;

--
-- Name: candidates; Type: TABLE; Schema: public; Owner: chrs
--

CREATE TABLE candidates (
    pin text NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL
);


ALTER TABLE candidates OWNER TO chrs;

--
-- Name: candidates_accounts; Type: TABLE; Schema: public; Owner: chrs
--

CREATE TABLE candidates_accounts (
    pin text NOT NULL,
    email_address text NOT NULL,
    password text NOT NULL
);


ALTER TABLE candidates_accounts OWNER TO chrs;

--
-- Name: credits; Type: TABLE; Schema: public; Owner: chrs
--

CREATE TABLE credits (
    pin text NOT NULL,
    available numeric DEFAULT 0
);


ALTER TABLE credits OWNER TO chrs;

--
-- Name: credits_log; Type: TABLE; Schema: public; Owner: chrs
--

CREATE TABLE credits_log (
    pin text,
    log text NOT NULL,
    datecreated timestamp with time zone DEFAULT now()
);


ALTER TABLE credits_log OWNER TO chrs;

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
-- Name: employers; Type: TABLE; Schema: public; Owner: chrs
--

CREATE TABLE employers (
    pin text NOT NULL,
    name text NOT NULL,
    currencies_pk integer,
    plans_pk integer
);


ALTER TABLE employers OWNER TO chrs;

--
-- Name: employers_bucket; Type: TABLE; Schema: public; Owner: chrs
--

CREATE TABLE employers_bucket (
    pk integer NOT NULL,
    pin text NOT NULL,
    applicant_id text NOT NULL,
    datecreated timestamp with time zone DEFAULT now()
);


ALTER TABLE employers_bucket OWNER TO chrs;

--
-- Name: employers_bucket_pk_seq; Type: SEQUENCE; Schema: public; Owner: chrs
--

CREATE SEQUENCE employers_bucket_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE employers_bucket_pk_seq OWNER TO chrs;

--
-- Name: employers_bucket_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chrs
--

ALTER SEQUENCE employers_bucket_pk_seq OWNED BY employers_bucket.pk;


--
-- Name: employers_logs; Type: TABLE; Schema: public; Owner: chrs
--

CREATE TABLE employers_logs (
    pin text NOT NULL,
    log text NOT NULL,
    datecreated timestamp with time zone
);


ALTER TABLE employers_logs OWNER TO chrs;

--
-- Name: plans; Type: TABLE; Schema: public; Owner: chrs
--

CREATE TABLE plans (
    pk integer NOT NULL,
    plan text NOT NULL,
    archived boolean DEFAULT false
);


ALTER TABLE plans OWNER TO chrs;

--
-- Name: plans_pk_seq; Type: SEQUENCE; Schema: public; Owner: chrs
--

CREATE SEQUENCE plans_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE plans_pk_seq OWNER TO chrs;

--
-- Name: plans_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chrs
--

ALTER SEQUENCE plans_pk_seq OWNED BY plans.pk;


--
-- Name: prices; Type: TABLE; Schema: public; Owner: chrs
--

CREATE TABLE prices (
    pk integer NOT NULL,
    type text NOT NULL,
    currencies_pk integer,
    price numeric NOT NULL,
    archived boolean DEFAULT false
);


ALTER TABLE prices OWNER TO chrs;

--
-- Name: prices_pk_seq; Type: SEQUENCE; Schema: public; Owner: chrs
--

CREATE SEQUENCE prices_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE prices_pk_seq OWNER TO chrs;

--
-- Name: prices_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chrs
--

ALTER SEQUENCE prices_pk_seq OWNED BY prices.pk;


--
-- Name: statuses; Type: TABLE; Schema: public; Owner: chrs
--

CREATE TABLE statuses (
    pk integer NOT NULL,
    status text NOT NULL,
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

ALTER TABLE ONLY currencies ALTER COLUMN pk SET DEFAULT nextval('currencies_pk_seq'::regclass);


--
-- Name: pk; Type: DEFAULT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY employers_bucket ALTER COLUMN pk SET DEFAULT nextval('employers_bucket_pk_seq'::regclass);


--
-- Name: pk; Type: DEFAULT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY plans ALTER COLUMN pk SET DEFAULT nextval('plans_pk_seq'::regclass);


--
-- Name: pk; Type: DEFAULT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY prices ALTER COLUMN pk SET DEFAULT nextval('prices_pk_seq'::regclass);


--
-- Name: pk; Type: DEFAULT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY statuses ALTER COLUMN pk SET DEFAULT nextval('statuses_pk_seq'::regclass);


--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: chrs
--

COPY accounts (pin, password) FROM stdin;
1	c4ca4238a0b923820dcc509a6f75849b
\.


--
-- Data for Name: candidates; Type: TABLE DATA; Schema: public; Owner: chrs
--

COPY candidates (pin, first_name, last_name) FROM stdin;
88N2R2	Rafael	Pascual
\.


--
-- Data for Name: candidates_accounts; Type: TABLE DATA; Schema: public; Owner: chrs
--

COPY candidates_accounts (pin, email_address, password) FROM stdin;
88N2R2	rpascual0812@gmail.com	c4ca4238a0b923820dcc509a6f75849b
\.


--
-- Data for Name: credits; Type: TABLE DATA; Schema: public; Owner: chrs
--

COPY credits (pin, available) FROM stdin;
1	600
\.


--
-- Data for Name: credits_log; Type: TABLE DATA; Schema: public; Owner: chrs
--

COPY credits_log (pin, log, datecreated) FROM stdin;
\.


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
-- Data for Name: employers; Type: TABLE DATA; Schema: public; Owner: chrs
--

COPY employers (pin, name, currencies_pk, plans_pk) FROM stdin;
1	Accenture Phils.	1	1
\.


--
-- Data for Name: employers_bucket; Type: TABLE DATA; Schema: public; Owner: chrs
--

COPY employers_bucket (pk, pin, applicant_id, datecreated) FROM stdin;
1	1	KR1984	2016-06-05 22:50:37.676483+08
3	1	A8776V	2016-06-05 22:51:07.500356+08
6	1	P2621L	2016-06-06 15:22:31.114377+08
7	1	88N2R2	2016-06-10 15:12:42.799098+08
8	1	16T7S2	2016-06-20 00:03:25.348576+08
\.


--
-- Name: employers_bucket_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: chrs
--

SELECT pg_catalog.setval('employers_bucket_pk_seq', 8, true);


--
-- Data for Name: employers_logs; Type: TABLE DATA; Schema: public; Owner: chrs
--

COPY employers_logs (pin, log, datecreated) FROM stdin;
1	Added new candidate to bucket	\N
\.


--
-- Data for Name: plans; Type: TABLE DATA; Schema: public; Owner: chrs
--

COPY plans (pk, plan, archived) FROM stdin;
1	Standard	f
2	Premium	f
\.


--
-- Name: plans_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: chrs
--

SELECT pg_catalog.setval('plans_pk_seq', 2, true);


--
-- Data for Name: prices; Type: TABLE DATA; Schema: public; Owner: chrs
--

COPY prices (pk, type, currencies_pk, price, archived) FROM stdin;
1	Standard	1	5000.00	f
2	Standard	2	120.00	f
3	Premium	1	15000.00	f
4	Premium	2	350.00	f
5	CV	1	100.00	f
6	CV	2	2.00	f
\.


--
-- Name: prices_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: chrs
--

SELECT pg_catalog.setval('prices_pk_seq', 6, true);


--
-- Data for Name: statuses; Type: TABLE DATA; Schema: public; Owner: chrs
--

COPY statuses (pk, status, archived) FROM stdin;
1	Currently looking for a job	f
\.


--
-- Name: statuses_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: chrs
--

SELECT pg_catalog.setval('statuses_pk_seq', 1, true);


--
-- Name: candidates_pkey; Type: CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY candidates
    ADD CONSTRAINT candidates_pkey PRIMARY KEY (pin);


--
-- Name: credits_pkey; Type: CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY credits
    ADD CONSTRAINT credits_pkey PRIMARY KEY (pin);


--
-- Name: currencies_pkey; Type: CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY currencies
    ADD CONSTRAINT currencies_pkey PRIMARY KEY (pk);


--
-- Name: employers_bucket_pkey; Type: CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY employers_bucket
    ADD CONSTRAINT employers_bucket_pkey PRIMARY KEY (pk);


--
-- Name: employers_pkey; Type: CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY employers
    ADD CONSTRAINT employers_pkey PRIMARY KEY (pin);


--
-- Name: plans_pkey; Type: CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY plans
    ADD CONSTRAINT plans_pkey PRIMARY KEY (pk);


--
-- Name: prices_pkey; Type: CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY prices
    ADD CONSTRAINT prices_pkey PRIMARY KEY (pk);


--
-- Name: statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY statuses
    ADD CONSTRAINT statuses_pkey PRIMARY KEY (pk);


--
-- Name: accounts_pin; Type: INDEX; Schema: public; Owner: chrs
--

CREATE UNIQUE INDEX accounts_pin ON accounts USING btree (pin);


--
-- Name: candidates_accounts_email_address; Type: INDEX; Schema: public; Owner: chrs
--

CREATE UNIQUE INDEX candidates_accounts_email_address ON candidates_accounts USING btree (email_address);


--
-- Name: candidates_accounts_pin; Type: INDEX; Schema: public; Owner: chrs
--

CREATE UNIQUE INDEX candidates_accounts_pin ON candidates_accounts USING btree (pin);


--
-- Name: credits_pin; Type: INDEX; Schema: public; Owner: chrs
--

CREATE UNIQUE INDEX credits_pin ON credits USING btree (pin);


--
-- Name: employers_bucket_pin; Type: INDEX; Schema: public; Owner: chrs
--

CREATE UNIQUE INDEX employers_bucket_pin ON employers_bucket USING btree (pin, applicant_id);


--
-- Name: employers_name; Type: INDEX; Schema: public; Owner: chrs
--

CREATE UNIQUE INDEX employers_name ON employers USING btree (name);


--
-- Name: plans_plan; Type: INDEX; Schema: public; Owner: chrs
--

CREATE UNIQUE INDEX plans_plan ON plans USING btree (plan);


--
-- Name: prices_type; Type: INDEX; Schema: public; Owner: chrs
--

CREATE UNIQUE INDEX prices_type ON prices USING btree (type, currencies_pk);


--
-- Name: statuses_status; Type: INDEX; Schema: public; Owner: chrs
--

CREATE UNIQUE INDEX statuses_status ON statuses USING btree (status);


--
-- Name: accounts_pin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_pin_fkey FOREIGN KEY (pin) REFERENCES employers(pin);


--
-- Name: candidates_accounts_pin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY candidates_accounts
    ADD CONSTRAINT candidates_accounts_pin_fkey FOREIGN KEY (pin) REFERENCES candidates(pin);


--
-- Name: credits_log_pin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY credits_log
    ADD CONSTRAINT credits_log_pin_fkey FOREIGN KEY (pin) REFERENCES credits(pin);


--
-- Name: credits_pin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY credits
    ADD CONSTRAINT credits_pin_fkey FOREIGN KEY (pin) REFERENCES employers(pin);


--
-- Name: employers_bucket_pin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY employers_bucket
    ADD CONSTRAINT employers_bucket_pin_fkey FOREIGN KEY (pin) REFERENCES employers(pin);


--
-- Name: employers_currencies_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY employers
    ADD CONSTRAINT employers_currencies_pk_fkey FOREIGN KEY (currencies_pk) REFERENCES currencies(pk);


--
-- Name: employers_plans_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY employers
    ADD CONSTRAINT employers_plans_pk_fkey FOREIGN KEY (plans_pk) REFERENCES plans(pk);


--
-- Name: prices_currencies_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chrs
--

ALTER TABLE ONLY prices
    ADD CONSTRAINT prices_currencies_pk_fkey FOREIGN KEY (currencies_pk) REFERENCES currencies(pk);


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

