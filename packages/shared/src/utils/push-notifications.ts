import { getToken, onMessage } from 'firebase/messaging';
import { messaging, db } from '../firebase';
import { doc, updateDoc, arrayUnion, getDoc } from 'firebase/firestore';
import { Capacitor } from '@capacitor/core';
import { PushNotifications } from '@capacitor/push-notifications';

const VAPID_KEY = "BLWRWaUwEZaCEChXuZQlbs64mDqm_HGV4NSp216Tce9s4ac65zwR3jaITKbGKmGKxi8ReYvbtj30w5Z6Os1YrVI";

let isNativeListenersSetup = false;

export async function requestNotificationPermission(userId: string, isAdmin: boolean = false) {
  if (Capacitor.isNativePlatform()) {
    try {
      if (!isNativeListenersSetup) {
        PushNotifications.addListener('registration', async (token) => {
          console.log('[Push] Native Token generated:', token.value);
          const userRef = doc(db, 'users', userId);
          await updateDoc(userRef, {
            fcmTokens: arrayUnion(token.value)
          });
          
          await subscribeTokenToTopic(token.value, 'all_users');
          if (isAdmin) {
            await subscribeTokenToTopic(token.value, 'admins');
          }
        });

        PushNotifications.addListener('registrationError', (error) => {
          console.error('[Push] Native Registration error:', error);
        });

        PushNotifications.addListener('pushNotificationReceived', (notification) => {
          console.log('[Push] Notification received in foreground:', notification);
        });

        PushNotifications.addListener('pushNotificationActionPerformed', (action) => {
          const data = action.notification.data;
          if (data && (data.actionUrl || data.link)) {
            const url = data.actionUrl || data.link;
            window.dispatchEvent(new CustomEvent('push-notification-click', { detail: { url } }));
          }
        });

        isNativeListenersSetup = true;
      }

      let permStatus = await PushNotifications.checkPermissions();

      if (permStatus.receive === 'prompt') {
        permStatus = await PushNotifications.requestPermissions();
      }

      if (permStatus.receive !== 'granted') {
        return null;
      }

      if (Capacitor.getPlatform() === 'android') {
        try {
          await PushNotifications.createChannel({
            id: 'high_priority',
            name: 'High Priority',
            description: 'Important notifications that appear on screen',
            importance: 5,
            visibility: 1,
            vibration: true,
          });
        } catch (e) {
          console.warn('Channel creation error:', e);
        }
      }
      await PushNotifications.register();
      return 'native-registered';
    } catch (e) {
      console.error('[Push] Native setup failed:', e);
    }
    return null;
  }

  if (!messaging) return;

  try {
    if (!window.isSecureContext) {
      return null;
    }

    const permission = await Notification.requestPermission();
    if (permission === 'granted') {
      const vapidKey = (import.meta as any).env?.VITE_VAPID_KEY || VAPID_KEY;
      
      const swRegistration = (window as any).swRegistration || await navigator.serviceWorker.ready;

      const token = await getToken(messaging, { 
        vapidKey,
        serviceWorkerRegistration: swRegistration
      });

      if (token) {
        const userRef = doc(db, 'users', userId);
        await updateDoc(userRef, {
          fcmTokens: arrayUnion(token)
        });

        await subscribeTokenToTopic(token, 'all_users');
        if (isAdmin) {
          await subscribeTokenToTopic(token, 'admins');
        }
        
        return token;
      }
    }
  } catch (error) {
    console.error('Error getting web notification permission:', error);
  }
  return null;
}

export function onMessageListener(callback: (payload: any) => void) {
  if (Capacitor.isNativePlatform()) {
    return PushNotifications.addListener('pushNotificationReceived', (notification) => {
      callback({
        notification: {
          title: notification.title,
          body: notification.body
        },
        data: notification.data
      });
    });
  }
  
  if (!messaging) return;
  return onMessage(messaging, callback);
}

export async function sendPushNotification(target: 'global' | string, title: string, message: string, data?: any) {
  let workerUrl = '';
  try {
    let storedWorkerUrl = localStorage.getItem('cfWorkerUrl');
    
    if (!storedWorkerUrl) {
      try {
        const docSnap = await getDoc(doc(db, 'configs', 'ai_worker'));
        if (docSnap.exists()) {
          storedWorkerUrl = docSnap.data().url;
          if (storedWorkerUrl) localStorage.setItem('cfWorkerUrl', storedWorkerUrl);
        }
      } catch (e) {
        console.error('[Worker Push] Firestore fallback failed:', e);
      }
    }

    workerUrl = (storedWorkerUrl || (import.meta as any).env?.VITE_WORKER_URL || 'https://rankearn.thesmartrankers.workers.dev').replace(/\/$/, '');
    
    const response = await fetch(`${workerUrl}/send-push`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ target, title, message, data })
    });
    
    if (!response.ok) {
      const errText = await response.text();
      try {
        return JSON.parse(errText);
      } catch (e) {
        return { success: false, error: errText };
      }
    }
    const responseData = await response.json();
    return responseData;
  } catch (error) {
    console.error('[Worker Push] Fetch failed:', error);
    return null;
  }
}

export async function subscribeTokenToTopic(token: string, topic: string) {
  try {
    let workerUrl = localStorage.getItem('cfWorkerUrl');
    if (!workerUrl) {
      const docSnap = await getDoc(doc(db, 'configs', 'ai_worker'));
      if (docSnap.exists()) {
        workerUrl = docSnap.data().url;
      }
    }
    workerUrl = (workerUrl || 'https://rankearn.thesmartrankers.workers.dev').replace(/\/$/, '');

    const response = await fetch(`${workerUrl}/subscribe-topic`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ token, topic })
    });

    const data = await response.json();
    return data;
  } catch (error) {
    console.error(`[Push] Failed to subscribe to topic ${topic}:`, error);
    return null;
  }
}
