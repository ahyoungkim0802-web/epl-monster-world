-- =====================================================================
-- MONSTER WORLD · 데이터베이스 v2.2  (Supabase / PostgreSQL) — 여러 학원용
-- v2.2: 칭찬모아 기준(출석·태도·AR·NELT 등, 차감 포함), 선생님이 활동 목록을 직접 편집, 1000 XP = 1레벨
-- v2.3: 마을 지도(mw_map, map_zones), 진화 단계 이름 Rookie · Elite · Legend
-- v2.4: 지도 이름 표시 설정(map_name_mode: nickname·masked·real·hidden) — 서버에서 가려서 보냄
-- v2.5: 스탯(독해·작문·어휘·성실)과 스탯 목표 달성 몬스터, 새 몬스터 3종, 선생님 선물은 시즌 한정 + 사유 필수
-- v2.13: 담당 선생님 변경(mw_set_teacher, 원장 전용)
-- v2.12: 영어 역량 단계 이름 Speaker → Creator (Reader·Builder·Writer·Creator·Author)
-- v2.11: 책 종류별 1권 완료(독해·구문·문법·라이팅·단어책, 각 200 XP, 선생님 지급)를 추가하고, 학생 요청이던 "교재 1권 완료"를 대신함
-- v2.10: 클래스카드 활동(학생 요청, 50 XP, 어휘) + 연속 보상(streak_rewards): 평일 7일 연속 승인 → 진화석 1개. 주말은 세지도 끊지도 않음
-- v2.9: 원장(관리자) 계정. 선생님 계정은 원장만 보고 바꿀 수 있음. 학원마다 가장 먼저 가입한 선생님이 원장
-- v2.8: 선생님 계정 이름·비밀번호 변경(mw_update_teacher). 퇴사 시 계정을 새 선생님에게 넘길 때 사용
-- v2.7: 진화 보너스. Elite·Legend로 진화하면 그 주 주간 정산의 입력할 포인트에 보너스(기본 500·1000)를 더함(XP 아님)
-- v2.6: 진화 = 레벨 + 진화석. AR +1 → 진화석, NELT +1 → 전설석. Elite: 진화석·전설석 1개 / Legend: 전설석 1개 또는 진화석 2개
-- v2.1: 학생이 스스로 '다 했어요' 요청(mw_self_report), 북라이팅·북퀴즈 활동 추가
-- Supabase > SQL Editor 에 전체를 붙여 넣고 실행합니다. 여러 번 실행해도 안전합니다.
-- 실행 후 학원을 만들 때마다 맨 아래 "학원 만들기" 한 줄을 실행합니다.
--
-- 원칙
--  1) 모든 테이블은 mw_ 로 시작합니다(기존 프로젝트의 다른 테이블과 섞이지 않음).
--  2) 클라이언트는 테이블에 직접 쓰지 못합니다. 모든 변경은 아래 함수(RPC)로만 처리합니다.
--  3) 학원 간 데이터는 서버에서 분리됩니다. 선생님은 자기 학원 학생만 보고 승인할 수 있습니다.
-- =====================================================================

-- ---------- 1. 테이블 ----------
create table if not exists mw_academies (
  id uuid primary key default gen_random_uuid(),
  code text unique not null check (code ~ '^[a-z0-9]{3,12}$'),   -- 학원 코드(로그인에 사용)
  name text not null,
  active boolean not null default true,          -- false 로 바꾸면 해당 학원 이용 중지
  max_students int not null default 100,         -- 활성 학생 정원(요금제용)
  created_at timestamptz not null default now()
);

create table if not exists mw_academy_secrets (   -- 클라이언트에서 절대 읽을 수 없음
  academy_id uuid primary key references mw_academies(id) on delete cascade,
  teacher_code text not null
);

create table if not exists mw_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  academy_id uuid references mw_academies(id),
  login_id text not null,
  display_name text not null default '',
  role text not null default 'student' check (role in ('student','teacher')),
  active boolean not null default false,
  teacher_id uuid references mw_profiles(id),
  epl_stage text not null default '',
  active_monster uuid,
  created_at timestamptz not null default now()
);

create table if not exists mw_species (           -- 몬스터 종류는 모든 학원이 공유
  id text primary key,
  name text not null,
  animal text not null default '',
  concept text not null default '',
  rarity text not null default 'common' check (rarity in ('starter','common','rare','seasonal')),
  season text,
  enabled boolean not null default true,
  sort int not null default 0,
  art jsonb not null default '{}'::jsonb,      -- 임시 아트(SVG) 설정: 색상·귀·꼬리·문양
  forms jsonb not null default '[]'::jsonb,    -- 진화 형태: [{stage,stage_name,form_name,image_url}]
  branches jsonb                               -- 향후 진화 분기용 (현재 미사용)
);

create table if not exists mw_monsters (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references mw_profiles(id) on delete cascade,
  species_id text not null references mw_species(id),
  nickname text not null default '',
  xp int not null default 0 check (xp >= 0),
  level int not null default 1,
  stage int not null default 1,
  seen_level int not null default 1,
  seen_stage int not null default 1,
  hatched boolean not null default false,
  branch text,
  source text not null default '',
  obtained_at timestamptz not null default now(),
  hatched_at timestamptz,
  unique (student_id, species_id)
);

create table if not exists mw_missions (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references mw_profiles(id) on delete cascade,
  activity text not null,
  title text not null default '',
  xp int not null check (xp between -5000 and 5000),
  due_date date not null default current_date,
  status text not null default 'assigned'
    check (status in ('assigned','requested','approved','rejected','revoked','cancelled')),
  batch_id uuid,
  monster_id uuid references mw_monsters(id),
  created_by uuid references mw_profiles(id),
  created_at timestamptz not null default now(),
  requested_at timestamptz,
  decided_by uuid references mw_profiles(id),
  decided_at timestamptz,
  note text,
  unique (student_id, batch_id)   -- 같은 배정/지급 버튼을 두 번 눌러도 한 번만 생성
);
create index if not exists mw_missions_student on mw_missions(student_id, status);
-- v2.2: 차감(음수)과 큰 보상(AR·NELT)을 위해 XP 범위를 -5000~5000으로 넓힘
alter table mw_missions drop constraint if exists mw_missions_xp_check;
alter table mw_missions add constraint mw_missions_xp_check check (xp between -5000 and 5000);

create table if not exists mw_books (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references mw_profiles(id) on delete cascade,
  title text not null,
  title_key text not null,
  book_level text,            -- 향후: AR/Lexile 등 난이도
  comprehension int,          -- 향후: 이해도 평가(0~100)
  status text not null default 'requested'
    check (status in ('requested','approved','rejected','revoked')),
  monster_id uuid references mw_monsters(id),
  created_at timestamptz not null default now(),
  decided_by uuid references mw_profiles(id),
  decided_at timestamptz,
  note text,
  unique (student_id, title_key)  -- 같은 책 반복 등록 방지
);

create table if not exists mw_ledger (            -- XP 거래 내역 (수정·삭제 없음, 정정은 새 행으로)
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references mw_profiles(id) on delete cascade,
  monster_id uuid not null references mw_monsters(id) on delete cascade,
  amount int not null,
  kind text not null check (kind in ('grant','revoke','adjust')),
  reason text not null default '',
  mission_id uuid references mw_missions(id),
  book_id uuid references mw_books(id),
  level_after int not null default 1,
  actor uuid references mw_profiles(id),
  created_at timestamptz not null default now()
);
create unique index if not exists mw_ledger_mission_once on mw_ledger(mission_id, kind) where mission_id is not null;
create unique index if not exists mw_ledger_book_once on mw_ledger(book_id, kind) where book_id is not null;
create index if not exists mw_ledger_student on mw_ledger(student_id, created_at desc);

create table if not exists mw_badges (
  student_id uuid not null references mw_profiles(id) on delete cascade,
  badge_id text not null,
  earned_at timestamptz not null default now(),
  primary key (student_id, badge_id)
);

create table if not exists mw_rewards (           -- 보상 지급 기록(중복 지급 방지)
  student_id uuid not null references mw_profiles(id) on delete cascade,
  reward_key text not null,
  granted_at timestamptz not null default now(),
  primary key (student_id, reward_key)
);

create table if not exists mw_settings (          -- academy_id 가 비어 있으면 전체 기본값
  academy_id uuid references mw_academies(id) on delete cascade,
  key text not null,
  value jsonb not null,
  updated_by uuid,
  updated_at timestamptz not null default now()
);

create table if not exists mw_settlements (       -- 주간 포인트 입력 완료 표시
  student_id uuid not null references mw_profiles(id) on delete cascade,
  week_start date not null,
  done_by uuid references mw_profiles(id),
  done_at timestamptz not null default now(),
  primary key (student_id, week_start)
);

create table if not exists mw_audit (             -- 변경 이력
  id bigint generated always as identity primary key,
  academy_id uuid,
  actor uuid,
  action text not null,
  target uuid,
  detail jsonb not null default '{}'::jsonb,
  at timestamptz not null default now()
);

-- ---------- 1-2. v1(단일 학원)에서 올라오는 경우의 구조 변경 ----------
alter table mw_profiles add column if not exists academy_id uuid references mw_academies(id);
alter table mw_profiles drop constraint if exists mw_profiles_login_id_key;
alter table mw_profiles drop constraint if exists mw_profiles_epl_stage_check;
alter table mw_profiles alter column epl_stage set default '';
create unique index if not exists mw_profiles_login on mw_profiles(academy_id, login_id);
alter table mw_settings add column if not exists academy_id uuid references mw_academies(id) on delete cascade;
alter table mw_settings drop constraint if exists mw_settings_pkey;
create unique index if not exists mw_settings_uk
  on mw_settings(coalesce(academy_id, '00000000-0000-0000-0000-000000000000'::uuid), key);
alter table mw_audit add column if not exists academy_id uuid;

do $$   -- v1 데이터가 있으면 'epl' 학원으로 묶음
declare v_ac uuid; v_code text;
begin
  if exists (select 1 from mw_profiles where academy_id is null) then
    insert into mw_academies(code, name) values ('epl', 'EPL 영어학원') on conflict (code) do nothing;
    select id into v_ac from mw_academies where code = 'epl';
    update mw_profiles set academy_id = v_ac where academy_id is null;
    if to_regclass('public.mw_secrets') is not null then
      execute 'select value from mw_secrets where key = ''teacher_code''' into v_code;
    end if;
    insert into mw_academy_secrets(academy_id, teacher_code) values (v_ac, coalesce(v_code, 'EPL-CHANGE-ME'))
    on conflict (academy_id) do nothing;
  end if;
end $$;

