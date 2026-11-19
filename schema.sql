-- =====================================================================
-- MONSTER WORLD · 데이터베이스 v2.2  (Supabase / PostgreSQL) — 여러 학원용
-- v2.2: 칭찬모아 기준(출석·태도·AR·NELT 등, 차감 포함), 선생님이 활동 목록을 직접 편집, 1000 XP = 1레벨
-- v2.3: 마을 지도(mw_map, map_zones), 진화 단계 이름 Rookie · Elite · Legend
-- v2.4: 지도 이름 표시 설정(map_name_mode: nickname·masked·real·hidden) — 서버에서 가려서 보냄
-- v2.5: 스탯(독해·작문·어휘·성실)과 스탯 목표 달성 몬스터, 새 몬스터 3종, 선생님 선물은 시즌 한정 + 사유 필수
-- v2.20: 몬스터 도감 201종(67가문 × 3단계). 가문별 한국어 이름·속성·설명, 형태별 고유 ID·이름·요구 레벨·이미지. 도감 관리(mw_species_save)는 본사 학원 원장만. 이미지 저장소(mw-monsters)
-- v2.21: 상점에서 XP로도 사기. 받은 XP만큼 '쓸 수 있는 XP'가 따로 쌓이고, 써도 레벨·진화·칭찬모아 정산은 그대로(가격 = 코인 × 10)
-- v2.22: 칭찬 포인트(⭐) — 주간 정산과 같은 기준으로 쌓이고, 상점에서 쓴 만큼 칭찬모아로 넘어가지 않음. 입력 완료 = 보냄 기록. 🐷 모으기. XP 구매 없앰.
--        방 꾸미기 아이템 54종(시즌 소품 10 추가) · 희귀도 · 그림 · 시즌 판매 · 학습 성과 해금 · 벽걸이/좌우 뒤집기 · 아이템 관리(본사 원장)
-- v2.23: 몬스터 장비 꾸미기(머리·몸·손·등 4칸, 전투력·세트 효과·전설 장비는 실력으로만), 전투력 등급(브론즈~레전드), 강적 도전(실버부터, 문제 2배), 방 테마 8종(한 번에 바꾸기)
-- v2.24: 장비 29종 3D 그림(assets/equipment)과 그림에 맞춘 이름, 몬스터별 장비 위치·크기·회전 맞춤(mw_gear_fit, 본사 원장)
-- v2.28: 방 테마 30종 추가(베이커리·한옥·해적선·로켓·수정 동굴 등). 그림이 있는 테마만 학생 상점에 보임
-- v2.25: 몬스터는 진화로만 성장(장비 전투력 끔, 장비·가구 데이터는 그대로 둠), 방 테마 12종(진화하면 열리는 테마 포함), 가구 자유 꾸미기는 화면에서 뺌
-- v2.19: 친구 대결(같은 10문제를 각자 풀고 점수 비교, 서버가 시간 측정, 코인만, 하루 3번, 48시간 지나면 취소, 처음엔 꺼 둠)
-- v2.18: 친구 집 방문 + 스티커(정해진 6종, 친구마다 하루 1개, 자유 글쓰기 없음). 방문은 임시 열쇠(visit_key)로만, 이름은 지도 표시 방식 그대로
-- v2.17: 코인·상점·내 집(가구·벽지·바닥·몬스터 액세서리). 활동 승인·배틀 승리·연속 기록·진화로 코인, 반려·취소 시 회수
-- v2.16: 배틀에 내 몬스터 힘 반영(레벨·진화·어휘 스탯 치명타), 문제 유형 섞기(뜻 고르기·영어 고르기·듣기·철자)
-- v2.15: 단어 배틀(단어장 업로드, 단어 동굴, 서버 출제·채점, 배틀 XP·진화석 조각)
-- v2.14: 담당 선생님 변경을 모든 선생님이 할 수 있게. 선생님 이름 목록(mw_teacher_names, 이름만)
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
alter table mw_academies add column if not exists is_owner boolean not null default false;   -- v2.20: 본사 학원(모든 학원이 함께 쓰는 몬스터 도감을 관리)

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
-- v2.20 도감: 가문 번호·한국어 이름·속성·설명. 형태(forms)에는 id(MW-001~)·name_ko·description·req_level·image_url·thumb_url 을 함께 저장
alter table mw_species add column if not exists no int;
alter table mw_species add column if not exists name_ko text not null default '';
alter table mw_species add column if not exists element text not null default '';
alter table mw_species add column if not exists description text not null default '';
alter table mw_species drop constraint if exists mw_species_rarity_check;
alter table mw_species add constraint mw_species_rarity_check check (rarity in ('starter','common','rare','epic','legendary','seasonal'));

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

-- v2.15 단어 배틀: 단어장(학원별, 클라이언트에서 직접 읽을 수 없음), 학생 위치, 배틀 기록(정답 포함 → 직접 읽기 금지), 틀린 단어
create table if not exists mw_words (
  id uuid primary key default gen_random_uuid(),
  academy_id uuid not null references mw_academies(id) on delete cascade,
  book int not null check (book between 1 and 999),
  unit int not null check (unit between 1 and 999),
  no int not null check (no between 1 and 9999),
  en text not null,
  ko text not null,
  updated_at timestamptz not null default now(),
  unique (academy_id, book, unit, no)
);
create index if not exists mw_words_unit on mw_words(academy_id, book, unit);

create table if not exists mw_word_pos (           -- 학생별 현재 권·Unit (start: 처음 지정한 위치, 밀린 Unit 계산 시작점)
  student_id uuid primary key references mw_profiles(id) on delete cascade,
  book int not null, unit int not null,
  start_book int not null, start_unit int not null,
  updated_by uuid,
  updated_at timestamptz not null default now()
);

create table if not exists mw_battles (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references mw_profiles(id) on delete cascade,
  academy_id uuid not null,
  day date not null,                               -- 한국 날짜
  book int not null, unit int not null,            -- 수문장은 마지막 Unit(5·10·15…)
  kind text not null check (kind in ('unit','gate')),
  items jsonb not null,                            -- 문제와 정답(서버 전용)
  queue jsonb not null,                            -- 남은 문제 순서
  qn int not null default 1,                       -- 지금 문제 번호(같은 문제에 두 번 답하지 못하게)
  hearts int not null, hearts_max int not null,
  hp int not null, hp_max int not null,
  combo int not null default 0,
  status text not null default 'playing' check (status in ('playing','won','lost','quit')),
  revoked boolean not null default false,          -- 그날 요청이 반려되어 회수됨
  rewarded boolean not null default false,
  first_win boolean not null default false,
  xp int not null default 0,
  shards int not null default 0,
  mult numeric not null default 1,
  created_at timestamptz not null default now(),
  finished_at timestamptz
);
alter table mw_battles drop constraint if exists mw_battles_kind_check;
alter table mw_battles add constraint mw_battles_kind_check check (kind in ('unit','gate','hard'));   -- v2.23 hard = 강적 도전
alter table mw_battles add column if not exists power int not null default 1;     -- v2.16: 정답 1번의 공격력(시작할 때 내 몬스터로 계산)
alter table mw_battles add column if not exists crit numeric not null default 0;   -- 치명타 확률(0~1)
create index if not exists mw_battles_student on mw_battles(student_id, day);
create index if not exists mw_battles_won on mw_battles(student_id, book, unit, kind) where status = 'won' and not revoked;


-- v2.17 코인·상점·내 집 (게임 안 화폐. 칭찬모아와 별개, 학생끼리 주고받기·현금 결제 없음)
create table if not exists mw_coins (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references mw_profiles(id) on delete cascade,
  amount int not null,
  reason text not null default '',
  ref text,                                        -- 같은 일로 두 번 받지 않게(예: m:<미션>, bt:<배틀>, buy:<구매>)
  created_at timestamptz not null default now()
);
create unique index if not exists mw_coins_ref on mw_coins(student_id, ref) where ref is not null;
create index if not exists mw_coins_student on mw_coins(student_id, created_at desc);
-- v2.21: XP로 산 기록(레벨 XP는 그대로 두고, 쓸 수 있는 XP = 받은 XP 합계 - 여기 합계)
create table if not exists mw_xp_spend (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references mw_profiles(id) on delete cascade,
  item_id text not null,
  amount int not null check (amount > 0),
  created_at timestamptz not null default now()
);
create index if not exists mw_xp_spend_student on mw_xp_spend(student_id);
-- v2.22: ⭐ 칭찬 포인트 거래 내역. 잔액 = 합계. earn(승인·취소, 주간 정산과 같은 기준) · bonus(진화 보너스) · spend(상점) · send(칭찬모아로 보냄) · base(처음 시작분)
create table if not exists mw_points (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references mw_profiles(id) on delete cascade,
  amount int not null,
  kind text not null check (kind in ('earn','bonus','spend','send','base')),
  ref text,
  note text not null default '',
  created_at timestamptz not null default now()
);
create unique index if not exists mw_points_ref on mw_points(student_id, ref) where ref is not null;
create index if not exists mw_points_student on mw_points(student_id, created_at desc);
alter table mw_profiles add column if not exists point_save boolean not null default false;   -- 🐷 모으기: 켜면 주간 정산 때 칭찬모아로 보내지 않음

create table if not exists mw_shop_items (          -- 상점 목록(모든 학원 공통)
  id text primary key,
  kind text not null check (kind in ('furniture','wall','floor','acc')),
  name text not null,
  price int not null check (price between 0 and 100000),
  min_level int not null default 1,
  sort int not null default 0,
  enabled boolean not null default true
);
-- v2.22: 아이템 정보(희귀도·시즌·그림·해금 조건·놓는 곳·차지하는 칸). meta_v 2 = 도감처럼 원장이 고친 아이템(다시 실행해도 덮어쓰지 않음)
alter table mw_shop_items drop constraint if exists mw_shop_items_kind_check;
alter table mw_shop_items add constraint mw_shop_items_kind_check check (kind in ('furniture','wall','floor','acc','seasonal','gear','theme'));
alter table mw_shop_items add column if not exists slot text;          -- v2.23 장비 칸: head·body·hand·back
alter table mw_shop_items add column if not exists power int not null default 0;
alter table mw_shop_items add column if not exists set_id text;
alter table mw_shop_items add column if not exists grant_key text;     -- 전설 장비: 살 수 없고 이 조건을 이루면 받음(nelt·gate·streak·legend_evo)
alter table mw_shop_items add column if not exists preset jsonb;       -- 방 테마: {"wall","floor","layout"}
alter table mw_shop_items add column if not exists rarity text not null default 'common';
alter table mw_shop_items add column if not exists season text;
alter table mw_shop_items add column if not exists image_url text not null default '';
alter table mw_shop_items add column if not exists unlock jsonb;
alter table mw_shop_items add column if not exists place text not null default 'floor';
alter table mw_shop_items add column if not exists w int not null default 1;
alter table mw_shop_items add column if not exists meta_v int not null default 0;
insert into mw_shop_items(id, kind, name, price, min_level, sort) values
 ('bed','furniture','침대',120,1,0),
 ('desk','furniture','책상',80,1,1),
 ('chair','furniture','의자',40,1,2),
 ('bookshelf','furniture','책장',150,1,3),
 ('sofa','furniture','소파',180,1,4),
 ('lamp','furniture','스탠드',50,1,5),
 ('plant','furniture','화분',30,1,6),
 ('cactus','furniture','선인장',30,1,7),
 ('rug','furniture','러그',60,1,8),
 ('aquarium','furniture','어항',250,1,9),
 ('trophy','furniture','트로피',200,10,10),
 ('poster','furniture','포스터',40,1,11),
 ('window','furniture','창문',70,1,12),
 ('clock','furniture','벽시계',50,1,13),
 ('globe','furniture','지구본',90,1,14),
 ('piano','furniture','피아노',300,15,15),
 ('tv','furniture','TV',220,1,16),
 ('beanbag','furniture','빈백',70,1,17),
 ('telescope','furniture','망원경',260,20,18),
 ('drawers','furniture','서랍장',90,1,19),
 ('guitar','furniture','기타',160,1,20),
 ('petbed','furniture','몬스터 쿠션',60,1,21),
 ('pennant','furniture','깃발',40,1,22),
 ('fireplace','furniture','벽난로',280,25,23),
 ('wall_cream','wall','크림 벽지',0,1,24),
 ('wall_mint','wall','민트 벽지',60,1,25),
 ('wall_sky','wall','하늘 벽지',60,1,26),
 ('wall_lilac','wall','라일락 벽지',60,1,27),
 ('wall_stripe','wall','줄무늬 벽지',100,1,28),
 ('wall_star','wall','밤하늘 벽지',150,10,29),
 ('floor_wood','floor','나무 바닥',0,1,30),
 ('floor_tile','floor','타일 바닥',60,1,31),
 ('floor_grass','floor','잔디 바닥',80,1,32),
 ('floor_carpet','floor','카펫 바닥',80,1,33),
 ('floor_marble','floor','대리석 바닥',150,10,34),
 ('floor_cloud','floor','구름 바닥',200,20,35),
 ('acc_hat','gear','모자',80,1,36),
 ('acc_ribbon','gear','리본',60,1,37),
 ('acc_glasses','gear','안경',70,1,38),
 ('acc_scarf','gear','목도리',70,1,39),
 ('acc_headphones','gear','헤드폰',120,1,40),
 ('acc_flower','gear','꽃',50,1,41),
 ('acc_star','gear','별 배지',200,10,42),
 ('acc_crown','gear','왕관',300,20,43)
on conflict (id) do update set kind = excluded.kind, name = excluded.name, price = excluded.price, min_level = excluded.min_level, sort = excluded.sort
  where mw_shop_items.meta_v < 2;
-- v2.22: 시즌 소품 10종
insert into mw_shop_items(id, kind, name, price, min_level, sort) values
 ('s_cherry','seasonal','벚꽃 화분',120,1,44),
 ('s_picnic','seasonal','피크닉 바구니',150,1,45),
 ('s_fan','seasonal','선풍기',100,1,46),
 ('s_melon','seasonal','수박',80,1,47),
 ('s_float','seasonal','오리 튜브',120,1,48),
 ('s_maple','seasonal','단풍 화분',120,1,49),
 ('s_pumpkin','seasonal','호박 등불',140,1,50),
 ('s_tree','seasonal','크리스마스 트리',200,1,51),
 ('s_snowman','seasonal','눈사람',150,1,52),
 ('s_gift','seasonal','선물 상자',100,1,53)
on conflict (id) do nothing;
-- v2.23: 장비 21종 + 방 테마 8종
insert into mw_shop_items(id, kind, name, price, min_level, sort) values
 ('g_wizhat','gear','마법사 모자',220,1,54),
 ('g_helmet','gear','기사 투구',220,1,55),
 ('g_rainbow','gear','무지개 왕관',0,1,56),
 ('g_robe','gear','별빛 로브',240,1,57),
 ('g_armor','gear','기사 갑옷',240,1,58),
 ('g_vest','gear','탐험가 조끼',140,1,59),
 ('g_jacket','gear','반짝이 재킷',140,1,60),
 ('g_emblem','gear','용사의 문장',0,1,61),
 ('g_wand','gear','별 지팡이',200,1,62),
 ('g_sword','gear','나무 검',200,1,63),
 ('g_lens','gear','돋보기',120,1,64),
 ('g_mic','gear','반짝 마이크',120,1,65),
 ('g_book','gear','영어책',80,1,66),
 ('g_lightbook','gear','빛의 책',0,1,67),
 ('g_cape_p','gear','보라 망토',220,1,68),
 ('g_cape_r','gear','빨간 망토',220,1,69),
 ('g_rocket','gear','로켓 배낭',140,1,70),
 ('g_fairy','gear','요정 날개',160,1,71),
 ('g_angel','gear','천사 날개',160,1,72),
 ('g_dragon','gear','드래곤 날개',320,1,73),
 ('g_goldwings','gear','황금 날개',0,1,74),
 ('t_cozy','theme','포근한 침실',0,1,75),
 ('t_star','theme','별밤 천문대',450,1,76),
 ('t_forest','theme','숲속 오두막',450,1,77),
 ('t_music','theme','반짝 음악실',600,1,78),
 ('t_spring','theme','벚꽃 피크닉',400,1,79),
 ('t_summer','theme','바닷가 방',400,1,80),
 ('t_autumn','theme','단풍 할로윈',400,1,81),
 ('t_winter','theme','눈꽃 산장',450,1,82)
on conflict (id) do nothing;
-- v2.25: 방 테마 4종 추가
insert into mw_shop_items(id, kind, name, price, min_level, sort) values
 ('t_library','theme','책벌레 도서관',500,1,90),
 ('t_ocean','theme','바닷속 수족관',600,1,91),
 ('t_sky','theme','구름 위 하늘정원',0,1,92),
 ('t_space','theme','별빛 우주 관측소',0,1,93)
on conflict (id) do nothing;
-- 장비 칸·전투력·세트·획득 조건(원장이 고칠 수 없는 항목이라 늘 덮어씀). 희귀도는 처음 한 번만
update mw_shop_items i set slot = v.slot, power = v.power, set_id = v.set_id, grant_key = v.grant_key,
       rarity = case when i.meta_v < 2 then v.rarity else i.rarity end
  from (values
   ('acc_hat','head','common',3,'explorer',null),
   ('acc_ribbon','head','common',3,null,null),
   ('acc_glasses','head','common',3,'scholar',null),
   ('acc_headphones','head','rare',6,'star',null),
   ('acc_flower','head','common',3,null,null),
   ('acc_crown','head','epic',10,null,null),
   ('g_wizhat','head','epic',10,'wizard',null),
   ('g_helmet','head','epic',10,'knight',null),
   ('g_rainbow','head','legend',20,'legend','legend_evo'),
   ('acc_scarf','body','common',3,'scholar',null),
   ('acc_star','body','rare',6,null,null),
   ('g_robe','body','epic',10,'wizard',null),
   ('g_armor','body','epic',10,'knight',null),
   ('g_vest','body','rare',6,'explorer',null),
   ('g_jacket','body','rare',6,'star',null),
   ('g_emblem','body','legend',20,'legend','streak'),
   ('g_wand','hand','epic',10,'wizard',null),
   ('g_sword','hand','epic',10,'knight',null),
   ('g_lens','hand','rare',6,'explorer',null),
   ('g_mic','hand','rare',6,'star',null),
   ('g_book','hand','common',3,'scholar',null),
   ('g_lightbook','hand','legend',20,'legend','gate'),
   ('g_cape_p','back','epic',10,'wizard',null),
   ('g_cape_r','back','epic',10,'knight',null),
   ('g_rocket','back','rare',6,'explorer',null),
   ('g_fairy','back','rare',6,'star',null),
   ('g_angel','back','rare',6,'scholar',null),
   ('g_dragon','back','epic',12,null,null),
   ('g_goldwings','back','legend',20,'legend','nelt')
  ) as v(id, slot, rarity, power, set_id, grant_key)
 where i.id = v.id;
update mw_shop_items set kind = 'gear' where kind = 'acc';
-- v2.25: 진화하면 열리는 방 테마(하늘정원 = Elite, 우주 관측소 = Legend), 도서관 = 원서 5권
update mw_shop_items i set unlock = v.u from (values ('t_sky','{"t":"stage","v":2}'::jsonb),('t_space','{"t":"stage","v":3}'::jsonb),('t_library','{"t":"books","v":5}'::jsonb)) as v(id, u)
 where i.id = v.id and i.meta_v < 2;   -- 예전 액세서리는 모두 머리·몸 장비로
-- v2.24: 새 장비 그림에 맞춘 이름(원장이 직접 고친 이름은 그대로)
update mw_shop_items i set name = v.name from (values ('acc_hat','털모자'),('acc_ribbon','별 캡 모자'),('acc_glasses','탐험 고글'),('acc_headphones','별빛 헤드폰'),('acc_flower','꽃 사슴뿔 화관'),('acc_crown','수정 왕관'),('g_wizhat','마법사 모자'),('g_helmet','기사 투구'),('g_rainbow','영웅의 월계관'),('acc_scarf','목도리 겨울 코트'),('acc_star','숲의 잎사귀 망토'),('g_robe','별빛 후드 로브'),('g_armor','기사 갑옷'),('g_vest','탐험가 조끼'),('g_jacket','모험가 튜닉'),('g_emblem','영웅의 망토깃'),('g_wand','별 지팡이'),('g_sword','기사의 깃발'),('g_lens','나침반 지팡이'),('g_mic','달빛 지팡이'),('g_book','마법 영어책'),('g_lightbook','빛의 랜턴'),('g_cape_p','달빛 망토'),('g_cape_r','깃발 장식'),('g_rocket','모험가 가방끈'),('g_fairy','수정 고리'),('g_angel','천사 날개'),('g_dragon','숲의 정령 날개'),('g_goldwings','별빛 고리')) as v(id, name) where i.id = v.id and i.meta_v < 2;
-- v2.24: 몬스터별 장비 위치 맞춤. species_id '*' + stage 0 = 그 장비의 모든 몬스터 기본값
create table if not exists mw_gear_fit (
  species_id text not null,
  stage int not null check (stage between 0 and 3),
  item_id text not null references mw_shop_items(id) on delete cascade,
  dx numeric not null default 0 check (dx between -2 and 2),
  dy numeric not null default 0 check (dy between -2 and 2),
  s numeric not null default 1 check (s between 0.3 and 2.5),
  r numeric not null default 0 check (r between -60 and 60),
  updated_at timestamptz not null default now(),
  primary key (species_id, stage, item_id)
);
alter table mw_gear_fit enable row level security;
update mw_shop_items i set preset = v.preset, rarity = case when i.meta_v < 2 then v.rarity else i.rarity end,
       season = case when i.meta_v < 2 then v.season else i.season end
  from (values
   ('t_cozy','common',null,'{"wall": "wall_cream", "floor": "floor_wood", "layout": [{"i": "poster", "x": 0, "y": -1}, {"i": "window", "x": 2, "y": -1}, {"i": "clock", "x": 5, "y": -1}, {"i": "pennant", "x": 7, "y": -1}, {"i": "drawers", "x": 0, "y": 0}, {"i": "bed", "x": 1, "y": 0}, {"i": "lamp", "x": 3, "y": 0}, {"i": "desk", "x": 4, "y": 0}, {"i": "bookshelf", "x": 6, "y": 0}, {"i": "plant", "x": 7, "y": 0}, {"i": "chair", "x": 5, "y": 1}, {"i": "petbed", "x": 7, "y": 1}, {"i": "rug", "x": 2, "y": 2}, {"i": "beanbag", "x": 0, "y": 3}, {"i": "plant", "x": 7, "y": 4}, {"i": "cactus", "x": 0, "y": 5}]}'::jsonb),
   ('t_star','rare',null,'{"wall": "wall_star", "floor": "floor_marble", "layout": [{"i": "poster", "x": 0, "y": -1}, {"i": "window", "x": 2, "y": -1}, {"i": "poster", "x": 5, "y": -1}, {"i": "clock", "x": 7, "y": -1}, {"i": "bookshelf", "x": 0, "y": 0}, {"i": "bookshelf", "x": 1, "y": 0}, {"i": "globe", "x": 2, "y": 0}, {"i": "telescope", "x": 4, "y": 0}, {"i": "lamp", "x": 5, "y": 0}, {"i": "drawers", "x": 6, "y": 0}, {"i": "plant", "x": 7, "y": 0}, {"i": "beanbag", "x": 0, "y": 2}, {"i": "rug", "x": 3, "y": 2}, {"i": "globe", "x": 6, "y": 2}, {"i": "telescope", "x": 7, "y": 2}, {"i": "trophy", "x": 0, "y": 4}, {"i": "lamp", "x": 7, "y": 4}]}'::jsonb),
   ('t_forest','rare',null,'{"wall": "wall_mint", "floor": "floor_grass", "layout": [{"i": "pennant", "x": 0, "y": -1}, {"i": "window", "x": 2, "y": -1}, {"i": "clock", "x": 5, "y": -1}, {"i": "pennant", "x": 7, "y": -1}, {"i": "plant", "x": 0, "y": 0}, {"i": "plant", "x": 1, "y": 0}, {"i": "fireplace", "x": 2, "y": 0}, {"i": "plant", "x": 4, "y": 0}, {"i": "bookshelf", "x": 5, "y": 0}, {"i": "cactus", "x": 6, "y": 0}, {"i": "plant", "x": 7, "y": 0}, {"i": "chair", "x": 1, "y": 1}, {"i": "petbed", "x": 4, "y": 1}, {"i": "rug", "x": 2, "y": 2}, {"i": "aquarium", "x": 7, "y": 2}, {"i": "cactus", "x": 0, "y": 3}, {"i": "plant", "x": 7, "y": 4}, {"i": "beanbag", "x": 0, "y": 5}]}'::jsonb),
   ('t_music','epic',null,'{"wall": "wall_lilac", "floor": "floor_carpet", "layout": [{"i": "pennant", "x": 0, "y": -1}, {"i": "poster", "x": 2, "y": -1}, {"i": "clock", "x": 4, "y": -1}, {"i": "poster", "x": 6, "y": -1}, {"i": "pennant", "x": 7, "y": -1}, {"i": "piano", "x": 0, "y": 0}, {"i": "lamp", "x": 2, "y": 0}, {"i": "tv", "x": 3, "y": 0}, {"i": "guitar", "x": 4, "y": 0}, {"i": "drawers", "x": 5, "y": 0}, {"i": "guitar", "x": 6, "y": 0}, {"i": "plant", "x": 7, "y": 0}, {"i": "beanbag", "x": 0, "y": 2}, {"i": "rug", "x": 2, "y": 2}, {"i": "sofa", "x": 5, "y": 2}, {"i": "lamp", "x": 7, "y": 3}, {"i": "guitar", "x": 0, "y": 4}, {"i": "trophy", "x": 7, "y": 5}]}'::jsonb),
   ('t_spring','rare','spring','{"wall": "wall_mint", "floor": "floor_grass", "layout": [{"i": "window", "x": 1, "y": -1}, {"i": "poster", "x": 4, "y": -1}, {"i": "clock", "x": 6, "y": -1}, {"i": "s_cherry", "x": 0, "y": 0}, {"i": "plant", "x": 1, "y": 0}, {"i": "drawers", "x": 2, "y": 0}, {"i": "s_cherry", "x": 4, "y": 0}, {"i": "cactus", "x": 5, "y": 0}, {"i": "plant", "x": 6, "y": 0}, {"i": "s_cherry", "x": 7, "y": 0}, {"i": "petbed", "x": 0, "y": 2}, {"i": "rug", "x": 2, "y": 2}, {"i": "beanbag", "x": 7, "y": 2}, {"i": "s_picnic", "x": 4, "y": 3}, {"i": "s_cherry", "x": 0, "y": 4}, {"i": "plant", "x": 7, "y": 4}]}'::jsonb),
   ('t_summer','rare','summer','{"wall": "wall_sky", "floor": "floor_tile", "layout": [{"i": "window", "x": 1, "y": -1}, {"i": "poster", "x": 4, "y": -1}, {"i": "window", "x": 5, "y": -1}, {"i": "aquarium", "x": 0, "y": 0}, {"i": "plant", "x": 1, "y": 0}, {"i": "s_fan", "x": 3, "y": 0}, {"i": "aquarium", "x": 4, "y": 0}, {"i": "drawers", "x": 5, "y": 0}, {"i": "plant", "x": 7, "y": 0}, {"i": "beanbag", "x": 6, "y": 1}, {"i": "s_melon", "x": 2, "y": 2}, {"i": "rug", "x": 4, "y": 2}, {"i": "s_float", "x": 0, "y": 3}, {"i": "s_fan", "x": 7, "y": 3}, {"i": "cactus", "x": 0, "y": 5}, {"i": "s_float", "x": 6, "y": 5}]}'::jsonb),
   ('t_autumn','rare','autumn','{"wall": "wall_stripe", "floor": "floor_wood", "layout": [{"i": "window", "x": 1, "y": -1}, {"i": "clock", "x": 4, "y": -1}, {"i": "pennant", "x": 6, "y": -1}, {"i": "s_maple", "x": 0, "y": 0}, {"i": "bed", "x": 1, "y": 0}, {"i": "lamp", "x": 3, "y": 0}, {"i": "bookshelf", "x": 4, "y": 0}, {"i": "s_maple", "x": 5, "y": 0}, {"i": "drawers", "x": 6, "y": 0}, {"i": "s_maple", "x": 7, "y": 0}, {"i": "s_pumpkin", "x": 0, "y": 2}, {"i": "rug", "x": 2, "y": 2}, {"i": "chair", "x": 5, "y": 2}, {"i": "s_pumpkin", "x": 7, "y": 2}, {"i": "s_pumpkin", "x": 1, "y": 4}, {"i": "s_maple", "x": 7, "y": 4}]}'::jsonb),
   ('t_winter','epic','winter','{"wall": "wall_sky", "floor": "floor_carpet", "layout": [{"i": "window", "x": 1, "y": -1}, {"i": "clock", "x": 4, "y": -1}, {"i": "window", "x": 5, "y": -1}, {"i": "s_tree", "x": 0, "y": 0}, {"i": "s_gift", "x": 1, "y": 0}, {"i": "fireplace", "x": 2, "y": 0}, {"i": "s_gift", "x": 4, "y": 0}, {"i": "bookshelf", "x": 5, "y": 0}, {"i": "lamp", "x": 6, "y": 0}, {"i": "s_tree", "x": 7, "y": 0}, {"i": "s_gift", "x": 0, "y": 2}, {"i": "sofa", "x": 2, "y": 2}, {"i": "rug", "x": 4, "y": 2}, {"i": "s_snowman", "x": 7, "y": 2}, {"i": "s_snowman", "x": 0, "y": 4}, {"i": "s_gift", "x": 7, "y": 4}]}'::jsonb),
   ('t_library','rare',null,'{"wall": "wall_stripe", "floor": "floor_wood", "layout": [{"i": "poster", "x": 0, "y": -1}, {"i": "clock", "x": 2, "y": -1}, {"i": "window", "x": 4, "y": -1}, {"i": "pennant", "x": 7, "y": -1}, {"i": "bookshelf", "x": 0, "y": 0}, {"i": "bookshelf", "x": 1, "y": 0}, {"i": "bookshelf", "x": 2, "y": 0}, {"i": "lamp", "x": 3, "y": 0}, {"i": "bookshelf", "x": 4, "y": 0}, {"i": "bookshelf", "x": 5, "y": 0}, {"i": "globe", "x": 6, "y": 0}, {"i": "plant", "x": 7, "y": 0}, {"i": "desk", "x": 0, "y": 2}, {"i": "chair", "x": 2, "y": 2}, {"i": "rug", "x": 3, "y": 3}, {"i": "beanbag", "x": 7, "y": 2}, {"i": "lamp", "x": 7, "y": 4}, {"i": "plant", "x": 0, "y": 5}]}'::jsonb),
   ('t_ocean','epic',null,'{"wall": "wall_sky", "floor": "floor_tile", "layout": [{"i": "window", "x": 1, "y": -1}, {"i": "poster", "x": 4, "y": -1}, {"i": "window", "x": 5, "y": -1}, {"i": "aquarium", "x": 0, "y": 0}, {"i": "aquarium", "x": 1, "y": 0}, {"i": "aquarium", "x": 2, "y": 0}, {"i": "plant", "x": 3, "y": 0}, {"i": "aquarium", "x": 4, "y": 0}, {"i": "aquarium", "x": 5, "y": 0}, {"i": "aquarium", "x": 6, "y": 0}, {"i": "plant", "x": 7, "y": 0}, {"i": "s_float", "x": 0, "y": 2}, {"i": "rug", "x": 3, "y": 2}, {"i": "aquarium", "x": 7, "y": 2}, {"i": "beanbag", "x": 6, "y": 4}, {"i": "s_float", "x": 1, "y": 5}]}'::jsonb),
   ('t_sky','epic',null,'{"wall": "wall_sky", "floor": "floor_cloud", "layout": [{"i": "window", "x": 2, "y": -1}, {"i": "clock", "x": 5, "y": -1}, {"i": "plant", "x": 0, "y": 0}, {"i": "s_cherry", "x": 1, "y": 0}, {"i": "plant", "x": 2, "y": 0}, {"i": "telescope", "x": 3, "y": 0}, {"i": "s_cherry", "x": 5, "y": 0}, {"i": "plant", "x": 6, "y": 0}, {"i": "s_cherry", "x": 7, "y": 0}, {"i": "beanbag", "x": 0, "y": 2}, {"i": "rug", "x": 3, "y": 2}, {"i": "petbed", "x": 7, "y": 2}, {"i": "plant", "x": 0, "y": 4}, {"i": "cactus", "x": 7, "y": 4}]}'::jsonb),
   ('t_space','legend',null,'{"wall": "wall_star", "floor": "floor_cloud", "layout": [{"i": "poster", "x": 0, "y": -1}, {"i": "window", "x": 2, "y": -1}, {"i": "poster", "x": 5, "y": -1}, {"i": "clock", "x": 7, "y": -1}, {"i": "telescope", "x": 0, "y": 0}, {"i": "globe", "x": 1, "y": 0}, {"i": "telescope", "x": 2, "y": 0}, {"i": "trophy", "x": 3, "y": 0}, {"i": "trophy", "x": 4, "y": 0}, {"i": "telescope", "x": 5, "y": 0}, {"i": "globe", "x": 6, "y": 0}, {"i": "telescope", "x": 7, "y": 0}, {"i": "globe", "x": 0, "y": 2}, {"i": "rug", "x": 3, "y": 2}, {"i": "lamp", "x": 7, "y": 2}, {"i": "trophy", "x": 0, "y": 4}, {"i": "lamp", "x": 7, "y": 4}]}'::jsonb)
  ) as v(id, rarity, season, preset)
 where i.id = v.id;
