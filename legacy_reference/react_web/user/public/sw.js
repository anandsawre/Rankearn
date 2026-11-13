const CACHE_NAME = 'smartrank-app-shell';
const CACHE_PREFIX = 'smartrank-';
const ASSETS_TO_CACHE = [
  '/',
  '/index.html',
  '/manifest.json',
  '/icons/icon-192.png',
  '/icons/icon-512.png',
  '/icons/apple-touch-icon.png',
  '/icons/favicon.svg'
];


// --- Caching Logic ---
const isCacheableRequest = (request) => {
  if (request.method !== 'GET') return false;

  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return false;

  return request.mode === 'navigate' || ['document', 'script', 'style', 'image', 'font', 'manifest'].includes(request.destination);
};

self.addEventListener('message', (event) => {
  if (event.data?.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});

const clearAppCaches = async () => {
  const cacheKeys = await caches.keys();
  await Promise.all(
    cacheKeys
      .filter((key) => key.startsWith(CACHE_PREFIX))
      .map((key) => caches.delete(key))
  );
};

const preCacheAppShell = async () => {
  const cache = await caches.open(CACHE_NAME);
  await cache.addAll(ASSETS_TO_CACHE);
};

self.addEventListener('install', (event) => {
  event.waitUntil(
    (async () => {
      await self.skipWaiting();
      await preCacheAppShell();
    })()
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      await clearAppCaches();
      await preCacheAppShell();
      await self.clients.claim();
    })()
  );
});

self.addEventListener('fetch', (event) => {
  if (!isCacheableRequest(event.request)) return;

  event.respondWith(
    (async () => {
      const cache = await caches.open(CACHE_NAME);

      try {
        const networkResponse = await fetch(event.request);

        if (networkResponse.ok) {
          cache.put(event.request, networkResponse.clone());
        }

        return networkResponse;
      } catch (error) {
        const cachedResponse = await cache.match(event.request);
        if (cachedResponse) {
          return cachedResponse;
        }

        if (event.request.mode === 'navigate') {
          return cache.match('/index.html');
        }

        throw error;
      }
    })()
  );
});

