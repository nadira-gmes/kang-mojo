-- Run this FIRST in Supabase: SQL Editor -> New query -> paste -> Run.

-- 1) Words and greeting (public to read, admin-only to change)
create table if not exists public.words (
  id          text primary key,
  kind        text not null default 'word' check (kind in ('word','greeting')),
  sort        int  not null default 0,
  en          text,
  ind         text,
  su          text not null,
  keys        text[] not null default '{}',
  audio_path  text,
  updated_at  timestamptz not null default now()
);
alter table public.words enable row level security;
drop policy if exists "words readable by everyone" on public.words;
create policy "words readable by everyone" on public.words for select using (true);
drop policy if exists "admin writes words" on public.words;
create policy "admin writes words" on public.words for all to authenticated using ((select auth.uid()) is not null) with check ((select auth.uid()) is not null);

-- 2) Optional anonymous quiz results (no names, no audio, no device info)
create table if not exists public.quiz_results (
  id          bigint generated always as identity primary key,
  created_at  timestamptz not null default now(),
  level       int  not null check (level between 1 and 3),
  score       int  not null check (score >= 0),
  total       int  not null check (total > 0),
  lang        text check (lang in ('en','id')),
  check (score <= total)
);
alter table public.quiz_results enable row level security;
drop policy if exists "anyone can add a result" on public.quiz_results;
create policy "anyone can add a result" on public.quiz_results for insert to anon, authenticated with check (level between 1 and 3 and total > 0 and score >= 0 and score <= total);
drop policy if exists "admin reads results" on public.quiz_results;
create policy "admin reads results" on public.quiz_results for select to authenticated using ((select auth.uid()) is not null);

-- 4) Starting words. The Sundanese texts are placeholders: have Sundanese speakers check them.
insert into public.words (id, kind, sort, en, ind, su, keys) values
 ('greet',    'greeting', 0,  null,             null,            'Waalaikumsalam',  '{}'),
 ('morning',  'word', 1,  'good morning',   'selamat pagi',  'Wilujeng énjing', array['good morning','selamat pagi']),
 ('afternoon','word', 2,  'good afternoon', 'selamat siang', 'Wilujeng siang',  array['good afternoon','selamat siang']),
 ('night',    'word', 3,  'good night',     'selamat malam', 'Wilujeng wengi',  array['good night','selamat malam']),
 ('eat',      'word', 4,  'eat',            'makan',         'Tuang',           array['eat','eating','makan']),
 ('drink',    'word', 5,  'drink',          'minum',         'Ngaleueut',          array['drink','drinking','minum']),
 ('write',    'word', 6,  'write',          'menulis',       'Nulis',           array['write','writing','menulis','tulis']),
 ('read',     'word', 7,  'read',           'membaca',       'Maca',            array['read','reading','membaca','baca']),
 ('thanks',   'word', 8,  'thank you',      'terima kasih',  'Hatur nuhun',     array['thank you','thanks','terima kasih']),
 ('water',    'word', 9,  'water',          'air',           'Cai',             array['water']),
 ('yes',      'word', 10, 'yes',            'ya',            'Muhun',            array['yes','yeah'])
on conflict (id) do nothing;
