/// Rankearn Presentation Formatters
class AppFormatters {
  AppFormatters._();

  static String formatCoins(int coins) {
    final str = coins.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count == 3 && i > 0) {
        buffer.write(',');
      } else if (count > 3 && (count - 3) % 2 == 0 && i > 0) {
        buffer.write(',');
      }
    }
    return buffer.toString().split('').reversed.join();
  }

  static String formatNumber(int number) => formatCoins(number);

  static String formatRupees(num amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  static String formatTimeTaken(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');
    return '$mStr:$sStr';
  }

  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Cleans image URLs copied from web browsers, HTML embed tags, markdown or image hosts (e.g. ImgBB)
  /// by stripping accidental quotes (" or %22), HTML attributes, whitespace and trailing artifacts.
  static String sanitizeImageUrl(String? input) {
    if (input == null) return '';
    var raw = input.trim();
    if (raw.isEmpty) return '';

    // If copied from HTML embed code like <img src="..." /> or <a href="...">
    final srcMatch = RegExp(r'''(?:src|href)=["']([^"']+)["']''', caseSensitive: false).firstMatch(raw);
    if (srcMatch != null) {
      raw = srcMatch.group(1)!;
    }

    // If copied from markdown like ![alt](url) or [title](url)
    final mdMatch = RegExp(r'''\((https?://[^)]+)\)''').firstMatch(raw);
    if (mdMatch != null) {
      raw = mdMatch.group(1)!;
    }

    // Strip URL encoded quotes and HTML entity quotes
    raw = raw.replaceAll('%22', '');
    raw = raw.replaceAll('&quot;', '');
    raw = raw.replaceAll(RegExp(r'%20[a-zA-Z0-9_-]+$'), '');

    // Strip leading/trailing quotation marks, backticks, brackets, HTML remnants
    raw = raw.replaceAll(RegExp(r'''^["'`<(\s]+|["'`>)%\s]+$'''), '');

    // If there's an embedded quote followed by tag attributes (e.g. url" alt=...)
    if (raw.contains('"')) {
      raw = raw.split('"').first;
    }
    if (raw.contains("'")) {
      raw = raw.split("'").first;
    }

    raw = raw.trim();

    // Auto-prepend https:// if missing protocol
    if (raw.isNotEmpty && !raw.startsWith('http://') && !raw.startsWith('https://')) {
      raw = 'https://$raw';
    }

    return raw;
  }

  /// Returns a web-safe image URL that bypasses browser CanvasKit CORS blocks
  /// for external image hosts (e.g. ImgBB) by routing through Cloudflare's public wsrv.nl proxy.
  static String webSafeImageUrl(String? input) {
    final clean = sanitizeImageUrl(input);
    if (clean.isEmpty) return '';
    if (clean.startsWith('https://wsrv.nl') || clean.startsWith('data:') || clean.startsWith('blob:')) {
      return clean;
    }
    // External domains known to block CORS in browsers (ImgBB, postimg, etc.)
    final lower = clean.toLowerCase();
    if (lower.contains('ibb.co') || lower.contains('imgbb.com') || lower.contains('postimg.cc')) {
      return 'https://wsrv.nl/?url=${Uri.encodeComponent(clean)}';
    }
    return clean;
  }
}
