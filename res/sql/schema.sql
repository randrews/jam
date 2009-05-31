create table files (
       id integer primary key,
       path text,
       created_at datetime,
       updated_at datetime
);

create table tags (
       id integer primary key,
       name text unique,
       created_at datetime,
       updated_at datetime       
);

create table file_tags (
       id integer primary key,
       file_id integer,
       tag_id integer,
       note text,
       tagged_by text,
       created_at datetime,
       updated_at datetime
)