-- ---------- 2. 기본 데이터 ----------
-- v2.2 기준 변경(한 번만 실행): 예전 기본값 그대로인 공통 설정만 바꾸고, 학원이 직접 바꾼 값은 건드리지 않습니다.
do $$
begin
  if exists (select 1 from mw_settings where academy_id is null)
     and not exists (select 1 from mw_settings where academy_id is null and key = 'activity_list') then
    update mw_settings set value = '1000'::jsonb where academy_id is null and key = 'xp_per_level' and value = '300'::jsonb;
    update mw_settings set value = '800'::jsonb where academy_id is null and key = 'weekly_xp_goal' and value = '300'::jsonb;
    update mw_settings set value = value || '{"vocab":50}'::jsonb where academy_id is null and key = 'activity_xp' and value->'vocab' = '30'::jsonb;
    update mw_settings set value = '["vocab","textbook","bookwriting","bookquiz","homework"]'::jsonb
     where academy_id is null and key = 'self_report_acts' and value = '["vocab","bookwriting","bookquiz","homework"]'::jsonb;
  end if;
end $$;

do $$
declare d record;
begin
  for d in select * from jsonb_each('{
    "xp_per_level": 1000, "max_level": 50, "evolve_levels": [15,35], "evolve_bonus": [500,1000], "weekly_xp_goal": 800, "point_rate": 0,
    "point_name": "포인트",
    "stages": ["Reader","Builder","Writer","Creator","Author"],
    "activity_xp": {"classcard":50,"book_reading":200,"book_syntax":200,"book_grammar":200,"book_writing":200,"book_vocab":200,"reading":20,"attend":50,"late":-10,"good":50,"bad":-100,"vocab":50,"textbook":200,"bookwriting":30,"bookquiz":30,"homework":20,"praise":100,"ar":1000,"nelt":3000,"syntax":30,"grammar":30,"writing":50,"challenge":100},
    "activity_labels": {"classcard":"클래스카드 학습","book_reading":"독해책 1권 완료","book_syntax":"구문책 1권 완료","book_grammar":"문법책 1권 완료","book_writing":"라이팅책 1권 완료","book_vocab":"단어책 1권 완료","reading":"원서 읽기 완료","attend":"출석","late":"지각","good":"태도 Good","bad":"태도 Bad","vocab":"단어 테스트 통과","textbook":"교재 1권 완료","bookwriting":"북라이팅 완료","bookquiz":"북퀴즈 통과","homework":"숙제 성실 완료","praise":"Special Praise","ar":"AR 북레벨 +1","nelt":"NELT 레벨 +1","syntax":"Syntax Builder 완료","grammar":"Grammar 완료","writing":"Writing Builder 완료","challenge":"특별 영어 챌린지"},
    "activity_list": ["attend","late","good","bad","vocab","classcard","book_reading","book_syntax","book_grammar","book_writing","book_vocab","bookwriting","bookquiz","homework","praise","ar","nelt","syntax","grammar","writing","challenge"],
    "self_report_acts": ["vocab","classcard","bookwriting","bookquiz","homework"],
    "map_name_mode": "nickname",
    "map_zones": [{"from":1,"name":"Starter Village","ko":"시작의 마을"},{"from":10,"name":"Whisper Woods","ko":"속삭이는 숲"},{"from":20,"name":"Gale Canyon","ko":"바람의 협곡"},{"from":30,"name":"Starlight Harbor","ko":"별빛 항구"},{"from":40,"name":"Ember Citadel","ko":"불꽃 성채"}],
    "activity_stones": {"ar":"evo","nelt":"legend"},
    "streak_rewards": {"classcard":{"days":7,"stone":"evo"}},
    "activity_stats": {"classcard":"vocab","book_reading":"read","book_syntax":"read","book_grammar":"write","book_writing":"write","book_vocab":"vocab","reading":"read","bookquiz":"read","ar":"read","textbook":"read","bookwriting":"write","writing":"write","grammar":"write","vocab":"vocab","syntax":"vocab","attend":"grit","homework":"grit","good":"grit","praise":"grit"},
    "stat_rewards": [{"stat":"read","at":1000,"species":"tiddle"},{"stat":"read","at":5000,"species":"aurorix"},{"stat":"write","at":1000,"species":"nimbo"},{"stat":"write","at":5000,"species":"quillo"},{"stat":"vocab","at":1000,"species":"lexi"},{"stat":"vocab","at":5000,"species":"runex"},{"stat":"grit","at":1000,"species":"pebblo"},{"stat":"grit","at":5000,"species":"terron"}],
    "reading_milestones": [{"books":10,"reward":"badge","id":"reader10"},{"books":30,"reward":"badge","id":"reader30"},{"books":50,"reward":"badge","id":"reader50"},{"books":100,"reward":"badge","id":"master_reader"}]
  }'::jsonb) loop
    if not exists (select 1 from mw_settings where academy_id is null and key = d.key) then
      insert into mw_settings(academy_id, key, value) values (null, d.key, d.value);
    end if;
  end loop;
end $$;

-- v2.10: 이미 운영 중인 학원 설정에 클래스카드를 한 번만 추가합니다(이후 선생님이 지워도 다시 넣지 않음).
do $$
begin
  if not exists (select 1 from mw_settings where academy_id is null and key = 'migr_classcard') then
    update mw_settings set value = value || '{"classcard":50}'::jsonb where key = 'activity_xp' and not value ? 'classcard';
    update mw_settings set value = value || '{"classcard":"클래스카드 학습"}'::jsonb where key = 'activity_labels' and not value ? 'classcard';
    update mw_settings set value = value || '{"classcard":"vocab"}'::jsonb where key = 'activity_stats' and not value ? 'classcard';
    update mw_settings set value = value || '["classcard"]'::jsonb where key in ('activity_list','self_report_acts') and not value ? 'classcard';
    insert into mw_settings(academy_id, key, value) values (null, 'migr_classcard', 'true'::jsonb);
  end if;
end $$;

-- v2.11: 책 종류별 1권 완료(선생님 지급)를 한 번만 추가하고, "교재 1권 완료"는 목록과 학생 요청에서 뺍니다(지난 기록은 그대로).
do $$
begin
  if not exists (select 1 from mw_settings where academy_id is null and key = 'migr_books') then
    update mw_settings set value = '{"book_reading":200,"book_syntax":200,"book_grammar":200,"book_writing":200,"book_vocab":200}'::jsonb || value where key = 'activity_xp';
    update mw_settings set value = '{"book_reading":"독해책 1권 완료","book_syntax":"구문책 1권 완료","book_grammar":"문법책 1권 완료","book_writing":"라이팅책 1권 완료","book_vocab":"단어책 1권 완료"}'::jsonb || value where key = 'activity_labels';
    update mw_settings set value = '{"book_reading":"read","book_syntax":"read","book_grammar":"write","book_writing":"write","book_vocab":"vocab"}'::jsonb || value where key = 'activity_stats';
    update mw_settings set value = (value - 'textbook') || '["book_reading","book_syntax","book_grammar","book_writing","book_vocab"]'::jsonb where key = 'activity_list' and not value ? 'book_reading';
    update mw_settings set value = value - 'textbook' where key = 'self_report_acts';
    insert into mw_settings(academy_id, key, value) values (null, 'migr_books', 'true'::jsonb);
  end if;
end $$;

-- v2.12: 역량 단계 Speaker → Creator. 예전 기본값을 그대로 쓰는 설정과, 그 단계에 있던 학생만 바꿉니다.
update mw_profiles p set epl_stage = 'Creator'
 where p.epl_stage = 'Speaker'
   and coalesce((select s.value from mw_settings s where s.academy_id = p.academy_id and s.key = 'stages'),
                (select s.value from mw_settings s where s.academy_id is null and s.key = 'stages'))
       = '["Reader","Builder","Writer","Speaker","Author"]'::jsonb;
update mw_settings set value = '["Reader","Builder","Writer","Creator","Author"]'::jsonb
 where key = 'stages' and value = '["Reader","Builder","Writer","Speaker","Author"]'::jsonb;

-- v2.1 보충: 이미 있는 설정에 새 활동(북라이팅·북퀴즈)만 추가합니다. 학원이 바꾼 값은 그대로 둡니다.
update mw_settings set value = '{"bookwriting":30,"bookquiz":30}'::jsonb || value
 where key = 'activity_xp' and not (value ? 'bookwriting' and value ? 'bookquiz');
update mw_settings set value = '{"bookwriting":"북라이팅 완료","bookquiz":"북퀴즈 통과"}'::jsonb || value
 where key = 'activity_labels' and academy_id is null and not (value ? 'bookwriting' and value ? 'bookquiz');
-- v2.5: 원서 10·30권 보상을 알 → 배지로 (알은 이제 스탯 목표에서 나옴). 예전 기본값 그대로인 경우만 변경
update mw_settings set value = '[{"books":10,"reward":"badge","id":"reader10"},{"books":30,"reward":"badge","id":"reader30"},{"books":50,"reward":"badge","id":"reader50"},{"books":100,"reward":"badge","id":"master_reader"}]'::jsonb
 where key = 'reading_milestones' and value = '[{"books":10,"reward":"egg"},{"books":30,"reward":"rare_egg"},{"books":50,"reward":"badge","id":"reader50"},{"books":100,"reward":"badge","id":"master_reader"}]'::jsonb;

-- v2.2 보충: 칭찬모아 활동의 기본 XP·이름 추가 (이미 있는 값은 유지)
update mw_settings set value = '{"reading":20,"attend":50,"late":-10,"good":50,"bad":-100,"vocab":50,"textbook":200,"bookwriting":30,"bookquiz":30,"homework":20,"praise":100,"ar":1000,"nelt":3000,"syntax":30,"grammar":30,"writing":50,"challenge":100}'::jsonb || value
 where key = 'activity_xp' and not (value ? 'nelt');
update mw_settings set value = '{"reading":"원서 읽기 완료","attend":"출석","late":"지각","good":"태도 Good","bad":"태도 Bad","vocab":"단어 테스트 통과","textbook":"교재 1권 완료","bookwriting":"북라이팅 완료","bookquiz":"북퀴즈 통과","homework":"숙제 성실 완료","praise":"Special Praise","ar":"AR 북레벨 +1","nelt":"NELT 레벨 +1","syntax":"Syntax Builder 완료","grammar":"Grammar 완료","writing":"Writing Builder 완료","challenge":"특별 영어 챌린지"}'::jsonb || value
 where key = 'activity_labels' and academy_id is null and not (value ? 'nelt');

