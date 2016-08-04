create table views(
	type text not null,
	pin text references accounts(pin),
	date_created timestamptz default now()
);
alter table views owner to chrs;