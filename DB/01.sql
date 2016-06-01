create table employers (
	pin text not null primary key,
	name text not null
);
alter table employers owner to chrs;

create table accounts (
	pin text not null references employers(pin),
	password text not null
);
alter table accounts owner to chrs;

create table statuses (
	pk serial primay key,
	status text not null,
	archived boolean default false
);
alter table statuses owner to chrs;

create table candidates (
	pin text not null primary key,
	firstname text not null,
	middlename text not null,
	lastname text not null,
	nameextension text not null,
	statuses_pk int references statuses(pk)
);
alter table candidates owner to chrs;

create table candidates_log(
	pin text not null references candidates(pin),
	log text not null
	datecreated timestamptz default now()
);

create table notifications_employer(
	
);