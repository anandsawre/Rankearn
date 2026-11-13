importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-messaging-compat.js');

const firebaseConfig = {
  apiKey: "AIzaSyBOLayRcEJupp7EoSJMLMyT69bFyWvPWuY",
  authDomain: "rankearn.firebaseapp.com",
  projectId: "rankearn",
  storageBucket: "rankearn.firebasestorage.app",
  messagingSenderId: "884271494365",
  appId: "1:884271494365:web:0c858e3ab9a15c1fa11734"
};

if (!firebase.apps.length) {
  firebase.initializeApp(firebaseConfig);
}

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  
  const notificationTitle = payload.notification?.title || payload.data?.title || 'New Message';
  const notificationBody = payload.notification?.body || payload.data?.body || payload.data?.message || 'You have a new update.';
  const notificationImage = payload.notification?.image || payload.data?.image || payload.data?.imageUrl;

  const notificationOptions = {
    body: notificationBody,
    icon: '/logo.png',
    image: notificationImage,
    badge: '/logo.png',
    data: payload.data,
    tag: payload.data?.tag || 'smartrank-notif',
    renotify: true,
    requireInteraction: true
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});

// Extra logging for push events
self.addEventListener('push', (event) => {
  console.log('[firebase-messaging-sw.js] Push event received:', event);
  if (event.data) {
    try {
      const payload = event.data.json();
      console.log('[firebase-messaging-sw.js] Push data (JSON):', payload);
      // Fallback: if we didn't show a notification, show it here
    } catch (e) {
      console.log('[firebase-messaging-sw.js] Push data (Text):', event.data.text());
    }
  }
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  
  const data = event.notification.data || {};
  const actionUrl = data.actionUrl || data.link || '/';
  
  const targetUrl = new URL(actionUrl, self.location.origin).href;
  
  event.waitUntil(
    self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientList) => {
      for (const client of clientList) {
        if (client.url === targetUrl && 'focus' in client) {
          return client.focus();
        }
      }
      
      if (clientList.length > 0) {
        const client = clientList[0];
        if ('focus' in client) {
          return client.focus().then((focusedClient) => {
            return focusedClient.navigate(targetUrl);
          });
        }
      }
      
      if (self.clients.openWindow) {
        return self.clients.openWindow(targetUrl);
      }
    })
  );
});

// Import the main caching worker logic
importScripts('/sw.js');