-- v2.28: 방 테마 30종 추가(그림이 있는 테마만 학생 상점에 보임 — 그림은 assets/themes 또는 아이템 관리에서 올림). 원장이 고친 테마는 그대로
insert into mw_shop_items(id, kind, name, price, min_level, sort) values
 ('t_bakery','theme','달콤 베이커리',350,1,200),
 ('t_candy','theme','사탕 과자집',450,1,201),
 ('t_camping','theme','별빛 캠핑',450,1,202),
 ('t_greenhouse','theme','햇살 온실',350,1,203),
 ('t_art','theme','알록달록 미술실',350,1,204),
 ('t_science','theme','꼬마 과학 실험실',500,1,205),
 ('t_dino','theme','공룡 화석 박물관',650,1,206),
 ('t_pirate','theme','해적선 선장실',650,1,207),
 ('t_castle','theme','동화 속 성',650,1,208),
 ('t_treehouse','theme','나무 위 오두막',450,1,209),
 ('t_cafe','theme','아늑한 카페',350,1,210),
 ('t_hanok','theme','한옥 사랑방',500,1,211),
 ('t_jungle','theme','정글 탐험 캠프',450,1,212),
 ('t_igloo','theme','북극 이글루',450,1,213),
 ('t_train','theme','꼬마 기차 객실',450,1,214),
 ('t_rocket','theme','로켓 조종실',650,1,215),
 ('t_robot','theme','로봇 공방',600,1,216),
 ('t_gym','theme','신나는 체육관',350,1,217),
 ('t_arcade','theme','레트로 오락실',500,1,218),
 ('t_potion','theme','마법 물약 연구실',650,1,219),
 ('t_fairy','theme','요정 버섯 마을',450,1,220),
 ('t_moon','theme','달토끼 방',600,1,221),
 ('t_farm','theme','농장 헛간',350,1,222),
 ('t_pet','theme','아기 동물 돌봄방',400,1,223),
 ('t_stage','theme','꿈의 무대 연습실',500,1,224),
 ('t_butterfly','theme','나비 꽃정원',400,1,225),
 ('t_rainy','theme','비 오는 날 개구리방',400,1,226),
 ('t_chuseok','theme','추석 보름달',400,1,227),
 ('t_crystal','theme','수정 동굴',0,1,228),
 ('t_aurora','theme','오로라 별장',0,1,229)
on conflict (id) do nothing;
update mw_shop_items i set preset = v.preset,
       rarity = case when i.meta_v < 2 then v.rarity else i.rarity end,
       season = case when i.meta_v < 2 then v.season else i.season end,
       unlock = case when i.meta_v < 2 then v.u else i.unlock end
  from (values
   ('t_bakery','common',null,'{"wall": "wall_cream", "floor": "floor_wood", "layout": []}'::jsonb,null::jsonb),
   ('t_candy','rare',null,'{"wall": "wall_lilac", "floor": "floor_carpet", "layout": []}'::jsonb,null::jsonb),
   ('t_camping','rare',null,'{"wall": "wall_mint", "floor": "floor_grass", "layout": []}'::jsonb,null::jsonb),
   ('t_greenhouse','common',null,'{"wall": "wall_mint", "floor": "floor_tile", "layout": []}'::jsonb,null::jsonb),
   ('t_art','common',null,'{"wall": "wall_cream", "floor": "floor_wood", "layout": []}'::jsonb,null::jsonb),
   ('t_science','rare',null,'{"wall": "wall_sky", "floor": "floor_tile", "layout": []}'::jsonb,null::jsonb),
   ('t_dino','epic',null,'{"wall": "wall_stripe", "floor": "floor_marble", "layout": []}'::jsonb,null::jsonb),
   ('t_pirate','epic',null,'{"wall": "wall_stripe", "floor": "floor_wood", "layout": []}'::jsonb,null::jsonb),
   ('t_castle','epic',null,'{"wall": "wall_lilac", "floor": "floor_marble", "layout": []}'::jsonb,null::jsonb),
   ('t_treehouse','rare',null,'{"wall": "wall_mint", "floor": "floor_wood", "layout": []}'::jsonb,null::jsonb),
   ('t_cafe','common',null,'{"wall": "wall_cream", "floor": "floor_wood", "layout": []}'::jsonb,null::jsonb),
   ('t_hanok','rare',null,'{"wall": "wall_cream", "floor": "floor_wood", "layout": []}'::jsonb,null::jsonb),
   ('t_jungle','rare',null,'{"wall": "wall_mint", "floor": "floor_grass", "layout": []}'::jsonb,null::jsonb),
   ('t_igloo','rare',null,'{"wall": "wall_sky", "floor": "floor_cloud", "layout": []}'::jsonb,null::jsonb),
   ('t_train','rare',null,'{"wall": "wall_stripe", "floor": "floor_carpet", "layout": []}'::jsonb,null::jsonb),
   ('t_rocket','epic',null,'{"wall": "wall_star", "floor": "floor_tile", "layout": []}'::jsonb,null::jsonb),
   ('t_robot','epic',null,'{"wall": "wall_sky", "floor": "floor_tile", "layout": []}'::jsonb,null::jsonb),
   ('t_gym','common',null,'{"wall": "wall_sky", "floor": "floor_wood", "layout": []}'::jsonb,null::jsonb),
   ('t_arcade','rare',null,'{"wall": "wall_star", "floor": "floor_carpet", "layout": []}'::jsonb,null::jsonb),
   ('t_potion','epic',null,'{"wall": "wall_lilac", "floor": "floor_wood", "layout": []}'::jsonb,null::jsonb),
   ('t_fairy','rare',null,'{"wall": "wall_mint", "floor": "floor_grass", "layout": []}'::jsonb,null::jsonb),
   ('t_moon','epic',null,'{"wall": "wall_star", "floor": "floor_cloud", "layout": []}'::jsonb,null::jsonb),
   ('t_farm','common',null,'{"wall": "wall_cream", "floor": "floor_wood", "layout": []}'::jsonb,null::jsonb),
   ('t_pet','common',null,'{"wall": "wall_cream", "floor": "floor_carpet", "layout": []}'::jsonb,null::jsonb),
   ('t_stage','rare',null,'{"wall": "wall_lilac", "floor": "floor_wood", "layout": []}'::jsonb,null::jsonb),
   ('t_butterfly','rare','spring','{"wall": "wall_mint", "floor": "floor_grass", "layout": []}'::jsonb,null::jsonb),
   ('t_rainy','rare','summer','{"wall": "wall_sky", "floor": "floor_wood", "layout": []}'::jsonb,null::jsonb),
   ('t_chuseok','rare','autumn','{"wall": "wall_cream", "floor": "floor_wood", "layout": []}'::jsonb,null::jsonb),
   ('t_crystal','legend',null,'{"wall": "wall_star", "floor": "floor_marble", "layout": []}'::jsonb,'{"t": "books", "v": 15}'::jsonb),
   ('t_aurora','legend',null,'{"wall": "wall_star", "floor": "floor_cloud", "layout": []}'::jsonb,'{"t": "books", "v": 30}'::jsonb)
  ) as v(id, rarity, season, preset, u)
 where i.id = v.id;
-- v2.22: 아이템 기본 정보(원장이 고친 아이템은 건드리지 않음)
update mw_shop_items i set rarity = v.rarity, season = v.season, place = v.place, w = v.w, unlock = v.unlock, meta_v = 1
  from (values
   ('bed','common',null,'floor',2,null::jsonb),('desk','common',null,'floor',2,null),('chair','common',null,'floor',1,null),
   ('bookshelf','common',null,'floor',1,null),('sofa','common',null,'floor',2,null),('lamp','common',null,'floor',1,null),
   ('plant','common',null,'floor',1,null),('cactus','common',null,'floor',1,null),('rug','common',null,'floor',2,null),
   ('aquarium','rare',null,'floor',1,null),('trophy','epic',null,'floor',1,'{"t":"stage","v":2}'),('poster','common',null,'wall',1,null),
   ('window','common',null,'wall',2,null),('clock','common',null,'wall',1,null),('globe','common',null,'floor',1,'{"t":"stat","k":"read","v":1000}'),
   ('piano','rare',null,'floor',2,'{"t":"stat","k":"write","v":1000}'),('tv','rare',null,'floor',1,null),('beanbag','common',null,'floor',1,null),
   ('telescope','rare',null,'floor',1,'{"t":"books","v":10}'),('drawers','common',null,'floor',1,null),('guitar','rare',null,'floor',1,'{"t":"stat","k":"vocab","v":1000}'),
   ('petbed','common',null,'floor',1,null),('pennant','common',null,'wall',1,null),('fireplace','rare',null,'floor',2,null),
   ('wall_cream','common',null,'floor',1,null),('wall_mint','common',null,'floor',1,null),('wall_sky','common',null,'floor',1,null),
   ('wall_lilac','common',null,'floor',1,null),('wall_stripe','common',null,'floor',1,null),('wall_star','rare',null,'floor',1,null),
   ('floor_wood','common',null,'floor',1,null),('floor_tile','common',null,'floor',1,null),('floor_grass','common',null,'floor',1,null),
   ('floor_carpet','common',null,'floor',1,null),('floor_marble','rare',null,'floor',1,null),('floor_cloud','rare',null,'floor',1,null),
   ('acc_hat','common',null,'floor',1,null),('acc_ribbon','common',null,'floor',1,null),('acc_glasses','common',null,'floor',1,null),
   ('acc_scarf','common',null,'floor',1,null),('acc_headphones','rare',null,'floor',1,null),('acc_flower','common',null,'floor',1,null),
   ('acc_star','rare',null,'floor',1,'{"t":"stat","k":"grit","v":1000}'),('acc_crown','epic',null,'floor',1,'{"t":"stage","v":2}'),
   ('s_cherry','rare','spring','floor',1,null),('s_picnic','rare','spring','floor',2,null),('s_fan','rare','summer','floor',1,null),
   ('s_melon','rare','summer','floor',1,null),('s_float','rare','summer','floor',1,null),('s_maple','rare','autumn','floor',1,null),
   ('s_pumpkin','rare','autumn','floor',1,null),('s_tree','epic','winter','floor',1,null),('s_snowman','rare','winter','floor',1,null),
   ('s_gift','rare','winter','floor',1,null)
  ) as v(id, rarity, season, place, w, unlock)
 where i.id = v.id and i.meta_v < 1;

create table if not exists mw_inventory (
  student_id uuid not null references mw_profiles(id) on delete cascade,
  item_id text not null references mw_shop_items(id),
  qty int not null default 1,
  acquired_at timestamptz not null default now(),
  primary key (student_id, item_id)
);

create table if not exists mw_homes (
  student_id uuid primary key references mw_profiles(id) on delete cascade,
  wall text not null default 'wall_cream',
  floor text not null default 'floor_wood',
  layout jsonb not null default '[]'::jsonb,       -- [{"i": 가구 id, "x": 0~7, "y": 0~5}]
  updated_at timestamptz not null default now()
);
alter table mw_monsters add column if not exists acc text;   -- 씌운 액세서리
alter table mw_monsters add column if not exists gear jsonb not null default '{}'::jsonb;   -- v2.23 장비 {"head","body","hand","back"}
alter table mw_homes add column if not exists theme text;          -- v2.23 방 테마(없으면 자유 꾸미기)
-- 예전에 씌운 액세서리를 장비 칸으로 옮김(한 번만)
update mw_monsters m set gear = jsonb_build_object(i.slot, m.acc)
  from mw_shop_items i where i.id = m.acc and m.acc is not null and i.slot is not null and m.gear = '{}'::jsonb;

-- v2.18 친구 집 방문 + 스티커
alter table mw_profiles add column if not exists visit_key text not null default substr(md5(random()::text || clock_timestamp()::text), 1, 12);
create unique index if not exists mw_profiles_visit_key on mw_profiles(visit_key);
create table if not exists mw_stickers (
  id uuid primary key default gen_random_uuid(),
  from_student uuid not null references mw_profiles(id) on delete cascade,
  to_student uuid not null references mw_profiles(id) on delete cascade,
  kind text not null check (kind in ('like','fire','star','cute','cheer','best')),
  day date not null,
  created_at timestamptz not null default now(),
  unique (from_student, to_student, day)            -- 한 친구에게 하루 1개
);
create index if not exists mw_stickers_to on mw_stickers(to_student, created_at desc);

-- v2.19 친구 대결(정답 포함 → 클라이언트 직접 읽기 금지)
create table if not exists mw_duels (
  id uuid primary key default gen_random_uuid(),
  academy_id uuid not null,
  a uuid not null references mw_profiles(id) on delete cascade,   -- 신청한 학생
  b uuid not null references mw_profiles(id) on delete cascade,   -- 받은 학생
  items jsonb not null,
  status text not null default 'a_playing' check (status in ('a_playing','waiting','b_playing','done','expired')),
  result text check (result in ('a','b','draw')),
  day date not null,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null,
  finished_at timestamptz
);
create index if not exists mw_duels_a on mw_duels(a, created_at desc);
create index if not exists mw_duels_b on mw_duels(b, created_at desc);
create table if not exists mw_duel_play (
  duel_id uuid not null references mw_duels(id) on delete cascade,
  student_id uuid not null references mw_profiles(id) on delete cascade,
  qn int not null default 1,
  served_at timestamptz,                             -- 지금 문제를 보낸 시각(빠르기 계산)
  correct int not null default 0,
  raw int not null default 0,
  score int not null default 0,
  ms bigint not null default 0,
  power int not null default 10,
  done boolean not null default false,
  primary key (duel_id, student_id)
);

create table if not exists mw_word_misses (
  student_id uuid not null references mw_profiles(id) on delete cascade,
  academy_id uuid not null,
  k text not null,                                 -- 소문자 영어
  misses int not null default 0,
  last_at timestamptz not null default now(),
  primary key (student_id, academy_id, k)
);

-- 배틀 XP는 별도 종류(battle / battle_revoke)로 기록 → 주간 정산(grant만 합산)과 스탯에는 들어가지 않음
alter table mw_ledger add column if not exists battle_id uuid;
alter table mw_ledger drop constraint if exists mw_ledger_kind_check;
alter table mw_ledger add constraint mw_ledger_kind_check check (kind in ('grant','revoke','adjust','battle','battle_revoke'));
create unique index if not exists mw_ledger_battle_once on mw_ledger(battle_id, kind) where battle_id is not null;

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
    "home_visit": true,
    "duel": {"on":false,"win":15,"draw":5,"lose":3,"daily":3,"hours":48,"power_max":20},
    "coins": {"activity":5,"battle_first":10,"battle_rewin":2,"gate_first":30,"streak":20,"evo_elite":50,"evo_legend":100},
    "battle": {"first_xp":30,"rewin_xp":5,"gate_xp":100,"gate_rewin_xp":5,"shard_first":5,"shard_rewin":1,"shard_gate":20,"shard_gate_rewin":1,"shards_per_stone":100,"over_ratio":0.25,"streak":[{"days":3,"mult":1.2},{"days":7,"mult":1.5},{"days":30,"mult":2}],"hearts":3,"hp":120,"gate_hp":240,"pool":10,"gate_q":20,"combo":5,"advance_act":"vocab","dmg_base":10,"dmg_lv_div":5,"dmg_lv_max":10,"dmg_elite":3,"dmg_legend":6,"crit_per":200,"crit_max":25,"mix_rev":25,"mix_listen":25},
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

-- v2.16: 배틀 설정에 새 항목(공격력·치명타·문제 유형)을 더하고, 예전 기본 체력(10/20)은 공격력 단위에 맞게 120/240으로
update mw_settings set value = '{"first_xp":30,"rewin_xp":5,"gate_xp":100,"gate_rewin_xp":5,"shard_first":5,"shard_rewin":1,"shard_gate":20,"shard_gate_rewin":1,"shards_per_stone":100,"over_ratio":0.25,"streak":[{"days":3,"mult":1.2},{"days":7,"mult":1.5},{"days":30,"mult":2}],"hearts":3,"hp":120,"gate_hp":240,"pool":10,"gate_q":20,"combo":5,"advance_act":"vocab","dmg_base":10,"dmg_lv_div":5,"dmg_lv_max":10,"dmg_elite":3,"dmg_legend":6,"crit_per":200,"crit_max":25,"mix_rev":25,"mix_listen":25}'::jsonb || value where key = 'battle';
update mw_settings set value = value || '{"hp":120,"gate_hp":240}'::jsonb
 where key = 'battle' and value ->> 'hp' = '10' and value ->> 'gate_hp' = '20';

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

