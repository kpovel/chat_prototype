create table message (
    id      integer primary key autoincrement,
    content text      not null,
    sent_at timestamp not null default current_timestamp
);

insert into message (content) values ($1);

select id, content, sent_at from message;

