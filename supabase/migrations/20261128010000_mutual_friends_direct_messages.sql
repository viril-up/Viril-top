-- Mutual-friend gate for Viril direct messages.
create table if not exists public.friend_requests (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid not null references auth.users(id) on delete cascade,
  recipient_id uuid not null references auth.users(id) on delete cascade,
  status text not null default 'pending' check (status in ('pending','accepted','rejected','cancelled')),
  created_at timestamptz not null default now(),
  responded_at timestamptz,
  constraint friend_requests_not_self check (requester_id <> recipient_id),
  constraint friend_requests_pair_unique unique (requester_id, recipient_id)
);
create index if not exists friend_requests_recipient_status_idx
  on public.friend_requests(recipient_id, status, created_at desc);
create index if not exists friend_requests_requester_status_idx
  on public.friend_requests(requester_id, status, created_at desc);

create table if not exists public.friendships (
  user_low uuid not null references auth.users(id) on delete cascade,
  user_high uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_low, user_high),
  constraint friendships_ordered check (user_low < user_high)
);
create index if not exists friendships_high_idx on public.friendships(user_high);

alter table public.friend_requests enable row level security;
alter table public.friendships enable row level security;
revoke all on public.friend_requests, public.friendships from anon, authenticated;
grant select on public.friend_requests, public.friendships to authenticated;

drop policy if exists friend_requests_read_participant on public.friend_requests;
create policy friend_requests_read_participant on public.friend_requests
for select to authenticated
using (requester_id = (select auth.uid()) or recipient_id = (select auth.uid()));

drop policy if exists friendships_read_member on public.friendships;
create policy friendships_read_member on public.friendships
for select to authenticated
using ((select auth.uid()) = user_low or (select auth.uid()) = user_high);

create or replace function public.viril_send_friend_request(p_recipient_id uuid)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user uuid := auth.uid();
  v_id uuid;
  v_low uuid;
  v_high uuid;
begin
  if v_user is null or (auth.jwt() ->> 'is_anonymous') = 'true' then
    raise exception 'Authentication required';
  end if;
  if p_recipient_id is null or p_recipient_id = v_user then
    raise exception 'Invalid recipient';
  end if;
  if not exists (select 1 from public.profiles p where p.user_id = p_recipient_id) then
    raise exception 'User not found';
  end if;
  v_low := least(v_user, p_recipient_id);
  v_high := greatest(v_user, p_recipient_id);
  if exists (select 1 from public.friendships f where f.user_low = v_low and f.user_high = v_high) then
    raise exception 'Already friends';
  end if;

  -- If the other user already requested us, accept that request and form a mutual friendship.
  update public.friend_requests
     set status = 'accepted', responded_at = now()
   where requester_id = p_recipient_id and recipient_id = v_user and status = 'pending';
  if found then
    insert into public.friendships(user_low, user_high)
    values (v_low, v_high) on conflict do nothing;
    insert into public.friend_requests(requester_id, recipient_id, status, responded_at)
    values (v_user, p_recipient_id, 'accepted', now())
    on conflict (requester_id, recipient_id) do update
      set status = 'accepted', responded_at = now();
    return null;
  end if;

  insert into public.friend_requests(requester_id, recipient_id, status)
  values (v_user, p_recipient_id, 'pending')
  on conflict (requester_id, recipient_id) do update
    set status = 'pending', created_at = now(), responded_at = null
    where public.friend_requests.status in ('rejected','cancelled')
  returning id into v_id;
  if v_id is null then
    raise exception 'Friend request already pending or processed';
  end if;
  return v_id;
end;
$$;

create or replace function public.viril_respond_friend_request(p_request_id uuid, p_accept boolean)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user uuid := auth.uid();
  v_request public.friend_requests%rowtype;
  v_low uuid;
  v_high uuid;