-- v2.20: 몬스터 도감 67가문 × 3단계 = 201종. 없는 가문은 새로 넣고, 이미 있는 가문은 비어 있는 값만 채웁니다.
-- (도감 관리 화면에서 고친 이름·설명·요구 레벨·이미지는 다시 실행해도 그대로 남습니다.)
do $mwdex$
declare r jsonb;
begin
  for r in select * from jsonb_array_elements($seed$[
 {"id":"flamy","no":1,"name":"FLAMY","name_ko":"플래미","animal":"불꽃 여우","concept":"용기와 도전","element":"fire","rarity":"starter","season":null,"art":{"body":"#F2A65A","belly":"#FFF3DC","accent":"#E8743B","dark":"#B5522A","ears":"fox","tail":"fox","mark":"flame"},"description":"작은 불꽃을 꼬리에 달고 다니는 여우. 처음 해 보는 일 앞에서 먼저 한 걸음을 내딛습니다.","forms":[{"stage":1,"id":"MW-001","stage_name":"Rookie","form_name":"Rookie Flamy","name_ko":"루키 플래미","description":"불꽃 여우의 첫 모습입니다. 용기와 도전의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-002","stage_name":"Elite","form_name":"Elite Flamy","name_ko":"엘리트 플래미","description":"한 단계 자란 플래미입니다. 용기와 도전의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-003","stage_name":"Legend","form_name":"Legend Flamy","name_ko":"레전드 플래미","description":"플래미의 마지막 모습입니다. 용기와 도전의 힘을 온전히 갖추었습니다."}]},
 {"id":"lumi","no":2,"name":"LUMI","name_ko":"루미","animal":"별빛 고양이","concept":"창의력과 지혜","element":"star","rarity":"starter","season":null,"art":{"body":"#B8A7E8","belly":"#F1ECFF","accent":"#7C63C9","dark":"#58439E","ears":"cat","tail":"cat","mark":"star"},"description":"밤하늘의 별빛을 모으는 고양이. 조용히 생각하다가 남다른 답을 찾아냅니다.","forms":[{"stage":1,"id":"MW-004","stage_name":"Rookie","form_name":"Rookie Lumi","name_ko":"루키 루미","description":"별빛 고양이의 첫 모습입니다. 창의력과 지혜의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-005","stage_name":"Elite","form_name":"Elite Lumi","name_ko":"엘리트 루미","description":"한 단계 자란 루미입니다. 창의력과 지혜의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-006","stage_name":"Legend","form_name":"Legend Lumi","name_ko":"레전드 루미","description":"루미의 마지막 모습입니다. 창의력과 지혜의 힘을 온전히 갖추었습니다."}]},
 {"id":"mochi","no":3,"name":"MOCHI","name_ko":"모치","animal":"숲 토끼","concept":"꾸준함과 성장","element":"forest","rarity":"starter","season":null,"art":{"body":"#B9E4D0","belly":"#F4FFF6","accent":"#6FBF8E","dark":"#3F8F63","ears":"bunny","tail":"puff","mark":"leaf"},"description":"숲길을 매일 같은 걸음으로 걷는 토끼. 하루하루 쌓은 만큼 자랍니다.","forms":[{"stage":1,"id":"MW-007","stage_name":"Rookie","form_name":"Rookie Mochi","name_ko":"루키 모치","description":"숲 토끼의 첫 모습입니다. 꾸준함과 성장의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-008","stage_name":"Elite","form_name":"Elite Mochi","name_ko":"엘리트 모치","description":"한 단계 자란 모치입니다. 꾸준함과 성장의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-009","stage_name":"Legend","form_name":"Legend Mochi","name_ko":"레전드 모치","description":"모치의 마지막 모습입니다. 꾸준함과 성장의 힘을 온전히 갖추었습니다."}]},
 {"id":"pebblo","no":4,"name":"PEBBLO","name_ko":"페블로","animal":"조약돌 곰","concept":"끈기와 집중","element":"earth","rarity":"common","season":null,"art":{"body":"#C9BCA8","belly":"#F6F0E4","accent":"#8C7B64","dark":"#5F5242","ears":"round","tail":"puff","mark":"stone"},"description":"강가의 조약돌처럼 단단한 곰. 한자리에 앉으면 끝날 때까지 일어나지 않습니다.","forms":[{"stage":1,"id":"MW-010","stage_name":"Rookie","form_name":"Rookie Pebblo","name_ko":"루키 페블로","description":"조약돌 곰의 첫 모습입니다. 끈기와 집중의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-011","stage_name":"Elite","form_name":"Elite Pebblo","name_ko":"엘리트 페블로","description":"한 단계 자란 페블로입니다. 끈기와 집중의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-012","stage_name":"Legend","form_name":"Legend Pebblo","name_ko":"레전드 페블로","description":"페블로의 마지막 모습입니다. 끈기와 집중의 힘을 온전히 갖추었습니다."}]},
 {"id":"nimbo","no":5,"name":"NIMBO","name_ko":"님보","animal":"구름 양","concept":"상상과 여유","element":"wind","rarity":"common","season":null,"art":{"body":"#DCE8F7","belly":"#FFFFFF","accent":"#8FB1DE","dark":"#5A7FB3","ears":"horn","tail":"puff","mark":"cloud"},"description":"구름 위를 걷는 양. 서두르지 않고 머릿속에 이야기를 그립니다.","forms":[{"stage":1,"id":"MW-013","stage_name":"Rookie","form_name":"Rookie Nimbo","name_ko":"루키 님보","description":"구름 양의 첫 모습입니다. 상상과 여유의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-014","stage_name":"Elite","form_name":"Elite Nimbo","name_ko":"엘리트 님보","description":"한 단계 자란 님보입니다. 상상과 여유의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-015","stage_name":"Legend","form_name":"Legend Nimbo","name_ko":"레전드 님보","description":"님보의 마지막 모습입니다. 상상과 여유의 힘을 온전히 갖추었습니다."}]},
 {"id":"tiddle","no":6,"name":"TIDDLE","name_ko":"티들","animal":"물방울 수달","concept":"호기심과 탐구","element":"water","rarity":"common","season":null,"art":{"body":"#8FCBE0","belly":"#EAF8FC","accent":"#3F96B8","dark":"#2B6F8C","ears":"round","tail":"drop","mark":"drop"},"description":"물속을 들여다보기 좋아하는 수달. 궁금한 것은 끝까지 따라가 봅니다.","forms":[{"stage":1,"id":"MW-016","stage_name":"Rookie","form_name":"Rookie Tiddle","name_ko":"루키 티들","description":"물방울 수달의 첫 모습입니다. 호기심과 탐구의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-017","stage_name":"Elite","form_name":"Elite Tiddle","name_ko":"엘리트 티들","description":"한 단계 자란 티들입니다. 호기심과 탐구의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-018","stage_name":"Legend","form_name":"Legend Tiddle","name_ko":"레전드 티들","description":"티들의 마지막 모습입니다. 호기심과 탐구의 힘을 온전히 갖추었습니다."}]},
 {"id":"lexi","no":7,"name":"LEXI","name_ko":"렉시","animal":"글자 다람쥐","concept":"어휘와 기억","element":"word","rarity":"common","season":null,"art":{"body":"#E9C46A","belly":"#FFF6DA","accent":"#C9772B","dark":"#8A5320","ears":"cat","tail":"fox","mark":"leaf"},"description":"낱말을 도토리처럼 모으는 다람쥐. 한 번 본 단어를 잘 잊지 않습니다.","forms":[{"stage":1,"id":"MW-019","stage_name":"Rookie","form_name":"Rookie Lexi","name_ko":"루키 렉시","description":"글자 다람쥐의 첫 모습입니다. 어휘와 기억의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-020","stage_name":"Elite","form_name":"Elite Lexi","name_ko":"엘리트 렉시","description":"한 단계 자란 렉시입니다. 어휘와 기억의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-021","stage_name":"Legend","form_name":"Legend Lexi","name_ko":"레전드 렉시","description":"렉시의 마지막 모습입니다. 어휘와 기억의 힘을 온전히 갖추었습니다."}]},
 {"id":"embit","no":8,"name":"EMBIT","name_ko":"엠빗","animal":"불씨 병아리","concept":"시작과 설렘","element":"fire","rarity":"common","season":null,"art":{"body":"#E3B596","belly":"#FBF4EE","accent":"#C6B22F","dark":"#8D5834","ears":"round","tail":"puff","mark":"flame"},"description":"갓 피어난 불씨를 품은 병아리. 무엇이든 처음 시작하는 순간을 좋아합니다.","forms":[{"stage":1,"id":"MW-022","stage_name":"Rookie","form_name":"Rookie Embit","name_ko":"루키 엠빗","description":"불씨 병아리의 첫 모습입니다. 시작과 설렘의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-023","stage_name":"Elite","form_name":"Elite Embit","name_ko":"엘리트 엠빗","description":"한 단계 자란 엠빗입니다. 시작과 설렘의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-024","stage_name":"Legend","form_name":"Legend Embit","name_ko":"레전드 엠빗","description":"엠빗의 마지막 모습입니다. 시작과 설렘의 힘을 온전히 갖추었습니다."}]},
 {"id":"sparko","no":9,"name":"SPARKO","name_ko":"스파코","animal":"불꽃 도마뱀","concept":"열정과 속도","element":"fire","rarity":"common","season":null,"art":{"body":"#E3A196","belly":"#FBF0EE","accent":"#C68A2F","dark":"#8D4034","ears":"horn","tail":"drop","mark":"flame"},"description":"꼬리 끝에서 불꽃이 튀는 도마뱀. 마음먹으면 바로 움직입니다.","forms":[{"stage":1,"id":"MW-025","stage_name":"Rookie","form_name":"Rookie Sparko","name_ko":"루키 스파코","description":"불꽃 도마뱀의 첫 모습입니다. 열정과 속도의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-026","stage_name":"Elite","form_name":"Elite Sparko","name_ko":"엘리트 스파코","description":"한 단계 자란 스파코입니다. 열정과 속도의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-027","stage_name":"Legend","form_name":"Legend Sparko","name_ko":"레전드 스파코","description":"스파코의 마지막 모습입니다. 열정과 속도의 힘을 온전히 갖추었습니다."}]},
 {"id":"toasty","no":10,"name":"TOASTY","name_ko":"토스티","animal":"화롯불 햄스터","concept":"따뜻함과 나눔","element":"fire","rarity":"common","season":null,"art":{"body":"#E3C496","belly":"#FBF6EE","accent":"#BCC62F","dark":"#8D6A34","ears":"round","tail":"puff","mark":"flame"},"description":"볼 주머니가 늘 따뜻한 햄스터. 아는 것을 친구와 나누기를 좋아합니다.","forms":[{"stage":1,"id":"MW-028","stage_name":"Rookie","form_name":"Rookie Toasty","name_ko":"루키 토스티","description":"화롯불 햄스터의 첫 모습입니다. 따뜻함과 나눔의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-029","stage_name":"Elite","form_name":"Elite Toasty","name_ko":"엘리트 토스티","description":"한 단계 자란 토스티입니다. 따뜻함과 나눔의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-030","stage_name":"Legend","form_name":"Legend Toasty","name_ko":"레전드 토스티","description":"토스티의 마지막 모습입니다. 따뜻함과 나눔의 힘을 온전히 갖추었습니다."}]},
 {"id":"dewie","no":11,"name":"DEWIE","name_ko":"듀이","animal":"이슬 개구리","concept":"맑음과 새로움","element":"water","rarity":"common","season":null,"art":{"body":"#96E3D0","belly":"#EEFBF8","accent":"#2FA5C6","dark":"#348D77","ears":"round","tail":"none","mark":"drop"},"description":"아침 이슬 위에 앉는 개구리. 어제 배운 것을 오늘 새 마음으로 다시 봅니다.","forms":[{"stage":1,"id":"MW-031","stage_name":"Rookie","form_name":"Rookie Dewie","name_ko":"루키 듀이","description":"이슬 개구리의 첫 모습입니다. 맑음과 새로움의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-032","stage_name":"Elite","form_name":"Elite Dewie","name_ko":"엘리트 듀이","description":"한 단계 자란 듀이입니다. 맑음과 새로움의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-033","stage_name":"Legend","form_name":"Legend Dewie","name_ko":"레전드 듀이","description":"듀이의 마지막 모습입니다. 맑음과 새로움의 힘을 온전히 갖추었습니다."}]},
 {"id":"bubblo","no":12,"name":"BUBBLO","name_ko":"버블로","animal":"물방울 복어","concept":"유쾌함과 여유","element":"water","rarity":"common","season":null,"art":{"body":"#96D6E3","belly":"#EEF9FB","accent":"#2F66C6","dark":"#347F8D","ears":"round","tail":"drop","mark":"drop"},"description":"기분이 좋으면 물방울을 부는 복어. 틀려도 웃으며 다시 해 봅니다.","forms":[{"stage":1,"id":"MW-034","stage_name":"Rookie","form_name":"Rookie Bubblo","name_ko":"루키 버블로","description":"물방울 복어의 첫 모습입니다. 유쾌함과 여유의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-035","stage_name":"Elite","form_name":"Elite Bubblo","name_ko":"엘리트 버블로","description":"한 단계 자란 버블로입니다. 유쾌함과 여유의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-036","stage_name":"Legend","form_name":"Legend Bubblo","name_ko":"레전드 버블로","description":"버블로의 마지막 모습입니다. 유쾌함과 여유의 힘을 온전히 갖추었습니다."}]},
 {"id":"ripplo","no":13,"name":"RIPPLO","name_ko":"리플로","animal":"잔물결 오리","concept":"차분함과 흐름","element":"water","rarity":"common","season":null,"art":{"body":"#96C3E3","belly":"#EEF6FB","accent":"#2F40C6","dark":"#34688D","ears":"round","tail":"puff","mark":"drop"},"description":"잔물결을 따라 헤엄치는 오리. 급하지 않게 차례대로 해 나갑니다.","forms":[{"stage":1,"id":"MW-037","stage_name":"Rookie","form_name":"Rookie Ripplo","name_ko":"루키 리플로","description":"잔물결 오리의 첫 모습입니다. 차분함과 흐름의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-038","stage_name":"Elite","form_name":"Elite Ripplo","name_ko":"엘리트 리플로","description":"한 단계 자란 리플로입니다. 차분함과 흐름의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-039","stage_name":"Legend","form_name":"Legend Ripplo","name_ko":"레전드 리플로","description":"리플로의 마지막 모습입니다. 차분함과 흐름의 힘을 온전히 갖추었습니다."}]},
 {"id":"sprouty","no":14,"name":"SPROUTY","name_ko":"스프라우티","animal":"새싹 두더지","concept":"기초와 성실","element":"forest","rarity":"common","season":null,"art":{"body":"#A9E396","belly":"#F2FBEE","accent":"#2FC64F","dark":"#4B8D34","ears":"round","tail":"none","mark":"leaf"},"description":"머리에 새싹이 난 두더지. 눈에 띄지 않는 기초를 먼저 다집니다.","forms":[{"stage":1,"id":"MW-040","stage_name":"Rookie","form_name":"Rookie Sprouty","name_ko":"루키 스프라우티","description":"새싹 두더지의 첫 모습입니다. 기초와 성실의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-041","stage_name":"Elite","form_name":"Elite Sprouty","name_ko":"엘리트 스프라우티","description":"한 단계 자란 스프라우티입니다. 기초와 성실의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-042","stage_name":"Legend","form_name":"Legend Sprouty","name_ko":"레전드 스프라우티","description":"스프라우티의 마지막 모습입니다. 기초와 성실의 힘을 온전히 갖추었습니다."}]},
 {"id":"acorny","no":15,"name":"ACORNY","name_ko":"에이코니","animal":"도토리 청설모","concept":"준비와 계획","element":"forest","rarity":"common","season":null,"art":{"body":"#E3BF96","belly":"#FBF5EE","accent":"#C6C62F","dark":"#8D6434","ears":"cat","tail":"fox","mark":"leaf"},"description":"도토리를 미리 모아 두는 청설모. 내일 할 일을 오늘 챙겨 둡니다.","forms":[{"stage":1,"id":"MW-043","stage_name":"Rookie","form_name":"Rookie Acorny","name_ko":"루키 에이코니","description":"도토리 청설모의 첫 모습입니다. 준비와 계획의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-044","stage_name":"Elite","form_name":"Elite Acorny","name_ko":"엘리트 에이코니","description":"한 단계 자란 에이코니입니다. 준비와 계획의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-045","stage_name":"Legend","form_name":"Legend Acorny","name_ko":"레전드 에이코니","description":"에이코니의 마지막 모습입니다. 준비와 계획의 힘을 온전히 갖추었습니다."}]},
 {"id":"fernie","no":16,"name":"FERNIE","name_ko":"퍼니","animal":"고사리 고슴도치","concept":"조심성과 배려","element":"forest","rarity":"common","season":null,"art":{"body":"#96E3A3","belly":"#EEFBF1","accent":"#2FC68F","dark":"#348D43","ears":"round","tail":"puff","mark":"leaf"},"description":"고사리 잎을 등에 진 고슴도치. 천천히 살피고 실수를 줄입니다.","forms":[{"stage":1,"id":"MW-046","stage_name":"Rookie","form_name":"Rookie Fernie","name_ko":"루키 퍼니","description":"고사리 고슴도치의 첫 모습입니다. 조심성과 배려의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-047","stage_name":"Elite","form_name":"Elite Fernie","name_ko":"엘리트 퍼니","description":"한 단계 자란 퍼니입니다. 조심성과 배려의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-048","stage_name":"Legend","form_name":"Legend Fernie","name_ko":"레전드 퍼니","description":"퍼니의 마지막 모습입니다. 조심성과 배려의 힘을 온전히 갖추었습니다."}]},
 {"id":"mossy","no":17,"name":"MOSSY","name_ko":"모시","animal":"이끼 달팽이","concept":"느림과 꾸준함","element":"forest","rarity":"common","season":null,"art":{"body":"#C3E396","belly":"#F6FBEE","accent":"#40C62F","dark":"#688D34","ears":"horn","tail":"none","mark":"leaf"},"description":"등껍질에 이끼가 자라는 달팽이. 느린 걸음으로 가장 멀리 갑니다.","forms":[{"stage":1,"id":"MW-049","stage_name":"Rookie","form_name":"Rookie Mossy","name_ko":"루키 모시","description":"이끼 달팽이의 첫 모습입니다. 느림과 꾸준함의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-050","stage_name":"Elite","form_name":"Elite Mossy","name_ko":"엘리트 모시","description":"한 단계 자란 모시입니다. 느림과 꾸준함의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-051","stage_name":"Legend","form_name":"Legend Mossy","name_ko":"레전드 모시","description":"모시의 마지막 모습입니다. 느림과 꾸준함의 힘을 온전히 갖추었습니다."}]},
 {"id":"breezy","no":18,"name":"BREEZY","name_ko":"브리지","animal":"산들바람 참새","concept":"가벼움과 자유","element":"wind","rarity":"common","season":null,"art":{"body":"#96CAE3","belly":"#EEF7FB","accent":"#2F4DC6","dark":"#34708D","ears":"owl","tail":"none","mark":"cloud"},"description":"산들바람을 타고 다니는 참새. 가벼운 마음으로 새 책을 펼칩니다.","forms":[{"stage":1,"id":"MW-052","stage_name":"Rookie","form_name":"Rookie Breezy","name_ko":"루키 브리지","description":"산들바람 참새의 첫 모습입니다. 가벼움과 자유의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-053","stage_name":"Elite","form_name":"Elite Breezy","name_ko":"엘리트 브리지","description":"한 단계 자란 브리지입니다. 가벼움과 자유의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-054","stage_name":"Legend","form_name":"Legend Breezy","name_ko":"레전드 브리지","description":"브리지의 마지막 모습입니다. 가벼움과 자유의 힘을 온전히 갖추었습니다."}]},
 {"id":"whiffy","no":19,"name":"WHIFFY","name_ko":"위피","animal":"솜바람 강아지","concept":"친근함과 활기","element":"wind","rarity":"common","season":null,"art":{"body":"#96B6E3","belly":"#EEF4FB","accent":"#362FC6","dark":"#34598D","ears":"round","tail":"puff","mark":"cloud"},"description":"솜털 같은 바람을 몰고 다니는 강아지. 누구에게나 먼저 인사합니다.","forms":[{"stage":1,"id":"MW-055","stage_name":"Rookie","form_name":"Rookie Whiffy","name_ko":"루키 위피","description":"솜바람 강아지의 첫 모습입니다. 친근함과 활기의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-056","stage_name":"Elite","form_name":"Elite Whiffy","name_ko":"엘리트 위피","description":"한 단계 자란 위피입니다. 친근함과 활기의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-057","stage_name":"Legend","form_name":"Legend Whiffy","name_ko":"레전드 위피","description":"위피의 마지막 모습입니다. 친근함과 활기의 힘을 온전히 갖추었습니다."}]},
 {"id":"kiteo","no":20,"name":"KITEO","name_ko":"카이토","animal":"연 다람쥐","concept":"도전과 균형","element":"wind","rarity":"common","season":null,"art":{"body":"#B096E3","belly":"#F3EEFB","accent":"#A82FC6","dark":"#52348D","ears":"cat","tail":"fox","mark":"cloud"},"description":"연처럼 바람을 타는 다람쥐. 높이 오르면서도 중심을 잃지 않습니다.","forms":[{"stage":1,"id":"MW-058","stage_name":"Rookie","form_name":"Rookie Kiteo","name_ko":"루키 카이토","description":"연 다람쥐의 첫 모습입니다. 도전과 균형의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-059","stage_name":"Elite","form_name":"Elite Kiteo","name_ko":"엘리트 카이토","description":"한 단계 자란 카이토입니다. 도전과 균형의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-060","stage_name":"Legend","form_name":"Legend Kiteo","name_ko":"레전드 카이토","description":"카이토의 마지막 모습입니다. 도전과 균형의 힘을 온전히 갖추었습니다."}]},
 {"id":"clayo","no":21,"name":"CLAYO","name_ko":"클레이오","animal":"찰흙 비버","concept":"만들기와 인내","element":"earth","rarity":"common","season":null,"art":{"body":"#E3B296","belly":"#FBF3EE","accent":"#C6AD2F","dark":"#8D5534","ears":"round","tail":"drop","mark":"stone"},"description":"찰흙으로 무엇이든 빚는 비버. 마음에 들 때까지 고쳐 만듭니다.","forms":[{"stage":1,"id":"MW-061","stage_name":"Rookie","form_name":"Rookie Clayo","name_ko":"루키 클레이오","description":"찰흙 비버의 첫 모습입니다. 만들기와 인내의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-062","stage_name":"Elite","form_name":"Elite Clayo","name_ko":"엘리트 클레이오","description":"한 단계 자란 클레이오입니다. 만들기와 인내의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-063","stage_name":"Legend","form_name":"Legend Clayo","name_ko":"레전드 클레이오","description":"클레이오의 마지막 모습입니다. 만들기와 인내의 힘을 온전히 갖추었습니다."}]},
 {"id":"sando","no":22,"name":"SANDO","name_ko":"샌도","animal":"모래 미어캣","concept":"관찰과 주의","element":"earth","rarity":"common","season":null,"art":{"body":"#E3CC96","belly":"#FBF7EE","accent":"#ADC62F","dark":"#8D7334","ears":"cat","tail":"cat","mark":"stone"},"description":"모래 언덕 위에 서서 살피는 미어캣. 작은 차이도 놓치지 않습니다.","forms":[{"stage":1,"id":"MW-064","stage_name":"Rookie","form_name":"Rookie Sando","name_ko":"루키 샌도","description":"모래 미어캣의 첫 모습입니다. 관찰과 주의의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-065","stage_name":"Elite","form_name":"Elite Sando","name_ko":"엘리트 샌도","description":"한 단계 자란 샌도입니다. 관찰과 주의의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-066","stage_name":"Legend","form_name":"Legend Sando","name_ko":"레전드 샌도","description":"샌도의 마지막 모습입니다. 관찰과 주의의 힘을 온전히 갖추었습니다."}]},
 {"id":"rooty","no":23,"name":"ROOTY","name_ko":"루티","animal":"뿌리 너구리","concept":"근성과 뚝심","element":"earth","rarity":"common","season":null,"art":{"body":"#E3BA96","belly":"#FBF4EE","accent":"#C6BC2F","dark":"#8D5E34","ears":"round","tail":"fox","mark":"stone"},"description":"나무뿌리 아래 사는 너구리. 한 번 정한 일은 끝까지 붙듭니다.","forms":[{"stage":1,"id":"MW-067","stage_name":"Rookie","form_name":"Rookie Rooty","name_ko":"루키 루티","description":"뿌리 너구리의 첫 모습입니다. 근성과 뚝심의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-068","stage_name":"Elite","form_name":"Elite Rooty","name_ko":"엘리트 루티","description":"한 단계 자란 루티입니다. 근성과 뚝심의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-069","stage_name":"Legend","form_name":"Legend Rooty","name_ko":"레전드 루티","description":"루티의 마지막 모습입니다. 근성과 뚝심의 힘을 온전히 갖추었습니다."}]},
 {"id":"twinkle","no":24,"name":"TWINKLE","name_ko":"트윙클","animal":"반짝 생쥐","concept":"호기심과 발견","element":"star","rarity":"common","season":null,"art":{"body":"#E3D996","belly":"#FBFAEE","accent":"#94C62F","dark":"#8D8234","ears":"round","tail":"cat","mark":"star"},"description":"눈이 별처럼 반짝이는 생쥐. 작은 것에서 새로운 것을 찾아냅니다.","forms":[{"stage":1,"id":"MW-070","stage_name":"Rookie","form_name":"Rookie Twinkle","name_ko":"루키 트윙클","description":"반짝 생쥐의 첫 모습입니다. 호기심과 발견의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-071","stage_name":"Elite","form_name":"Elite Twinkle","name_ko":"엘리트 트윙클","description":"한 단계 자란 트윙클입니다. 호기심과 발견의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-072","stage_name":"Legend","form_name":"Legend Twinkle","name_ko":"레전드 트윙클","description":"트윙클의 마지막 모습입니다. 호기심과 발견의 힘을 온전히 갖추었습니다."}]},
 {"id":"glimmy","no":25,"name":"GLIMMY","name_ko":"글리미","animal":"반딧불 아기곰","concept":"희망과 길잡이","element":"star","rarity":"common","season":null,"art":{"body":"#D6E396","belly":"#F9FBEE","accent":"#66C62F","dark":"#7F8D34","ears":"round","tail":"puff","mark":"star"},"description":"배에 반딧불을 켠 아기곰. 어두운 길에서도 갈 곳을 알려 줍니다.","forms":[{"stage":1,"id":"MW-073","stage_name":"Rookie","form_name":"Rookie Glimmy","name_ko":"루키 글리미","description":"반딧불 아기곰의 첫 모습입니다. 희망과 길잡이의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-074","stage_name":"Elite","form_name":"Elite Glimmy","name_ko":"엘리트 글리미","description":"한 단계 자란 글리미입니다. 희망과 길잡이의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-075","stage_name":"Legend","form_name":"Legend Glimmy","name_ko":"레전드 글리미","description":"글리미의 마지막 모습입니다. 희망과 길잡이의 힘을 온전히 갖추었습니다."}]},
 {"id":"inklo","no":26,"name":"INKLO","name_ko":"잉클로","animal":"잉크 문어","concept":"표현과 상상","element":"word","rarity":"common","season":null,"art":{"body":"#A396E3","belly":"#F1EEFB","accent":"#8F2FC6","dark":"#43348D","ears":"round","tail":"none","mark":"quill"},"description":"여덟 다리로 글을 쓰는 문어. 떠오른 생각을 바로 적어 둡니다.","forms":[{"stage":1,"id":"MW-076","stage_name":"Rookie","form_name":"Rookie Inklo","name_ko":"루키 잉클로","description":"잉크 문어의 첫 모습입니다. 표현과 상상의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-077","stage_name":"Elite","form_name":"Elite Inklo","name_ko":"엘리트 잉클로","description":"한 단계 자란 잉클로입니다. 표현과 상상의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-078","stage_name":"Legend","form_name":"Legend Inklo","name_ko":"레전드 잉클로","description":"잉클로의 마지막 모습입니다. 표현과 상상의 힘을 온전히 갖추었습니다."}]},
 {"id":"pagie","no":27,"name":"PAGIE","name_ko":"페이지","animal":"책갈피 고양이","concept":"독서와 몰입","element":"word","rarity":"common","season":null,"art":{"body":"#E396B0","belly":"#FBEEF3","accent":"#C6432F","dark":"#8D3452","ears":"cat","tail":"cat","mark":"quill"},"description":"책 사이에서 낮잠을 자는 고양이. 책을 펼치면 주변 소리가 들리지 않습니다.","forms":[{"stage":1,"id":"MW-079","stage_name":"Rookie","form_name":"Rookie Pagie","name_ko":"루키 페이지","description":"책갈피 고양이의 첫 모습입니다. 독서와 몰입의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-080","stage_name":"Elite","form_name":"Elite Pagie","name_ko":"엘리트 페이지","description":"한 단계 자란 페이지입니다. 독서와 몰입의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-081","stage_name":"Legend","form_name":"Legend Pagie","name_ko":"레전드 페이지","description":"페이지의 마지막 모습입니다. 독서와 몰입의 힘을 온전히 갖추었습니다."}]},
 {"id":"dotto","no":28,"name":"DOTTO","name_ko":"도토","animal":"마침표 무당벌레","concept":"정확함과 마무리","element":"word","rarity":"common","season":null,"art":{"body":"#E3969D","belly":"#FBEEEF","accent":"#C6692F","dark":"#8D343C","ears":"round","tail":"none","mark":"quill"},"description":"등에 마침표를 찍은 무당벌레. 시작한 문장은 꼭 끝맺습니다.","forms":[{"stage":1,"id":"MW-082","stage_name":"Rookie","form_name":"Rookie Dotto","name_ko":"루키 도토","description":"마침표 무당벌레의 첫 모습입니다. 정확함과 마무리의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-083","stage_name":"Elite","form_name":"Elite Dotto","name_ko":"엘리트 도토","description":"한 단계 자란 도토입니다. 정확함과 마무리의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-084","stage_name":"Legend","form_name":"Legend Dotto","name_ko":"레전드 도토","description":"도토의 마지막 모습입니다. 정확함과 마무리의 힘을 온전히 갖추었습니다."}]},
 {"id":"snowby","no":29,"name":"SNOWBY","name_ko":"스노비","animal":"눈송이 물범","concept":"포근함과 휴식","element":"ice","rarity":"common","season":null,"art":{"body":"#96CCE3","belly":"#EEF7FB","accent":"#2F52C6","dark":"#34738D","ears":"round","tail":"drop","mark":"snow"},"description":"눈밭에서 뒹구는 물범. 잘 쉬는 것도 실력이라고 믿습니다.","forms":[{"stage":1,"id":"MW-085","stage_name":"Rookie","form_name":"Rookie Snowby","name_ko":"루키 스노비","description":"눈송이 물범의 첫 모습입니다. 포근함과 휴식의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-086","stage_name":"Elite","form_name":"Elite Snowby","name_ko":"엘리트 스노비","description":"한 단계 자란 스노비입니다. 포근함과 휴식의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-087","stage_name":"Legend","form_name":"Legend Snowby","name_ko":"레전드 스노비","description":"스노비의 마지막 모습입니다. 포근함과 휴식의 힘을 온전히 갖추었습니다."}]},
 {"id":"quillo","no":30,"name":"QUILLO","name_ko":"퀼로","animal":"깃펜 부엉이","concept":"글쓰기와 표현","element":"word","rarity":"rare","season":null,"art":{"body":"#4E5A85","belly":"#E9E4D4","accent":"#D9B25F","dark":"#28314B","ears":"owl","tail":"none","mark":"quill"},"description":"깃펜을 품고 다니는 부엉이. 생각을 문장으로 옮기는 일을 즐깁니다.","forms":[{"stage":1,"id":"MW-088","stage_name":"Rookie","form_name":"Rookie Quillo","name_ko":"루키 퀼로","description":"깃펜 부엉이의 첫 모습입니다. 글쓰기와 표현의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-089","stage_name":"Elite","form_name":"Elite Quillo","name_ko":"엘리트 퀼로","description":"한 단계 자란 퀼로입니다. 글쓰기와 표현의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-090","stage_name":"Legend","form_name":"Legend Quillo","name_ko":"레전드 퀼로","description":"퀼로의 마지막 모습입니다. 글쓰기와 표현의 힘을 온전히 갖추었습니다."}]},
 {"id":"aurorix","no":31,"name":"AURORIX","name_ko":"오로릭스","animal":"오로라 사슴","concept":"통찰과 품격","element":"star","rarity":"rare","season":null,"art":{"body":"#F5A995","belly":"#FFF1EA","accent":"#7FD1C2","dark":"#B86B58","ears":"antler","tail":"puff","mark":"star"},"description":"뿔에 오로라가 걸리는 사슴. 많이 읽은 만큼 멀리 내다봅니다.","forms":[{"stage":1,"id":"MW-091","stage_name":"Rookie","form_name":"Rookie Aurorix","name_ko":"루키 오로릭스","description":"오로라 사슴의 첫 모습입니다. 통찰과 품격의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-092","stage_name":"Elite","form_name":"Elite Aurorix","name_ko":"엘리트 오로릭스","description":"한 단계 자란 오로릭스입니다. 통찰과 품격의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-093","stage_name":"Legend","form_name":"Legend Aurorix","name_ko":"레전드 오로릭스","description":"오로릭스의 마지막 모습입니다. 통찰과 품격의 힘을 온전히 갖추었습니다."}]},
 {"id":"runex","no":32,"name":"RUNEX","name_ko":"루넥스","animal":"룬 비룡","concept":"언어의 힘","element":"word","rarity":"rare","season":null,"art":{"body":"#3E8E8A","belly":"#E2F4EF","accent":"#E3B341","dark":"#21534F","ears":"horn","tail":"fox","mark":"star"},"description":"오래된 글자를 몸에 새긴 비룡. 아는 말이 늘수록 날개가 커집니다.","forms":[{"stage":1,"id":"MW-094","stage_name":"Rookie","form_name":"Rookie Runex","name_ko":"루키 루넥스","description":"룬 비룡의 첫 모습입니다. 언어의 힘의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-095","stage_name":"Elite","form_name":"Elite Runex","name_ko":"엘리트 루넥스","description":"한 단계 자란 루넥스입니다. 언어의 힘의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-096","stage_name":"Legend","form_name":"Legend Runex","name_ko":"레전드 루넥스","description":"루넥스의 마지막 모습입니다. 언어의 힘의 힘을 온전히 갖추었습니다."}]},
 {"id":"terron","no":33,"name":"TERRON","name_ko":"테론","animal":"바위 거북","concept":"불굴의 의지","element":"earth","rarity":"rare","season":null,"art":{"body":"#7D8B6A","belly":"#EEF0E2","accent":"#C46A3A","dark":"#4A5540","ears":"round","tail":"none","mark":"stone"},"description":"등에 바위를 진 거북. 느려도 멈추지 않고 끝까지 갑니다.","forms":[{"stage":1,"id":"MW-097","stage_name":"Rookie","form_name":"Rookie Terron","name_ko":"루키 테론","description":"바위 거북의 첫 모습입니다. 불굴의 의지의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-098","stage_name":"Elite","form_name":"Elite Terron","name_ko":"엘리트 테론","description":"한 단계 자란 테론입니다. 불굴의 의지의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-099","stage_name":"Legend","form_name":"Legend Terron","name_ko":"레전드 테론","description":"테론의 마지막 모습입니다. 불굴의 의지의 힘을 온전히 갖추었습니다."}]},
 {"id":"flaren","no":34,"name":"FLAREN","name_ko":"플라렌","animal":"화염 늑대","concept":"결단과 리더십","element":"fire","rarity":"rare","season":null,"art":{"body":"#D0806C","belly":"#F7E7E3","accent":"#C6942F","dark":"#5D3228","ears":"fox","tail":"fox","mark":"flame"},"description":"갈기가 불길처럼 일렁이는 늑대. 망설이는 무리 앞에서 방향을 정합니다.","forms":[{"stage":1,"id":"MW-100","stage_name":"Rookie","form_name":"Rookie Flaren","name_ko":"루키 플라렌","description":"화염 늑대의 첫 모습입니다. 결단과 리더십의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-101","stage_name":"Elite","form_name":"Elite Flaren","name_ko":"엘리트 플라렌","description":"한 단계 자란 플라렌입니다. 결단과 리더십의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-102","stage_name":"Legend","form_name":"Legend Flaren","name_ko":"레전드 플라렌","description":"플라렌의 마지막 모습입니다. 결단과 리더십의 힘을 온전히 갖추었습니다."}]},
 {"id":"cindra","no":35,"name":"CINDRA","name_ko":"신드라","animal":"잿불 고양이","concept":"침착함과 재기","element":"fire","rarity":"rare","season":null,"art":{"body":"#D06C7D","belly":"#F7E3E6","accent":"#C65C2F","dark":"#5D2831","ears":"cat","tail":"cat","mark":"flame"},"description":"잿더미 속 불씨를 지키는 고양이. 넘어져도 조용히 다시 일어섭니다.","forms":[{"stage":1,"id":"MW-103","stage_name":"Rookie","form_name":"Rookie Cindra","name_ko":"루키 신드라","description":"잿불 고양이의 첫 모습입니다. 침착함과 재기의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-104","stage_name":"Elite","form_name":"Elite Cindra","name_ko":"엘리트 신드라","description":"한 단계 자란 신드라입니다. 침착함과 재기의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-105","stage_name":"Legend","form_name":"Legend Cindra","name_ko":"레전드 신드라","description":"신드라의 마지막 모습입니다. 침착함과 재기의 힘을 온전히 갖추었습니다."}]},
 {"id":"magmo","no":36,"name":"MAGMO","name_ko":"마그모","animal":"용암 거북","concept":"인내와 폭발력","element":"fire","rarity":"rare","season":null,"art":{"body":"#D08A6C","belly":"#F7E9E3","accent":"#C6A32F","dark":"#5D3828","ears":"round","tail":"none","mark":"flame"},"description":"등껍질 아래 용암이 흐르는 거북. 오래 참고 준비한 힘을 한 번에 냅니다.","forms":[{"stage":1,"id":"MW-106","stage_name":"Rookie","form_name":"Rookie Magmo","name_ko":"루키 마그모","description":"용암 거북의 첫 모습입니다. 인내와 폭발력의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-107","stage_name":"Elite","form_name":"Elite Magmo","name_ko":"엘리트 마그모","description":"한 단계 자란 마그모입니다. 인내와 폭발력의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-108","stage_name":"Legend","form_name":"Legend Magmo","name_ko":"레전드 마그모","description":"마그모의 마지막 모습입니다. 인내와 폭발력의 힘을 온전히 갖추었습니다."}]},
 {"id":"coralia","no":37,"name":"CORALIA","name_ko":"코랄리아","animal":"산호 해마","concept":"섬세함과 조화","element":"water","rarity":"rare","season":null,"art":{"body":"#D06C85","belly":"#F7E3E8","accent":"#C64F2F","dark":"#5D2835","ears":"horn","tail":"drop","mark":"drop"},"description":"산호 숲을 가꾸는 해마. 작은 부분까지 살펴 전체를 맞춥니다.","forms":[{"stage":1,"id":"MW-109","stage_name":"Rookie","form_name":"Rookie Coralia","name_ko":"루키 코랄리아","description":"산호 해마의 첫 모습입니다. 섬세함과 조화의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-110","stage_name":"Elite","form_name":"Elite Coralia","name_ko":"엘리트 코랄리아","description":"한 단계 자란 코랄리아입니다. 섬세함과 조화의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-111","stage_name":"Legend","form_name":"Legend Coralia","name_ko":"레전드 코랄리아","description":"코랄리아의 마지막 모습입니다. 섬세함과 조화의 힘을 온전히 갖추었습니다."}]},
 {"id":"tidelo","no":38,"name":"TIDELO","name_ko":"타이델로","animal":"밀물 돌고래","concept":"리듬과 협동","element":"water","rarity":"rare","season":null,"art":{"body":"#6C9ED0","belly":"#E3EDF7","accent":"#2F34C6","dark":"#28425D","ears":"round","tail":"drop","mark":"drop"},"description":"밀물과 썰물의 때를 아는 돌고래. 친구들과 호흡을 맞춰 헤엄칩니다.","forms":[{"stage":1,"id":"MW-112","stage_name":"Rookie","form_name":"Rookie Tidelo","name_ko":"루키 타이델로","description":"밀물 돌고래의 첫 모습입니다. 리듬과 협동의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-113","stage_name":"Elite","form_name":"Elite Tidelo","name_ko":"엘리트 타이델로","description":"한 단계 자란 타이델로입니다. 리듬과 협동의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-114","stage_name":"Legend","form_name":"Legend Tidelo","name_ko":"레전드 타이델로","description":"타이델로의 마지막 모습입니다. 리듬과 협동의 힘을 온전히 갖추었습니다."}]},
 {"id":"thornix","no":39,"name":"THORNIX","name_ko":"쏘닉스","animal":"가시덤불 살쾡이","concept":"신중함과 용기","element":"forest","rarity":"rare","season":null,"art":{"body":"#6CD08D","belly":"#E3F7EA","accent":"#2FC6A8","dark":"#285D39","ears":"cat","tail":"cat","mark":"leaf"},"description":"가시덤불 속을 지나는 살쾡이. 어려운 길을 피하지 않고 살피며 갑니다.","forms":[{"stage":1,"id":"MW-115","stage_name":"Rookie","form_name":"Rookie Thornix","name_ko":"루키 쏘닉스","description":"가시덤불 살쾡이의 첫 모습입니다. 신중함과 용기의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-116","stage_name":"Elite","form_name":"Elite Thornix","name_ko":"엘리트 쏘닉스","description":"한 단계 자란 쏘닉스입니다. 신중함과 용기의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-117","stage_name":"Legend","form_name":"Legend Thornix","name_ko":"레전드 쏘닉스","description":"쏘닉스의 마지막 모습입니다. 신중함과 용기의 힘을 온전히 갖추었습니다."}]},
 {"id":"willowa","no":40,"name":"WILLOWA","name_ko":"윌로와","animal":"버드나무 사슴","concept":"유연함과 품위","element":"forest","rarity":"rare","season":null,"art":{"body":"#96D06C","belly":"#EBF7E3","accent":"#2FC636","dark":"#3E5D28","ears":"antler","tail":"puff","mark":"leaf"},"description":"버드나무 가지 같은 뿔을 가진 사슴. 바람에 휘어도 꺾이지 않습니다.","forms":[{"stage":1,"id":"MW-118","stage_name":"Rookie","form_name":"Rookie Willowa","name_ko":"루키 윌로와","description":"버드나무 사슴의 첫 모습입니다. 유연함과 품위의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-119","stage_name":"Elite","form_name":"Elite Willowa","name_ko":"엘리트 윌로와","description":"한 단계 자란 윌로와입니다. 유연함과 품위의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-120","stage_name":"Legend","form_name":"Legend Willowa","name_ko":"레전드 윌로와","description":"윌로와의 마지막 모습입니다. 유연함과 품위의 힘을 온전히 갖추었습니다."}]},
 {"id":"galeon","no":41,"name":"GALEON","name_ko":"게일온","animal":"돌풍 매","concept":"집중과 속도","element":"wind","rarity":"rare","season":null,"art":{"body":"#6C8DD0","belly":"#E3EAF7","accent":"#432FC6","dark":"#28395D","ears":"owl","tail":"none","mark":"cloud"},"description":"돌풍을 가르는 매. 목표 하나를 정하면 눈을 떼지 않습니다.","forms":[{"stage":1,"id":"MW-121","stage_name":"Rookie","form_name":"Rookie Galeon","name_ko":"루키 게일온","description":"돌풍 매의 첫 모습입니다. 집중과 속도의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-122","stage_name":"Elite","form_name":"Elite Galeon","name_ko":"엘리트 게일온","description":"한 단계 자란 게일온입니다. 집중과 속도의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-123","stage_name":"Legend","form_name":"Legend Galeon","name_ko":"레전드 게일온","description":"게일온의 마지막 모습입니다. 집중과 속도의 힘을 온전히 갖추었습니다."}]},
 {"id":"zephie","no":42,"name":"ZEPHIE","name_ko":"제피","animal":"서풍 여우","concept":"재치와 민첩","element":"wind","rarity":"rare","season":null,"art":{"body":"#6CC8D0","belly":"#E3F6F7","accent":"#2F73C6","dark":"#28585D","ears":"fox","tail":"fox","mark":"cloud"},"description":"서풍을 타고 달리는 여우. 막히면 다른 길을 금방 찾아냅니다.","forms":[{"stage":1,"id":"MW-124","stage_name":"Rookie","form_name":"Rookie Zephie","name_ko":"루키 제피","description":"서풍 여우의 첫 모습입니다. 재치와 민첩의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-125","stage_name":"Elite","form_name":"Elite Zephie","name_ko":"엘리트 제피","description":"한 단계 자란 제피입니다. 재치와 민첩의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-126","stage_name":"Legend","form_name":"Legend Zephie","name_ko":"레전드 제피","description":"제피의 마지막 모습입니다. 재치와 민첩의 힘을 온전히 갖추었습니다."}]},
 {"id":"quarzo","no":43,"name":"QUARZO","name_ko":"쿼조","animal":"수정 아르마딜로","concept":"단단함과 투명함","element":"earth","rarity":"rare","season":null,"art":{"body":"#AF6CD0","belly":"#F1E3F7","accent":"#C62FB2","dark":"#4B285D","ears":"round","tail":"none","mark":"stone"},"description":"등에 수정이 돋은 아르마딜로. 모르는 것은 모른다고 말하고 다시 배웁니다.","forms":[{"stage":1,"id":"MW-127","stage_name":"Rookie","form_name":"Rookie Quarzo","name_ko":"루키 쿼조","description":"수정 아르마딜로의 첫 모습입니다. 단단함과 투명함의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-128","stage_name":"Elite","form_name":"Elite Quarzo","name_ko":"엘리트 쿼조","description":"한 단계 자란 쿼조입니다. 단단함과 투명함의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-129","stage_name":"Legend","form_name":"Legend Quarzo","name_ko":"레전드 쿼조","description":"쿼조의 마지막 모습입니다. 단단함과 투명함의 힘을 온전히 갖추었습니다."}]},
 {"id":"novalo","no":44,"name":"NOVALO","name_ko":"노발로","animal":"신성 토끼","concept":"도약과 가능성","element":"star","rarity":"rare","season":null,"art":{"body":"#D06CD0","belly":"#F7E3F7","accent":"#C62F7F","dark":"#5D285D","ears":"bunny","tail":"puff","mark":"star"},"description":"새로 태어난 별빛을 두른 토끼. 한 번의 도약으로 한 단계를 넘어섭니다.","forms":[{"stage":1,"id":"MW-130","stage_name":"Rookie","form_name":"Rookie Novalo","name_ko":"루키 노발로","description":"신성 토끼의 첫 모습입니다. 도약과 가능성의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-131","stage_name":"Elite","form_name":"Elite Novalo","name_ko":"엘리트 노발로","description":"한 단계 자란 노발로입니다. 도약과 가능성의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-132","stage_name":"Legend","form_name":"Legend Novalo","name_ko":"레전드 노발로","description":"노발로의 마지막 모습입니다. 도약과 가능성의 힘을 온전히 갖추었습니다."}]},
 {"id":"comette","no":45,"name":"COMETTE","name_ko":"코메트","animal":"혜성 족제비","concept":"추진력과 방향","element":"star","rarity":"rare","season":null,"art":{"body":"#6C7DD0","belly":"#E3E6F7","accent":"#5C2FC6","dark":"#28315D","ears":"cat","tail":"fox","mark":"star"},"description":"혜성 같은 꼬리를 끄는 족제비. 가야 할 곳을 향해 곧게 나아갑니다.","forms":[{"stage":1,"id":"MW-133","stage_name":"Rookie","form_name":"Rookie Comette","name_ko":"루키 코메트","description":"혜성 족제비의 첫 모습입니다. 추진력과 방향의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-134","stage_name":"Elite","form_name":"Elite Comette","name_ko":"엘리트 코메트","description":"한 단계 자란 코메트입니다. 추진력과 방향의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-135","stage_name":"Legend","form_name":"Legend Comette","name_ko":"레전드 코메트","description":"코메트의 마지막 모습입니다. 추진력과 방향의 힘을 온전히 갖추었습니다."}]},
 {"id":"scrollo","no":46,"name":"SCROLLO","name_ko":"스크롤로","animal":"두루마리 너구리","concept":"기록과 정리","element":"word","rarity":"rare","season":null,"art":{"body":"#D0AC6C","belly":"#F7F0E3","accent":"#B7C62F","dark":"#5D4928","ears":"round","tail":"fox","mark":"quill"},"description":"두루마리를 메고 다니는 너구리. 배운 것을 적어 두고 다시 꺼내 봅니다.","forms":[{"stage":1,"id":"MW-136","stage_name":"Rookie","form_name":"Rookie Scrollo","name_ko":"루키 스크롤로","description":"두루마리 너구리의 첫 모습입니다. 기록과 정리의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-137","stage_name":"Elite","form_name":"Elite Scrollo","name_ko":"엘리트 스크롤로","description":"한 단계 자란 스크롤로입니다. 기록과 정리의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-138","stage_name":"Legend","form_name":"Legend Scrollo","name_ko":"레전드 스크롤로","description":"스크롤로의 마지막 모습입니다. 기록과 정리의 힘을 온전히 갖추었습니다."}]},
 {"id":"glacio","no":47,"name":"GLACIO","name_ko":"글라시오","animal":"빙하 곰","concept":"묵직함과 평정","element":"ice","rarity":"rare","season":null,"art":{"body":"#6CB7D0","belly":"#E3F2F7","accent":"#2F5AC6","dark":"#28505D","ears":"round","tail":"puff","mark":"snow"},"description":"빙하 위를 천천히 걷는 곰. 어떤 상황에서도 마음이 흔들리지 않습니다.","forms":[{"stage":1,"id":"MW-139","stage_name":"Rookie","form_name":"Rookie Glacio","name_ko":"루키 글라시오","description":"빙하 곰의 첫 모습입니다. 묵직함과 평정의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-140","stage_name":"Elite","form_name":"Elite Glacio","name_ko":"엘리트 글라시오","description":"한 단계 자란 글라시오입니다. 묵직함과 평정의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-141","stage_name":"Legend","form_name":"Legend Glacio","name_ko":"레전드 글라시오","description":"글라시오의 마지막 모습입니다. 묵직함과 평정의 힘을 온전히 갖추었습니다."}]},
 {"id":"pyralis","no":48,"name":"PYRALIS","name_ko":"파이랄리스","animal":"불새","concept":"재도전과 회복","element":"fire","rarity":"epic","season":null,"art":{"body":"#B15F43","belly":"#F2DFD9","accent":"#62DABC","dark":"#4B2F26","ears":"owl","tail":"fox","mark":"flame"},"description":"불 속에서 다시 날아오르는 새. 실패한 자리에서 한 번 더 시작합니다.","forms":[{"stage":1,"id":"MW-142","stage_name":"Rookie","form_name":"Rookie Pyralis","name_ko":"루키 파이랄리스","description":"불새의 첫 모습입니다. 재도전과 회복의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-143","stage_name":"Elite","form_name":"Elite Pyralis","name_ko":"엘리트 파이랄리스","description":"한 단계 자란 파이랄리스입니다. 재도전과 회복의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-144","stage_name":"Legend","form_name":"Legend Pyralis","name_ko":"레전드 파이랄리스","description":"파이랄리스의 마지막 모습입니다. 재도전과 회복의 힘을 온전히 갖추었습니다."}]},
 {"id":"abyssa","no":49,"name":"ABYSSA","name_ko":"어비사","animal":"심해 고래","concept":"깊이와 사색","element":"water","rarity":"epic","season":null,"art":{"body":"#435FB1","belly":"#D9DFF2","accent":"#DA8062","dark":"#262F4B","ears":"round","tail":"drop","mark":"drop"},"description":"빛이 닿지 않는 바다를 헤엄치는 고래. 한 가지 질문을 오래 생각합니다.","forms":[{"stage":1,"id":"MW-145","stage_name":"Rookie","form_name":"Rookie Abyssa","name_ko":"루키 어비사","description":"심해 고래의 첫 모습입니다. 깊이와 사색의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-146","stage_name":"Elite","form_name":"Elite Abyssa","name_ko":"엘리트 어비사","description":"한 단계 자란 어비사입니다. 깊이와 사색의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-147","stage_name":"Legend","form_name":"Legend Abyssa","name_ko":"레전드 어비사","description":"어비사의 마지막 모습입니다. 깊이와 사색의 힘을 온전히 갖추었습니다."}]},
 {"id":"eldwood","no":50,"name":"ELDWOOD","name_ko":"엘드우드","animal":"고목 사슴","concept":"지혜와 세월","element":"forest","rarity":"epic","season":null,"art":{"body":"#56B143","belly":"#DDF2D9","accent":"#8A62DA","dark":"#2C4B26","ears":"antler","tail":"none","mark":"leaf"},"description":"천 년 된 나무의 뿔을 가진 사슴. 오래 읽은 책이 나이테로 남습니다.","forms":[{"stage":1,"id":"MW-148","stage_name":"Rookie","form_name":"Rookie Eldwood","name_ko":"루키 엘드우드","description":"고목 사슴의 첫 모습입니다. 지혜와 세월의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-149","stage_name":"Elite","form_name":"Elite Eldwood","name_ko":"엘리트 엘드우드","description":"한 단계 자란 엘드우드입니다. 지혜와 세월의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-150","stage_name":"Legend","form_name":"Legend Eldwood","name_ko":"레전드 엘드우드","description":"엘드우드의 마지막 모습입니다. 지혜와 세월의 힘을 온전히 갖추었습니다."}]},
 {"id":"tempesta","no":51,"name":"TEMPESTA","name_ko":"템페스타","animal":"폭풍 표범","concept":"돌파와 기세","element":"wind","rarity":"epic","season":null,"art":{"body":"#4C43B1","belly":"#DBD9F2","accent":"#DAA862","dark":"#29264B","ears":"cat","tail":"cat","mark":"cloud"},"description":"폭풍 속을 달리는 표범. 막힌 곳을 만나면 속도를 더 냅니다.","forms":[{"stage":1,"id":"MW-151","stage_name":"Rookie","form_name":"Rookie Tempesta","name_ko":"루키 템페스타","description":"폭풍 표범의 첫 모습입니다. 돌파와 기세의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-152","stage_name":"Elite","form_name":"Elite Tempesta","name_ko":"엘리트 템페스타","description":"한 단계 자란 템페스타입니다. 돌파와 기세의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-153","stage_name":"Legend","form_name":"Legend Tempesta","name_ko":"레전드 템페스타","description":"템페스타의 마지막 모습입니다. 돌파와 기세의 힘을 온전히 갖추었습니다."}]},
 {"id":"obsidon","no":52,"name":"OBSIDON","name_ko":"옵시돈","animal":"흑요석 코뿔소","concept":"굳건함과 책임","element":"earth","rarity":"epic","season":null,"art":{"body":"#7A43B1","belly":"#E6D9F2","accent":"#DADA62","dark":"#38264B","ears":"horn","tail":"none","mark":"stone"},"description":"흑요석 뿔을 가진 코뿔소. 맡은 일은 끝까지 책임집니다.","forms":[{"stage":1,"id":"MW-154","stage_name":"Rookie","form_name":"Rookie Obsidon","name_ko":"루키 옵시돈","description":"흑요석 코뿔소의 첫 모습입니다. 굳건함과 책임의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-155","stage_name":"Elite","form_name":"Elite Obsidon","name_ko":"엘리트 옵시돈","description":"한 단계 자란 옵시돈입니다. 굳건함과 책임의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-156","stage_name":"Legend","form_name":"Legend Obsidon","name_ko":"레전드 옵시돈","description":"옵시돈의 마지막 모습입니다. 굳건함과 책임의 힘을 온전히 갖추었습니다."}]},
 {"id":"stellara","no":53,"name":"STELLARA","name_ko":"스텔라라","animal":"별자리 유니콘","concept":"꿈과 이상","element":"star","rarity":"epic","season":null,"art":{"body":"#9F43B1","belly":"#EED9F2","accent":"#B2DA62","dark":"#44264B","ears":"antler","tail":"fox","mark":"star"},"description":"몸에 별자리가 그려진 유니콘. 먼 목표를 보고 오늘 할 일을 정합니다.","forms":[{"stage":1,"id":"MW-157","stage_name":"Rookie","form_name":"Rookie Stellara","name_ko":"루키 스텔라라","description":"별자리 유니콘의 첫 모습입니다. 꿈과 이상의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-158","stage_name":"Elite","form_name":"Elite Stellara","name_ko":"엘리트 스텔라라","description":"한 단계 자란 스텔라라입니다. 꿈과 이상의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-159","stage_name":"Legend","form_name":"Legend Stellara","name_ko":"레전드 스텔라라","description":"스텔라라의 마지막 모습입니다. 꿈과 이상의 힘을 온전히 갖추었습니다."}]},
 {"id":"lunette","no":54,"name":"LUNETTE","name_ko":"루네트","animal":"달빛 늑대","concept":"고요와 직관","element":"star","rarity":"epic","season":null,"art":{"body":"#434DB1","belly":"#D9DBF2","accent":"#DA9462","dark":"#26294B","ears":"fox","tail":"fox","mark":"star"},"description":"보름달 아래에서 깨어나는 늑대. 조용한 시간에 가장 깊이 배웁니다.","forms":[{"stage":1,"id":"MW-160","stage_name":"Rookie","form_name":"Rookie Lunette","name_ko":"루키 루네트","description":"달빛 늑대의 첫 모습입니다. 고요와 직관의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-161","stage_name":"Elite","form_name":"Elite Lunette","name_ko":"엘리트 루네트","description":"한 단계 자란 루네트입니다. 고요와 직관의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-162","stage_name":"Legend","form_name":"Legend Lunette","name_ko":"레전드 루네트","description":"루네트의 마지막 모습입니다. 고요와 직관의 힘을 온전히 갖추었습니다."}]},
 {"id":"grammara","no":55,"name":"GRAMMARA","name_ko":"그래마라","animal":"문법 스핑크스","concept":"규칙과 논리","element":"word","rarity":"epic","season":null,"art":{"body":"#B19643","belly":"#F2ECD9","accent":"#62BCDA","dark":"#4B4126","ears":"cat","tail":"cat","mark":"quill"},"description":"문장의 수수께끼를 내는 스핑크스. 규칙을 알면 길이 열린다고 말합니다.","forms":[{"stage":1,"id":"MW-163","stage_name":"Rookie","form_name":"Rookie Grammara","name_ko":"루키 그래마라","description":"문법 스핑크스의 첫 모습입니다. 규칙과 논리의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-164","stage_name":"Elite","form_name":"Elite Grammara","name_ko":"엘리트 그래마라","description":"한 단계 자란 그래마라입니다. 규칙과 논리의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-165","stage_name":"Legend","form_name":"Legend Grammara","name_ko":"레전드 그래마라","description":"그래마라의 마지막 모습입니다. 규칙과 논리의 힘을 온전히 갖추었습니다."}]},
 {"id":"lexicon","no":56,"name":"LEXICON","name_ko":"렉시콘","animal":"사전 코끼리","concept":"박식과 기억","element":"word","rarity":"epic","season":null,"art":{"body":"#5F43B1","belly":"#DFD9F2","accent":"#DABC62","dark":"#2F264B","ears":"round","tail":"none","mark":"quill"},"description":"사전 한 권을 통째로 기억하는 코끼리. 한 번 익힌 낱말을 잊지 않습니다.","forms":[{"stage":1,"id":"MW-166","stage_name":"Rookie","form_name":"Rookie Lexicon","name_ko":"루키 렉시콘","description":"사전 코끼리의 첫 모습입니다. 박식과 기억의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-167","stage_name":"Elite","form_name":"Elite Lexicon","name_ko":"엘리트 렉시콘","description":"한 단계 자란 렉시콘입니다. 박식과 기억의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-168","stage_name":"Legend","form_name":"Legend Lexicon","name_ko":"레전드 렉시콘","description":"렉시콘의 마지막 모습입니다. 박식과 기억의 힘을 온전히 갖추었습니다."}]},
 {"id":"crystara","no":57,"name":"CRYSTARA","name_ko":"크리스타라","animal":"얼음 수정 백조","concept":"우아함과 절제","element":"ice","rarity":"epic","season":null,"art":{"body":"#43A3B1","belly":"#D9EFF2","accent":"#DA628E","dark":"#26464B","ears":"owl","tail":"none","mark":"snow"},"description":"얼음 수정 날개를 가진 백조. 꼭 필요한 말만 골라 씁니다.","forms":[{"stage":1,"id":"MW-169","stage_name":"Rookie","form_name":"Rookie Crystara","name_ko":"루키 크리스타라","description":"얼음 수정 백조의 첫 모습입니다. 우아함과 절제의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-170","stage_name":"Elite","form_name":"Elite Crystara","name_ko":"엘리트 크리스타라","description":"한 단계 자란 크리스타라입니다. 우아함과 절제의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-171","stage_name":"Legend","form_name":"Legend Crystara","name_ko":"레전드 크리스타라","description":"크리스타라의 마지막 모습입니다. 우아함과 절제의 힘을 온전히 갖추었습니다."}]},
 {"id":"solarion","no":58,"name":"SOLARION","name_ko":"솔라리온","animal":"태양 사자","concept":"자신감과 빛","element":"fire","rarity":"legendary","season":null,"art":{"body":"#D4A649","belly":"#F8EFDD","accent":"#62C6DA","dark":"#54411C","ears":"round","tail":"fox","mark":"flame"},"description":"태양의 갈기를 두른 사자. 스스로 쌓은 실력에서 자신감이 나옵니다.","forms":[{"stage":1,"id":"MW-172","stage_name":"Rookie","form_name":"Rookie Solarion","name_ko":"루키 솔라리온","description":"태양 사자의 첫 모습입니다. 자신감과 빛의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-173","stage_name":"Elite","form_name":"Elite Solarion","name_ko":"엘리트 솔라리온","description":"한 단계 자란 솔라리온입니다. 자신감과 빛의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-174","stage_name":"Legend","form_name":"Legend Solarion","name_ko":"레전드 솔라리온","description":"솔라리온의 마지막 모습입니다. 자신감과 빛의 힘을 온전히 갖추었습니다."}]},
 {"id":"leviatha","no":59,"name":"LEVIATHA","name_ko":"레비아사","animal":"대해 용","concept":"포용과 위엄","element":"water","rarity":"legendary","season":null,"art":{"body":"#4983D4","belly":"#DDE8F8","accent":"#DA6C62","dark":"#1C3354","ears":"horn","tail":"drop","mark":"drop"},"description":"큰 바다를 다스리는 용. 서로 다른 생각을 모두 품어 하나로 엮습니다.","forms":[{"stage":1,"id":"MW-175","stage_name":"Rookie","form_name":"Rookie Leviatha","name_ko":"루키 레비아사","description":"대해 용의 첫 모습입니다. 포용과 위엄의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-176","stage_name":"Elite","form_name":"Elite Leviatha","name_ko":"엘리트 레비아사","description":"한 단계 자란 레비아사입니다. 포용과 위엄의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-177","stage_name":"Legend","form_name":"Legend Leviatha","name_ko":"레전드 레비아사","description":"레비아사의 마지막 모습입니다. 포용과 위엄의 힘을 온전히 갖추었습니다."}]},
 {"id":"aetheron","no":60,"name":"AETHERON","name_ko":"에테론","animal":"하늘 용","concept":"자유와 통찰","element":"wind","rarity":"legendary","season":null,"art":{"body":"#49D4C9","belly":"#DDF8F6","accent":"#DA62A8","dark":"#1C544F","ears":"antler","tail":"fox","mark":"cloud"},"description":"구름 위 하늘을 나는 용. 높은 곳에서 글 전체의 흐름을 내려다봅니다.","forms":[{"stage":1,"id":"MW-178","stage_name":"Rookie","form_name":"Rookie Aetheron","name_ko":"루키 에테론","description":"하늘 용의 첫 모습입니다. 자유와 통찰의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-179","stage_name":"Elite","form_name":"Elite Aetheron","name_ko":"엘리트 에테론","description":"한 단계 자란 에테론입니다. 자유와 통찰의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-180","stage_name":"Legend","form_name":"Legend Aetheron","name_ko":"레전드 에테론","description":"에테론의 마지막 모습입니다. 자유와 통찰의 힘을 온전히 갖추었습니다."}]},
 {"id":"authora","no":61,"name":"AUTHORA","name_ko":"오소라","animal":"이야기 그리폰","concept":"창작과 완성","element":"word","rarity":"legendary","season":null,"art":{"body":"#9A49D4","belly":"#EDDDF8","accent":"#D0DA62","dark":"#3D1C54","ears":"owl","tail":"fox","mark":"quill"},"description":"자기 이야기를 책으로 엮는 그리폰. 읽고 쓰고 말한 모든 것이 한 권이 됩니다.","forms":[{"stage":1,"id":"MW-181","stage_name":"Rookie","form_name":"Rookie Authora","name_ko":"루키 오소라","description":"이야기 그리폰의 첫 모습입니다. 창작과 완성의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-182","stage_name":"Elite","form_name":"Elite Authora","name_ko":"엘리트 오소라","description":"한 단계 자란 오소라입니다. 창작과 완성의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-183","stage_name":"Legend","form_name":"Legend Authora","name_ko":"레전드 오소라","description":"오소라의 마지막 모습입니다. 창작과 완성의 힘을 온전히 갖추었습니다."}]},
 {"id":"frostie","no":62,"name":"FROSTIE","name_ko":"프로스티","animal":"눈꽃 여우새","concept":"겨울 시즌 한정","element":"ice","rarity":"seasonal","season":"winter","art":{"body":"#EAF2FA","belly":"#FFFFFF","accent":"#9CC3E8","dark":"#6C93BD","ears":"cat","tail":"fox","mark":"snow"},"description":"첫눈이 오는 날 나타나는 여우새. 추운 계절에도 하던 일을 이어 갑니다.","forms":[{"stage":1,"id":"MW-184","stage_name":"Rookie","form_name":"Rookie Frostie","name_ko":"루키 프로스티","description":"눈꽃 여우새의 첫 모습입니다. 포근함과 고요의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-185","stage_name":"Elite","form_name":"Elite Frostie","name_ko":"엘리트 프로스티","description":"한 단계 자란 프로스티입니다. 포근함과 고요의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-186","stage_name":"Legend","form_name":"Legend Frostie","name_ko":"레전드 프로스티","description":"프로스티의 마지막 모습입니다. 포근함과 고요의 힘을 온전히 갖추었습니다."}]},
 {"id":"blossy","no":63,"name":"BLOSSY","name_ko":"블로시","animal":"벚꽃 토끼","concept":"설렘과 새 출발","element":"forest","rarity":"seasonal","season":"spring","art":{"body":"#E9A5C1","belly":"#FBEEF4","accent":"#C6362F","dark":"#9F3863","ears":"bunny","tail":"puff","mark":"leaf"},"description":"벚꽃이 필 때 찾아오는 토끼. 새 학기의 첫 마음을 떠올리게 합니다.","forms":[{"stage":1,"id":"MW-187","stage_name":"Rookie","form_name":"Rookie Blossy","name_ko":"루키 블로시","description":"벚꽃 토끼의 첫 모습입니다. 설렘과 새 출발의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-188","stage_name":"Elite","form_name":"Elite Blossy","name_ko":"엘리트 블로시","description":"한 단계 자란 블로시입니다. 설렘과 새 출발의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-189","stage_name":"Legend","form_name":"Legend Blossy","name_ko":"레전드 블로시","description":"블로시의 마지막 모습입니다. 설렘과 새 출발의 힘을 온전히 갖추었습니다."}]},
 {"id":"sunnix","no":64,"name":"SUNNIX","name_ko":"서닉스","animal":"한여름 여우","concept":"활력과 도전","element":"fire","rarity":"seasonal","season":"summer","art":{"body":"#E9DBA5","belly":"#FBF9EE","accent":"#9EC62F","dark":"#9F8A38","ears":"fox","tail":"fox","mark":"flame"},"description":"한여름 햇살을 닮은 여우. 긴 방학에도 하루 계획을 지킵니다.","forms":[{"stage":1,"id":"MW-190","stage_name":"Rookie","form_name":"Rookie Sunnix","name_ko":"루키 서닉스","description":"한여름 여우의 첫 모습입니다. 활력과 도전의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-191","stage_name":"Elite","form_name":"Elite Sunnix","name_ko":"엘리트 서닉스","description":"한 단계 자란 서닉스입니다. 활력과 도전의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-192","stage_name":"Legend","form_name":"Legend Sunnix","name_ko":"레전드 서닉스","description":"서닉스의 마지막 모습입니다. 활력과 도전의 힘을 온전히 갖추었습니다."}]},
 {"id":"maplo","no":65,"name":"MAPLO","name_ko":"메이플로","animal":"단풍 다람쥐","concept":"결실과 감사","element":"earth","rarity":"seasonal","season":"autumn","art":{"body":"#E9B5A5","belly":"#FBF1EE","accent":"#C6992F","dark":"#9F5038","ears":"cat","tail":"fox","mark":"stone"},"description":"단풍잎을 모으는 다람쥐. 한 해 동안 쌓은 것을 돌아봅니다.","forms":[{"stage":1,"id":"MW-193","stage_name":"Rookie","form_name":"Rookie Maplo","name_ko":"루키 메이플로","description":"단풍 다람쥐의 첫 모습입니다. 결실과 감사의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-194","stage_name":"Elite","form_name":"Elite Maplo","name_ko":"엘리트 메이플로","description":"한 단계 자란 메이플로입니다. 결실과 감사의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-195","stage_name":"Legend","form_name":"Legend Maplo","name_ko":"레전드 메이플로","description":"메이플로의 마지막 모습입니다. 결실과 감사의 힘을 온전히 갖추었습니다."}]},
 {"id":"pumpkee","no":66,"name":"PUMPKEE","name_ko":"펌키","animal":"호박 고양이","concept":"재미와 상상","element":"star","rarity":"seasonal","season":"halloween","art":{"body":"#E9C5A5","belly":"#FBF4EE","accent":"#C6BC2F","dark":"#9F6838","ears":"cat","tail":"cat","mark":"star"},"description":"호박 등불을 들고 다니는 고양이. 10월의 밤에 이야기를 들려줍니다.","forms":[{"stage":1,"id":"MW-196","stage_name":"Rookie","form_name":"Rookie Pumpkee","name_ko":"루키 펌키","description":"호박 고양이의 첫 모습입니다. 재미와 상상의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-197","stage_name":"Elite","form_name":"Elite Pumpkee","name_ko":"엘리트 펌키","description":"한 단계 자란 펌키입니다. 재미와 상상의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-198","stage_name":"Legend","form_name":"Legend Pumpkee","name_ko":"레전드 펌키","description":"펌키의 마지막 모습입니다. 재미와 상상의 힘을 온전히 갖추었습니다."}]},
 {"id":"jinglo","no":67,"name":"JINGLO","name_ko":"징글로","animal":"방울 순록","concept":"나눔과 기쁨","element":"ice","rarity":"seasonal","season":"christmas","art":{"body":"#A5E9D2","belly":"#EEFBF7","accent":"#2FB2C6","dark":"#389F7C","ears":"antler","tail":"puff","mark":"snow"},"description":"방울 소리와 함께 오는 순록. 한 해의 끝에 서로의 노력을 축하합니다.","forms":[{"stage":1,"id":"MW-199","stage_name":"Rookie","form_name":"Rookie Jinglo","name_ko":"루키 징글로","description":"방울 순록의 첫 모습입니다. 나눔과 기쁨의 씨앗을 품고 있습니다."},{"stage":2,"id":"MW-200","stage_name":"Elite","form_name":"Elite Jinglo","name_ko":"엘리트 징글로","description":"한 단계 자란 징글로입니다. 나눔과 기쁨의 힘이 뚜렷해졌습니다."},{"stage":3,"id":"MW-201","stage_name":"Legend","form_name":"Legend Jinglo","name_ko":"레전드 징글로","description":"징글로의 마지막 모습입니다. 나눔과 기쁨의 힘을 온전히 갖추었습니다."}]}
]$seed$::jsonb) loop
    insert into mw_species(id, no, name, name_ko, animal, concept, element, rarity, season, sort, art, description, forms)
    values (r->>'id', (r->>'no')::int, r->>'name', r->>'name_ko', r->>'animal', r->>'concept', r->>'element', r->>'rarity', r->>'season',
            (r->>'no')::int, r->'art', r->>'description', r->'forms')
    on conflict (id) do update set
      no = excluded.no, sort = excluded.sort,
      name_ko = case when mw_species.name_ko = '' then excluded.name_ko else mw_species.name_ko end,
      element = case when mw_species.element = '' then excluded.element else mw_species.element end,
      description = case when mw_species.description = '' then excluded.description else mw_species.description end,
      forms = (select jsonb_agg(e.f || coalesce((select jsonb_object_agg(x.k, x.v) from jsonb_each(o.f) as x(k, v)
                                                  where x.v <> 'null'::jsonb and x.v <> '""'::jsonb), '{}'::jsonb)
                                order by (e.f->>'stage')::int)
                 from jsonb_array_elements(excluded.forms) as e(f)
                 left join jsonb_array_elements(mw_species.forms) as o(f) on (o.f->>'stage') = (e.f->>'stage'));
  end loop;
