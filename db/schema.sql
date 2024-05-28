create table message (
    id      integer primary key autoincrement,
    content text      not null,
    sent_at timestamp not null default current_timestamp
);

insert into message (content)
values (:message)
returning id, sent_at;

select id, content, sent_at
from message
order by id desc
limit 20;

select id, content, sent_at
from message
where id < :id
order by id desc
limit 20;