insert into mw_species(id, name, animal, concept, rarity, season, sort, art, forms) values
 ('flamy','FLAMY','불꽃 여우','용기와 도전','starter',null,1,
  '{"body":"#F2A65A","belly":"#FFF3DC","accent":"#E8743B","dark":"#B5522A","ears":"fox","tail":"fox","mark":"flame"}',
  '[{"stage":1,"stage_name":"Rookie","form_name":"Rookie Flamy"},{"stage":2,"stage_name":"Elite","form_name":"Elite Flamy"},{"stage":3,"stage_name":"Legend","form_name":"Legend Flamy"}]'),
 ('lumi','LUMI','별빛 고양이','창의력과 지혜','starter',null,2,
  '{"body":"#B8A7E8","belly":"#F1ECFF","accent":"#7C63C9","dark":"#58439E","ears":"cat","tail":"cat","mark":"star"}',
  '[{"stage":1,"stage_name":"Rookie","form_name":"Rookie Lumi"},{"stage":2,"stage_name":"Elite","form_name":"Elite Lumi"},{"stage":3,"stage_name":"Legend","form_name":"Legend Lumi"}]'),
 ('mochi','MOCHI','숲 토끼','꾸준함과 성장','starter',null,3,
  '{"body":"#B9E4D0","belly":"#F4FFF6","accent":"#6FBF8E","dark":"#3F8F63","ears":"bunny","tail":"puff","mark":"leaf"}',
  '[{"stage":1,"stage_name":"Rookie","form_name":"Rookie Mochi"},{"stage":2,"stage_name":"Elite","form_name":"Elite Mochi"},{"stage":3,"stage_name":"Legend","form_name":"Legend Mochi"}]'),
 ('pebblo','PEBBLO','조약돌 곰','끈기와 집중','common',null,10,
  '{"body":"#C9BCA8","belly":"#F6F0E4","accent":"#8C7B64","dark":"#5F5242","ears":"round","tail":"puff","mark":"stone"}',
  '[{"stage":1,"stage_name":"Rookie","form_name":"Rookie Pebblo"},{"stage":2,"stage_name":"Elite","form_name":"Elite Pebblo"},{"stage":3,"stage_name":"Legend","form_name":"Legend Pebblo"}]'),
 ('nimbo','NIMBO','구름 양','상상과 여유','common',null,11,
  '{"body":"#DCE8F7","belly":"#FFFFFF","accent":"#8FB1DE","dark":"#5A7FB3","ears":"horn","tail":"puff","mark":"cloud"}',
  '[{"stage":1,"stage_name":"Rookie","form_name":"Rookie Nimbo"},{"stage":2,"stage_name":"Elite","form_name":"Elite Nimbo"},{"stage":3,"stage_name":"Legend","form_name":"Legend Nimbo"}]'),
 ('tiddle','TIDDLE','물방울 수달','호기심과 탐구','common',null,12,
  '{"body":"#8FCBE0","belly":"#EAF8FC","accent":"#3F96B8","dark":"#2B6F8C","ears":"round","tail":"drop","mark":"drop"}',
  '[{"stage":1,"stage_name":"Rookie","form_name":"Rookie Tiddle"},{"stage":2,"stage_name":"Elite","form_name":"Elite Tiddle"},{"stage":3,"stage_name":"Legend","form_name":"Legend Tiddle"}]'),
 ('quillo','QUILLO','깃펜 부엉이','글쓰기와 표현','rare',null,20,
  '{"body":"#4E5A85","belly":"#E9E4D4","accent":"#D9B25F","dark":"#28314B","ears":"owl","tail":"none","mark":"quill"}',
  '[{"stage":1,"stage_name":"Rookie","form_name":"Rookie Quillo"},{"stage":2,"stage_name":"Elite","form_name":"Elite Quillo"},{"stage":3,"stage_name":"Legend","form_name":"Legend Quillo"}]'),
 ('aurorix','AURORIX','오로라 사슴','통찰과 품격','rare',null,21,
  '{"body":"#F5A995","belly":"#FFF1EA","accent":"#7FD1C2","dark":"#B86B58","ears":"antler","tail":"puff","mark":"star"}',
  '[{"stage":1,"stage_name":"Rookie","form_name":"Rookie Aurorix"},{"stage":2,"stage_name":"Elite","form_name":"Elite Aurorix"},{"stage":3,"stage_name":"Legend","form_name":"Legend Aurorix"}]'),
 ('lexi','LEXI','글자 다람쥐','어휘와 기억','common',null,13,
  '{"body":"#E9C46A","belly":"#FFF6DA","accent":"#C9772B","dark":"#8A5320","ears":"cat","tail":"fox","mark":"leaf"}',
  '[{"stage":1,"stage_name":"Rookie","form_name":"Rookie Lexi"},{"stage":2,"stage_name":"Elite","form_name":"Elite Lexi"},{"stage":3,"stage_name":"Legend","form_name":"Legend Lexi"}]'),
 ('runex','RUNEX','룬 비룡','언어의 힘','rare',null,22,
  '{"body":"#3E8E8A","belly":"#E2F4EF","accent":"#E3B341","dark":"#21534F","ears":"horn","tail":"fox","mark":"star"}',
  '[{"stage":1,"stage_name":"Rookie","form_name":"Rookie Runex"},{"stage":2,"stage_name":"Elite","form_name":"Elite Runex"},{"stage":3,"stage_name":"Legend","form_name":"Legend Runex"}]'),
 ('terron','TERRON','바위 거북','불굴의 의지','rare',null,23,
  '{"body":"#7D8B6A","belly":"#EEF0E2","accent":"#C46A3A","dark":"#4A5540","ears":"round","tail":"none","mark":"stone"}',
  '[{"stage":1,"stage_name":"Rookie","form_name":"Rookie Terron"},{"stage":2,"stage_name":"Elite","form_name":"Elite Terron"},{"stage":3,"stage_name":"Legend","form_name":"Legend Terron"}]'),
 ('frostie','FROSTIE','눈꽃 여우새','겨울 시즌 한정','seasonal','winter',30,
  '{"body":"#EAF2FA","belly":"#FFFFFF","accent":"#9CC3E8","dark":"#6C93BD","ears":"cat","tail":"fox","mark":"snow"}',
  '[{"stage":1,"stage_name":"Rookie","form_name":"Rookie Frostie"},{"stage":2,"stage_name":"Elite","form_name":"Elite Frostie"},{"stage":3,"stage_name":"Legend","form_name":"Legend Frostie"}]')
on conflict (id) do nothing;

-- v2.3: 진화 단계 이름 변경 (Baby·Explorer·Master → Rookie·Elite·Legend). 이미지 주소 등 다른 값은 유지
update mw_species set forms = replace(replace(replace(forms::text, '"Baby', '"Rookie'), '"Explorer', '"Elite'), '"Master', '"Legend')::jsonb
 where forms::text like '%"Baby%' or forms::text like '%"Explorer%' or forms::text like '%"Master%';

-- v2.9: 원장(관리자) 표시. 학원마다 원장이 없으면 가장 먼저 가입한 선생님을 원장으로 지정합니다.
alter table mw_profiles add column if not exists is_admin boolean not null default false;
update mw_profiles p set is_admin = true
 where p.role = 'teacher'
   and p.id = (select t.id from mw_profiles t where t.academy_id = p.academy_id and t.role = 'teacher' order by t.created_at, t.id limit 1)
   and not exists (select 1 from mw_profiles a where a.academy_id = p.academy_id and a.is_admin);

-- ---------- 3. 권한 (Row Level Security) ----------
create or replace function mw_my_academy() returns uuid
language sql stable security definer set search_path = public as $$
  select academy_id from mw_profiles where id = auth.uid();
$$;

create or replace function mw_is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from mw_profiles p join mw_academies a on a.id = p.academy_id
                  where p.id = auth.uid() and p.role = 'teacher' and p.is_admin and p.active and a.active);
$$;

create or replace function mw_is_teacher() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from mw_profiles p join mw_academies a on a.id = p.academy_id
                  where p.id = auth.uid() and p.role = 'teacher' and p.active and a.active);
$$;

-- 이 학생이 "내 학원" 학생인가 (선생님 전용)
create or replace function mw_same(p_student uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select mw_is_teacher() and exists (select 1 from mw_profiles s
          where s.id = p_student and s.role = 'student' and s.academy_id = mw_my_academy());
$$;

alter table mw_academies       enable row level security;
alter table mw_academy_secrets enable row level security;   -- 정책 없음 = 아무도 읽지 못함
alter table mw_profiles    enable row level security;
alter table mw_species     enable row level security;
alter table mw_monsters    enable row level security;
alter table mw_missions    enable row level security;
alter table mw_books       enable row level security;
alter table mw_ledger      enable row level security;
alter table mw_badges      enable row level security;
alter table mw_rewards     enable row level security;
alter table mw_settings    enable row level security;
alter table mw_settlements enable row level security;
alter table mw_audit       enable row level security;

drop policy if exists mw_academies_read on mw_academies;
create policy mw_academies_read on mw_academies for select to authenticated using (id = mw_my_academy());
drop policy if exists mw_profiles_read on mw_profiles;
create policy mw_profiles_read on mw_profiles for select to authenticated
  using (id = auth.uid() or (mw_is_teacher() and academy_id = mw_my_academy() and (role = 'student' or mw_is_admin())));   -- 다른 선생님 계정은 원장만 봄
drop policy if exists mw_species_read on mw_species;
create policy mw_species_read on mw_species for select to authenticated using (true);
drop policy if exists mw_settings_read on mw_settings;
create policy mw_settings_read on mw_settings for select to authenticated using (academy_id is null or academy_id = mw_my_academy());
drop policy if exists mw_monsters_read on mw_monsters;
create policy mw_monsters_read on mw_monsters for select to authenticated using (student_id = auth.uid() or mw_same(student_id));
drop policy if exists mw_missions_read on mw_missions;
create policy mw_missions_read on mw_missions for select to authenticated using (student_id = auth.uid() or mw_same(student_id));
drop policy if exists mw_books_read on mw_books;
create policy mw_books_read on mw_books for select to authenticated using (student_id = auth.uid() or mw_same(student_id));
drop policy if exists mw_ledger_read on mw_ledger;
create policy mw_ledger_read on mw_ledger for select to authenticated using (student_id = auth.uid() or mw_same(student_id));
drop policy if exists mw_badges_read on mw_badges;
create policy mw_badges_read on mw_badges for select to authenticated using (student_id = auth.uid() or mw_same(student_id));
drop policy if exists mw_rewards_read on mw_rewards;
create policy mw_rewards_read on mw_rewards for select to authenticated using (student_id = auth.uid() or mw_same(student_id));
drop policy if exists mw_settlements_read on mw_settlements;
create policy mw_settlements_read on mw_settlements for select to authenticated using (mw_same(student_id));
drop policy if exists mw_audit_read on mw_audit;
create policy mw_audit_read on mw_audit for select to authenticated using (mw_is_teacher() and academy_id = mw_my_academy());
-- insert/update/delete 정책은 만들지 않습니다 → 클라이언트 직접 쓰기 전면 차단.

grant select on mw_academies, mw_profiles, mw_species, mw_monsters, mw_missions, mw_books, mw_ledger,
  mw_badges, mw_rewards, mw_settings, mw_settlements, mw_audit to authenticated;

-- ---------- 4. 가입 시 프로필 자동 생성 (학원 코드가 맞을 때만) ----------
create or replace function mw_on_signup() returns trigger
language plpgsql security definer set search_path = public as $$
declare v_ac uuid; v_code text := lower(coalesce(new.raw_user_meta_data->>'academy', ''));
begin
  if coalesce(new.raw_user_meta_data->>'mw', '') = 'true' then
    begin
      select id into v_ac from mw_academies where code = v_code and active;
      if v_ac is not null then
        insert into mw_profiles(id, academy_id, login_id, display_name)
        values (new.id, v_ac, split_part(split_part(new.email, '@', 1), '.', 1),
                left(coalesce(new.raw_user_meta_data->>'display_name', ''), 20))
        on conflict do nothing;
      end if;
    exception when others then null;   -- 가입 자체는 막지 않음
    end;
  end if;
  return new;
end $$;
drop trigger if exists mw_on_signup on auth.users;
create trigger mw_on_signup after insert on auth.users for each row execute function mw_on_signup();

-- ---------- 5. 내부 함수 (클라이언트 호출 불가) ----------
drop function if exists mw_setting(text);
create or replace function mw_setting(p_academy uuid, p_key text) returns jsonb
language sql stable security definer set search_path = public as $$
  select value from mw_settings where key = p_key and (academy_id = p_academy or academy_id is null)
   order by academy_id nulls last limit 1;
$$;

create or replace function mw_need_teacher() returns void
language plpgsql security definer set search_path = public as $$
begin
  if not mw_is_teacher() then raise exception '선생님 권한이 필요합니다.'; end if;
end $$;

create or replace function mw_need_student(p_student uuid) returns void
language plpgsql security definer set search_path = public as $$
begin
  if not mw_same(p_student) then raise exception '우리 학원 학생만 처리할 수 있습니다.'; end if;
end $$;

create or replace function mw_student_ok() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from mw_profiles p join mw_academies a on a.id = p.academy_id
                  where p.id = auth.uid() and p.role = 'student' and p.active and a.active);
