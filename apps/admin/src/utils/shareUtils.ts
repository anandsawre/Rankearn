import { Share as CapacitorShare } from '@capacitor/share';
import { Capacitor } from '@capacitor/core';

export interface ShareOptions {
  title: string;
  text: string;
  url: string;
  imageUrl?: string;
}

export const shareContent = async (options: ShareOptions): Promise<{ success: boolean; method: 'native' | 'clipboard' | 'failed' }> => {
  const { title, text, url, imageUrl } = options;

  // 1. Try Capacitor Native Share if on APK/Native platform
  if (Capacitor.isNativePlatform()) {
    try {
      await CapacitorShare.share({
        title,
        text,
        url,
        dialogTitle: 'Share with friends',
      });
      return { success: true, method: 'native' };
    } catch (error) {
      console.error('Capacitor native share failed:', error);
      // Fallback to clipboard if native share fails
    }
  }

  // 2. Try Native Web Share API (Mobile/Modern Browsers)
  if (navigator.share) {
    try {
      // Combine text and URL to encourage apps (like WhatsApp) to treat it as a caption
      const combinedText = `${text}\n\nJoin here: ${url}`;
      
      const shareData: ShareData = {
        title,
      };

      // Handle Image Sharing if imageUrl is provided
      let fileToShare: File | null = null;
      if (imageUrl) {
        try {
          const response = await fetch(imageUrl);
          const blob = await response.blob();
          fileToShare = new File([blob], 'contest-banner.png', { type: blob.type });
        } catch (imgErr) {
          console.error('Failed to fetch image for sharing:', imgErr);
        }
      }

      // If we have a file and can share it
      if (fileToShare && navigator.canShare && navigator.canShare({ files: [fileToShare] })) {
        shareData.files = [fileToShare];
        shareData.text = combinedText; // This usually becomes the caption
        // Note: We omit the 'url' property here because some apps split them if both are present
      } else {
        // Fallback to text + url if no image or sharing files is not supported
        shareData.text = text;
        shareData.url = url;
      }

      await navigator.share(shareData);
      return { success: true, method: 'native' };
    } catch (error) {
      // If user cancelled, don't show error but don't count as success
      if ((error as Error).name === 'AbortError') {
        return { success: false, method: 'failed' };
      }
      console.error('Native share failed:', error);
      // Fallback to clipboard if native fails
    }
  }

  // 2. Fallback to Clipboard
  try {
    await navigator.clipboard.writeText(`${text}\n\nJoin here: ${url}`);
    return { success: true, method: 'clipboard' };
  } catch (error) {
    console.error('Clipboard copy failed:', error);
    return { success: false, method: 'failed' };
  }
};

/**
 * Generates a shareable link for a test
 */
export const getTestShareLink = (testId: string): string => {
  const baseUrl = "https://rankearn.web.app";
  return `${baseUrl}/dashboard?join=${testId}`;
};

/**
 * Generates a shareable link for a result
 */
export const getResultShareLink = (attemptId: string): string => {
  const baseUrl = "https://rankearn.web.app";
  return `${baseUrl}/results/${attemptId}`;
};

/**
 * Returns a domain name suited for sharing, falling back to production if local
 */
export const getDomainFriendlyOrigin = (): string => {
  const origin = window.location.origin;
  if (origin.includes('localhost') || origin.includes('capacitor://') || origin.startsWith('file://')) {
    return "https://rankearn.web.app";
  }
  return origin;
};
