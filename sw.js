// MONSTER WORLD 서비스 워커: 홈 화면 설치용. 파일을 저장(캐시)하지 않아서 항상 최신 화면이 열립니다.
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', e => e.waitUntil(self.clients.claim()));
self.addEventListener('fetch', e => {
  if (e.request.mode !== 'navigate') return;
  e.respondWith(fetch(e.request).catch(() => new Response(
    '<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><p style="font:16px sans-serif;padding:24px;line-height:1.6">인터넷에 연결되어 있지 않습니다.<br>연결한 뒤 다시 열어 주세요.</p>',
    { headers: { 'Content-Type': 'text/html; charset=utf-8' } })));
});