$$;

create or replace function mw_log(p_action text, p_target uuid, p_detail jsonb) returns void
language sql security definer set search_path = public as $$
  insert into mw_audit(academy_id, actor, action, target, detail)
  values (mw_my_academy(), auth.uid(), p_action, p_target, coalesce(p_detail, '{}'::jsonb));
$$;

create or replace function mw_badge(p_student uuid, p_badge text) returns void
language sql security definer set search_path = public as $$
  insert into mw_badges(student_id, badge_id) values (p_student, p_badge) on conflict do nothing;
$$;

create or replace function mw_grant_egg(p_student uuid, p_rarity text, p_source text) returns uuid
language plpgsql security definer set search_path = public as $$
declare v_species text; v_id uuid;
begin
  select s.id into v_species from mw_species s
   where s.rarity = p_rarity and s.enabled
     and not exists (select 1 from mw_monsters m where m.student_id = p_student and m.species_id = s.id)
   order by random() limit 1;
  if v_species is null then   -- 해당 등급을 모두 모았으면 다른 미보유 몬스터로 대체
    select s.id into v_species from mw_species s
     where s.rarity in ('common','starter','rare') and s.enabled
       and not exists (select 1 from mw_monsters m where m.student_id = p_student and m.species_id = s.id)
     order by case s.rarity when 'common' then 1 when 'starter' then 2 else 3 end, random() limit 1;
  end if;
  if v_species is null then return null; end if;
  insert into mw_monsters(student_id, species_id, hatched, source)
  values (p_student, v_species, false, p_source) returning id into v_id;
  return v_id;
end $$;

create or replace function mw_apply_xp(
  p_student uuid, p_monster uuid, p_amount int, p_kind text, p_reason text,
  p_mission uuid, p_book uuid) returns int
language plpgsql security definer set search_path = public as $$
declare m mw_monsters; v_ac uuid; v_per int; v_max int; v_xp int; v_lvl int; v_stage int;
begin
  select * into m from mw_monsters where id = p_monster and student_id = p_student and hatched for update;
  if not found then raise exception '성장시킬 몬스터가 없습니다.'; end if;
  select academy_id into v_ac from mw_profiles where id = p_student;
  v_per := greatest(1, (mw_setting(v_ac, 'xp_per_level'))::int);
  v_max := greatest(1, (mw_setting(v_ac, 'max_level'))::int);
  v_xp := greatest(0, m.xp + p_amount);
  v_lvl := least(v_max, 1 + v_xp / v_per);
  v_stage := m.stage;   -- v2.6: 진화는 레벨 + 진화석(mw_evolve)으로만. XP가 늘거나 줄어도 진화 단계는 바뀌지 않음
  update mw_monsters set xp = v_xp, level = v_lvl, stage = v_stage,
         seen_level = least(seen_level, v_lvl), seen_stage = least(seen_stage, v_stage)
   where id = m.id;
  insert into mw_ledger(student_id, monster_id, amount, kind, reason, mission_id, book_id, level_after, actor)
  values (p_student, m.id, p_amount, p_kind, coalesce(p_reason, ''), p_mission, p_book, v_lvl, auth.uid());
  if v_lvl >= 10 then perform mw_badge(p_student, 'lv10'); end if;
  if v_lvl >= 25 then perform mw_badge(p_student, 'lv25'); end if;
  if v_stage >= 2 then perform mw_badge(p_student, 'evo_explorer'); end if;
  if v_stage >= 3 then perform mw_badge(p_student, 'evo_master'); end if;
  if v_lvl >= v_max and m.level < v_max then        -- 최대 레벨 달성: 배지 + 새 알
    perform mw_badge(p_student, 'lvmax');
    if not exists (select 1 from mw_rewards where student_id = p_student and reward_key = 'max:' || m.id) then
      insert into mw_rewards(student_id, reward_key) values (p_student, 'max:' || m.id);
      perform mw_grant_egg(p_student, 'common', 'Lv.MAX 달성');
    end if;
  end if;
  if p_kind = 'grant' and p_amount > 0 then perform mw_stat_rewards(p_student); end if;   -- 스탯 목표 달성 몬스터
  return v_lvl;
end $$;

-- 스탯: 취소되지 않은 지급 XP(양수)를 활동별 스탯(activity_stats)으로 합산. 차감·정정은 넣지 않음. Demo.statValues 와 같은 규칙
create or replace function mw_stat_values(p_student uuid) returns jsonb
language sql stable security definer set search_path = public as $$
  with cfg as (select coalesce(mw_setting(p.academy_id, 'activity_stats'), '{}'::jsonb) as m from mw_profiles p where p.id = p_student)
  select coalesce(jsonb_object_agg(k, v), '{}'::jsonb) from (
    select cfg.m ->> l.reason as k, sum(l.amount)::int as v
      from mw_ledger l, cfg
     where l.student_id = p_student and l.kind = 'grant' and l.amount > 0 and cfg.m ? l.reason
       and not exists (select 1 from mw_ledger r where r.student_id = l.student_id and r.kind = 'revoke'
                        and ((l.mission_id is not null and r.mission_id = l.mission_id)
                          or (l.book_id is not null and r.book_id = l.book_id)))
     group by 1) t;
$$;

-- 진화석 잔액: 받은 돌(activity_stones 활동의 취소되지 않은 지급 1건 = 1개) − 쓴 돌(mw_rewards 'evo:<몬스터>:<단계>:<사용>')
-- Demo.stoneBalance 와 같은 규칙
-- 연속 기록(내부용). streak_rewards = {활동: {days, stone}}. 평일(월~금)만 세고 주말은 건너뜀(끊기지 않음).
--   len: 지금 이어지고 있는 연속 일수(승인 + 확인 중 포함, 오늘 아직 안 했으면 어제까지 이어진 기록)
--   earned: 승인된 날만으로 만든 연속 구간마다 days일당 돌 1개. 지급 순서와 상관없이 기록에서 계산하므로 중복 지급이 없음
create or replace function mw_streak_info(p_student uuid) returns jsonb
language sql stable security definer set search_path = public as $$
  with cfg as (select coalesce(mw_setting(p.academy_id, 'streak_rewards'), '{}'::jsonb) as m from mw_profiles p where p.id = p_student),
  acts as (select e.key as act, (e.value ->> 'days')::int as days, e.value ->> 'stone' as stone
             from cfg, jsonb_each(cfg.m) e
            where jsonb_typeof(e.value) = 'object' and coalesce(e.value ->> 'days', '') ~ '^[0-9]{1,3}$'
              and (e.value ->> 'days')::int >= 2 and e.value ->> 'stone' in ('evo','legend')),
  td as (select (now() at time zone 'Asia/Seoul')::date - date '2024-01-01' as t),
  base as (select m.activity as act,
                  ((m.due_date - date '2024-01-01') / 7) * 5 + ((m.due_date - date '2024-01-01') % 7) as idx,
                  bool_or(m.status = 'approved') as ok
             from mw_missions m join acts a on a.act = m.activity
            where m.student_id = p_student and m.status in ('approved','requested')
              and m.due_date >= date '2024-01-01' and (m.due_date - date '2024-01-01') % 7 < 5
            group by 1, 2),
  ra as (select act, idx - row_number() over (partition by act order by idx) as g from base where ok),
  earned as (select r.act, sum(r.n / a.days)::int as n
               from (select act, g, count(*)::int as n from ra group by 1, 2) r join acts a on a.act = r.act group by 1),
  rb as (select act, idx, idx - row_number() over (partition by act order by idx) as g from base),
  runs as (select act, max(idx) as last, count(*)::int as n from rb group by act, g)
  select coalesce(jsonb_object_agg(a.act, jsonb_build_object(
           'days', a.days, 'stone', a.stone,
           'earned', coalesce((select e.n from earned e where e.act = a.act), 0),
           'today', (td.t % 7 < 5) and exists (select 1 from base b where b.act = a.act and b.idx = (td.t / 7) * 5 + td.t % 7),
           'len', coalesce((select r.n from runs r where r.act = a.act and r.last in (
                    case when td.t % 7 < 5 then (td.t / 7) * 5 + td.t % 7 else (td.t / 7) * 5 + 4 end,
                    case when td.t % 7 < 5 then (td.t / 7) * 5 + td.t % 7 - 1 else -1 end)
                  order by r.last desc limit 1), 0))), '{}'::jsonb)
    from acts a, td;
$$;