end $mwdex$;

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

-- v2.20: 본사 학원이 없으면 가장 먼저 만든 학원을 본사로 지정합니다. 도감 관리는 본사 학원의 원장만 할 수 있습니다.
update mw_academies set is_owner = true
 where id = (select id from mw_academies order by created_at, id limit 1)
   and not exists (select 1 from mw_academies where is_owner);

create or replace function mw_is_owner() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from mw_profiles p join mw_academies a on a.id = p.academy_id
                  where p.id = auth.uid() and p.role = 'teacher' and p.is_admin and p.active and a.active and a.is_owner);
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
alter table mw_words       enable row level security;   -- 정책 없음 = 서버 함수로만(정답 보호)
alter table mw_word_pos    enable row level security;
alter table mw_battles     enable row level security;
alter table mw_word_misses enable row level security;
alter table mw_coins       enable row level security;
alter table mw_xp_spend    enable row level security;
alter table mw_points      enable row level security;
alter table mw_shop_items  enable row level security;
alter table mw_inventory   enable row level security;
alter table mw_homes       enable row level security;
alter table mw_stickers    enable row level security;
alter table mw_duels       enable row level security;
alter table mw_duel_play   enable row level security;

drop policy if exists mw_academies_read on mw_academies;
create policy mw_academies_read on mw_academies for select to authenticated using (id = mw_my_academy());
drop policy if exists mw_profiles_read on mw_profiles;
create policy mw_profiles_read on mw_profiles for select to authenticated
  using (id = auth.uid() or (mw_is_teacher() and academy_id = mw_my_academy() and (role = 'student' or mw_is_admin())));   -- 다른 선생님 계정은 원장만 봄
