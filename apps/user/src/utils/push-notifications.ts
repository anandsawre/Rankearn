import { getToken, onMessage } from 'firebase/messaging';
import { messaging, db } from '../firebase';
import { doc, updateDoc, arrayUnion, getDoc } from 'firebase/firestore';
import { Capacitor } from '@capacitor/core';
import { PushNotifications } from '@capacitor/push-notifications';

const VAPID_KEY = "BLWRWaUwEZaCEChXuZQlbs64mDqm_HGV4NSp216Tce9s4ac65zwR3jaITKbGKmGKxi8ReYvbtj30w5Z6Os1YrVI";

// Global listener tracker to avoid duplicate listeners
let isNativeListenersSetup = false;

export async function requestNotificationPermission(userId: string, isAdmin: boolean = false) {
  // --- NATIVE MOBILE (APK) ---
  if (Capacitor.isNativePlatform()) {
    try {
      if (!isNativeListenersSetup) {
        // 1. Add Listeners BEFORE registering
        PushNotifications.addListener('registration', async (token) => {
          console.log('[Push] Native Token generated:', token.value);
          const userRef = doc(db, 'users', userId);
          await updateDoc(userRef, {
            fcmTokens: arrayUnion(token.value)
          });
          console.log('[Push] Native Token saved to DB');
          
          // Subscribe to topics
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
          console.log('[Push] Notification action performed:', action);
          const data = action.notification.data;
          if (data && (data.actionUrl || data.link)) {
            const url = data.actionUrl || data.link;
            window.dispatchEvent(new CustomEvent('push-notification-click', { detail: { url } }));
          }
        });

        isNativeListenersSetup = true;
      }

      // 2. Check and Request Permissions
      let permStatus = await PushNotifications.checkPermissions();

      if (permStatus.receive === 'prompt') {
        permStatus = await PushNotifications.requestPermissions();
      }

      if (permStatus.receive !== 'granted') {
        console.warn('[Push] User denied permissions on native');
        return null;
      }

      // 3. Register with Apple/Google to get the token
      if (Capacitor.getPlatform() === 'android') {
        try {
          await PushNotifications.createChannel({
            id: 'high_priority',
            name: 'High Priority',
            description: 'Important notifications that appear on screen',
            importance: 5, // IMPORTANCE_MAX (causes heads-up drop down)
            visibility: 1, // VISIBILITY_PUBLIC
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

  // --- WEB / PWA ---
  if (!messaging) return;

  try {
    console.log('[Push] Requesting permission for userId:', userId);
    console.log('[Push] Current Domain:', window.location.hostname);
    
    if (!window.isSecureContext) {
      console.error('[Push] Browser is in an INSECURE context. Push notifications will NOT work. Please use HTTPS or localhost.');
      return null;
    }

    const permission = await Notification.requestPermission();
    console.log('[Push] Web Notification permission status:', permission);
    if (permission === 'granted') {
      const vapidKey = (import.meta as any).env?.VITE_VAPID_KEY || VAPID_KEY;
      
      const swRegistration = (window as any).swRegistration || await navigator.serviceWorker.ready;
      console.log('[Push] SW Registration found:', swRegistration.scope);

      // Ensure the messaging instance is using the correct SW
      const token = await getToken(messaging, { 
        vapidKey,
        serviceWorkerRegistration: swRegistration
      });

      if (token) {
        console.log('[Push] Web Token generated:', token);
        const userRef = doc(db, 'users', userId);
        await updateDoc(userRef, {
          fcmTokens: arrayUnion(token)
        });
        console.log('[Push] Web Token successfully saved to DB');

        // Subscribe to topics
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
      console.error('[Push] Worker returned error:', response.status, errText);
      try {
        return JSON.parse(errText);
      } catch (e) {
        return { success: false, error: errText };
      }
    }
    const responseData = await response.json();
    console.log('[Push] Worker Response:', responseData);
    
    if (responseData.results) {
      const failed = responseData.results.filter((r: any) => !r.ok);
      if (failed.length > 0) {
        console.error(`[Push] Delivery failed for ${failed.length} tokens:`, failed);
      } else {
        console.log(`[Push] Successfully dispatched to all ${responseData.results.length} tokens.`);
      }
    }

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
    console.log(`[Push] Subscription to ${topic}:`, data);
    return data;
  } catch (error) {
    console.error(`[Push] Failed to subscribe to topic ${topic}:`, error);
    return null;
  }
}