create or replace function mw_stone_balance(p_student uuid) returns jsonb
language sql stable security definer set search_path = public as $$
  with cfg as (select coalesce(mw_setting(p.academy_id, 'activity_stones'), '{}'::jsonb) as m from mw_profiles p where p.id = p_student),
  earned as (
    select cfg.m ->> l.reason as k, count(*)::int as n
      from mw_ledger l, cfg
     where l.student_id = p_student and l.kind = 'grant' and l.amount > 0 and cfg.m ? l.reason
       and not exists (select 1 from mw_ledger r where r.student_id = l.student_id and r.kind = 'revoke'
                        and ((l.mission_id is not null and r.mission_id = l.mission_id)
                          or (l.book_id is not null and r.book_id = l.book_id)))
     group by 1),
  spent as (
    select coalesce(sum(case split_part(reward_key, ':', 4) when 'evo' then 1 when 'evo2' then 2 else 0 end), 0)::int as evo,
           coalesce(sum(case split_part(reward_key, ':', 4) when 'legend' then 1 else 0 end), 0)::int as legend
      from mw_rewards where student_id = p_student and reward_key like 'evo:%'),
  streak as (
    select coalesce(sum(case when e.value ->> 'stone' = 'evo' then (e.value ->> 'earned')::int end), 0)::int as evo,
           coalesce(sum(case when e.value ->> 'stone' = 'legend' then (e.value ->> 'earned')::int end), 0)::int as legend
      from jsonb_each(mw_streak_info(p_student)) e)
  select jsonb_build_object(
    'evo',    greatest(0, coalesce((select n from earned where k = 'evo'), 0)    + (select evo from streak)    - (select evo from spent)),
    'legend', greatest(0, coalesce((select n from earned where k = 'legend'), 0) + (select legend from streak) - (select legend from spent)));
$$;

-- 정해진 몬스터 알 지급. 이미 가진 몬스터면 같은 등급의 다른 미보유 몬스터로 대신 지급
create or replace function mw_grant_species(p_student uuid, p_species text, p_source text) returns uuid
language plpgsql security definer set search_path = public as $$
declare v_id uuid; v_rar text;
begin
  select rarity into v_rar from mw_species where id = p_species and enabled;
  if v_rar is not null and not exists (select 1 from mw_monsters where student_id = p_student and species_id = p_species) then
    insert into mw_monsters(student_id, species_id, hatched, source) values (p_student, p_species, false, p_source) returning id into v_id;
    return v_id;
  end if;
  return mw_grant_egg(p_student, coalesce(v_rar, 'common'), p_source);
end $$;

-- 스탯 목표(stat_rewards) 달성 시 몬스터 알을 한 번씩 지급. Demo.statRewards 와 같은 규칙
create or replace function mw_stat_rewards(p_student uuid) returns void
language plpgsql security definer set search_path = public as $$
declare v_ac uuid; v_st jsonb; r jsonb; v_key text;
begin
  select academy_id into v_ac from mw_profiles where id = p_student;
  v_st := mw_stat_values(p_student);
  for r in select * from jsonb_array_elements(coalesce(mw_setting(v_ac, 'stat_rewards'), '[]'::jsonb)) loop
    if coalesce((v_st ->> (r ->> 'stat'))::int, 0) >= (r ->> 'at')::int then
      v_key := 'stat:' || (r ->> 'stat') || ':' || (r ->> 'at');
      if not exists (select 1 from mw_rewards where student_id = p_student and reward_key = v_key) then
        insert into mw_rewards(student_id, reward_key) values (p_student, v_key);
        perform mw_grant_species(p_student, r ->> 'species',
          case r ->> 'stat' when 'read' then '독해' when 'write' then '작문' when 'vocab' then '어휘' when 'grit' then '성실' else r ->> 'stat' end
          || ' ' || to_char((r ->> 'at')::int, 'FM999,999,990') || ' 달성');
      end if;
    end if;
  end loop;
end $$;

-- 학원 만들기 / 학원 상태 변경 — SQL Editor 에서만 실행 가능(앱에서는 호출 불가)
create or replace function mw_create_academy(p_code text, p_name text, p_teacher_code text) returns text
language plpgsql security definer set search_path = public as $$
declare v_id uuid; v_code text := lower(btrim(p_code));
begin
  if v_code !~ '^[a-z0-9]{3,12}$' then raise exception '학원 코드는 영문 소문자·숫자 3~12자입니다.'; end if;
  if length(coalesce(p_teacher_code, '')) < 6 then raise exception '선생님 코드는 6자 이상으로 정해 주세요.'; end if;
  insert into mw_academies(code, name) values (v_code, btrim(p_name)) returning id into v_id;
  insert into mw_academy_secrets(academy_id, teacher_code) values (v_id, p_teacher_code);
  return '학원 생성 완료 · 학원 코드: ' || v_code;
end $$;

create or replace function mw_set_academy(p_code text, p_active boolean, p_max_students int, p_teacher_code text) returns text
language plpgsql security definer set search_path = public as $$
declare v_id uuid;
begin
  select id into v_id from mw_academies where code = lower(btrim(p_code));
  if v_id is null then raise exception '없는 학원 코드입니다.'; end if;
  update mw_academies set active = coalesce(p_active, active), max_students = coalesce(p_max_students, max_students) where id = v_id;
  if p_teacher_code is not null then
    insert into mw_academy_secrets(academy_id, teacher_code) values (v_id, p_teacher_code)
    on conflict (academy_id) do update set teacher_code = excluded.teacher_code;
  end if;
  return '변경 완료 · ' || lower(btrim(p_code));
end $$;

-- ---------- 6. 학생용 함수 ----------
create or replace function mw_choose_starter(p_species text, p_nickname text) returns uuid
language plpgsql security definer set search_path = public as $$
declare v_id uuid; p mw_profiles;
begin
  if not mw_student_ok() then raise exception '승인된 학생 계정이 아닙니다.'; end if;
  select * into p from mw_profiles where id = auth.uid() for update;
  if exists (select 1 from mw_monsters where student_id = p.id) then raise exception '이미 스타터를 선택했습니다.'; end if;
  if not exists (select 1 from mw_species where id = p_species and rarity = 'starter' and enabled) then
    raise exception '선택할 수 없는 몬스터입니다.'; end if;
  insert into mw_monsters(student_id, species_id, nickname, hatched, hatched_at, source)
  values (p.id, p_species, left(coalesce(p_nickname, ''), 12), true, now(), '스타터') returning id into v_id;
  update mw_profiles set active_monster = v_id where id = p.id;
  return v_id;
end $$;

create or replace function mw_hatch(p_monster uuid, p_nickname text) returns void
language plpgsql security definer set search_path = public as $$
begin
  if not mw_student_ok() then raise exception '승인된 학생 계정이 아닙니다.'; end if;
  update mw_monsters set hatched = true, hatched_at = now(), nickname = left(coalesce(p_nickname, ''), 12)
   where id = p_monster and student_id = auth.uid() and not hatched;
  if not found then raise exception '부화할 알이 없습니다.'; end if;
  perform mw_badge(auth.uid(), 'first_hatch');
end $$;

create or replace function mw_set_active(p_monster uuid) returns void
language plpgsql security definer set search_path = public as $$
begin
  if not exists (select 1 from mw_monsters where id = p_monster and student_id = auth.uid() and hatched) then
    raise exception '대표로 지정할 수 없는 몬스터입니다.'; end if;
  update mw_profiles set active_monster = p_monster where id = auth.uid();
end $$;

create or replace function mw_ack(p_monster uuid) returns void
language sql security definer set search_path = public as $$
  update mw_monsters set seen_level = level, seen_stage = stage where id = p_monster and student_id = auth.uid();
$$;

create or replace function mw_request_mission(p_id uuid) returns void
language plpgsql security definer set search_path = public as $$
begin
  if not mw_student_ok() then raise exception '승인된 학생 계정이 아닙니다.'; end if;
  update mw_missions set status = 'requested', requested_at = now()
   where id = p_id and student_id = auth.uid() and status in ('assigned','rejected');
  if not found then raise exception '요청할 수 없는 미션입니다.'; end if;
end $$;

-- 학생이 배정 없이 스스로 '다 했어요' 요청. 활동마다 하루(한국 시간) 1번, XP는 학원 설정값.
-- 같은 날 배정된(assigned) 또는 반려된(rejected) 미션이 있으면 새로 만들지 않고 그 미션을 요청 상태로 바꿉니다.
-- 체험 모드 Demo.F.self_report 와 같은 규칙입니다.
create or replace function mw_self_report(p_activity text) returns uuid
language plpgsql security definer set search_path = public as $$
declare v_ac uuid := mw_my_academy(); v_day date := (now() at time zone 'Asia/Seoul')::date;
        v_xp int; v_id uuid; v_st text;
begin
  if not mw_student_ok() then raise exception '승인된 학생 계정이 아닙니다.'; end if;
  if not (coalesce(mw_setting(v_ac, 'self_report_acts'), '[]'::jsonb) ? coalesce(p_activity, ''))
     or not (coalesce(mw_setting(v_ac, 'activity_list'), '[]'::jsonb) ? coalesce(p_activity, '')) then
    raise exception '스스로 요청할 수 없는 활동입니다.'; end if;
  perform pg_advisory_xact_lock(hashtext('mw_self_report:' || auth.uid()::text || ':' || p_activity));
  select id, status into v_id, v_st from mw_missions
   where student_id = auth.uid() and activity = p_activity and due_date = v_day
     and status in ('assigned','requested','approved','rejected')
   order by case status when 'assigned' then 0 when 'rejected' then 1 else 2 end, created_at desc
   limit 1;
  if v_st in ('assigned','rejected') then
    update mw_missions set status = 'requested', requested_at = now() where id = v_id;
    return v_id;
  elsif v_st is not null then
    raise exception '오늘 이미 요청한 활동입니다.';
  end if;
  v_xp := (mw_setting(v_ac, 'activity_xp')->>p_activity)::int;
  if v_xp is null or v_xp > 5000 then
    raise exception '이 활동의 XP 기준이 설정되지 않았습니다. 선생님께 알려 주세요.'; end if;
  if v_xp < 0 then raise exception '차감 항목은 선생님만 입력할 수 있습니다.'; end if;
  insert into mw_missions(student_id, activity, title, xp, due_date, status, requested_at, created_by)
  values (auth.uid(), p_activity, '', v_xp, v_day, 'requested', now(), auth.uid())
  returning id into v_id;
  return v_id;
end $$;

create or replace function mw_title_key(p_title text) returns text
language sql immutable as $$
  select lower(regexp_replace(coalesce(p_title, ''), '[^[:alnum:]]', '', 'g'));
$$;

create or replace function mw_request_book(p_title text) returns uuid
language plpgsql security definer set search_path = public as $$
declare v_id uuid; v_title text := btrim(left(coalesce(p_title, ''), 120));
begin
  if not mw_student_ok() then raise exception '승인된 학생 계정이 아닙니다.'; end if;
  if length(mw_title_key(v_title)) < 2 then raise exception '책 제목을 입력해 주세요.'; end if;
  if exists (select 1 from mw_books where student_id = auth.uid() and title_key = mw_title_key(v_title)) then
    raise exception '이미 등록한 책입니다.'; end if;
  insert into mw_books(student_id, title, title_key) values (auth.uid(), v_title, mw_title_key(v_title)) returning id into v_id;
  return v_id;
end $$;

-- 진화석 조회: 본인 또는 우리 학원 선생님만
create or replace function mw_stones(p_student uuid) returns jsonb
language plpgsql stable security definer set search_path = public as $$
begin
  if not ((p_student = auth.uid() and mw_student_ok()) or mw_same(p_student)) then raise exception '볼 수 없는 학생입니다.'; end if;
  return mw_stone_balance(p_student);
