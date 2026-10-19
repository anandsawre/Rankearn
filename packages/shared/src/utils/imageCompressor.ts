export const compressImage = (file: File, maxSizeKB: number, maxWidth = 1200): Promise<File> => {
  return new Promise((resolve, reject) => {
    if (!file.type.startsWith('image/')) {
      return reject(new Error('Invalid file type. Please upload an image.'));
    }

    const maxSizeBytes = maxSizeKB * 1024;

    if (file.size <= maxSizeBytes && (file.type === 'image/jpeg' || file.type === 'image/webp' || file.type === 'image/png')) {
      return resolve(file);
    }

    const reader = new FileReader();

    reader.readAsDataURL(file);
    reader.onload = (event) => {
      const img = new Image();
      img.src = event.target?.result as string;

      img.onload = () => {
        let width = img.width;
        let height = img.height;

        if (width > maxWidth) {
          const ratio = maxWidth / width;
          width = maxWidth;
          height = height * ratio;
        }

        const canvas = document.createElement('canvas');
        canvas.width = width;
        canvas.height = height;

        const ctx = canvas.getContext('2d');
        if (!ctx) return reject(new Error('Failed to get canvas context'));

        ctx.fillStyle = "#FFFFFF";
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        ctx.drawImage(img, 0, 0, width, height);

        let quality = 0.9;
        let compressedFile: File | null = null;
        
        const tryCompress = () => {
          canvas.toBlob((blob) => {
            if (!blob) return reject(new Error('Canvas to Blob failed'));

            compressedFile = new File([blob], file.name.replace(/\.[^/.]+$/, "") + ".jpg", {
              type: 'image/jpeg',
              lastModified: Date.now(),
            });

            if (compressedFile.size <= maxSizeBytes || quality <= 0.3) {
                resolve(compressedFile);
            } else {
                quality -= 0.1;
                tryCompress();
            }
          }, 'image/jpeg', quality);
        };

        tryCompress();
      };
      img.onerror = (e) => reject(e);
    };
    reader.onerror = (e) => reject(e);
  });
};
