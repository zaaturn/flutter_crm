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

messaging.onBackgroundMessage(function(payload) {
  self.registration.showNotification(
    payload.data.title,
    {
      body: payload.data.body,
      icon: '/icons/Icon-192.png',
    }
  );
});
