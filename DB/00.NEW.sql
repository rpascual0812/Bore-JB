drop table if exists accounts cascade;
create table accounts (
	pin text primary key not null,
	email_address text not null,
	password text not null,
	usertype text default 'candidate'
);
alter table accounts owner to chrs;
create unique index accounts_pin on accounts(pin);
create unique index accounts_email_address on accounts(email_address);

drop table if exists companies cascade;
create table companies (
	pk serial primary key,
	name text not null,
	logo text
);
alter table companies owner to chrs;
create unique index companies_name on companies(name);

drop table if exists profiles;
create table profiles (
	pin text references accounts(pin),
	profile jsonb not null,
	archived boolean default false
);
alter table profiles owner to chrs;
create unique index profiles_pin on profiles(pin);

drop table if exists profiles_logs;
create table profiles_logs (
	pin text not null,
	log text not null,
	datecreated timestamptz
);
alter table profiles_logs owner to chrs;

drop table if exists messages;
create table messages (
	pk serial primary key,
	sender text references accounts(pin),
	subject text not null,
	message text not null,
	date_created timestamptz default now(),
	archived boolean default false
);
alter table messages owner to chrs;

drop table if exists currencies cascade;
create table currencies(
	pk serial primary key,
	currency text not null default 'PHP',
	archived boolean default false
);
alter table currencies owner to chrs;
create unique index currencies_currency on currencies (currency);

drop table if exists languages cascade;
create table languages(
	pk serial primary key,
	code text not null,
	language text not null,
	archived boolean default false
);
alter table languages owner to chrs;
create unique index languages_code on languages (code);
create unique index languages_language on languages (language);

drop table if exists accounts_others;
create table accounts_others (
	pin text references accounts(pin),
	currencies_pk int references currencies(pk),
	languages_pk int references languages(pk)
);
alter table accounts_others owner to chrs;
create unique index accounts_others_idx on accounts_others (pin);

drop table if exists statuses;
create table statuses
(
	pk serial primary key,
	status text not null,
	seq int not null,
	archived boolean default false
);
alter table statuses owner to chrs;
create unique index status_idx on statuses (status);
create unique index seq_idx on statuses (seq);

drop table if exists job_posts cascade;
create table job_posts
(
	pk serial primary key,
	pin text references accounts(pin),
	type text not null,
	archived boolean default false
);
alter table job_posts owner to chrs;

-- drop table if exists details;
-- create table details
-- (
-- 	pk serial primary key,
-- 	status text not null,
-- 	archived boolean default false
-- );
-- alter table details owner to chrs;

drop table if exists admired_candidates;
create table admired_candidates (
	pk serial primary key,
	pin text references accounts(pin),
	admired_pin text references accounts(pin),
	datecreated timestamptz default now()
);
alter table admired_candidates owner to chrs;
create unique index admired_candidates on admired_candidates (pin, admired_pin);

drop table if exists admired_companies;
create table admired_companies (
	pk serial primary key,
	pin text references accounts(pin),
	companies_pk int references companies(pk),
	datecreated timestamptz default now()
);
alter table admired_companies owner to chrs;
create unique index admired_companies on admired_companies (pin, companies_pk);

drop table if exists admired_job_posts;
create table admired_job_posts (
	pk serial primary key,
	pin text references accounts(pin),
	job_posts_pk int references job_posts(pk),
	datecreated timestamptz default now()
);
alter table admired_job_posts owner to chrs;

drop table if exists notifications;
create table notifications (
	pk serial primary key,
	notification text not null,
	pin text references accounts(pin),
	table_name text not null,
	table_pk integer not null,
	datecreated timestamptz default now()
);
alter table notifications owner to chrs;

-- DEFAULT DATA

insert into accounts
(
	pin,
	email_address,
	password,
	usertype
)
values
(
	'1234-JJ',
	'rpascual0812@gmail.com',
	md5('1'),
	'candidate'
),
(
	'JJ-1234-JJ',
	'rpascual.chrs@gmail.com',
	md5('1'),
	'recruiter'
)
;

insert into currencies 
(
	currency
)
values
(
	'PHP'
),
(
	'USD'
)
;

insert into statuses
(
	status,
	seq
)
values
(
	'Unemployed, willing to start ASAP',
	1
),
(
	'Happily employed',
	2
),
(
	'Currently exploring',
	3
),
(
	'Looking for part-time jobs only',
	4
),
(
	'Looking for internship',
	5
),
(
	'Willing to consider new job offers',
	6
),
(
	'Looking for home-based jobs',
	7
),
(
	'Looking for oversees jobs',
	8
),
(
	'Looking for project-based jobs',
	9
),
(
	'Looking for commission-based jobs',
	10
),
(
	'Looking for consultancy jobs',
	11
),
(
	'Looking for freelance jobs',
	12
),
(
	'Looking for working student jobs',
	13
)
;