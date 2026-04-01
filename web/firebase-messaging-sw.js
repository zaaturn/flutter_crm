importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyBAwXxy3UIPTzV7JHmgBbVKzuWHU-wsKa4',
  appId: '1:1016540886778:web:f09d71d458516a952c7b43',
  messagingSenderId: '1016540886778',
  projectId: 'crm-leave-management',
  authDomain: 'crm-leave-management.firebaseapp.com',
  storageBucket: 'crm-leave-management.firebasestorage.app',
  measurementId: 'G-7JVRX3VRDY',
});

const messaging = firebase.messaging();

function notificationTitleBody(payload) {
  const n = payload.notification || {};
  const d = payload.data || {};
  const title =
    n.title ||
    d.title ||
    d.headline ||
    'Notification';
  const body = n.body || d.body || d.message || '';
  return { title: String(title), body: String(body) };
}

messaging.onBackgroundMessage(function (payload) {
  const { title, body } = notificationTitleBody(payload);
  return self.registration.showNotification(title, {
    body: body,
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    data: payload.data || {},
  });
});

self.addEventListener('notificationclick', function (event) {
  event.notification.close();
  event.waitUntil(
    clients
      .matchAll({ type: 'window', includeUncontrolled: true })
      .then(function (clientList) {
        for (let i = 0; i < clientList.length; i++) {
          const client = clientList[i];
          if ('focus' in client) {
            return client.focus();
          }
        }
        if (clients.openWindow) {
          return clients.openWindow('/');
        }
      }),
  );
});