drop policy if exists mw_shop_read on mw_shop_items;
create policy mw_shop_read on mw_shop_items for select to authenticated using (true);
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

drop function if exists mw_apply_xp(uuid, uuid, int, text, text, uuid, uuid);
create or replace function mw_apply_xp(
  p_student uuid, p_monster uuid, p_amount int, p_kind text, p_reason text,
  p_mission uuid, p_book uuid, p_battle uuid default null) returns int
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
  insert into mw_ledger(student_id, monster_id, amount, kind, reason, mission_id, book_id, battle_id, level_after, actor)
  values (p_student, m.id, p_amount, p_kind, coalesce(p_reason, ''), p_mission, p_book, p_battle, v_lvl, auth.uid());
  -- v2.22: 칭찬 포인트도 주간 정산과 같은 기준(지급·취소만, 정정·배틀은 제외)으로 함께 쌓음
  if p_kind in ('grant', 'revoke') and p_amount <> 0 then
    insert into mw_points(student_id, amount, kind, note) values (p_student, round(p_amount * mw_point_rate(v_ac))::int, 'earn', coalesce(p_reason, ''));
  end if;
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
  if p_kind = 'grant' and p_amount > 0 and p_reason = 'nelt' then perform mw_gear_grant(p_student, 'g_goldwings'); end if;   -- v2.23 전설 장비: NELT 레벨업
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
-- ---------- v2.18 방문 도우미(내부용) ----------
create or replace function mw_visit_ok(p_ac uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select coalesce((mw_setting(p_ac, 'home_visit') #>> '{}')::boolean, true)
     and coalesce(mw_setting(p_ac, 'map_name_mode') #>> '{}', 'nickname') <> 'hidden';
$$;
-- 친구에게 보이는 이름(지도 표시 방식과 같음)
create or replace function mw_pub_name(p_student uuid) returns text
language sql stable security definer set search_path = public as $$
  select case coalesce(mw_setting(p.academy_id, 'map_name_mode') #>> '{}', 'nickname')
           when 'real' then p.display_name
           when 'masked' then case when char_length(p.display_name) <= 1 then '*'
                                   when char_length(p.display_name) = 2 then left(p.display_name, 1) || '*'
                                   else left(p.display_name, 1) || repeat('*', char_length(p.display_name) - 2) || right(p.display_name, 1) end
           when 'hidden' then '친구'
           else coalesce(nullif(btrim(m.nickname), ''), s.name, '새 모험가') end
    from mw_profiles p left join mw_monsters m on m.id = p.active_monster left join mw_species s on s.id = m.species_id
   where p.id = p_student;
$$;

-- ---------- v2.17 코인 도우미(내부용) ----------
create or replace function mw_coin_cfg(p_ac uuid) returns jsonb
language sql stable security definer set search_path = public as $$
  select '{"activity":5,"battle_first":10,"battle_rewin":2,"gate_first":30,"streak":20,"evo_elite":50,"evo_legend":100}'::jsonb || coalesce(mw_setting(p_ac, 'coins'), '{}'::jsonb);
$$;
create or replace function mw_coin_balance(p_student uuid) returns int
language sql stable security definer set search_path = public as $$
  select coalesce(sum(amount), 0)::int from mw_coins where student_id = p_student;
$$;
-- v2.21: 쓸 수 있는 XP(내부용). 받은 XP(취소·차감 반영) - XP로 산 합계, 0 아래로는 내려가지 않음
create or replace function mw_xp_wallet(p_student uuid) returns int
language sql stable security definer set search_path = public as $$
  select greatest(0, (select coalesce(sum(amount), 0) from mw_ledger where student_id = p_student)
                   - (select coalesce(sum(amount), 0) from mw_xp_spend where student_id = p_student))::int;
$$;
-- v2.22: 칭찬 포인트(내부용). 환산 기준 point_rate(0이면 1 XP = 1 포인트)
create or replace function mw_point_rate(p_ac uuid) returns numeric
language sql stable security definer set search_path = public as $$
  select case when coalesce((mw_setting(p_ac, 'point_rate') #>> '{}')::numeric, 0) > 0 then (mw_setting(p_ac, 'point_rate') #>> '{}')::numeric else 1 end;
$$;
create or replace function mw_point_balance(p_student uuid) returns int
language sql stable security definer set search_path = public as $$
  select coalesce(sum(amount), 0)::int from mw_points where student_id = p_student;
$$;
-- 학습 성과 해금 조건 확인(내부용). {"t":"stat","k":"read","v":1000} · {"t":"books","v":10} · {"t":"stage","v":2}
create or replace function mw_item_unlocked(p_student uuid, p_unlock jsonb) returns boolean
language plpgsql stable security definer set search_path = public as $$
declare v int;
begin
  if p_unlock is null or jsonb_typeof(p_unlock) <> 'object' then return true; end if;
  v := coalesce((p_unlock ->> 'v')::int, 0);
  if p_unlock ->> 't' = 'stat' then return coalesce((mw_stat_values(p_student) ->> (p_unlock ->> 'k'))::int, 0) >= v; end if;
  if p_unlock ->> 't' = 'books' then return (select count(*) from mw_books b where b.student_id = p_student and b.status = 'approved') >= v; end if;
  if p_unlock ->> 't' = 'stage' then return coalesce((select max(stage) from mw_monsters m where m.student_id = p_student and m.hatched), 1) >= v; end if;
  return true;
end $$;
-- 지금 계절(한국 시간): 3~5 봄, 6~8 여름, 9~11 가을, 12~2 겨울
create or replace function mw_season_now() returns text
language sql stable as $$
  select case when extract(month from (now() at time zone 'Asia/Seoul'))::int between 3 and 5 then 'spring'
              when extract(month from (now() at time zone 'Asia/Seoul'))::int between 6 and 8 then 'summer'
              when extract(month from (now() at time zone 'Asia/Seoul'))::int between 9 and 11 then 'autumn' else 'winter' end;
$$;
-- 코인 지급(같은 ref 는 한 번만). 0 이하면 아무것도 하지 않음
create or replace function mw_coin_add(p_student uuid, p_amount int, p_reason text, p_ref text) returns void
language sql security definer set search_path = public as $$
  insert into mw_coins(student_id, amount, reason, ref)
  select p_student, p_amount, left(coalesce(p_reason, ''), 60), p_ref where coalesce(p_amount, 0) > 0
  on conflict (student_id, ref) where ref is not null do nothing;
$$;
-- 지급 회수: 그 ref 로 받은 코인을 한 번만 되돌림
create or replace function mw_coin_revoke(p_student uuid, p_ref text, p_reason text) returns void
language sql security definer set search_path = public as $$
  insert into mw_coins(student_id, amount, reason, ref)
  select c.student_id, -c.amount, left(coalesce(p_reason, ''), 60), p_ref || ':rv' from mw_coins c
   where c.student_id = p_student and c.ref = p_ref and c.amount > 0
  on conflict (student_id, ref) where ref is not null do nothing;
$$;

-- ---------- v2.15 단어 배틀 도우미(내부용) ----------
create or replace function mw_seoul_today() returns date
language sql stable as $$ select (now() at time zone 'Asia/Seoul')::date $$;

-- 평일 번호(주말은 그 주 금요일 번호). 연속 기록 계산용
create or replace function mw_wd_idx(d date) returns int
language sql immutable as $$ select ((d - date '2024-01-01') / 7) * 5 + least((d - date '2024-01-01') % 7, 4) $$;

create or replace function mw_battle_cfg(p_ac uuid) returns jsonb
language sql stable security definer set search_path = public as $$
  select '{"first_xp":30,"rewin_xp":5,"gate_xp":100,"gate_rewin_xp":5,"shard_first":5,"shard_rewin":1,"shard_gate":20,"shard_gate_rewin":1,"shards_per_stone":100,"over_ratio":0.25,"streak":[{"days":3,"mult":1.2},{"days":7,"mult":1.5},{"days":30,"mult":2}],"hearts":3,"hp":120,"gate_hp":240,"pool":10,"gate_q":20,"combo":5,"advance_act":"vocab","dmg_base":10,"dmg_lv_div":5,"dmg_lv_max":10,"dmg_elite":3,"dmg_legend":6,"crit_per":200,"crit_max":25,"mix_rev":25,"mix_listen":25}'::jsonb || coalesce(mw_setting(p_ac, 'battle'), '{}'::jsonb);
$$;

create or replace function mw_battle_shards(p_student uuid) returns int
language sql stable security definer set search_path = public as $$
  select coalesce(sum(shards), 0)::int from mw_battles where student_id = p_student and status = 'won' and not revoked;
$$;

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
      from jsonb_each(mw_streak_info(p_student)) e),
  shard as (   -- v2.15: 배틀 진화석 조각 shards_per_stone 개 = 진화석 1개
    select (mw_battle_shards(p_student) / greatest(1, coalesce((mw_battle_cfg(p.academy_id) ->> 'shards_per_stone')::int, 100)))::int as evo
      from mw_profiles p where p.id = p_student)
  select jsonb_build_object(
    'evo',    greatest(0, coalesce((select n from earned where k = 'evo'), 0)    + (select evo from streak) + coalesce((select evo from shard), 0) - (select evo from spent)),
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
  insert into mw_academies(code, name, is_owner) values (v_code, btrim(p_name), not exists (select 1 from mw_academies where is_owner)) returning id into v_id;
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
  v_need := coalesce(   -- v2.20: 도감에서 형태별 요구 레벨을 정했으면 그 값, 비어 있으면 학원 기준 설정
    (select (f ->> 'req_level')::int from mw_species s, jsonb_array_elements(s.forms) f
      where s.id = m.species_id and (f ->> 'stage')::int = v_to and (f ->> 'req_level') ~ '^[0-9]{1,3}$' limit 1),
    (mw_setting(mw_my_academy(), 'evolve_levels') ->> (m.stage - 1))::int);
  if v_need is null or m.level < v_need then raise exception '레벨이 부족합니다. Lv.%부터 진화할 수 있습니다.', v_need; end if;
  if not ((v_to = 2 and p_use in ('evo','legend')) or (v_to = 3 and p_use in ('legend','evo2'))) then
    raise exception '사용할 수 없는 진화 방법입니다.'; end if;
  v_bal := mw_stone_balance(auth.uid());
  if (p_use = 'evo' and (v_bal ->> 'evo')::int < 1) or (p_use = 'evo2' and (v_bal ->> 'evo')::int < 2)
     or (p_use = 'legend' and (v_bal ->> 'legend')::int < 1) then
    raise exception '진화석이 부족합니다.'; end if;
  insert into mw_rewards(student_id, reward_key) values (auth.uid(), 'evo:' || m.id || ':' || v_to || ':' || p_use);
  update mw_monsters set stage = v_to where id = m.id;
  if v_to = 3 then perform mw_gear_grant(auth.uid(), 'g_rainbow'); end if;   -- v2.23 전설 장비: Legend 진화
  -- v2.22: 진화 보너스를 칭찬 포인트에도 쌓음(주간 정산 진화 보너스와 같은 숫자)
  if coalesce((mw_setting(mw_my_academy(), 'evolve_bonus') ->> (v_to - 2))::int, 0) > 0 then
    insert into mw_points(student_id, amount, kind, ref, note)
    values (auth.uid(), (mw_setting(mw_my_academy(), 'evolve_bonus') ->> (v_to - 2))::int, 'bonus', 'evo:' || m.id || ':' || v_to,
            case when v_to = 2 then 'Elite 진화 보너스' else 'Legend 진화 보너스' end)
    on conflict (student_id, ref) where ref is not null do nothing;
  end if;
  perform mw_badge(auth.uid(), case when v_to = 2 then 'evo_explorer' else 'evo_master' end);
  perform mw_coin_add(auth.uid(), (mw_coin_cfg(mw_my_academy()) ->> (case when v_to = 2 then 'evo_elite' else 'evo_legend' end))::int,
                      case when v_to = 2 then 'Elite 진화' else 'Legend 진화' end, 'evo:' || m.id || ':' || v_to);
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
create or replace function mw_map() returns table(student_id uuid, name text, level int, stage int, species_id text, vk text)
language plpgsql stable security definer set search_path = public as $$
declare v_t boolean := mw_is_teacher(); v_mode text; v_visit boolean;
begin
  if not (mw_student_ok() or v_t) then raise exception '승인된 계정이 아닙니다.'; end if;
  v_mode := coalesce(mw_setting(mw_my_academy(), 'map_name_mode') #>> '{}', 'nickname');
  v_visit := mw_visit_ok(mw_my_academy());
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
         case when v_t or p.id = auth.uid() or v_mode <> 'hidden' then m.species_id end,
         case when v_t or (p.id <> auth.uid() and v_visit) then p.visit_key end   -- 친구 집 방문용 임시 열쇠(계정 번호 아님)
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
      if p_activity = coalesce(mw_battle_cfg(mw_my_academy()) ->> 'advance_act', 'vocab') then perform mw_word_advance(s); end if;
      if v_xp > 0 then perform mw_coin_on_approve(s, p_activity, 'm:' || v_id); end if;
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
      if r.activity = coalesce(mw_battle_cfg(mw_my_academy()) ->> 'advance_act', 'vocab') then perform mw_word_advance(r.student_id); end if;
      if r.xp > 0 then perform mw_coin_on_approve(r.student_id, r.activity, 'm:' || r.id); end if;
    else
      update mw_missions set status = 'rejected', decided_by = auth.uid(), decided_at = now() where id = r.id;
      perform mw_battle_recheck(r.student_id, r.due_date);
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
  perform mw_battle_recheck(r.student_id, r.due_date);
  perform mw_coin_revoke(r.student_id, 'm:' || r.id, '승인 취소');
end $$;

create or replace function mw_cancel_mission(p_id uuid) returns void
language plpgsql security definer set search_path = public as $$
declare v_s uuid; v_d date;
begin
  perform mw_need_teacher();
  update mw_missions set status = 'cancelled', decided_by = auth.uid(), decided_at = now()
   where id = p_id and status in ('assigned','requested','rejected') and mw_same(student_id)
  returning student_id, due_date into v_s, v_d;
  if not found then raise exception '삭제할 수 없는 미션입니다.'; end if;
  perform mw_battle_recheck(v_s, v_d);
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
      if v_xp > 0 then perform mw_coin_on_approve(r.student_id, 'reading', 'b:' || r.id); end if;
      perform mw_book_rewards(r.student_id);
    else
      update mw_books set status = 'rejected', decided_by = auth.uid(), decided_at = now() where id = r.id;
      perform mw_battle_recheck(r.student_id, (r.created_at at time zone 'Asia/Seoul')::date);
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
  perform mw_battle_recheck(r.student_id, (r.created_at at time zone 'Asia/Seoul')::date);
  perform mw_coin_revoke(r.student_id, 'b:' || r.id, '독서 실적 취소');
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
                   'point_rate','point_name','stages','activity_labels','self_report_acts','activity_list','map_zones','map_name_mode','activity_stats','stat_rewards','activity_stones','evolve_bonus','streak_rewards','battle','coins','home_visit','duel') then
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
  if p_key = 'duel' and (jsonb_typeof(p_value) <> 'object' or exists (
       select 1 from jsonb_each(p_value) e
        where e.key not in ('on','win','draw','lose','daily','hours','power_max')
           or case when e.key = 'on' then jsonb_typeof(e.value) <> 'boolean'
                   else jsonb_typeof(e.value) <> 'number' or (e.value #>> '{}')::numeric <> round((e.value #>> '{}')::numeric)
                        or (e.value #>> '{}')::numeric not between (case when e.key in ('daily','hours') then 1 else 0 end) and 1000 end)) then
    raise exception '친구 대결 설정이 올바르지 않습니다.'; end if;
  if p_key = 'home_visit' and jsonb_typeof(p_value) <> 'boolean' then raise exception '집 방문 설정이 올바르지 않습니다.'; end if;
  if p_key = 'coins' and (jsonb_typeof(p_value) <> 'object' or exists (
       select 1 from jsonb_each(p_value) e
        where e.key not in ('activity','battle_first','battle_rewin','gate_first','streak','evo_elite','evo_legend')
           or jsonb_typeof(e.value) <> 'number' or (e.value #>> '{}')::numeric <> round((e.value #>> '{}')::numeric)
           or (e.value #>> '{}')::numeric not between 0 and 10000)) then
    raise exception '코인 설정이 올바르지 않습니다. 0~10000 사이 정수로 입력해 주세요.'; end if;
  if p_key = 'battle' and (jsonb_typeof(p_value) <> 'object' or exists (
       select 1 from jsonb_each(p_value) e
        where e.key not in ('first_xp','rewin_xp','gate_xp','gate_rewin_xp','shard_first','shard_rewin','shard_gate','shard_gate_rewin',
                            'shards_per_stone','over_ratio','streak','hearts','hp','gate_hp','pool','gate_q','combo','advance_act',
                            'dmg_base','dmg_lv_div','dmg_lv_max','dmg_elite','dmg_legend','crit_per','crit_max','mix_rev','mix_listen')
           or case e.key
                when 'streak' then jsonb_typeof(e.value) <> 'array' or jsonb_array_length(e.value) > 6 or exists (
                    select 1 from jsonb_array_elements(e.value) s
                     where jsonb_typeof(s) <> 'object' or coalesce(s ->> 'days', '') !~ '^[1-9][0-9]{0,2}$'
                        or coalesce(s ->> 'mult', '') !~ '^[0-9]+(\.[0-9]+)?$' or (s ->> 'mult')::numeric not between 1 and 5)
                when 'advance_act' then jsonb_typeof(e.value) <> 'string' or (e.value #>> '{}') !~ '^[a-z0-9_]{1,24}$'
                when 'over_ratio' then jsonb_typeof(e.value) <> 'number' or (e.value #>> '{}')::numeric not between 0 and 1
                else jsonb_typeof(e.value) <> 'number' or (e.value #>> '{}')::numeric <> round((e.value #>> '{}')::numeric)
                     or (e.value #>> '{}')::numeric not between (case when e.key in ('shards_per_stone','hearts','hp','gate_hp','pool','gate_q','combo','dmg_base','dmg_lv_div','crit_per') then 1 else 0 end) and 10000
              end)) then
    raise exception '단어 배틀 설정이 올바르지 않습니다.'; end if;
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

-- 학생 담당 선생님 변경(우리 학원 선생님 누구나). p_teacher 가 null 이면 담당 없음
create or replace function mw_set_teacher(p_student uuid, p_teacher uuid) returns void
language plpgsql security definer set search_path = public as $$
begin
  perform mw_need_teacher();
  perform mw_need_student(p_student);
  if p_teacher is not null and not exists (select 1 from mw_profiles where id = p_teacher and role = 'teacher' and active and academy_id = mw_my_academy()) then
    raise exception '우리 학원 선생님만 담당으로 지정할 수 있습니다.'; end if;
  update mw_profiles set teacher_id = p_teacher where id = p_student;
  perform mw_log('set_teacher', p_student, jsonb_build_object('teacher', p_teacher));
end $$;

-- 담당 지정용 선생님 이름 목록(우리 학원 활성 선생님의 id·이름만. 아이디 등 계정 정보는 원장만 봄)
create or replace function mw_teacher_names() returns table(id uuid, name text)
language plpgsql stable security definer set search_path = public as $$
begin
  perform mw_need_teacher();
  return query select p.id, coalesce(nullif(p.display_name, ''), '선생님') from mw_profiles p
   where p.academy_id = mw_my_academy() and p.role = 'teacher' and p.active order by p.created_at;
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
returns table(student_id uuid, n bigint, xp bigint, acts jsonb, done_at timestamptz, bonus bigint, wallet bigint, saving boolean, sent bigint)
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
                 and (r.granted_at at time zone 'Asia/Seoul')::date between p_start and p_start + 6), 0)::bigint,
    mw_point_balance(p.id)::bigint,
    p.point_save,
    coalesce((select -x.amount from mw_points x where x.student_id = p.id and x.ref = 'send:' || p_start), 0)::bigint
  from mw_profiles p where p.role = 'student' and p.active and p.academy_id = mw_my_academy();
end $$;

create or replace function mw_settle(p_students uuid[], p_start date, p_done boolean) returns void
language plpgsql security definer set search_path = public as $$
begin
  perform mw_need_teacher();
  perform 1 from mw_profiles where id = any(p_students) for update;   -- 구매와 동시에 일어나도 숫자가 어긋나지 않게
  if not p_done then   -- 되돌리기: 그 주에 보낸 기록을 지워 포인트를 돌려놓음
    delete from mw_points x where x.student_id = any(p_students) and x.ref = 'send:' || p_start and mw_same(x.student_id);
  end if;
  delete from mw_settlements s where s.student_id = any(p_students) and s.week_start = p_start and mw_same(s.student_id);
  if p_done then
    insert into mw_settlements(student_id, week_start, done_by)
    select u, p_start, auth.uid() from unnest(p_students) u where mw_same(u);
    -- v2.22: 입력 완료 = 지금 남은 칭찬 포인트를 칭찬모아로 보냄(모으기 중이면 0). 같은 주는 한 번만
    insert into mw_points(student_id, amount, kind, ref, note)
    select u, -(case when p.point_save then 0 else greatest(0, mw_point_balance(u)) end), 'send', 'send:' || p_start, '칭찬모아로 보냄'
      from unnest(p_students) u join mw_profiles p on p.id = u where mw_same(u)
    on conflict (student_id, ref) where ref is not null do nothing;
  end if;
  perform mw_log('settle', null, jsonb_build_object('week', p_start, 'done', p_done, 'count', coalesce(array_length(p_students, 1), 0)));
end $$;

-- ---------- v2.15 단어 배틀 ----------
-- 그날 배틀이 열리는가: 그날 "다 했어요" 요청 중이거나 승인된 활동(미션·독서)이 있으면 열림
create or replace function mw_battle_day_ok(p_student uuid, p_day date) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from mw_missions m where m.student_id = p_student and m.due_date = p_day and m.status in ('requested','approved'))
      or exists (select 1 from mw_books b where b.student_id = p_student and (b.created_at at time zone 'Asia/Seoul')::date = p_day
                  and b.status in ('requested','approved'));
$$;

-- 배틀 연속 기록: 배틀에서 이긴 평일이 며칠 이어졌는지(주말은 세지도 끊지도 않음). p_day 가 주말이면 그 주 금요일까지
create or replace function mw_battle_streak(p_student uuid, p_day date) returns int
language plpgsql stable security definer set search_path = public as $$
declare v int := mw_wd_idx(p_day); n int := 0;
begin
  loop
    exit when not exists (select 1 from mw_battles b where b.student_id = p_student and b.status = 'won' and not b.revoked
                           and b.day <= p_day and (b.day - date '2024-01-01') % 7 < 5 and mw_wd_idx(b.day) = v);
    n := n + 1; v := v - 1;
  end loop;
  return n;
end $$;

create or replace function mw_battle_mult(p_cfg jsonb, p_streak int) returns numeric
language sql immutable as $$
  select greatest(1, coalesce(max((e ->> 'mult')::numeric) filter (where (e ->> 'days')::int <= p_streak), 1))
    from jsonb_array_elements(coalesce(p_cfg -> 'streak', '[]'::jsonb)) e;
$$;

-- 밀린 Unit: 처음 지정한 위치부터 현재 Unit 앞까지, 한 번도 이기지 않은 Unit 수
create or replace function mw_word_backlog(p_student uuid) returns int
language sql stable security definer set search_path = public as $$
  select count(*)::int from (
    select distinct w.book, w.unit from mw_words w
      join mw_profiles p on p.id = p_student and w.academy_id = p.academy_id
      join mw_word_pos s on s.student_id = p_student
     where (w.book, w.unit) >= (s.start_book, s.start_unit) and (w.book, w.unit) < (s.book, s.unit)) u
   where not exists (select 1 from mw_battles x where x.student_id = p_student and x.book = u.book and x.unit = u.unit
                      and x.kind = 'unit' and x.status = 'won' and not x.revoked);
$$;

-- 단어시험 승인 → 현재 Unit +1 (권의 끝이면 다음 권 첫 Unit)
create or replace function mw_word_advance(p_student uuid) returns void
language plpgsql security definer set search_path = public as $$
declare pos mw_word_pos; v_ac uuid; v_next int;
begin
  select * into pos from mw_word_pos where student_id = p_student for update;
  if not found then return; end if;
  select academy_id into v_ac from mw_profiles where id = p_student;
  if exists (select 1 from mw_words where academy_id = v_ac and book = pos.book and unit = pos.unit + 1)
     or not exists (select 1 from mw_words where academy_id = v_ac) then
    update mw_word_pos set unit = pos.unit + 1, updated_at = now() where student_id = p_student;
  else
    select min(unit) into v_next from mw_words where academy_id = v_ac and book = pos.book + 1;
    if v_next is not null then update mw_word_pos set book = pos.book + 1, unit = v_next, updated_at = now() where student_id = p_student; end if;
  end if;
end $$;

-- 그날 활동이 반려·취소되어 배틀 조건이 사라지면: 그날 배틀 XP·조각 회수(연속 기록에서도 빠짐)
create or replace function mw_battle_recheck(p_student uuid, p_day date) returns void
language plpgsql security definer set search_path = public as $$
declare b mw_battles; v_mon uuid;
begin
  if p_day is null or mw_battle_day_ok(p_student, p_day) then return; end if;
  update mw_battles set status = 'quit', finished_at = now() where student_id = p_student and day = p_day and status = 'playing';
  for b in select * from mw_battles where student_id = p_student and day = p_day and status = 'won' and not revoked for update loop
    update mw_battles set revoked = true where id = b.id;
    perform mw_coin_revoke(p_student, 'bt:' || b.id, '배틀 회수');
    if b.xp > 0 then
      select monster_id into v_mon from mw_ledger where battle_id = b.id and kind = 'battle';
      if v_mon is not null then
        perform mw_apply_xp(p_student, v_mon, -b.xp, 'battle_revoke', '배틀 회수 · 요청 반려', null, null, b.id);
      end if;
    end if;
  end loop;
end $$;

-- 화면에 보낼 지금 문제(정답은 보내지 않음)
create or replace function mw_battle_state(b mw_battles) returns jsonb
language plpgsql stable as $$
declare it jsonb; t text;
begin
  if b.status = 'playing' and jsonb_array_length(b.queue) > 0 then it := b.items -> ((b.queue ->> 0)::int); t := it ->> 't'; end if;
  return jsonb_build_object('id', b.id, 'kind', b.kind, 'book', b.book, 'unit', b.unit, 'status', b.status,
    'hp', b.hp, 'hp_max', b.hp_max, 'hearts', b.hearts, 'hearts_max', b.hearts_max, 'combo', b.combo,
    'power', b.power, 'crit', round(b.crit * 100),
    'q', case when it is null then null else jsonb_build_object('n', b.qn, 't', t,
           -- mc: 영어 → 뜻 / listen: 소리만(say) → 뜻 / rev: 뜻 → 영어 고르기 / spell: 뜻 → 영어 쓰기
           'prompt', case when t in ('spell','rev') then it ->> 'ko' when t = 'listen' then null else it ->> 'en' end,
           'say', case when t = 'listen' then it ->> 'en' else null end,
           'options', case when t = 'spell' then null when t = 'rev' then it -> 'oe' else it -> 'o' end) end);
end $$;

-- 승리 보상(서버만 계산, 판마다 한 번)
create or replace function mw_battle_reward(p_battle uuid) returns jsonb
language plpgsql security definer set search_path = public as $$
declare b mw_battles; v_cfg jsonb; v_gate boolean; v_first boolean; v_today boolean; v_base int := 0; v_sh int := 0;
        v_streak int; v_mult numeric; v_raw int; v_ws date; v_class int; v_already int; v_room int; v_give int;
        v_mon uuid; v_per int; v_before int;
begin
  select * into b from mw_battles where id = p_battle for update;
  if b.status <> 'won' or b.rewarded then return null; end if;
  if not mw_battle_day_ok(b.student_id, b.day) then
    update mw_battles set revoked = true, rewarded = true where id = b.id;
    return jsonb_build_object('xp', 0, 'shards', 0, 'void', true);
  end if;
  v_cfg := mw_battle_cfg(b.academy_id); v_gate := b.kind = 'gate';
  v_first := not exists (select 1 from mw_battles x where x.student_id = b.student_id and x.book = b.book and x.unit = b.unit
                          and x.kind = b.kind and x.status = 'won' and not x.revoked and x.id <> b.id);
  v_today := exists (select 1 from mw_battles x where x.student_id = b.student_id and x.book = b.book and x.unit = b.unit
                      and x.kind = b.kind and x.status = 'won' and not x.revoked and x.id <> b.id and x.day = b.day);
  if b.kind = 'hard' then                           -- v2.23 강적: 첫 승리 XP 30·조각 10, 다시 이기면 하루 1번 XP 5·조각 2
    if v_first then v_base := coalesce((v_cfg ->> 'hard_xp')::int, 30); v_sh := coalesce((v_cfg ->> 'shard_hard')::int, 10);
    elsif not v_today then v_base := coalesce((v_cfg ->> 'hard_rewin_xp')::int, 5); v_sh := coalesce((v_cfg ->> 'shard_hard_rewin')::int, 2); end if;
  elsif v_first then
    v_base := (v_cfg ->> (case when v_gate then 'gate_xp' else 'first_xp' end))::int;
    v_sh := (v_cfg ->> (case when v_gate then 'shard_gate' else 'shard_first' end))::int;
  elsif not v_today then                            -- 재승리 보상은 하루에 Unit당 1번
    v_base := (v_cfg ->> (case when v_gate then 'gate_rewin_xp' else 'rewin_xp' end))::int;
    v_sh := (v_cfg ->> (case when v_gate then 'shard_gate_rewin' else 'shard_rewin' end))::int;
  end if;
  v_streak := mw_battle_streak(b.student_id, b.day);
  v_mult := mw_battle_mult(v_cfg, v_streak);
  v_raw := round(v_base * v_mult)::int;
  -- 주간 상한: 그 주 수업 XP(승인된 지급, 취소 제외)를 넘는 부분은 over_ratio 만큼만
  v_ws := b.day - (extract(isodow from b.day)::int - 1);
  select greatest(0, coalesce(sum(l.amount), 0))::int into v_class from mw_ledger l
   where l.student_id = b.student_id and l.kind = 'grant'
     and (l.created_at at time zone 'Asia/Seoul')::date between v_ws and v_ws + 6
     and not exists (select 1 from mw_ledger r where r.kind = 'revoke'
            and ((l.mission_id is not null and r.mission_id = l.mission_id) or (l.book_id is not null and r.book_id = l.book_id)));
  select coalesce(sum(l.amount), 0)::int into v_already from mw_ledger l
   where l.student_id = b.student_id and l.kind in ('battle','battle_revoke')
     and (l.created_at at time zone 'Asia/Seoul')::date between v_ws and v_ws + 6;
  v_room := greatest(0, v_class - v_already);
  v_give := least(v_raw, v_room) + floor((v_raw - least(v_raw, v_room)) * coalesce((v_cfg ->> 'over_ratio')::numeric, 0.25))::int;
  v_per := greatest(1, coalesce((v_cfg ->> 'shards_per_stone')::int, 100));
  v_before := mw_battle_shards(b.student_id);
  select active_monster into v_mon from mw_profiles where id = b.student_id;
  if v_give > 0 and v_mon is not null then
    perform mw_apply_xp(b.student_id, v_mon, v_give, 'battle', case when v_gate then '수문장 승리' when b.kind = 'hard' then '강적 승리' else 'Unit 승리' end, null, null, b.id);
  else v_give := 0; end if;
  update mw_battles set xp = v_give, shards = v_sh, first_win = v_first, mult = v_mult, rewarded = true where id = b.id;
  if v_first and v_gate then perform mw_gear_grant(b.student_id, 'g_lightbook'); end if;   -- v2.23 전설 장비: 수문장 첫 격파
  perform mw_coin_add(b.student_id, (mw_coin_cfg(b.academy_id) ->> (case when v_first and v_gate then 'gate_first' when v_first then 'battle_first' when v_base > 0 then 'battle_rewin' else 'none' end))::int,
                      case when v_gate then '수문장 승리' else '배틀 승리' end, 'bt:' || b.id);
  return jsonb_build_object('xp', v_give, 'raw', v_raw, 'shards', v_sh, 'first', v_first, 'mult', v_mult, 'streak', v_streak,
    'limited', (not v_first and v_today), 'shards_total', v_before + v_sh, 'per', v_per,
    'stone', ((v_before + v_sh) / v_per) > (v_before / v_per));
end $$;

-- 학생: 배틀 시작. 서버가 문제를 뽑아 저장하고 첫 문제만(정답 없이) 돌려줌
drop function if exists mw_battle_start(int, int, boolean);
create or replace function mw_battle_start(p_book int, p_unit int, p_gate boolean, p_hard boolean default false) returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_ac uuid := mw_my_academy(); v_cfg jsonb; pos mw_word_pos; v_units int[]; v_items jsonb := '[]'::jsonb;
        r record; v_i int := 0; v_opts jsonb; v_opte jsonb; v_hp int; b mw_battles; v_today date := mw_seoul_today(); v_gate boolean := coalesce(p_gate, false);
        v_hard boolean := coalesce(p_hard, false) and not coalesce(p_gate, false);
        m mw_monsters; v_power int; v_crit numeric; v_t text; v_rnd numeric;
begin
  if not mw_student_ok() then raise exception '승인된 학생 계정이 아닙니다.'; end if;
  perform 1 from mw_profiles where id = auth.uid() for update;
  select * into m from mw_monsters where id = (select active_monster from mw_profiles where id = auth.uid()) and hatched;
  if not found then raise exception '먼저 몬스터를 골라 주세요.'; end if;
  select * into pos from mw_word_pos where student_id = auth.uid();
  if not found then raise exception '선생님이 아직 단어장 위치를 정하지 않았습니다.'; end if;
  if not mw_battle_day_ok(auth.uid(), v_today) then raise exception '오늘 "다 했어요"를 하나 남기면 단어 동굴이 열려요.'; end if;
  v_cfg := mw_battle_cfg(v_ac);
  if p_book is null or p_unit is null or p_book > pos.book or (p_book = pos.book and p_unit > pos.unit) then
    raise exception '아직 열리지 않은 Unit입니다.'; end if;
  if v_gate then
    if p_unit % 5 <> 0 then raise exception '수문장은 5 Unit마다 있습니다.'; end if;
    v_units := array(select generate_series(p_unit - 4, p_unit));
    if exists (select 1 from (select distinct unit from mw_words where academy_id = v_ac and book = p_book and unit = any(v_units)) u
                where not exists (select 1 from mw_battles x where x.student_id = auth.uid() and x.book = p_book and x.unit = u.unit
                                   and x.kind = 'unit' and x.status = 'won' and not x.revoked)) then
      raise exception '수문장은 5개 Unit을 모두 한 번씩 이겨야 열립니다.'; end if;
  else
    v_units := array[p_unit];
  end if;
  if v_hard then   -- v2.23 강적 도전: 이긴 Unit만, 전투력 실버(130)부터. 문제·체력이 수문장만큼 많음(더 많이 풂)
    if not exists (select 1 from mw_battles x where x.student_id = auth.uid() and x.book = p_book and x.unit = p_unit and x.kind = 'unit' and x.status = 'won' and not x.revoked) then
      raise exception '먼저 이 Unit을 한 번 이겨야 강적이 나타나요.'; end if;
    if ((mw_power(auth.uid())) ->> 'total')::int < 130 then raise exception '강적은 전투력 130(실버)부터 도전할 수 있어요. 몬스터를 키우고 장비를 입혀 보세요.'; end if;
  end if;
  -- 내 몬스터의 힘: 기본 + 레벨 보너스 + 진화 보너스, 치명타 확률은 어휘 스탯에서
  v_power := (v_cfg ->> 'dmg_base')::int + least((v_cfg ->> 'dmg_lv_max')::int, m.level / greatest(1, (v_cfg ->> 'dmg_lv_div')::int))
             + case m.stage when 3 then (v_cfg ->> 'dmg_legend')::int when 2 then (v_cfg ->> 'dmg_elite')::int else 0 end;
  v_crit := least((v_cfg ->> 'crit_max')::numeric, coalesce((mw_stat_values(auth.uid()) ->> 'vocab')::numeric, 0) / greatest(1, (v_cfg ->> 'crit_per')::numeric)) / 100;
  update mw_battles set status = 'quit', finished_at = now() where student_id = auth.uid() and status = 'playing';
  for r in
    with w as (select lower(btrim(en)) as k, min(btrim(en)) as en, string_agg(distinct btrim(ko), ' / ') as ko
                 from mw_words where academy_id = v_ac and book = p_book and unit = any(v_units) group by 1)
    select w.k, w.en, w.ko from w
      left join mw_word_misses mm on mm.student_id = auth.uid() and mm.academy_id = v_ac and mm.k = w.k
     order by (coalesce(mm.misses, 0) > 0) desc, random()
     limit (case when v_gate or v_hard then (v_cfg ->> 'gate_q')::int else (v_cfg ->> 'pool')::int end)
  loop
    -- 오답 보기(뜻·영어): 같은 Unit 먼저, 모자라면 같은 권에서
    select coalesce(jsonb_agg(z.ko), '[]'::jsonb), coalesce(jsonb_agg(z.en), '[]'::jsonb) into v_opts, v_opte from (
      select y.ko, y.en from (
        select string_agg(distinct btrim(w2.ko), ' / ') as ko, min(btrim(w2.en)) as en, bool_or(w2.unit = any(v_units)) as near
          from mw_words w2 where w2.academy_id = v_ac and w2.book = p_book and lower(btrim(w2.en)) <> r.k
         group by lower(btrim(w2.en))) y
       where y.ko <> r.ko
       order by y.near desc, random() limit 3) z;
    select jsonb_agg(x order by random()) into v_opts from jsonb_array_elements(v_opts || jsonb_build_array(r.ko)) x;
    select jsonb_agg(x order by random()) into v_opte from jsonb_array_elements(v_opte || jsonb_build_array(r.en)) x;
    v_rnd := random() * 100;
    v_t := case when (v_gate or v_hard) and v_i % 2 = 1 then 'spell'
                when v_rnd < (v_cfg ->> 'mix_rev')::numeric then 'rev'
                when v_rnd < (v_cfg ->> 'mix_rev')::numeric + (v_cfg ->> 'mix_listen')::numeric then 'listen'
                else 'mc' end;
    v_items := v_items || jsonb_build_array(jsonb_build_object('k', r.k, 'en', r.en, 'ko', r.ko, 't', v_t, 'o', v_opts, 'oe', v_opte));
    v_i := v_i + 1;
  end loop;
  if v_i = 0 then raise exception '이 Unit에는 아직 단어가 없습니다.'; end if;
  v_hp := (v_cfg ->> (case when v_gate or v_hard then 'gate_hp' else 'hp' end))::int;
  insert into mw_battles(student_id, academy_id, day, book, unit, kind, items, queue, qn, hearts, hearts_max, hp, hp_max, power, crit)
  values (auth.uid(), v_ac, v_today, p_book, p_unit, case when v_gate then 'gate' when v_hard then 'hard' else 'unit' end, v_items,
          (select jsonb_agg(g) from generate_series(0, v_i - 1) g), 1,
          (v_cfg ->> 'hearts')::int, (v_cfg ->> 'hearts')::int, v_hp, v_hp, v_power, v_crit)
  returning * into b;
  return mw_battle_state(b);
end $$;

-- 학생: 답하기. 서버가 채점하고 다음 문제를 돌려줌. 끝나면 보상도 서버가 지급
create or replace function mw_battle_answer(p_battle uuid, p_n int, p_answer text) returns jsonb
language plpgsql security definer set search_path = public as $$
declare b mw_battles; v_cfg jsonb; it jsonb; v_cur int; v_ok boolean; v_dmg int := 0; v_crit boolean := false; v_rew jsonb; t text;
begin
  if not mw_student_ok() then raise exception '승인된 학생 계정이 아닙니다.'; end if;
  select * into b from mw_battles where id = p_battle and student_id = auth.uid() for update;
  if not found then raise exception '배틀을 찾을 수 없습니다.'; end if;
  if b.status <> 'playing' then raise exception '이미 끝난 배틀입니다.'; end if;
  if p_n is distinct from b.qn then raise exception '이미 답한 문제입니다.'; end if;
  v_cfg := mw_battle_cfg(b.academy_id);
  v_cur := (b.queue ->> 0)::int; it := b.items -> v_cur; t := it ->> 't';
  if t in ('spell','rev') then v_ok := lower(btrim(coalesce(p_answer, ''))) = lower(btrim(it ->> 'en'));
  else v_ok := coalesce(p_answer, '') = it ->> 'ko'; end if;
  if v_ok then
    b.combo := b.combo + 1;
    v_crit := random() < b.crit;
    v_dmg := round(b.power * (case when b.combo % greatest(1, (v_cfg ->> 'combo')::int) = 0 then 2 else 1 end)
                           * (case when v_crit then 1.5 else 1 end))::int;      -- 5번째·10번째 연속 정답 2배, 치명타 1.5배
    b.hp := greatest(0, b.hp - v_dmg);
    b.queue := b.queue - 0;
    update mw_word_misses set misses = greatest(0, misses - 1) where student_id = auth.uid() and academy_id = b.academy_id and k = it ->> 'k';
  else
    b.hearts := b.hearts - 1; b.combo := 0;
    b.queue := (b.queue - 0) || jsonb_build_array(v_cur);   -- 틀린 단어는 뒤에서 다시
    insert into mw_word_misses(student_id, academy_id, k, misses, last_at) values (auth.uid(), b.academy_id, it ->> 'k', 1, now())
    on conflict (student_id, academy_id, k) do update set misses = mw_word_misses.misses + 1, last_at = now();
  end if;
  if jsonb_array_length(b.queue) = 0 then b.queue := (select jsonb_agg(g) from generate_series(0, jsonb_array_length(b.items) - 1) g); end if;
  b.qn := b.qn + 1;
  if b.hp <= 0 then b.status := 'won'; b.finished_at := now();
  elsif b.hearts <= 0 then b.status := 'lost'; b.finished_at := now(); end if;
  update mw_battles set combo = b.combo, hp = b.hp, hearts = b.hearts, queue = b.queue, qn = b.qn, status = b.status, finished_at = b.finished_at
   where id = b.id;
  if b.status = 'won' then v_rew := mw_battle_reward(b.id); end if;
  select * into b from mw_battles where id = p_battle;
  return mw_battle_state(b) || jsonb_build_object('correct', v_ok, 'dmg', v_dmg, 'crit', v_crit, 'word', it ->> 'en',
    'answer', case when t in ('spell','rev') then it ->> 'en' else it ->> 'ko' end, 'reward', v_rew);
end $$;

-- 학생: 단어 동굴 현황(단어는 보내지 않음)
create or replace function mw_cave() returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare v_ac uuid := mw_my_academy(); pos mw_word_pos; v_cfg jsonb; v_books jsonb; v_streak int; v_today date := mw_seoul_today();
begin
  if not mw_student_ok() then raise exception '승인된 학생 계정이 아닙니다.'; end if;
  v_cfg := mw_battle_cfg(v_ac);
  v_streak := mw_battle_streak(auth.uid(), v_today);
  select * into pos from mw_word_pos where student_id = auth.uid();
  if found then
    select jsonb_agg(jsonb_build_object('book', bk.book, 'units', bk.units) order by bk.book) into v_books from (
      select u.book, jsonb_agg(jsonb_build_object('unit', u.unit, 'words', u.n,
               'won', exists (select 1 from mw_battles x where x.student_id = auth.uid() and x.book = u.book and x.unit = u.unit
                               and x.kind = 'unit' and x.status = 'won' and not x.revoked),
               'gate_won', exists (select 1 from mw_battles x where x.student_id = auth.uid() and x.book = u.book and x.unit = u.unit
                               and x.kind = 'gate' and x.status = 'won' and not x.revoked),
               'hard_won', exists (select 1 from mw_battles x where x.student_id = auth.uid() and x.book = u.book and x.unit = u.unit
                               and x.kind = 'hard' and x.status = 'won' and not x.revoked),
               'locked', (u.book = pos.book and u.unit > pos.unit)) order by u.unit) as units
        from (select book, unit, count(*)::int as n from mw_words where academy_id = v_ac and book <= pos.book group by book, unit) u
       group by u.book) bk;
  end if;
  return jsonb_build_object(
    'pos', case when pos.student_id is null then null else jsonb_build_object('book', pos.book, 'unit', pos.unit) end,
    'open', mw_battle_day_ok(auth.uid(), v_today), 'books', coalesce(v_books, '[]'::jsonb),
    'shards', mw_battle_shards(auth.uid()), 'per', greatest(1, (v_cfg ->> 'shards_per_stone')::int),
    'streak', v_streak, 'mult', mw_battle_mult(v_cfg, v_streak),
    'backlog', case when pos.student_id is null then 0 else mw_word_backlog(auth.uid()) end);
end $$;

-- 선생님: 단어 올리기(한 번에 1000개까지, 같은 권·Unit·번호는 덮어씀)
create or replace function mw_word_import(p_rows jsonb) returns int
language plpgsql security definer set search_path = public as $$
declare v_ac uuid := mw_my_academy(); e jsonb; n int := 0;
begin
  perform mw_need_teacher();
  if jsonb_typeof(p_rows) <> 'array' or jsonb_array_length(p_rows) > 1000 then raise exception '한 번에 1000개까지 올릴 수 있습니다.'; end if;
  for e in select * from jsonb_array_elements(p_rows) loop
    if coalesce(e ->> 'b', '') !~ '^[1-9][0-9]{0,2}$' or coalesce(e ->> 'u', '') !~ '^[1-9][0-9]{0,2}$' or coalesce(e ->> 'n', '') !~ '^[1-9][0-9]{0,3}$'
       or length(btrim(coalesce(e ->> 'en', ''))) not between 1 and 100 or length(btrim(coalesce(e ->> 'ko', ''))) not between 1 and 200 then
      raise exception '%번째 단어의 형식이 올바르지 않습니다. (권·Unit·번호는 1 이상 숫자, 영어·뜻은 비울 수 없음)', n + 1; end if;
    insert into mw_words(academy_id, book, unit, no, en, ko)
    values (v_ac, (e ->> 'b')::int, (e ->> 'u')::int, (e ->> 'n')::int, btrim(e ->> 'en'), btrim(e ->> 'ko'))
    on conflict (academy_id, book, unit, no) do update set en = excluded.en, ko = excluded.ko, updated_at = now();
    n := n + 1;
  end loop;
  perform mw_log('word_import', null, jsonb_build_object('count', n));
  return n;
end $$;

create or replace function mw_word_books() returns table(book int, units int, words int)
language plpgsql stable security definer set search_path = public as $$
begin
  perform mw_need_teacher();
  return query select w.book, count(distinct w.unit)::int, count(*)::int from mw_words w
   where w.academy_id = mw_my_academy() group by w.book order by w.book;
end $$;

create or replace function mw_word_delete_book(p_book int) returns int
language plpgsql security definer set search_path = public as $$
declare n int;
begin
  perform mw_need_teacher();
  delete from mw_words where academy_id = mw_my_academy() and book = p_book;
  get diagnostics n = row_count;
  perform mw_log('word_delete_book', null, jsonb_build_object('book', p_book, 'count', n));
  return n;
end $$;

-- 선생님: 학생 현재 권·Unit 지정(처음 지정한 위치가 밀린 Unit 계산의 시작점)
create or replace function mw_set_word_pos(p_student uuid, p_book int, p_unit int) returns void
language plpgsql security definer set search_path = public as $$
begin
  perform mw_need_student(p_student);
  if p_book is null or p_unit is null or p_book not between 1 and 999 or p_unit not between 1 and 999 then
    raise exception '권과 Unit은 1~999 사이 숫자로 입력해 주세요.'; end if;
  insert into mw_word_pos(student_id, book, unit, start_book, start_unit, updated_by)
  values (p_student, p_book, p_unit, p_book, p_unit, auth.uid())
  on conflict (student_id) do update set book = excluded.book, unit = excluded.unit, updated_by = auth.uid(), updated_at = now(),
    start_book = case when (excluded.book, excluded.unit) < (mw_word_pos.start_book, mw_word_pos.start_unit) then excluded.book else mw_word_pos.start_book end,
    start_unit = case when (excluded.book, excluded.unit) < (mw_word_pos.start_book, mw_word_pos.start_unit) then excluded.unit else mw_word_pos.start_unit end;
  perform mw_log('set_word_pos', p_student, jsonb_build_object('book', p_book, 'unit', p_unit));
end $$;

-- 선생님: 학생별 현재 위치와 밀린 Unit
create or replace function mw_word_status() returns table(student_id uuid, book int, unit int, backlog int)
language plpgsql stable security definer set search_path = public as $$
#variable_conflict use_column
begin
  perform mw_need_teacher();
  return query select p.id, s.book, s.unit, case when s.student_id is null then 0 else mw_word_backlog(p.id) end
    from mw_profiles p left join mw_word_pos s on s.student_id = p.id
   where p.academy_id = mw_my_academy() and p.role = 'student' and p.active;
end $$;

-- ---------- v2.17 코인·상점·내 집 ----------
-- 활동 승인 후 처리: 승인 코인 + 연속 보상 코인(streak_rewards 달성 횟수만큼, 한 번씩)
create or replace function mw_coin_on_approve(p_student uuid, p_activity text, p_ref text) returns void
language plpgsql security definer set search_path = public as $$
declare v_ac uuid; v_cfg jsonb; v_info jsonb; k int;
begin
  select academy_id into v_ac from mw_profiles where id = p_student;
  v_cfg := mw_coin_cfg(v_ac);
  perform mw_coin_add(p_student, (v_cfg ->> 'activity')::int, '활동 승인', p_ref);
  v_info := mw_streak_info(p_student) -> p_activity;
  if v_info is not null then
    for k in 1 .. coalesce((v_info ->> 'earned')::int, 0) loop
      perform mw_coin_add(p_student, (v_cfg ->> 'streak')::int, '연속 ' || (v_info ->> 'days') || '일 달성', 'st:' || p_activity || ':' || k);
    end loop;
    if coalesce((v_info ->> 'earned')::int, 0) > 0 then perform mw_gear_grant(p_student, 'g_emblem'); end if;   -- v2.23 전설 장비: 연속 보상 달성
  end if;
end $$;

-- 학생: 상점(목록·내 코인·가진 것)
create or replace function mw_shop() returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare v_lv int;
begin
  if not mw_student_ok() then raise exception '승인된 학생 계정이 아닙니다.'; end if;
  select coalesce(max(level), 1) into v_lv from mw_monsters where student_id = auth.uid() and hatched;
  return jsonb_build_object('coins', mw_coin_balance(auth.uid()), 'points', mw_point_balance(auth.uid()), 'point_rate', 10, 'level', v_lv,
    'point_save', (select point_save from mw_profiles where id = auth.uid()), 'season', mw_season_now(), 'power', mw_power(auth.uid()),
    'progress', jsonb_build_object('stats', mw_stat_values(auth.uid()),
                                   'books', (select count(*) from mw_books b where b.student_id = auth.uid() and b.status = 'approved'),
                                   'stage', coalesce((select max(stage) from mw_monsters m where m.student_id = auth.uid() and m.hatched), 1)),
    'items', coalesce((select jsonb_agg(jsonb_build_object('id', i.id, 'kind', i.kind, 'name', i.name, 'price', i.price, 'min_level', i.min_level,
              'rarity', i.rarity, 'season', i.season, 'image_url', i.image_url, 'unlock', i.unlock, 'place', i.place, 'w', i.w,
              'slot', i.slot, 'power', i.power, 'set_id', i.set_id, 'grant_key', i.grant_key, 'preset', i.preset,
              'owned', coalesce((select v.qty from mw_inventory v where v.student_id = auth.uid() and v.item_id = i.id), case when i.price = 0 and i.grant_key is null then 1 else 0 end))
              order by i.kind, i.sort) from mw_shop_items i where i.enabled), '[]'::jsonb));
end $$;

-- 학생: 사기(가격·잔액·레벨 조건은 서버가 확인)
drop function if exists mw_buy(text);
drop function if exists mw_buy(text, text);
create or replace function mw_buy(p_item text, p_pay text default 'coin') returns jsonb
language plpgsql security definer set search_path = public as $$
declare it mw_shop_items; v_lv int; v_bal int; v_has int; v_xp int;
begin
  if not mw_student_ok() then raise exception '승인된 학생 계정이 아닙니다.'; end if;
  perform 1 from mw_profiles where id = auth.uid() for update;
  select * into it from mw_shop_items where id = p_item and enabled;
  if not found then raise exception '살 수 없는 물건입니다.'; end if;
  select coalesce(max(level), 1) into v_lv from mw_monsters where student_id = auth.uid() and hatched;
  if v_lv < it.min_level then raise exception 'Lv.%부터 살 수 있어요.', it.min_level; end if;
  if it.grant_key is not null then raise exception '전설 장비는 살 수 없어요. 실력이 오르면 받을 수 있어요.'; end if;
  if not mw_item_unlocked(auth.uid(), it.unlock) then raise exception '아직 잠겨 있어요. 공부해서 조건을 채우면 열려요.'; end if;
  if it.season is not null and it.season <> mw_season_now() then raise exception '지금은 판매 기간이 아니에요.'; end if;
  select qty into v_has from mw_inventory where student_id = auth.uid() and item_id = it.id;
  if (it.kind <> 'furniture' and (coalesce(v_has, 0) > 0 or it.price = 0)) or coalesce(v_has, 0) >= 9 then raise exception '이미 가지고 있어요.'; end if;
  if coalesce(p_pay, 'coin') not in ('coin', 'point') then raise exception '결제 방법이 올바르지 않습니다.'; end if;
  if p_pay = 'point' and it.price > 0 then   -- v2.22: ⭐ 칭찬 포인트(코인 가격 × 10). 쓴 만큼 칭찬모아로 넘어가지 않음
    v_xp := it.price * 10;
    v_bal := mw_point_balance(auth.uid());
    if v_bal < v_xp then raise exception '칭찬 포인트가 부족해요. (% / %)', greatest(v_bal, 0), v_xp; end if;
    insert into mw_points(student_id, amount, kind, ref, note) values (auth.uid(), -v_xp, 'spend', 'buy:' || gen_random_uuid(), it.name || ' 구매');
  else
    v_bal := mw_coin_balance(auth.uid());
    if v_bal < it.price then raise exception '코인이 부족해요. (% / %)', v_bal, it.price; end if;
    if it.price > 0 then insert into mw_coins(student_id, amount, reason, ref) values (auth.uid(), -it.price, it.name || ' 구매', 'buy:' || gen_random_uuid()); end if;
  end if;
  insert into mw_inventory(student_id, item_id, qty) values (auth.uid(), it.id, 1)
  on conflict (student_id, item_id) do update set qty = mw_inventory.qty + 1;
  perform mw_log('buy', auth.uid(), jsonb_build_object('item', it.id, 'price', it.price, 'pay', coalesce(p_pay, 'coin')));
  return jsonb_build_object('coins', mw_coin_balance(auth.uid()), 'points', mw_point_balance(auth.uid()));
end $$;

-- 학생: 내 집
create or replace function mw_home() returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare h mw_homes;
begin
  if not mw_student_ok() then raise exception '승인된 학생 계정이 아닙니다.'; end if;
  select * into h from mw_homes where student_id = auth.uid();
  return jsonb_build_object('wall', coalesce(h.wall, 'wall_cream'), 'floor', coalesce(h.floor, 'floor_wood'), 'layout', coalesce(h.layout, '[]'::jsonb),
    'theme', h.theme, 'power', mw_power(auth.uid()),
    'inventory', coalesce((select jsonb_object_agg(item_id, qty) from mw_inventory where student_id = auth.uid()), '{}'::jsonb),
    'coins', mw_coin_balance(auth.uid()),
    'points', mw_point_balance(auth.uid()),
    'stickers', coalesce((select jsonb_object_agg(q.kind, q.n) from (select kind, count(*)::int as n from mw_stickers where to_student = auth.uid() group by kind) q), '{}'::jsonb),
    'today', coalesce((select jsonb_agg(jsonb_build_object('kind', x.kind, 'name', mw_pub_name(x.from_student)) order by x.created_at desc)
                        from mw_stickers x where x.to_student = auth.uid() and x.day = mw_seoul_today()), '[]'::jsonb),
    'visit', mw_visit_ok(mw_my_academy()));
end $$;

-- 학생: 집 저장(가진 물건만, 가진 개수만큼, 방 안에만)
create or replace function mw_home_save(p_wall text, p_floor text, p_layout jsonb) returns void
language plpgsql security definer set search_path = public as $$
declare e jsonb; v_cnt jsonb := '{}'::jsonb; v_i text; it mw_shop_items; v_x int; v_y int; v_cells text[] := '{}'; v_norm jsonb := '[]'::jsonb; k int;
begin
  if not mw_student_ok() then raise exception '승인된 학생 계정이 아닙니다.'; end if;
  if not exists (select 1 from mw_shop_items i where i.id = p_wall and i.kind = 'wall' and (i.price = 0 or exists (select 1 from mw_inventory v where v.student_id = auth.uid() and v.item_id = i.id)))
     or not exists (select 1 from mw_shop_items i where i.id = p_floor and i.kind = 'floor' and (i.price = 0 or exists (select 1 from mw_inventory v where v.student_id = auth.uid() and v.item_id = i.id))) then
    raise exception '가지고 있는 벽지·바닥만 쓸 수 있어요.'; end if;
  if jsonb_typeof(p_layout) <> 'array' or jsonb_array_length(p_layout) > 56 then raise exception '배치가 올바르지 않습니다.'; end if;
  -- v2.22: 바닥 8×6칸(y 0~5) + 벽 1줄(y -1, 벽걸이만). 가구마다 차지하는 칸(w) 만큼 겹치지 않게. f = 좌우 뒤집기
  for e in select * from jsonb_array_elements(p_layout) loop
    if jsonb_typeof(e) <> 'object' or coalesce(e ->> 'x', '') !~ '^[0-7]$' or coalesce(e ->> 'y', '') !~ '^(-1|[0-5])$'
       or (e ? 'f' and jsonb_typeof(e -> 'f') <> 'boolean') then raise exception '배치가 올바르지 않습니다.'; end if;
    v_i := e ->> 'i'; v_x := (e ->> 'x')::int; v_y := (e ->> 'y')::int;
    select * into it from mw_shop_items where id = v_i and kind in ('furniture', 'seasonal');
    if not found or (it.place = 'wall') <> (v_y = -1) then raise exception '배치가 올바르지 않습니다.'; end if;
    if v_x + greatest(1, it.w) > 8 then raise exception '방 밖으로 나갈 수 없어요.'; end if;
    for k in 0 .. greatest(1, it.w) - 1 loop
      if (v_x + k) || ',' || v_y = any(v_cells) then raise exception '한 칸에는 하나만 놓을 수 있어요.'; end if;
      v_cells := v_cells || ((v_x + k) || ',' || v_y);
    end loop;
    v_cnt := jsonb_set(v_cnt, array[v_i], to_jsonb(coalesce((v_cnt ->> v_i)::int, 0) + 1));
    if (v_cnt ->> v_i)::int > coalesce((select qty from mw_inventory where student_id = auth.uid() and item_id = v_i), 0) then
      raise exception '가진 개수보다 많이 놓을 수 없어요.'; end if;
    v_norm := v_norm || jsonb_build_array(jsonb_build_object('i', v_i, 'x', v_x, 'y', v_y, 'f', coalesce((e ->> 'f')::boolean, false)));
  end loop;
  insert into mw_homes(student_id, wall, floor, layout, updated_at) values (auth.uid(), p_wall, p_floor, v_norm, now())
  on conflict (student_id) do update set wall = excluded.wall, floor = excluded.floor, layout = excluded.layout, theme = null, updated_at = now();
end $$;

-- 학생: 몬스터에 액세서리 씌우기/벗기기
create or replace function mw_equip(p_monster uuid, p_item text) returns void
language plpgsql security definer set search_path = public as $$
begin
  if not mw_student_ok() then raise exception '승인된 학생 계정이 아닙니다.'; end if;
  if p_item is not null and not exists (select 1 from mw_inventory v join mw_shop_items i on i.id = v.item_id
                                         where v.student_id = auth.uid() and v.item_id = p_item and i.kind in ('acc','gear')) then
    raise exception '가지고 있는 액세서리만 씌울 수 있어요.'; end if;
  -- v2.23: 예전 기능 — 장비 칸에 입히기로 이어짐
  update mw_monsters set acc = p_item,
         gear = case when p_item is null then gear - 'head' else gear || jsonb_build_object(coalesce((select slot from mw_shop_items where id = p_item), 'head'), p_item) end
   where id = p_monster and student_id = auth.uid() and hatched;
  if not found then raise exception '내 몬스터가 아닙니다.'; end if;
end $$;

-- 선생님: 학생 코인 잔액과 최근 내역
create or replace function mw_coins_of(p_student uuid) returns jsonb
language plpgsql stable security definer set search_path = public as $$
begin
  if not ((p_student = auth.uid() and mw_student_ok()) or mw_same(p_student)) then raise exception '볼 수 없는 학생입니다.'; end if;
  return jsonb_build_object('coins', mw_coin_balance(p_student),
    'log', coalesce((select jsonb_agg(jsonb_build_object('amount', c.amount, 'reason', c.reason, 'at', c.created_at) order by c.created_at desc)
                      from (select * from mw_coins where student_id = p_student order by created_at desc limit 20) c), '[]'::jsonb));
end $$;

-- ---------- v2.18 친구 집 방문 + 스티커 ----------
-- 친구 집 보기(임시 열쇠로). 실명·코인·XP·공부 기록은 보내지 않음. 선생님은 실명으로 봄
create or replace function mw_home_of(p_key text) returns jsonb
language plpgsql stable security definer set search_path = public as $$
declare t mw_profiles; h mw_homes; v_t boolean := mw_is_teacher();
begin
  if not (mw_student_ok() or v_t) then raise exception '승인된 계정이 아닙니다.'; end if;
  select * into t from mw_profiles where visit_key = p_key and academy_id = mw_my_academy() and role = 'student' and active;
  if not found then raise exception '찾을 수 없는 집입니다.'; end if;
  if not v_t and not mw_visit_ok(t.academy_id) then raise exception '지금은 친구 집 방문이 꺼져 있어요.'; end if;
  select * into h from mw_homes where student_id = t.id;
  return jsonb_build_object('name', case when v_t then t.display_name else mw_pub_name(t.id) end, 'mine', t.id = auth.uid(),
    'wall', coalesce(h.wall, 'wall_cream'), 'floor', coalesce(h.floor, 'floor_wood'), 'layout', coalesce(h.layout, '[]'::jsonb), 'theme', h.theme,
    'power', mw_power(t.id),
    'monsters', coalesce((select jsonb_agg(jsonb_build_object('species_id', m.species_id, 'stage', m.stage, 'acc', m.acc, 'gear', m.gear))
                           from (select * from mw_monsters where student_id = t.id and hatched order by (id = t.active_monster) desc, level desc limit 6) m), '[]'::jsonb),
    'stickers', coalesce((select jsonb_object_agg(q.kind, q.n) from (select kind, count(*)::int as n from mw_stickers where to_student = t.id group by kind) q), '{}'::jsonb),
    'sent_today', exists (select 1 from mw_stickers where from_student = auth.uid() and to_student = t.id and day = mw_seoul_today()));
end $$;

-- 학생: 스티커 보내기(정해진 6종, 친구마다 하루 1개). 10·50개 받으면 배지
create or replace function mw_sticker(p_key text, p_kind text) returns void
language plpgsql security definer set search_path = public as $$
declare t mw_profiles; n int;
begin
  if not mw_student_ok() then raise exception '승인된 학생 계정이 아닙니다.'; end if;
  select * into t from mw_profiles where visit_key = p_key and academy_id = mw_my_academy() and role = 'student' and active;
  if not found then raise exception '찾을 수 없는 집입니다.'; end if;
  if not mw_visit_ok(t.academy_id) then raise exception '지금은 친구 집 방문이 꺼져 있어요.'; end if;
  if t.id = auth.uid() then raise exception '내 집에는 스티커를 보낼 수 없어요.'; end if;
  if p_kind not in ('like','fire','star','cute','cheer','best') then raise exception '보낼 수 없는 스티커입니다.'; end if;
  insert into mw_stickers(from_student, to_student, kind, day) values (auth.uid(), t.id, p_kind, mw_seoul_today())
  on conflict (from_student, to_student, day) do nothing;
  if not found then raise exception '오늘은 이 친구에게 이미 스티커를 보냈어요.'; end if;
  select count(*) into n from mw_stickers where to_student = t.id;
  if n >= 10 then perform mw_badge(t.id, 'sticker10'); end if;
  if n >= 50 then perform mw_badge(t.id, 'sticker50'); end if;
end $$;

-- 선생님: 학생이 받은·보낸 스티커(실명)
create or replace function mw_stickers_of(p_student uuid) returns jsonb
language plpgsql stable security definer set search_path = public as $$
begin
  perform mw_need_student(p_student);
  return jsonb_build_object(
    'received', coalesce((select jsonb_agg(jsonb_build_object('kind', x.kind, 'name', p.display_name, 'at', x.created_at) order by x.created_at desc)
                           from (select * from mw_stickers where to_student = p_student order by created_at desc limit 20) x join mw_profiles p on p.id = x.from_student), '[]'::jsonb),
    'given', coalesce((select jsonb_agg(jsonb_build_object('kind', x.kind, 'name', p.display_name, 'at', x.created_at) order by x.created_at desc)
                        from (select * from mw_stickers where from_student = p_student order by created_at desc limit 20) x join mw_profiles p on p.id = x.to_student), '[]'::jsonb));
end $$;

-- ---------- v2.19 친구 대결 ----------
create or replace function mw_duel_cfg(p_ac uuid) returns jsonb
language sql stable security definer set search_path = public as $$
  select '{"on":false,"win":15,"draw":5,"lose":3,"daily":3,"hours":48,"power_max":20}'::jsonb || coalesce(mw_setting(p_ac, 'duel'), '{}'::jsonb);
$$;

-- 내 몬스터 공격력(배틀과 같은 공식)
create or replace function mw_my_power(p_student uuid) returns int
language plpgsql stable security definer set search_path = public as $$
begin
  return (select coalesce((c ->> 'dmg_base')::int + least((c ->> 'dmg_lv_max')::int, m.level / greatest(1, (c ->> 'dmg_lv_div')::int))
         + case m.stage when 3 then (c ->> 'dmg_legend')::int when 2 then (c ->> 'dmg_elite')::int else 0 end
         + least(10, coalesce(mw_gear_power(p_student), 0) / 8), 10)   -- v2.23: 장비도 조금 반영(대결 보너스 상한은 그대로)
    from mw_profiles p join mw_monsters m on m.id = p.active_monster, mw_battle_cfg(p.academy_id) c
   where p.id = p_student);
end $$;

-- 지금 문제(보낼 때 시각을 기록. 한 번 기록되면 다시 불러도 바뀌지 않음)
create or replace function mw_duel_view(p_duel uuid, p_serve boolean) returns jsonb
language plpgsql security definer set search_path = public as $$
declare d mw_duels; pl mw_duel_play; it jsonb; t text; v_other uuid; op mw_duel_play; v_cfg jsonb;
begin
  select * into d from mw_duels where id = p_duel and (a = auth.uid() or b = auth.uid());
  if not found then raise exception '대결을 찾을 수 없습니다.'; end if;
  select * into pl from mw_duel_play where duel_id = d.id and student_id = auth.uid();
  v_other := case when d.a = auth.uid() then d.b else d.a end;
  select * into op from mw_duel_play where duel_id = d.id and student_id = v_other;
  if pl.duel_id is not null and p_serve and not pl.done and pl.qn <= jsonb_array_length(d.items) then
    if pl.served_at is null then update mw_duel_play set served_at = clock_timestamp() where duel_id = d.id and student_id = auth.uid(); end if;
    it := d.items -> (pl.qn - 1); t := it ->> 't';
  end if;
  v_cfg := mw_duel_cfg(d.academy_id);
  return jsonb_build_object('id', d.id, 'status', d.status, 'role', case when d.a = auth.uid() then 'a' else 'b' end,
    'other', mw_pub_name(v_other), 'total', jsonb_array_length(d.items), 'expires_at', d.expires_at,
    'n', pl.qn, 'my_score', pl.score, 'my_correct', pl.correct, 'my_done', coalesce(pl.done, false),
    'bonus', case when pl.power is null then 0 else least((v_cfg ->> 'power_max')::int, greatest(0, (pl.power - 10) * 2)) end,
    'other_score', case when d.status = 'done' then op.score end, 'other_correct', case when d.status = 'done' then op.correct end,
    'result', case when d.status <> 'done' then null when d.result = 'draw' then 'draw' when (d.result = 'a') = (d.a = auth.uid()) then 'win' else 'lose' end,
    'q', case when it is null then null else jsonb_build_object('n', pl.qn, 't', t,
           'prompt', case when t = 'rev' then it ->> 'ko' when t = 'listen' then null else it ->> 'en' end,
           'say', case when t = 'listen' then it ->> 'en' end,
           'options', (select jsonb_agg(x order by random()) from jsonb_array_elements(case when t = 'rev' then it -> 'oe' else it -> 'o' end) x)) end);
end $$;

-- 대결 마무리: 점수 비교, 코인(하루 daily 번까지)
create or replace function mw_duel_finish(p_duel uuid) returns void
language plpgsql security definer set search_path = public as $$
declare d mw_duels; pa mw_duel_play; pb mw_duel_play; v_cfg jsonb; v_res text; s uuid; v_amt int;
begin
  select * into d from mw_duels where id = p_duel for update;
  if d.status = 'done' then return; end if;
  select * into pa from mw_duel_play where duel_id = d.id and student_id = d.a;
  select * into pb from mw_duel_play where duel_id = d.id and student_id = d.b;
  v_res := case when coalesce(pa.score, 0) > coalesce(pb.score, 0) then 'a' when coalesce(pa.score, 0) < coalesce(pb.score, 0) then 'b' else 'draw' end;
  update mw_duels set status = 'done', result = v_res, finished_at = now() where id = d.id;
  v_cfg := mw_duel_cfg(d.academy_id);
  foreach s in array array[d.a, d.b] loop
    if (select count(*) from mw_coins c where c.student_id = s and c.ref like 'du:%' and c.amount > 0
         and (c.created_at at time zone 'Asia/Seoul')::date = mw_seoul_today()) < (v_cfg ->> 'daily')::int then
      v_amt := (v_cfg ->> (case when v_res = 'draw' then 'draw' when (v_res = 'a') = (s = d.a) then 'win' else 'lose' end))::int;
      perform mw_coin_add(s, v_amt, case when v_res = 'draw' then '대결 무승부' when (v_res = 'a') = (s = d.a) then '대결 승리' else '대결 참여' end, 'du:' || d.id);
    end if;
  end loop;
end $$;

-- 48시간이 지난 대결: 신청한 학생이 끝냈고 받은 학생이 풀던 중이면 그 점수로 마무리, 아니면 취소
create or replace function mw_duel_expire(p_student uuid) returns void
language plpgsql security definer set search_path = public as $$
declare d mw_duels;
begin
  for d in select * from mw_duels where (a = p_student or b = p_student) and status in ('a_playing','waiting','b_playing') and expires_at < now() for update loop
    if d.status = 'b_playing' then perform mw_duel_finish(d.id);
    else update mw_duels set status = 'expired', finished_at = now() where id = d.id; end if;
  end loop;
end $$;

-- 학생: 대결 신청(서버가 두 학생이 함께 배운 단어에서 10문제를 정함)
create or replace function mw_duel_create(p_key text) returns jsonb
language plpgsql security definer set search_path = public as $$
declare v_ac uuid := mw_my_academy(); v_cfg jsonb; v_bc jsonb; t mw_profiles; pa mw_word_pos; pb mw_word_pos; v_lb int; v_lu int;
        r record; v_items jsonb := '[]'::jsonb; v_i int := 0; v_opts jsonb; v_opte jsonb; v_rnd numeric; v_t text; v_id uuid;
begin
  if not mw_student_ok() then raise exception '승인된 학생 계정이 아닙니다.'; end if;
  v_cfg := mw_duel_cfg(v_ac);
  if not coalesce((v_cfg ->> 'on')::boolean, false) or not mw_visit_ok(v_ac) then raise exception '지금은 친구 대결이 꺼져 있어요.'; end if;
  perform 1 from mw_profiles where id = auth.uid() for update;
  select * into t from mw_profiles where visit_key = p_key and academy_id = v_ac and role = 'student' and active;
  if not found then raise exception '찾을 수 없는 친구입니다.'; end if;
  if t.id = auth.uid() then raise exception '나와는 대결할 수 없어요.'; end if;
  if (select active_monster from mw_profiles where id = auth.uid()) is null or t.active_monster is null then raise exception '두 사람 모두 몬스터가 있어야 해요.'; end if;
  perform mw_duel_expire(auth.uid());
  if (select count(*) from mw_duels where a = auth.uid() and day = mw_seoul_today()) >= (v_cfg ->> 'daily')::int then
    raise exception '오늘은 대결 신청을 %번 모두 했어요. 내일 또 해요!', (v_cfg ->> 'daily'); end if;
  if exists (select 1 from mw_duels where day = mw_seoul_today() and ((a = auth.uid() and b = t.id) or (a = t.id and b = auth.uid()))) then
    raise exception '오늘은 이 친구와 이미 대결했어요.'; end if;
  select * into pa from mw_word_pos where student_id = auth.uid();
  select * into pb from mw_word_pos where student_id = t.id;
  if pa.student_id is null or pb.student_id is null then raise exception '두 사람 모두 단어장 위치가 있어야 해요.'; end if;
  if (pa.book, pa.unit) <= (pb.book, pb.unit) then v_lb := pa.book; v_lu := pa.unit; else v_lb := pb.book; v_lu := pb.unit; end if;
  v_bc := mw_battle_cfg(v_ac);
  for r in
    with w as (select lower(btrim(en)) as k, min(btrim(en)) as en, string_agg(distinct btrim(ko), ' / ') as ko
                 from mw_words where academy_id = v_ac and (book, unit) <= (v_lb, v_lu) group by 1)
    select * from w order by random() limit 10
  loop
    select coalesce(jsonb_agg(z.ko), '[]'::jsonb), coalesce(jsonb_agg(z.en), '[]'::jsonb) into v_opts, v_opte from (
      select y.ko, y.en from (select string_agg(distinct btrim(w2.ko), ' / ') as ko, min(btrim(w2.en)) as en
                                from mw_words w2 where w2.academy_id = v_ac and (w2.book, w2.unit) <= (v_lb, v_lu) and lower(btrim(w2.en)) <> r.k
                               group by lower(btrim(w2.en))) y
       where y.ko <> r.ko order by random() limit 3) z;
    v_opts := v_opts || jsonb_build_array(r.ko); v_opte := v_opte || jsonb_build_array(r.en);
    v_rnd := random() * 100;
    v_t := case when v_rnd < (v_bc ->> 'mix_rev')::numeric then 'rev' when v_rnd < (v_bc ->> 'mix_rev')::numeric + (v_bc ->> 'mix_listen')::numeric then 'listen' else 'mc' end;
    v_items := v_items || jsonb_build_array(jsonb_build_object('k', r.k, 'en', r.en, 'ko', r.ko, 't', v_t, 'o', v_opts, 'oe', v_opte));
    v_i := v_i + 1;
  end loop;
  if v_i < 10 then raise exception '함께 배운 단어가 아직 10개가 안 돼요.'; end if;
  insert into mw_duels(academy_id, a, b, items, day, expires_at)
  values (v_ac, auth.uid(), t.id, v_items, mw_seoul_today(), now() + make_interval(hours => (v_cfg ->> 'hours')::int))
  returning id into v_id;
  insert into mw_duel_play(duel_id, student_id, power) values (v_id, auth.uid(), mw_my_power(auth.uid()));
  return mw_duel_view(v_id, true);
end $$;

-- 학생: 받은 대결 시작(또는 이어서) / 지금 문제 받기
create or replace function mw_duel_play(p_duel uuid) returns jsonb
language plpgsql security definer set search_path = public as $$
declare d mw_duels;
begin
  if not mw_student_ok() then raise exception '승인된 학생 계정이 아닙니다.'; end if;
  perform mw_duel_expire(auth.uid());
  select * into d from mw_duels where id = p_duel and (a = auth.uid() or b = auth.uid()) for update;
  if not found then raise exception '대결을 찾을 수 없습니다.'; end if;
  if d.status = 'expired' then raise exception '시간이 지나 취소된 대결이에요.'; end if;
  if d.b = auth.uid() and d.status = 'waiting' then
    update mw_duels set status = 'b_playing' where id = d.id;
    insert into mw_duel_play(duel_id, student_id, power) values (d.id, auth.uid(), mw_my_power(auth.uid())) on conflict do nothing;
  end if;
  if d.b = auth.uid() and d.status = 'a_playing' then raise exception '친구가 아직 문제를 풀고 있어요.'; end if;
  return mw_duel_view(d.id, true);
end $$;

-- 학생: 답하기(서버가 채점·시간 측정). 다음 문제는 mw_duel_play 로 받음(받는 순간부터 시간 측정)
create or replace function mw_duel_answer(p_duel uuid, p_n int, p_answer text) returns jsonb
language plpgsql security definer set search_path = public as $$
declare d mw_duels; pl mw_duel_play; it jsonb; t text; v_ok boolean; v_ms bigint; v_pts int := 0; v_cfg jsonb; v_total int;
begin
  if not mw_student_ok() then raise exception '승인된 학생 계정이 아닙니다.'; end if;
  select * into d from mw_duels where id = p_duel and (a = auth.uid() or b = auth.uid()) for update;
  if not found then raise exception '대결을 찾을 수 없습니다.'; end if;
  if d.status not in ('a_playing','b_playing') or (d.status = 'a_playing') <> (d.a = auth.uid()) then raise exception '지금은 답할 수 없는 대결입니다.'; end if;
  select * into pl from mw_duel_play where duel_id = d.id and student_id = auth.uid() for update;
  if pl.done or p_n is distinct from pl.qn or pl.served_at is null then raise exception '이미 답한 문제입니다.'; end if;
  v_total := jsonb_array_length(d.items);
  it := d.items -> (pl.qn - 1); t := it ->> 't';
  v_ok := case when t = 'rev' then lower(btrim(coalesce(p_answer, ''))) = lower(btrim(it ->> 'en')) else coalesce(p_answer, '') = it ->> 'ko' end;
  v_ms := greatest(0, (extract(epoch from (clock_timestamp() - pl.served_at)) * 1000)::bigint);
  if v_ok then v_pts := 100 + case when v_ms <= 3000 then 50 when v_ms <= 6000 then 25 else 0 end; end if;
  pl.raw := pl.raw + v_pts; pl.correct := pl.correct + case when v_ok then 1 else 0 end; pl.ms := pl.ms + v_ms; pl.qn := pl.qn + 1;
  v_cfg := mw_duel_cfg(d.academy_id);
  pl.score := round(pl.raw * (1 + least((v_cfg ->> 'power_max')::int, greatest(0, (pl.power - 10) * 2)) / 100.0))::int;   -- 공격력 보너스 최대 +20%
  pl.done := pl.qn > v_total;
  update mw_duel_play set raw = pl.raw, correct = pl.correct, ms = pl.ms, qn = pl.qn, score = pl.score, done = pl.done, served_at = null
   where duel_id = d.id and student_id = auth.uid();
  if pl.done then
    if d.a = auth.uid() then update mw_duels set status = 'waiting' where id = d.id;
    else perform mw_duel_finish(d.id); end if;
  end if;
  return mw_duel_view(d.id, false) || jsonb_build_object('correct', v_ok, 'pts', v_pts, 'ms', v_ms, 'word', it ->> 'en',
    'answer', case when t = 'rev' then it ->> 'en' else it ->> 'ko' end);
end $$;

-- 학생: 내 대결 목록(받은 신청·기다리는 중·결과)
create or replace function mw_duels() returns jsonb
language plpgsql security definer set search_path = public as $$
begin
  if not mw_student_ok() then raise exception '승인된 학생 계정이 아닙니다.'; end if;
  perform mw_duel_expire(auth.uid());
  return coalesce((select jsonb_agg(mw_duel_view(x.id, false) order by x.created_at desc)
                     from (select id, created_at from mw_duels where (a = auth.uid() or (b = auth.uid() and status <> 'a_playing'))
                            order by created_at desc limit 15) x), '[]'::jsonb);
end $$;

-- 선생님: 학생의 대결 기록(실명)
create or replace function mw_duels_of(p_student uuid) returns jsonb
language plpgsql stable security definer set search_path = public as $$
begin
  perform mw_need_student(p_student);
  return coalesce((select jsonb_agg(jsonb_build_object('other', p.display_name, 'status', d.status,
            'result', case when d.status <> 'done' then null when d.result = 'draw' then 'draw' when (d.result = 'a') = (d.a = p_student) then 'win' else 'lose' end,
            'my', (select score from mw_duel_play where duel_id = d.id and student_id = p_student),
            'their', (select score from mw_duel_play where duel_id = d.id and student_id <> p_student),
            'at', d.created_at) order by d.created_at desc)
     from (select * from mw_duels where a = p_student or b = p_student order by created_at desc limit 20) d
     join mw_profiles p on p.id = case when d.a = p_student then d.b else d.a end), '[]'::jsonb);
end $$;

-- ---------- 7-9. 몬스터 도감 관리 (v2.20, 본사 학원 원장 전용) ----------
-- 가문 정보와 세 형태의 이름·설명·요구 레벨·이미지 주소를 고칩니다. 형태 ID·단계는 바뀌지 않습니다.
create or replace function mw_species_save(p_id text, p_data jsonb) returns void
language plpgsql security definer set search_path = public as $$
declare sp mw_species; v_forms jsonb := '[]'::jsonb; f jsonb; n jsonb; v_stage int; v_img text; v_th text; v_lv int; v_lv2 int;
        v_rar text; v_el text; v_name text; k text;
        v_url constant text := '^(https://[^[:space:]"''<>]+|monsters/[A-Za-z0-9_./-]+)$';
begin
  if not mw_is_owner() then raise exception '몬스터 도감은 본사 원장 계정에서만 바꿀 수 있습니다.'; end if;
  if p_data is null or jsonb_typeof(p_data) <> 'object' then raise exception '저장할 내용이 없습니다.'; end if;
  select * into sp from mw_species where id = p_id for update;
  if not found then raise exception '없는 몬스터입니다.'; end if;
  v_rar := coalesce(nullif(p_data ->> 'rarity', ''), sp.rarity);
  if v_rar not in ('starter','common','rare','epic','legendary','seasonal') then raise exception '희귀도 값이 맞지 않습니다.'; end if;
  if (v_rar = 'starter') <> (sp.rarity = 'starter') then raise exception '스타터 몬스터는 희귀도를 바꿀 수 없습니다.'; end if;
  v_el := coalesce(p_data ->> 'element', sp.element);
  if v_el not in ('', 'fire','water','forest','wind','earth','star','ice','word') then raise exception '속성 값이 맞지 않습니다.'; end if;
  v_name := left(btrim(coalesce(p_data ->> 'name', sp.name)), 24);
  if v_name = '' then raise exception '영어 이름을 입력해 주세요.'; end if;

  for v_stage in 1..3 loop
    f := null; n := null;
    select x into f from jsonb_array_elements(sp.forms) x where (x ->> 'stage') = v_stage::text limit 1;
    f := coalesce(f, jsonb_build_object('stage', v_stage, 'stage_name', (array['Rookie','Elite','Legend'])[v_stage], 'form_name', sp.name));
    if f ->> 'id' is null and sp.no is not null then
      f := f || jsonb_build_object('id', 'MW-' || lpad(((sp.no - 1) * 3 + v_stage)::text, 3, '0'));
    end if;
    if jsonb_typeof(p_data -> 'forms') = 'array' then
      select x into n from jsonb_array_elements(p_data -> 'forms') x where (x ->> 'stage') = v_stage::text limit 1;
    end if;
    if n is not null then
      v_img := btrim(coalesce(n ->> 'image_url', f ->> 'image_url', ''));
      v_th  := btrim(coalesce(n ->> 'thumb_url', f ->> 'thumb_url', ''));
      if v_img = '' then v_th := ''; end if;
      if (v_img <> '' and (length(v_img) > 500 or v_img !~ v_url)) or (v_th <> '' and (length(v_th) > 500 or v_th !~ v_url)) then
        raise exception '이미지 주소 형식이 맞지 않습니다.'; end if;
      if n ? 'req_level' then
        if (n ->> 'req_level') is not null and (n ->> 'req_level') !~ '^[0-9]{1,3}$' then raise exception '요구 레벨은 숫자로 입력해 주세요.'; end if;
        v_lv := (n ->> 'req_level')::int;
      else
        v_lv := case when (f ->> 'req_level') ~ '^[0-9]{1,3}$' then (f ->> 'req_level')::int end;
      end if;
      if v_stage = 1 or v_lv = 0 then v_lv := null; end if;                 -- 첫 형태는 요구 레벨 없음. 0이나 빈 값 = 학원 기준
      if v_stage = 2 then v_lv2 := v_lv; end if;
      if v_stage = 3 and v_lv is not null and v_lv2 is not null and v_lv < v_lv2 then
        raise exception 'Legend 요구 레벨은 Elite 요구 레벨보다 낮을 수 없습니다.'; end if;
      f := f || jsonb_build_object(
        'form_name', coalesce(nullif(left(btrim(coalesce(n ->> 'form_name', '')), 40), ''), f ->> 'form_name'),
        'name_ko', left(btrim(coalesce(n ->> 'name_ko', f ->> 'name_ko', '')), 40),
        'description', left(btrim(coalesce(n ->> 'description', f ->> 'description', '')), 300),
        'image_url', v_img, 'thumb_url', v_th, 'req_level', v_lv);
    elsif v_stage = 2 then
      v_lv2 := case when (f ->> 'req_level') ~ '^[0-9]{1,3}$' then (f ->> 'req_level')::int end;
    end if;
    v_forms := v_forms || jsonb_build_array(f);
  end loop;

  update mw_species set
    name = v_name,
    name_ko = left(btrim(coalesce(p_data ->> 'name_ko', name_ko)), 24),
    animal = left(btrim(coalesce(p_data ->> 'animal', animal)), 40),
    concept = left(btrim(coalesce(p_data ->> 'concept', concept)), 40),
    description = left(btrim(coalesce(p_data ->> 'description', description)), 300),
    element = v_el, rarity = v_rar, forms = v_forms
   where id = p_id;
  perform mw_log('species_save', null, jsonb_build_object('species', p_id));
end $$;

-- 몬스터 이미지 저장소: 누구나 볼 수 있고(공개), 올리기는 본사 학원 원장만. 이미지 주소는 mw_species_save 로만 도감에 연결됩니다.
do $$
begin
  insert into storage.buckets(id, name, public) values ('mw-monsters', 'mw-monsters', true)
  on conflict (id) do update set public = true;
  begin
    update storage.buckets set file_size_limit = 2097152, allowed_mime_types = array['image/png','image/webp'] where id = 'mw-monsters';
  exception when others then null; end;
  drop policy if exists mw_monster_img_insert on storage.objects;
  create policy mw_monster_img_insert on storage.objects for insert to authenticated
    with check (bucket_id = 'mw-monsters' and public.mw_is_owner());
exception when others then
  raise notice '몬스터 이미지 저장소 설정을 건너뜁니다(Storage 를 쓸 수 없는 환경): %', sqlerrm;
end $$;

-- ---------- v2.23 장비 · 전투력 · 방 테마 ----------
-- 장비 전투력(내부용): 대표 몬스터가 입은 장비 합계 + 같은 세트 4칸이면 +15
create or replace function mw_gear_power(p_student uuid) returns int
language sql stable security definer set search_path = public as $$
  select 0;   -- v2.25: 몬스터는 진화로만 성장. 장비 전투력은 끔(입은 장비 기록은 그대로 둠)
$$;
-- 전투력 = 몬스터 기본 힘 × 10 + 장비. 등급: 브론즈 · 실버 130 · 골드 170 · 다이아 220 · 레전드 280
create or replace function mw_power(p_student uuid) returns jsonb
language sql stable security definer set search_path = public as $$
  select jsonb_build_object('base', b, 'gear', g, 'total', b + g,
    'tier', case when b + g >= 280 then 'legend' when b + g >= 220 then 'diamond' when b + g >= 170 then 'gold' when b + g >= 130 then 'silver' else 'bronze' end)
  from (select coalesce((select ((c ->> 'dmg_base')::int + least((c ->> 'dmg_lv_max')::int, m.level / greatest(1, (c ->> 'dmg_lv_div')::int))
                 + case m.stage when 3 then (c ->> 'dmg_legend')::int when 2 then (c ->> 'dmg_elite')::int else 0 end) * 10
                  from mw_profiles p join mw_monsters m on m.id = p.active_monster, mw_battle_cfg(p.academy_id) c where p.id = p_student), 100) as b,
               coalesce(mw_gear_power(p_student), 0) as g) q;
$$;
-- 전설 장비 주기(내부용, 한 번만)
create or replace function mw_gear_grant(p_student uuid, p_item text) returns void
language plpgsql security definer set search_path = public as $$
begin
  if not exists (select 1 from mw_shop_items where id = p_item and kind = 'gear') then return; end if;
  insert into mw_inventory(student_id, item_id, qty) values (p_student, p_item, 1) on conflict (student_id, item_id) do nothing;
end $$;
-- 학생: 장비 입히기/벗기기(가진 것만, 맞는 칸에만)
create or replace function mw_gear_equip(p_monster uuid, p_slot text, p_item text) returns jsonb
language plpgsql security definer set search_path = public as $$
begin
  if not mw_student_ok() then raise exception '승인된 학생 계정이 아닙니다.'; end if;
  if p_slot not in ('head','body','hand','back') then raise exception '장비 칸이 올바르지 않습니다.'; end if;
  if not exists (select 1 from mw_monsters where id = p_monster and student_id = auth.uid() and hatched) then raise exception '내 몬스터가 아닙니다.'; end if;
  if p_item is not null and not exists (select 1 from mw_inventory v join mw_shop_items i on i.id = v.item_id
                                         where v.student_id = auth.uid() and v.item_id = p_item and i.kind = 'gear' and i.slot = p_slot) then
    raise exception '가지고 있는 장비만 그 칸에 입힐 수 있어요.'; end if;
  update mw_monsters set gear = case when p_item is null then gear - p_slot else gear || jsonb_build_object(p_slot, p_item) end,
         acc = case when p_slot = 'head' then p_item else acc end
   where id = p_monster;
  return mw_power(auth.uid());
end $$;
-- 학생: 방 테마 바꾸기(가진 테마만). null 이면 자유 꾸미기로
create or replace function mw_home_theme(p_theme text) returns void
language plpgsql security definer set search_path = public as $$
begin
  if not mw_student_ok() then raise exception '승인된 학생 계정이 아닙니다.'; end if;
  if p_theme is not null and not exists (select 1 from mw_shop_items i where i.id = p_theme and i.kind = 'theme'
        and (i.price = 0 or exists (select 1 from mw_inventory v where v.student_id = auth.uid() and v.item_id = i.id))) then
    raise exception '가지고 있는 테마만 쓸 수 있어요.'; end if;
  if p_theme is not null and not mw_item_unlocked(auth.uid(), (select unlock from mw_shop_items where id = p_theme)) then
    raise exception '아직 열리지 않은 테마예요. 몬스터를 진화시키면 열려요.'; end if;
  insert into mw_homes(student_id, theme, updated_at) values (auth.uid(), p_theme, now())
  on conflict (student_id) do update set theme = excluded.theme, updated_at = now();
end $$;

-- v2.24 장비 위치 맞춤: 모두 읽기, 본사 원장만 저장
create or replace function mw_gear_fits() returns jsonb
language sql stable security definer set search_path = public as $$
  select coalesce(jsonb_agg(jsonb_build_object('species_id', species_id, 'stage', stage, 'item_id', item_id, 'dx', dx, 'dy', dy, 's', s, 'r', r)), '[]'::jsonb) from mw_gear_fit;
$$;
create or replace function mw_gear_fit_save(p_species text, p_stage int, p_item text, p_dx numeric, p_dy numeric, p_s numeric, p_r numeric) returns void
language plpgsql security definer set search_path = public as $$
begin
  if not mw_is_owner() then raise exception '장비 위치는 본사 원장 계정에서만 맞출 수 있습니다.'; end if;
  if not exists (select 1 from mw_shop_items where id = p_item and kind = 'gear') then raise exception '없는 장비입니다.'; end if;
  if not ((p_species = '*' and p_stage = 0) or (exists (select 1 from mw_species where id = p_species) and p_stage between 1 and 3)) then raise exception '몬스터가 올바르지 않습니다.'; end if;
  delete from mw_gear_fit where species_id = p_species and stage = p_stage and item_id = p_item;
  if p_dx is null then return; end if;   -- 값 없이 부르면 맞춤값 지우기
  if not (p_dx between -2 and 2 and p_dy between -2 and 2 and p_s between 0.3 and 2.5 and p_r between -60 and 60) then raise exception '값이 범위를 벗어났습니다.'; end if;
  insert into mw_gear_fit(species_id, stage, item_id, dx, dy, s, r) values (p_species, p_stage, p_item, round(p_dx, 2), round(p_dy, 2), round(p_s, 2), round(p_r, 1));
  perform mw_log('gear_fit', null, jsonb_build_object('species', p_species, 'stage', p_stage, 'item', p_item));
end $$;

-- ---------- v2.22 칭찬 포인트 · 아이템 관리 ----------
-- 학생: 🐷 모으기 켜기/끄기(켜면 주간 정산 때 칭찬모아로 보내지 않고 모음)
create or replace function mw_points_save(p_on boolean) returns boolean
language plpgsql security definer set search_path = public as $$
begin
  if not mw_student_ok() then raise exception '승인된 학생 계정이 아닙니다.'; end if;
  update mw_profiles set point_save = coalesce(p_on, false) where id = auth.uid();
  return coalesce(p_on, false);
end $$;

-- 학생·선생님: 칭찬 포인트 내역(학생은 자기 것만, 선생님은 같은 학원)
create or replace function mw_points_of(p_student uuid) returns jsonb
language plpgsql stable security definer set search_path = public as $$
begin
  if not (p_student = auth.uid() and mw_student_ok()) and not (exists (select 1 from mw_profiles t where t.id = auth.uid() and t.role = 'teacher' and t.active) and mw_same(p_student)) then
    raise exception '볼 수 없는 내역입니다.'; end if;
  return jsonb_build_object('points', mw_point_balance(p_student),
    'log', coalesce((select jsonb_agg(jsonb_build_object('amount', x.amount, 'kind', x.kind, 'note', x.note, 'at', x.created_at) order by x.created_at desc)
                       from (select * from mw_points where student_id = p_student order by created_at desc limit 20) x), '[]'::jsonb));
end $$;

-- 본사 원장: 아이템 목록(판매 중지 포함)
create or replace function mw_items_admin() returns jsonb
language plpgsql stable security definer set search_path = public as $$
begin
  if not mw_is_owner() then raise exception '아이템은 본사 원장 계정에서만 관리할 수 있습니다.'; end if;
  return coalesce((select jsonb_agg(to_jsonb(i) order by i.sort) from mw_shop_items i), '[]'::jsonb);
end $$;

-- 본사 원장: 아이템 고치기(이름·가격·희귀도·판매·시즌·레벨·해금 조건·그림). 고친 아이템은 다시 실행해도 덮어쓰지 않음
create or replace function mw_item_save(p_id text, p_data jsonb) returns void
language plpgsql security definer set search_path = public as $$
declare d jsonb := coalesce(p_data, '{}'::jsonb); u jsonb;
begin
  if not mw_is_owner() then raise exception '아이템은 본사 원장 계정에서만 관리할 수 있습니다.'; end if;
  if not exists (select 1 from mw_shop_items where id = p_id) then raise exception '없는 아이템입니다.'; end if;
  if jsonb_typeof(d) <> 'object' or exists (select 1 from jsonb_object_keys(d) k where k not in ('name','price','rarity','enabled','season','min_level','unlock','image_url')) then
    raise exception '고칠 수 없는 항목이 있습니다.'; end if;
  if d ? 'name' and not (length(btrim(d ->> 'name')) between 1 and 20) then raise exception '이름은 1~20자로 입력해 주세요.'; end if;
  if d ? 'price' and not ((d ->> 'price') ~ '^[0-9]{1,5}$') then raise exception '가격은 0~99999 사이 숫자로 입력해 주세요.'; end if;
  if d ? 'min_level' and not ((d ->> 'min_level') ~ '^[0-9]{1,3}$' and (d ->> 'min_level')::int >= 1) then raise exception '레벨은 1 이상 숫자로 입력해 주세요.'; end if;
  if d ? 'rarity' and d ->> 'rarity' not in ('common','rare','epic','legend') then raise exception '희귀도가 올바르지 않습니다.'; end if;
  if d ? 'season' and jsonb_typeof(d -> 'season') <> 'null' and d ->> 'season' not in ('spring','summer','autumn','winter') then raise exception '시즌이 올바르지 않습니다.'; end if;
  if d ? 'enabled' and jsonb_typeof(d -> 'enabled') <> 'boolean' then raise exception '판매 여부가 올바르지 않습니다.'; end if;
  if d ? 'image_url' and not (coalesce(d ->> 'image_url', '') = '' or (d ->> 'image_url') ~ '^(https://|data:image/(png|webp);base64,)') then raise exception '그림 주소가 올바르지 않습니다.'; end if;
  u := d -> 'unlock';
  if d ? 'unlock' and jsonb_typeof(u) <> 'null' and not (
       jsonb_typeof(u) = 'object' and (u ->> 'v') ~ '^[0-9]{1,6}$'
       and ((u ->> 't' = 'stat' and u ->> 'k' in ('read','write','vocab','grit')) or u ->> 't' in ('books','stage'))) then
    raise exception '해금 조건이 올바르지 않습니다.'; end if;
  update mw_shop_items set
    name = case when d ? 'name' then btrim(d ->> 'name') else name end,
    price = case when d ? 'price' then (d ->> 'price')::int else price end,
    min_level = case when d ? 'min_level' then (d ->> 'min_level')::int else min_level end,
    rarity = case when d ? 'rarity' then d ->> 'rarity' else rarity end,
    season = case when d ? 'season' then nullif(d ->> 'season', '') else season end,
    enabled = case when d ? 'enabled' then (d ->> 'enabled')::boolean else enabled end,
    image_url = case when d ? 'image_url' then coalesce(d ->> 'image_url', '') else image_url end,
    unlock = case when d ? 'unlock' then (case when jsonb_typeof(u) = 'null' then null else u end) else unlock end,
    meta_v = 2
  where id = p_id;
  perform mw_log('item_save', null, jsonb_build_object('item', p_id, 'data', d - 'image_url'));
end $$;

-- v2.22 처음 적용: 이번 주 이전 포인트는 이미 칭찬모아로 보낸 것으로 보고, 이번 주 몫(아직 입력 완료 전)만 지갑에 넣음. 한 번만
do $$
declare ws date := date_trunc('week', (now() at time zone 'Asia/Seoul'))::date;
begin
  insert into mw_points(student_id, amount, kind, ref, note)
  select p.id,
    case when exists (select 1 from mw_settlements s where s.student_id = p.id and s.week_start = ws) then 0 else
      round(coalesce((select sum(l.amount) from mw_ledger l
                       where l.student_id = p.id and l.kind = 'grant'
                         and (l.created_at at time zone 'Asia/Seoul')::date between ws and ws + 6
                         and not exists (select 1 from mw_ledger r where r.kind = 'revoke'
                               and ((l.mission_id is not null and r.mission_id = l.mission_id) or (l.book_id is not null and r.book_id = l.book_id)))), 0)
            * mw_point_rate(p.academy_id))::int
      + coalesce((select sum(coalesce((mw_setting(p.academy_id, 'evolve_bonus') ->> (split_part(r.reward_key, ':', 3)::int - 2))::int, 0))
                    from mw_rewards r where r.student_id = p.id and r.reward_key like 'evo:%'
                     and (r.granted_at at time zone 'Asia/Seoul')::date between ws and ws + 6), 0)
    end, 'base', 'base', '처음 시작(이번 주 몫)'
  from mw_profiles p where p.role = 'student'
  on conflict (student_id, ref) where ref is not null do nothing;
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
                         'mw_stat_values','mw_stat_rewards','mw_grant_species','mw_stone_balance','mw_streak_info',
                         'mw_seoul_today','mw_wd_idx','mw_battle_cfg','mw_battle_shards','mw_battle_day_ok','mw_battle_streak',
                         'mw_battle_mult','mw_word_backlog','mw_word_advance','mw_battle_recheck','mw_battle_state','mw_battle_reward',
                         'mw_coin_cfg','mw_coin_balance','mw_xp_wallet','mw_gear_power','mw_gear_grant','mw_point_rate','mw_point_balance','mw_item_unlocked','mw_coin_add','mw_coin_revoke','mw_coin_on_approve','mw_visit_ok','mw_pub_name','mw_duel_cfg','mw_my_power','mw_duel_view','mw_duel_finish','mw_duel_expire') then
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

-- 새 함수가 앱에 바로 보이도록 API 캐시를 새로 읽게 합니다(다시 실행해도 안전)
notify pgrst, 'reload schema';
