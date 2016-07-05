create table candidates
(
    pin text not null primary key,
    first_name text not null,
    last_name text not null
);

alter table candidates owner to chrs;

insert into candidates
(
	pin,
	first_name,
	last_name
)
values
(
	'88N2R2',
	'Rafael',
	'Pascual'
);

alter table candidates_accounts add foreign key (pin) references candidates(pin);