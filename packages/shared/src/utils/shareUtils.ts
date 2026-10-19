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
    }
  }

  if (navigator.share) {
    try {
      const combinedText = `${text}\n\nJoin here: ${url}`;
      
      const shareData: ShareData = {
        title,
      };

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

      if (fileToShare && navigator.canShare && navigator.canShare({ files: [fileToShare] })) {
        shareData.files = [fileToShare];
        shareData.text = combinedText;
      } else {
        shareData.text = text;
        shareData.url = url;
      }

      await navigator.share(shareData);
      return { success: true, method: 'native' };
    } catch (error) {
      if ((error as Error).name === 'AbortError') {
        return { success: false, method: 'failed' };
      }
      console.error('Native share failed:', error);
    }
  }

  try {
    await navigator.clipboard.writeText(`${text}\n\nJoin here: ${url}`);
    return { success: true, method: 'clipboard' };
  } catch (error) {
    console.error('Clipboard copy failed:', error);
    return { success: false, method: 'failed' };
  }
};

export const getTestShareLink = (testId: string): string => {
  const baseUrl = "https://rankearn.web.app";
  return `${baseUrl}/dashboard?join=${testId}`;
};

export const getResultShareLink = (attemptId: string): string => {
  const baseUrl = "https://rankearn.web.app";
  return `${baseUrl}/results/${attemptId}`;
};

export const getDomainFriendlyOrigin = (): string => {
  const origin = window.location.origin;
  if (origin.includes('localhost') || origin.includes('capacitor://') || origin.startsWith('file://')) {
    return "https://rankearn.web.app";
  }
  return origin;
};
