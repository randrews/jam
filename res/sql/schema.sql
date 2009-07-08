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

create table files_tags (
       id integer primary key,
       file_id integer,
       tag_id integer,
       note text,
       tagged_by text,
       created_at datetime,
       updated_at datetime
);

create index files_path_index on files(path);
create index files_tags_file_id_index on files_tags(file_id);
create index files_tags_tag_id_index on files_tags(tag_id);