create table currencies(
	pk serial primary key,
	currency text not null default 'PHP',
	archived boolean default false
);
alter table currencies owner to chrs;
create unique index currencies_currency on currencies (currency);

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

create table prices (
	pk serial primary key,
	type text not null,
	currencies_pk int references currencies(pk),
	price numeric not null,
	archived boolean default false
);
alter table prices owner to chrs;
create unique index prices_type on prices (type, currencies_pk);

insert into prices 
(
	type,
	currencies_pk,
	price
)
values
(
	'Standard',
	1,
	5000.00
),
(
	'Standard',
	2,
	120.00
),
(
	'Premium',
	1,
	15000.00
),
(
	'Premium',
	2,
	350.00
),
(
	'CV',
	1,
	100.00
),
(
	'CV',
	2,
	2.00
)
;

create table statuses (
	pk serial primary key,
	status text not null,
	archived boolean default false
);
alter table statuses owner to chrs;
create unique index statuses_status on statuses (status);

insert into statuses
(
	status
)
values
(
	'Currently looking for a job'
);

create table plans (
	pk serial primary key,
	plan text not null,
	archived boolean default false
);
alter table plans owner to chrs;
create unique index plans_plan on plans (plan);

create table employers (
	pin text not null primary key,
	name text not null,
	currencies_pk int references currencies(pk),
	plans_pk int references plans(pk)
);
alter table employers owner to chrs;
create unique index employers_name on employers (name);

create table employers_logs (
	pin text not null,
	log text not null,
	datecreated timestamptz
);
alter table employers_logs owner to chrs;

create table accounts (
	pin text not null references employers(pin),
	password text not null
);
alter table accounts owner to chrs;
create unique index accounts_pin on accounts (pin);

create table credits(
	pin text primary key references employers(pin),
	available numeric default 0
);
alter table credits owner to chrs;
create unique index credits_pin on credits (pin);

create table credits_log (
	pin text references credits (pin),
	log text not null,
	datecreated timestamptz default now()
);
alter table credits_log owner to chrs;

create table employers_bucket(
	pk serial primary key,
	pin text not null references employers(pin),
	applicant_id text not null,
	datecreated timestamptz default now()
);
alter table employers_bucket owner to chrs;
create unique index employers_bucket_pin on employers_bucket (pin, applicant_id);

create table candidates (
	pin text not null primary key,
	firstname text not null,
	middlename text not null,
	lastname text not null,
	nameextension text not null,
	statuses_pk int references statuses(pk)
);
alter table candidates owner to chrs;
create unique index candidates_pin on candidates (pin);

create table candidates_accounts (
	pin text not null,
	email_address text not null,
	password text not null
);
alter table candidates_accounts owner to chrs;
create unique index candidates_accounts_pin on candidates_accounts (pin);
create unique index candidates_accounts_email_address on candidates_accounts (email_address);

create table candidates_log(
	pin text not null references candidates(pin),
	log text not null
	datecreated timestamptz default now()
);

create table notifications_employer(
	
);



