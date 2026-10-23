// Rentrol · Truck Roster — service worker: app sin conexión + notificaciones push
const V = 'rr-shell-v3';
const SHELL = ['./', './index.html', './transfer.html', './manifest.webmanifest', './favicon.svg', './favicon-32.png', './apple-touch-icon.png', './icon-192.png', './icon-512.png', './badge-96.png'];
const IOS = /iPhone|iPad|iPod/.test(self.navigator.userAgent);
self.addEventListener('install', e => { e.waitUntil(caches.open(V).then(c => c.addAll(SHELL)).catch(() => null).then(() => self.skipWaiting())); });
self.addEventListener('activate', e => { e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== V).map(k => caches.delete(k)))).then(() => self.clients.claim())); });
self.addEventListener('fetch', e => {
  const req = e.request; if (req.method !== 'GET') return;
  const url = new URL(req.url);
  if (url.hostname.endsWith('supabase.co')) return;
  const isCdn = /cdn\.jsdelivr\.net|unpkg\.com|fonts\.googleapis\.com|fonts\.gstatic\.com|tile\.openstreetmap\.org|router\.project-osrm\.org/.test(url.hostname);
  if (url.pathname.endsWith('config.json')) { e.respondWith(fetch(req).then(r => { const cp = r.clone(); caches.open(V).then(c => c.put(req, cp)); return r; }).catch(() => caches.match(req))); return; }
  if (url.origin === location.origin || isCdn) {
    e.respondWith(caches.match(req).then(hit => { const net = fetch(req).then(r => { if (r && r.ok) { const cp = r.clone(); caches.open(V).then(c => c.put(req, cp)); } return r; }).catch(() => hit); return hit || net; }));
  }
});
self.addEventListener('push', e => {
  let d = {}; try { d = e.data ? e.data.json() : {}; } catch (x) { d = { title: 'Rentrol · Truck Roster', body: e.data ? e.data.text() : '' }; }
  const bad = d.level === 'bad', warn = d.level === 'warn';
  const opts = { body: d.body || '', tag: d.tag || ('rr-' + Date.now()), renotify: true, icon: 'icon-192.png', badge: 'badge-96.png', vibrate: bad ? [260, 90, 260, 90, 520] : warn ? [160, 80, 160] : [70], requireInteraction: bad, silent: false, timestamp: Date.now(), data: { url: d.url || './' }, actions: [{ action: 'open', title: 'Abrir' }] };
  e.waitUntil(self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then(cs => {
    cs.forEach(c => c.postMessage({ type: 'rr-push', payload: d }));
    if (!IOS && cs.some(c => c.visibilityState === 'visible')) return; // la app abierta ya lo muestra con su sonido
    return self.registration.showNotification(d.title || 'Rentrol · Truck Roster', opts);
  }));
});
self.addEventListener('notificationclick', e => {
  e.notification.close(); const url = (e.notification.data && e.notification.data.url) || './';
  e.waitUntil(self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then(cs => {
    for (const c of cs) { if ('focus' in c) { c.postMessage({ type: 'rr-open', url }); return c.focus(); } }
    return self.clients.openWindow(url);
  }));
});
self.addEventListener('pushsubscriptionchange', e => { e.waitUntil(self.clients.matchAll({ type: 'window' }).then(cs => cs.forEach(c => c.postMessage({ type: 'rr-resub' })))); });
