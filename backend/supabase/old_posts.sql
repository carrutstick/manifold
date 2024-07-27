-- This file is autogenerated from regen-schema.ts
create table if not exists
  old_posts (
    id text default extensions.uuid_generate_v4 () not null,
    data jsonb not null,
    visibility text,
    group_id text,
    creator_id text,
    created_time timestamp with time zone default now()
  );

-- Foreign Keys
alter table old_posts
add constraint public_old_posts_group_id_fkey foreign key (group_id) references groups (id) on update cascade on delete cascade;

-- Triggers
create trigger post_populate before insert
or
update on public.old_posts for each row
execute function post_populate_cols ();

-- Functions
create
or replace function public.post_populate_cols () returns trigger language plpgsql as $function$ begin 
    if new.data is not null then 
        new.visibility := (new.data)->>'visibility';
        new.group_id := (new.data)->>'groupId';
        new.creator_id := (new.data)->>'creatorId';
    end if;
    return new;
end $function$;

-- Policies
alter table old_posts enable row level security;

drop policy if exists "admin read" on old_posts;

create policy "admin read" on old_posts for
select
  using (true);

-- Indexes
drop index if exists posts_pkey;

create unique index posts_pkey on public.old_posts using btree (id);
