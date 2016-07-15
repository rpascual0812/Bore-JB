create table confirmation (
  	pk serial primary key,
  	pin text not null,
 	date_created timestamptz default now()
);
alter table confirmation owner to chrs;
create unique index confirmation_pin on confirmation(pin);