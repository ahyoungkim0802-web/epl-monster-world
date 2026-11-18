# MONSTER WORLD — 프로젝트 안내 (CLAUDE.md)

학원용 게임형 영어 학습 웹앱 **MONSTER WORLD**. 여러 학원에 판매하는 제품으로 설계한다.

## 구조
- 단일 `index.html` + Supabase(`schema.sql`). **빌드 과정 없음.**
- 배포: GitHub Pages (main 브랜치 루트 `/`) — https://www.classpoint.co.kr/ (사용자 도메인. github.io 주소는 여기로 자동 이동)

## 실행 모드
- `index.html` 상단 `CONFIG`가 비어 있으면 **체험 모드**(브라우저 안의 `Demo` 객체로 동작).
- `CONFIG`에 Supabase URL·anon key를 넣으면 **운영 모드**.

## 반드시 지킬 원칙
- 클라이언트는 테이블에 직접 쓰지 않고 **`mw_`로 시작하는 RPC 함수만 호출**한다.
  권한 검증·중복 지급 방지·학원 간 분리는 모두 `schema.sql`의 서버 함수와 RLS가 담당한다.
  이 원칙을 깨는 수정은 하지 말 것.
- 체험 모드(`Demo` 객체)와 서버 함수는 **같은 규칙을 구현**한다. 규칙을 바꾸면 양쪽을 함께 고칠 것.
- `schema.sql`은 **여러 번 실행해도 안전하게** 유지할 것.
- **실제 선생님 코드·service_role 키는 절대 커밋 금지.** (`schema.sql`의 `'EPL-CHANGE-ME'`는 자리표시자로 그대로 둔다.)

## 그 밖
- 몬스터 그림은 임시 SVG. `mw_species.forms`의 `image_url`로 교체 가능.
- 화면 문구는 한국어, 과장 없는 차분한 톤.
