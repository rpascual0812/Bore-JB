create table email_notifications (
	code text primary key,
	email json not null,
	date_created timestamptz default now()
);
alter table email_notifications owner to chrs;
create unique index email_notifications_idx on email_notifications(code);