end $$;

-- 연속 기록 조회: 본인 또는 우리 학원 선생님만
create or replace function mw_streaks(p_student uuid) returns jsonb
language plpgsql stable security definer set search_path = public as $$
begin
  if not ((p_student = auth.uid() and mw_student_ok()) or mw_same(p_student)) then raise exception '볼 수 없는 학생입니다.'; end if;
  return mw_streak_info(p_student);
end $$;

-- 진화: 학생이 자기 몬스터를 골라 돌을 써서 진화. 레벨 조건(evolve_levels) + 돌
--   Rookie→Elite: 'evo'(진화석 1) 또는 'legend'(전설석 1) / Elite→Legend: 'legend'(전설석 1) 또는 'evo2'(진화석 2)
-- Demo.F.evolve 와 같은 규칙입니다.
create or replace function mw_evolve(p_monster uuid, p_use text) returns int
language plpgsql security definer set search_path = public as $$
declare m mw_monsters; v_need int; v_bal jsonb; v_to int;
begin
  if not mw_student_ok() then raise exception '승인된 학생 계정이 아닙니다.'; end if;
  perform 1 from mw_profiles where id = auth.uid() for update;   -- 같은 돌을 동시에 두 번 쓰지 못하게
  select * into m from mw_monsters where id = p_monster and student_id = auth.uid() and hatched for update;
  if not found then raise exception '진화시킬 수 있는 몬스터가 아닙니다.'; end if;
  if m.stage >= 3 then raise exception '이미 최종 단계입니다.'; end if;
  v_to := m.stage + 1;
  v_need := (mw_setting(mw_my_academy(), 'evolve_levels') ->> (m.stage - 1))::int;
  if v_need is null or m.level < v_need then raise exception '레벨이 부족합니다. Lv.%부터 진화할 수 있습니다.', v_need; end if;
  if not ((v_to = 2 and p_use in ('evo','legend')) or (v_to = 3 and p_use in ('legend','evo2'))) then
    raise exception '사용할 수 없는 진화 방법입니다.'; end if;
  v_bal := mw_stone_balance(auth.uid());
  if (p_use = 'evo' and (v_bal ->> 'evo')::int < 1) or (p_use = 'evo2' and (v_bal ->> 'evo')::int < 2)
     or (p_use = 'legend' and (v_bal ->> 'legend')::int < 1) then
    raise exception '진화석이 부족합니다.'; end if;
  insert into mw_rewards(student_id, reward_key) values (auth.uid(), 'evo:' || m.id || ':' || v_to || ':' || p_use);
  update mw_monsters set stage = v_to where id = m.id;
  perform mw_badge(auth.uid(), case when v_to = 2 then 'evo_explorer' else 'evo_master' end);
  perform mw_log('evolve', auth.uid(), jsonb_build_object('monster', m.id, 'stage', v_to, 'use', p_use));
  return v_to;
end $$;

-- 스탯 조회: 본인 또는 우리 학원 선생님만
create or replace function mw_stats(p_student uuid) returns jsonb
language plpgsql stable security definer set search_path = public as $$
begin
  if not ((p_student = auth.uid() and mw_student_ok()) or mw_same(p_student)) then raise exception '볼 수 없는 학생입니다.'; end if;
  return mw_stat_values(p_student);
end $$;