begin
  if v_user is null or (auth.jwt() ->> 'is_anonymous') = 'true' then
    raise exception 'Authentication required';
  end if;
  select * into v_request from public.friend_requests
   where id = p_request_id and recipient_id = v_user and status = 'pending'
   for update;
  if not found then raise exception 'Pending request not found'; end if;

  update public.friend_requests
     set status = case when p_accept then 'accepted' else 'rejected' end,
         responded_at = now()
   where id = p_request_id;

  if p_accept then
    v_low := least(v_request.requester_id, v_request.recipient_id);
    v_high := greatest(v_request.requester_id, v_request.recipient_id);
    insert into public.friendships(user_low, user_high)
    values (v_low, v_high) on conflict do nothing;
  end if;
  return p_accept;
end;
$$;

create or replace function public.viril_remove_friend(p_friend_id uuid)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user uuid := auth.uid();
begin
  if v_user is null or (auth.jwt() ->> 'is_anonymous') = 'true' then
    raise exception 'Authentication required';
  end if;
  delete from public.friendships
   where user_low = least(v_user, p_friend_id)
     and user_high = greatest(v_user, p_friend_id);
  return found;
end;
$$;

create or replace function public.viril_search_users(p_query text)
returns table(user_id uuid, public_id text, nickname text, full_name text, avatar_url text)
language sql
stable
security invoker
set search_path = ''
as $$
  select p.user_id, p.public_id, p.nickname, p.full_name, p.avatar_url
  from public.profiles p
  where auth.uid() is not null
    and (p.public_id = trim(both from p_query)
      or lower(p.nickname) like '%' || lower(trim(both from p_query)) || '%')
    and p.user_id <> auth.uid()
  order by case when p.public_id = trim(both from p_query) then 0 else 1 end,
           p.nickname
  limit 30;
$$;

create or replace function public.viril_create_dm(p_friend_id uuid)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user uuid := auth.uid();
  v_low uuid;
  v_high uuid;
  v_conversation uuid;
begin
  if v_user is null or (auth.jwt() ->> 'is_anonymous') = 'true' then
    raise exception 'Authentication required';
  end if;
  if p_friend_id is null or p_friend_id = v_user then
    raise exception 'Invalid friend';
  end if;
  v_low := least(v_user, p_friend_id);
  v_high := greatest(v_user, p_friend_id);
  if not exists (select 1 from public.friendships f where f.user_low = v_low and f.user_high = v_high) then
    raise exception 'Mutual friendship required';
  end if;

  select c.id into v_conversation
  from public.dm_conversations c
  where exists (select 1 from public.dm_conversation_members m where m.conversation_id = c.id and m.user_id = v_user)
    and exists (select 1 from public.dm_conversation_members m where m.conversation_id = c.id and m.user_id = p_friend_id)
    and (select count(*) from public.dm_conversation_members m where m.conversation_id = c.id) = 2
  order by c.created_at
  limit 1;

  if v_conversation is null then
    insert into public.dm_conversations(created_by) values (v_user)
    returning id into v_conversation;
    insert into public.dm_conversation_members(conversation_id, user_id)
    values (v_conversation, v_user), (v_conversation, p_friend_id);
  end if;
  return v_conversation;
end;
$$;

revoke all on function public.viril_send_friend_request(uuid) from public, anon;
revoke all on function public.viril_respond_friend_request(uuid, boolean) from public, anon;
revoke all on function public.viril_remove_friend(uuid) from public, anon;
revoke all on function public.viril_create_dm(uuid) from public, anon;
revoke all on function public.viril_search_users(text) from public, anon;
grant execute on function public.viril_send_friend_request(uuid) to authenticated;
grant execute on function public.viril_respond_friend_request(uuid, boolean) to authenticated;
grant execute on function public.viril_remove_friend(uuid) to authenticated;
grant execute on function public.viril_create_dm(uuid) to authenticated;
grant execute on function public.viril_search_users(text) to authenticated;

-- Keep the existing DM tables and messages; only ensure Realtime publication membership.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'dm_messages'
  ) then
    alter publication supabase_realtime add table public.dm_messages;
  end if;
end $$;
