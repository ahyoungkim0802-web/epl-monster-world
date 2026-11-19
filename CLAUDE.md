# MONSTER WORLD — 프로젝트 안내 (CLAUDE.md)

학원용 게임형 영어 학습 웹앱 **MONSTER WORLD**. 여러 학원에 판매하는 제품으로 설계한다.

## 구조
- 단일 `index.html` + Supabase(`schema.sql`). **빌드 과정 없음.**
- 배포: GitHub Pages (main 브랜치 루트 `/`) — https://classpoint.co.kr/ (사용자 도메인. github.io 주소는 여기로 자동 이동)

## 실행 모드
- `index.html` 상단 `CONFIG`가 비어 있으면 **체험 모드**(브라우저 안의 `Demo` 객체로 동작).
- `CONFIG`에 Supabase URL·anon key를 넣으면 **운영 모드**.

## 반드시 지킬 원칙
- 클라이언트는 테이블에 직접 쓰지 않고 **`mw_`로 시작하는 RPC 함수만 호출**한다.
  권한 검증·중복 지급 방지·학원 간 분리는 모두 `schema.sql`의 서버 함수와 RLS가 담당한다.
  이 원칙을 깨는 수정은 하지 말 것.
- 체험 모드(`Demo` 객체)와 서버 함수는 **같은 규칙을 구현**한다. 규칙을 바꾸면 양쪽을 함께 고칠 것.
- `schema.sql`은 **여러 번 실행해도 안전하게** 유지할 것.
- **단어장(학원 교재 단어) 데이터는 저장소에 절대 넣지 않는다.** 단어는 선생님이 화면에서 올려 학원별로 DB(`mw_words`)에만 저장. 체험 모드는 직접 만든 예시 12개(`DEMO_WORDS`)만.
- 단어 배틀의 출제·채점·보상은 서버 함수(`mw_battle_*`)에서만. 정답을 클라이언트로 미리 보내지 않는다.
- ⭐ 칭찬 포인트(`mw_points`)는 주간 정산과 같은 기준으로 쌓이고, 상점에서 쓴 만큼 칭찬모아로 넘어가지 않는다. 잔액·차감·보냄 기록은 서버 함수만 쓴다. XP·진화 레벨은 구매와 무관.
- **실제 선생님 코드·service_role 키는 절대 커밋 금지.** (`schema.sql`의 `'EPL-CHANGE-ME'`는 자리표시자로 그대로 둔다.)

## 그 밖
- 몬스터 그림은 임시 SVG. `mw_species.forms`의 `image_url`로 교체 가능.
- 방 꾸미기 아이템 54종의 기본 그림은 `assets/items/`(임시 시안). 아이템 관리 화면에서 PNG를 올리면 `mw_shop_items.image_url`로 바뀐다. `SHOP_SEED`·`ITEM_META`(index.html)와 schema.sql의 아이템 기본 정보는 같아야 한다.
- 화면 문구는 한국어, 과장 없는 차분한 톤.

- 방 테마 그림: assets/themes/<id>.webp(1448×1086, 4:3)·카드용 assets/themes/thumb/<id>.webp(480). index.html THEME_ART 에 ID를 적으면 기본 그림으로 쓰임. 원장이 아이템 관리에서 올린 image_url 이 있으면 그것이 우선. t_star·t_space 는 그림 없음(칸 배치 방). 그림 방은 몬스터가 앞쪽 러그 영역(RM_ART)만 걸어 다니고, 그림 위 파티클 효과는 끔.
