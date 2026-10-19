/**
 * Capitalizes the first letter of every word in a string.
 * Preserves the rest of the casing (e.g., acronyms like "SSC CGL" stay "SSC CGL").
 */
export const capitalizeWords = (str: string): string => {
  if (!str) return str;
  return str.split(' ').map(word => {
    if (word.length === 0) return word;
    return word.charAt(0).toUpperCase() + word.slice(1);
  }).join(' ');
};