-- 마을 지도: 내 학원 활성 학생의 이름·레벨·대표 몬스터만 돌려줍니다(XP·기록 등 다른 정보는 공개하지 않음).
-- 학생에게는 학원 설정(map_name_mode)에 따라 다른 학생 이름을 서버에서 가려서 보냅니다. 선생님은 항상 실명.
--   nickname: 몬스터 별명(없으면 몬스터 이름) / masked: 김*준 / real: 실명 / hidden: 이름·몬스터 없이 레벨 위치만
-- 다른 학생의 계정 id는 학생에게 보내지 않습니다. 체험 모드 Demo.F.map 과 같은 규칙입니다.
drop function if exists mw_map();
create or replace function mw_map() returns table(student_id uuid, name text, level int, stage int, species_id text)
language plpgsql stable security definer set search_path = public as $$
declare v_t boolean := mw_is_teacher(); v_mode text;
begin
  if not (mw_student_ok() or v_t) then raise exception '승인된 계정이 아닙니다.'; end if;
  v_mode := coalesce(mw_setting(mw_my_academy(), 'map_name_mode') #>> '{}', 'nickname');
  return query
  select case when v_t or p.id = auth.uid() then p.id end,
         case when v_t or p.id = auth.uid() or v_mode = 'real' then p.display_name
              when v_mode = 'masked' then
                case when char_length(p.display_name) <= 1 then '*'
                     when char_length(p.display_name) = 2 then left(p.display_name, 1) || '*'
                     else left(p.display_name, 1) || repeat('*', char_length(p.display_name) - 2) || right(p.display_name, 1) end
              when v_mode = 'hidden' then null
              else coalesce(nullif(btrim(m.nickname), ''), s.name, '새 모험가') end,
         coalesce(m.level, 1), coalesce(m.stage, 1),
         case when v_t or p.id = auth.uid() or v_mode <> 'hidden' then m.species_id end
    from mw_profiles p
    left join mw_monsters m on m.id = p.active_monster
    left join mw_species s on s.id = m.species_id
   where p.academy_id = mw_my_academy() and p.role = 'student' and p.active
   order by coalesce(m.level, 1) desc, p.display_name;
end $$;

-- ---------- 7. 선생님용 함수 (모두 "내 학원" 안에서만 작동) ----------
create or replace function mw_claim_teacher(p_code text, p_name text) returns void
language plpgsql security definer set search_path = public as $$
declare v_ac uuid := mw_my_academy();
begin
  if v_ac is null or p_code is null or p_code = 'EPL-CHANGE-ME'
     or not exists (select 1 from mw_academy_secrets s join mw_academies a on a.id = s.academy_id
                     where s.academy_id = v_ac and a.active and s.teacher_code = p_code) then
    perform pg_sleep(1);
    raise exception '학원 코드 또는 선생님 코드가 올바르지 않습니다.';
  end if;
  update mw_profiles set role = 'teacher', active = true, display_name = left(coalesce(nullif(p_name, ''), display_name), 20)
   where id = auth.uid();
  perform mw_log('claim_teacher', auth.uid(), null);
end $$;

create or replace function mw_activate_student(p_id uuid, p_name text, p_active boolean) returns void
language plpgsql security definer set search_path = public as $$
declare v_max int; v_cnt int;
begin
  perform mw_need_student(p_id);
  if p_active then
    select a.max_students into v_max from mw_academies a where a.id = mw_my_academy();
    select count(*) into v_cnt from mw_profiles where academy_id = mw_my_academy() and role = 'student' and active and id <> p_id;
    if v_cnt >= v_max then raise exception '학생 정원(%명)을 모두 사용했습니다. 정원 추가는 운영사에 문의해 주세요.', v_max; end if;
  end if;
  update mw_profiles set active = p_active,
         display_name = left(coalesce(nullif(p_name, ''), display_name), 20),
         teacher_id = coalesce(teacher_id, auth.uid())
   where id = p_id;
  perform mw_log('activate_student', p_id, jsonb_build_object('active', p_active));
end $$;

create or replace function mw_set_stage(p_student uuid, p_stage text) returns void
language plpgsql security definer set search_path = public as $$
begin
  perform mw_need_student(p_student);
  if not exists (select 1 from jsonb_array_elements_text(mw_setting(mw_my_academy(), 'stages')) s where s = p_stage) then
    raise exception '설정에 없는 단계입니다.'; end if;
  update mw_profiles set epl_stage = p_stage where id = p_student;
  perform mw_log('set_stage', p_student, jsonb_build_object('stage', p_stage));
end $$;

-- 미션 배정. p_approve = true 이면 배정과 동시에 승인·XP 지급(빠른 지급).
create or replace function mw_assign_missions(
  p_students uuid[], p_activity text, p_title text, p_xp int, p_due date, p_batch uuid, p_approve boolean)
returns jsonb
language plpgsql security definer set search_path = public as $$
declare s uuid; v_xp int; v_id uuid; v_mon uuid; v_done int := 0; v_skip int := 0;
begin
  perform mw_need_teacher();
  v_xp := coalesce(p_xp, (mw_setting(mw_my_academy(), 'activity_xp')->>p_activity)::int, 0);
  if v_xp < -5000 or v_xp > 5000 then raise exception 'XP는 -5000~5000 사이여야 합니다.'; end if;
  foreach s in array p_students loop
    v_id := null;
    insert into mw_missions(student_id, activity, title, xp, due_date, batch_id, created_by)
    select s, p_activity, left(coalesce(p_title, ''), 80), v_xp, coalesce(p_due, current_date), p_batch, auth.uid()
     where mw_same(s) and exists (select 1 from mw_profiles where id = s and active)
    on conflict (student_id, batch_id) do nothing
    returning id into v_id;
    if v_id is null then v_skip := v_skip + 1; continue; end if;
    if p_approve then
      select active_monster into v_mon from mw_profiles where id = s;
      if v_mon is null then v_skip := v_skip + 1; continue; end if;   -- 스타터 미선택: 배정만 됨
      update mw_missions set status = 'approved', decided_by = auth.uid(), decided_at = now(), monster_id = v_mon where id = v_id;
      perform mw_apply_xp(s, v_mon, v_xp, 'grant', p_activity, v_id, null);
    end if;
    v_done := v_done + 1;
  end loop;
  return jsonb_build_object('done', v_done, 'skipped', v_skip);
end $$;

create or replace function mw_decide_missions(p_ids uuid[], p_approve boolean) returns jsonb
language plpgsql security definer set search_path = public as $$
declare r mw_missions; v_mon uuid; v_done int := 0; v_skip int := 0;
begin
  perform mw_need_teacher();
  for r in select * from mw_missions where id = any(p_ids) and status in ('assigned','requested','rejected')
            and mw_same(student_id) order by id for update loop
    if p_approve then
      select active_monster into v_mon from mw_profiles where id = r.student_id;
      if v_mon is null then v_skip := v_skip + 1; continue; end if;
      update mw_missions set status = 'approved', decided_by = auth.uid(), decided_at = now(), monster_id = v_mon where id = r.id;
      perform mw_apply_xp(r.student_id, v_mon, r.xp, 'grant', r.activity, r.id, null);
    else
      update mw_missions set status = 'rejected', decided_by = auth.uid(), decided_at = now() where id = r.id;
    end if;
    v_done := v_done + 1;
  end loop;
  return jsonb_build_object('done', v_done, 'skipped', v_skip);   -- 이미 처리된 미션은 조용히 건너뜀
end $$;

create or replace function mw_revoke_mission(p_id uuid, p_reason text) returns void
language plpgsql security definer set search_path = public as $$
declare r mw_missions;
begin
  perform mw_need_teacher();
  select * into r from mw_missions where id = p_id and status = 'approved' and mw_same(student_id) for update;
  if not found then raise exception '취소할 수 있는 승인 건이 아닙니다.'; end if;
  update mw_missions set status = 'revoked', note = left(coalesce(p_reason, ''), 200), decided_by = auth.uid(), decided_at = now() where id = r.id;
  perform mw_apply_xp(r.student_id, r.monster_id, -r.xp, 'revoke', coalesce(nullif(p_reason, ''), '승인 취소'), r.id, null);
end $$;

create or replace function mw_cancel_mission(p_id uuid) returns void
language plpgsql security definer set search_path = public as $$
begin
  perform mw_need_teacher();
  update mw_missions set status = 'cancelled', decided_by = auth.uid(), decided_at = now()
   where id = p_id and status in ('assigned','requested','rejected') and mw_same(student_id);
  if not found then raise exception '삭제할 수 없는 미션입니다.'; end if;
end $$;

create or replace function mw_book_rewards(p_student uuid) returns void
language plpgsql security definer set search_path = public as $$
declare v_count int; ms jsonb; v_key text; v_ac uuid;
begin
  select academy_id into v_ac from mw_profiles where id = p_student;
  select count(*) into v_count from mw_books where student_id = p_student and status = 'approved';
  for ms in select * from jsonb_array_elements(mw_setting(v_ac, 'reading_milestones')) loop
    if (ms->>'books')::int <= v_count then
      v_key := 'books:' || (ms->>'books') || ':' || (ms->>'reward');
      if not exists (select 1 from mw_rewards where student_id = p_student and reward_key = v_key) then
        insert into mw_rewards(student_id, reward_key) values (p_student, v_key);
        if ms->>'reward' = 'egg' then perform mw_grant_egg(p_student, 'common', '원서 ' || (ms->>'books') || '권');
        elsif ms->>'reward' = 'rare_egg' then perform mw_grant_egg(p_student, 'rare', '원서 ' || (ms->>'books') || '권');
        else perform mw_badge(p_student, coalesce(ms->>'id', 'reader' || (ms->>'books')));
        end if;
      end if;
    end if;
  end loop;
end $$;

create or replace function mw_decide_books(p_ids uuid[], p_approve boolean, p_comp int) returns jsonb
language plpgsql security definer set search_path = public as $$
declare r mw_books; v_mon uuid; v_xp int; v_done int := 0; v_skip int := 0;
begin
  perform mw_need_teacher();
  v_xp := coalesce((mw_setting(mw_my_academy(), 'activity_xp')->>'reading')::int, 0);
  for r in select * from mw_books where id = any(p_ids) and status = 'requested' and mw_same(student_id) order by id for update loop
    if p_approve then
      select active_monster into v_mon from mw_profiles where id = r.student_id;
      if v_mon is null then v_skip := v_skip + 1; continue; end if;
      update mw_books set status = 'approved', comprehension = p_comp, decided_by = auth.uid(), decided_at = now(), monster_id = v_mon where id = r.id;
      perform mw_apply_xp(r.student_id, v_mon, v_xp, 'grant', 'reading', null, r.id);
      perform mw_book_rewards(r.student_id);
    else
      update mw_books set status = 'rejected', decided_by = auth.uid(), decided_at = now() where id = r.id;
    end if;
    v_done := v_done + 1;
  end loop;
  return jsonb_build_object('done', v_done, 'skipped', v_skip);
end $$;

-- 선생님이 독서 실적을 직접 등록(등록과 동시에 승인)
create or replace function mw_add_book(p_student uuid, p_title text, p_comp int) returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_id uuid; v_title text := btrim(left(coalesce(p_title, ''), 120));
begin
  perform mw_need_student(p_student);
  if length(mw_title_key(v_title)) < 2 then raise exception '책 제목을 입력해 주세요.'; end if;
  if exists (select 1 from mw_books where student_id = p_student and title_key = mw_title_key(v_title)) then
    raise exception '이미 등록된 책입니다.'; end if;
  insert into mw_books(student_id, title, title_key) values (p_student, v_title, mw_title_key(v_title)) returning id into v_id;
  return mw_decide_books(array[v_id], true, p_comp);
end $$;

create or replace function mw_revoke_book(p_id uuid, p_reason text) returns void
language plpgsql security definer set search_path = public as $$
declare r mw_books; v_xp int;
begin
  perform mw_need_teacher();
  select * into r from mw_books where id = p_id and status = 'approved' and mw_same(student_id) for update;
  if not found then raise exception '취소할 수 있는 독서 실적이 아닙니다.'; end if;
  select amount into v_xp from mw_ledger where book_id = r.id and kind = 'grant';
  update mw_books set status = 'revoked', note = left(coalesce(p_reason, ''), 200), decided_by = auth.uid(), decided_at = now() where id = r.id;
  perform mw_apply_xp(r.student_id, r.monster_id, -coalesce(v_xp, 0), 'revoke', coalesce(nullif(p_reason, ''), '독서 실적 취소'), null, r.id);
end $$;

create or replace function mw_adjust_xp(p_student uuid, p_amount int, p_reason text) returns void
language plpgsql security definer set search_path = public as $$
declare v_mon uuid;
begin
  perform mw_need_student(p_student);
  if p_amount = 0 or abs(p_amount) > 1000 then raise exception '정정 XP는 ±1~1000 사이여야 합니다.'; end if;
  if coalesce(btrim(p_reason), '') = '' then raise exception '정정 사유를 입력해 주세요.'; end if;
  select active_monster into v_mon from mw_profiles where id = p_student;
  if v_mon is null then raise exception '대표 몬스터가 없습니다.'; end if;
  perform mw_apply_xp(p_student, v_mon, p_amount, 'adjust', left(p_reason, 200), null, null);
end $$;

-- 선생님 선물: 시즌 한정 몬스터만, 사유 필수(학생 도감에 획득 경로로 표시). Demo.F.gift_egg 와 같은 규칙
drop function if exists mw_gift_egg(uuid, text);
create or replace function mw_gift_egg(p_student uuid, p_species text, p_reason text) returns void
language plpgsql security definer set search_path = public as $$
begin
  perform mw_need_student(p_student);
  if char_length(btrim(coalesce(p_reason, ''))) < 2 then raise exception '선물 사유를 입력해 주세요.'; end if;
  if not exists (select 1 from mw_species where id = p_species and rarity = 'seasonal' and enabled) then
    raise exception '선생님 선물은 시즌 한정 몬스터만 가능합니다.'; end if;
  if exists (select 1 from mw_monsters where student_id = p_student and species_id = p_species) then
    raise exception '이미 가지고 있는 몬스터입니다.'; end if;
  insert into mw_monsters(student_id, species_id, hatched, source)
  values (p_student, p_species, false, '선생님 선물 · ' || left(btrim(p_reason), 40));
  perform mw_log('gift_egg', p_student, jsonb_build_object('species', p_species, 'reason', left(btrim(p_reason), 40)));
end $$;

create or replace function mw_set_setting(p_key text, p_value jsonb) returns void
language plpgsql security definer set search_path = public as $$
declare v_old jsonb; v_ac uuid := mw_my_academy();
begin
  perform mw_need_teacher();
  if p_key not in ('xp_per_level','max_level','evolve_levels','weekly_xp_goal','activity_xp','reading_milestones',
                   'point_rate','point_name','stages','activity_labels','self_report_acts','activity_list','map_zones','map_name_mode','activity_stats','stat_rewards','activity_stones','evolve_bonus','streak_rewards') then
    raise exception '알 수 없는 설정입니다.'; end if;
  if p_key = 'activity_xp' and (jsonb_typeof(p_value) <> 'object' or exists (
       select 1 from jsonb_each(p_value) e
        where e.key !~ '^[a-z0-9_]{1,24}$'
           or case when jsonb_typeof(e.value) = 'number'
                   then (e.value)::numeric not between -5000 and 5000 or (e.value)::numeric <> round((e.value)::numeric)
                   else true end)) then
    raise exception '활동 XP는 -5000~5000 사이 정수여야 합니다.'; end if;
  if p_key in ('activity_list','self_report_acts') and (jsonb_typeof(p_value) <> 'array' or jsonb_array_length(p_value) > 40 or exists (
       select 1 from jsonb_array_elements(p_value) e
        where jsonb_typeof(e) <> 'string' or (e #>> '{}') !~ '^[a-z0-9_]{1,24}$')) then
    raise exception '활동 목록 형식이 올바르지 않습니다.'; end if;
  if p_key = 'activity_stones' and (jsonb_typeof(p_value) <> 'object' or exists (
       select 1 from jsonb_each(p_value) e
        where e.key !~ '^[a-z0-9_]{1,24}$' or jsonb_typeof(e.value) <> 'string' or (e.value #>> '{}') not in ('evo','legend'))) then
    raise exception '진화석 설정이 올바르지 않습니다.'; end if;
  if p_key = 'activity_stats' and (jsonb_typeof(p_value) <> 'object' or exists (
       select 1 from jsonb_each(p_value) e
        where e.key !~ '^[a-z0-9_]{1,24}$' or jsonb_typeof(e.value) <> 'string' or (e.value #>> '{}') not in ('read','write','vocab','grit'))) then
    raise exception '활동별 스탯 설정이 올바르지 않습니다.'; end if;
  if p_key = 'stat_rewards' and (jsonb_typeof(p_value) <> 'array' or jsonb_array_length(p_value) > 24 or exists (
       select 1 from jsonb_array_elements(p_value) e
        where jsonb_typeof(e) <> 'object' or coalesce(e ->> 'stat', '') not in ('read','write','vocab','grit')
           or jsonb_typeof(e -> 'at') <> 'number' or coalesce(e ->> 'species', '') !~ '^[a-z0-9_]{1,24}$'
           or case when jsonb_typeof(e -> 'at') = 'number' then (e ->> 'at')::numeric not between 1 and 1000000 or (e ->> 'at')::numeric <> round((e ->> 'at')::numeric) else true end)) then
    raise exception '스탯 몬스터 기준이 올바르지 않습니다. 필요 스탯은 1 이상의 정수여야 합니다.'; end if;
  if p_key = 'streak_rewards' and (jsonb_typeof(p_value) <> 'object' or (select count(*) from jsonb_object_keys(p_value)) > 10 or exists (
       select 1 from jsonb_each(p_value) e
        where e.key !~ '^[a-z0-9_]{1,24}$' or jsonb_typeof(e.value) <> 'object'
           or coalesce(e.value ->> 'days', '') !~ '^[0-9]{1,2}$' or (e.value ->> 'days')::int not between 2 and 60
           or coalesce(e.value ->> 'stone', '') not in ('evo','legend'))) then
    raise exception '연속 보상 설정이 올바르지 않습니다. 연속 일수는 2~60일입니다.'; end if;
  if p_key = 'evolve_bonus' and (jsonb_typeof(p_value) <> 'array' or jsonb_array_length(p_value) <> 2 or exists (
       select 1 from jsonb_array_elements(p_value) e
        where jsonb_typeof(e) <> 'number' or (e #>> '{}')::numeric not between 0 and 10000 or (e #>> '{}')::numeric <> round((e #>> '{}')::numeric))) then
    raise exception '진화 보너스는 0~10000 사이 정수여야 합니다.'; end if;
  if p_key = 'map_name_mode' and (jsonb_typeof(p_value) <> 'string' or (p_value #>> '{}') not in ('nickname','masked','real','hidden')) then
    raise exception '이름 표시 방식이 올바르지 않습니다.'; end if;
  if p_key = 'map_zones' and (jsonb_typeof(p_value) <> 'array' or jsonb_array_length(p_value) not between 1 and 8 or exists (
       select 1 from jsonb_array_elements(p_value) with ordinality z(v, i)
        where jsonb_typeof(z.v) <> 'object' or jsonb_typeof(z.v->'from') <> 'number'
           or length(coalesce(z.v->>'name', '')) not between 1 and 24 or length(coalesce(z.v->>'ko', '')) > 24
           or (z.i = 1 and (z.v->>'from')::numeric <> 1)
           or (z.i > 1 and (z.v->>'from')::numeric <= (p_value->(z.i::int - 2)->>'from')::numeric))) then
    raise exception '마을 지도 설정이 올바르지 않습니다. 첫 마을은 Lv.1부터, 시작 레벨은 점점 커져야 합니다.'; end if;
  v_old := mw_setting(v_ac, p_key);
  update mw_settings set value = p_value, updated_by = auth.uid(), updated_at = now() where academy_id = v_ac and key = p_key;
  if not found then
    insert into mw_settings(academy_id, key, value, updated_by) values (v_ac, p_key, p_value, auth.uid());
  end if;
  perform mw_log('set_setting', null, jsonb_build_object('key', p_key, 'old', v_old, 'new', p_value));
end $$;

-- 학생 비밀번호 재설정(선생님 전용, 내 학원 학생 계정에만 적용)
create or replace function mw_reset_password(p_student uuid, p_pw text) returns void
language plpgsql security definer set search_path = public, extensions as $$
begin
  perform mw_need_student(p_student);
  if length(coalesce(p_pw, '')) < 6 then raise exception '비밀번호는 6자 이상이어야 합니다.'; end if;
  update auth.users set encrypted_password = crypt(p_pw, gen_salt('bf')) where id = p_student;
  perform mw_log('reset_password', p_student, null);
end $$;

-- 선생님 계정 이름·비밀번호 변경(우리 학원 선생님 계정만). 퇴사한 선생님 계정을 새 선생님에게 넘길 때 씁니다.
-- 비밀번호를 바꾸면 그 계정의 기존 로그인(세션)을 끊어서, 예전 사용자가 계속 접속하지 못하게 합니다.
create or replace function mw_update_teacher(p_id uuid, p_name text, p_pw text) returns void
language plpgsql security definer set search_path = public, extensions as $$
declare v_name text := nullif(btrim(coalesce(p_name, '')), ''); v_pw text := nullif(coalesce(p_pw, ''), '');
begin
  perform mw_need_teacher();
  if not mw_is_admin() then raise exception '선생님 계정은 원장 계정에서만 바꿀 수 있습니다.'; end if;
  if not exists (select 1 from mw_profiles where id = p_id and role = 'teacher' and academy_id = mw_my_academy()) then
    raise exception '우리 학원 선생님 계정만 바꿀 수 있습니다.'; end if;
  if v_name is null and v_pw is null then raise exception '바꿀 이름이나 비밀번호를 입력해 주세요.'; end if;
  if v_pw is not null and length(v_pw) < 6 then raise exception '비밀번호는 6자 이상이어야 합니다.'; end if;
  if v_name is not null then update mw_profiles set display_name = left(v_name, 20) where id = p_id; end if;
  if v_pw is not null then
    update auth.users set encrypted_password = crypt(v_pw, gen_salt('bf')) where id = p_id;
    if p_id <> auth.uid() then
      begin
        delete from auth.refresh_tokens where user_id = p_id::text;
        delete from auth.sessions where user_id = p_id;
      exception when insufficient_privilege or undefined_table then
        raise notice '기존 로그인 세션은 정리하지 못했습니다.';
      end;
    end if;
  end if;
  perform mw_log('update_teacher', null, jsonb_build_object('teacher', p_id, 'name', v_name is not null, 'pw', v_pw is not null));
end $$;

-- 학생 담당 선생님 변경(원장 전용). p_teacher 가 null 이면 담당 없음
create or replace function mw_set_teacher(p_student uuid, p_teacher uuid) returns void
language plpgsql security definer set search_path = public as $$
begin
  perform mw_need_teacher();
  if not mw_is_admin() then raise exception '담당 선생님은 원장 계정에서만 바꿀 수 있습니다.'; end if;
  perform mw_need_student(p_student);
  if p_teacher is not null and not exists (select 1 from mw_profiles where id = p_teacher and role = 'teacher' and active and academy_id = mw_my_academy()) then
    raise exception '우리 학원 선생님만 담당으로 지정할 수 있습니다.'; end if;
  update mw_profiles set teacher_id = p_teacher where id = p_student;
  perform mw_log('set_teacher', p_student, jsonb_build_object('teacher', p_teacher));
end $$;

-- 학생별 요약(선생님 화면·XP 기준 분석용)
create or replace function mw_summary() returns table(student_id uuid, week_xp bigint, xp_28d bigint, books bigint, pending bigint)
language plpgsql stable security definer set search_path = public as $$
begin
  perform mw_need_teacher();
  return query
  select p.id,
    coalesce((select sum(l.amount) from mw_ledger l where l.student_id = p.id and l.created_at >= date_trunc('week', now())), 0)::bigint,
    coalesce((select sum(l.amount) from mw_ledger l where l.student_id = p.id and l.created_at >= now() - interval '28 days'), 0)::bigint,
    (select count(*) from mw_books b where b.student_id = p.id and b.status = 'approved')::bigint,
    ((select count(*) from mw_missions m where m.student_id = p.id and m.status = 'requested')
     + (select count(*) from mw_books b where b.student_id = p.id and b.status = 'requested'))::bigint
  from mw_profiles p where p.role = 'student' and p.academy_id = mw_my_academy();
end $$;

-- 한 주(월~일, 한국 시간) 동안 승인된 내역을 학생별로 합산. 취소된 지급은 제외.
-- bonus: 그 주에 진화한 몬스터의 진화 보너스(evolve_bonus[Elite, Legend]) 합계. XP가 아니라 보상 포인트로만 입력합니다.
drop function if exists mw_weekly(date);
create or replace function mw_weekly(p_start date)
returns table(student_id uuid, n bigint, xp bigint, acts jsonb, done_at timestamptz, bonus bigint)
language plpgsql stable security definer set search_path = public as $$
declare v_bonus jsonb;
begin
  perform mw_need_teacher();
  v_bonus := coalesce(mw_setting(mw_my_academy(), 'evolve_bonus'), '[500,1000]'::jsonb);
  return query
  with g as (
    select l.student_id as sid, l.reason, l.amount from mw_ledger l
     where l.kind = 'grant'
       and (l.created_at at time zone 'Asia/Seoul')::date between p_start and p_start + 6
       and not exists (select 1 from mw_ledger r where r.kind = 'revoke'
             and ((l.mission_id is not null and r.mission_id = l.mission_id)
               or (l.book_id is not null and r.book_id = l.book_id)))
  ), a as (select g.sid, g.reason, count(*) as c, sum(g.amount) as x from g group by g.sid, g.reason)
  select p.id,
    coalesce((select sum(a.c) from a where a.sid = p.id), 0)::bigint,
    coalesce((select sum(a.x) from a where a.sid = p.id), 0)::bigint,
    coalesce((select jsonb_object_agg(a.reason, a.c) from a where a.sid = p.id), '{}'::jsonb),
    (select s.done_at from mw_settlements s where s.student_id = p.id and s.week_start = p_start),
    coalesce((select sum(coalesce((v_bonus ->> (split_part(r.reward_key, ':', 3)::int - 2))::int, 0))
                from mw_rewards r
               where r.student_id = p.id and r.reward_key like 'evo:%'
                 and (r.granted_at at time zone 'Asia/Seoul')::date between p_start and p_start + 6), 0)::bigint
  from mw_profiles p where p.role = 'student' and p.active and p.academy_id = mw_my_academy();
end $$;

create or replace function mw_settle(p_students uuid[], p_start date, p_done boolean) returns void
language plpgsql security definer set search_path = public as $$
begin
  perform mw_need_teacher();
  delete from mw_settlements s where s.student_id = any(p_students) and s.week_start = p_start and mw_same(s.student_id);
  if p_done then
    insert into mw_settlements(student_id, week_start, done_by)
    select u, p_start, auth.uid() from unnest(p_students) u where mw_same(u);
  end if;
  perform mw_log('settle', null, jsonb_build_object('week', p_start, 'done', p_done, 'count', coalesce(array_length(p_students, 1), 0)));
end $$;

-- ---------- 8. 함수 실행 권한 ----------
do $$
declare f record;
begin
  for f in select p.oid::regprocedure as sig, p.proname from pg_proc p join pg_namespace n on n.oid = p.pronamespace
            where n.nspname = 'public' and p.proname like 'mw\_%' loop
    execute format('revoke all on function %s from public', f.sig);
    begin execute format('revoke all on function %s from anon', f.sig); exception when others then null; end;
    begin execute format('revoke all on function %s from authenticated', f.sig); exception when others then null; end;
    if f.proname not in ('mw_apply_xp','mw_grant_egg','mw_badge','mw_book_rewards','mw_on_signup','mw_need_teacher',
                         'mw_need_student','mw_setting','mw_log','mw_create_academy','mw_set_academy',
                         'mw_stat_values','mw_stat_rewards','mw_grant_species','mw_stone_balance','mw_streak_info') then
      execute format('grant execute on function %s to authenticated', f.sig);
    end if;
  end loop;
end $$;

-- =====================================================================
-- 학원 만들기 (학원을 추가할 때마다 아래 한 줄을 값만 바꿔 실행)
--   select mw_create_academy('학원코드', '학원 이름', '선생님 코드');
--   예) select mw_create_academy('epl', 'EPL 영어학원', '여기에-선생님-코드');
--
-- 학원 상태 변경 (이용 중지 / 정원 변경 / 선생님 코드 변경 — 바꾸지 않을 값은 null)
--   select mw_set_academy('학원코드', false, null, null);     -- 이용 중지
--   select mw_set_academy('학원코드', null, 200, null);       -- 학생 정원 200명
--   select mw_set_academy('학원코드', null, null, '새코드');  -- 선생님 코드 변경
-- =====================================================================
