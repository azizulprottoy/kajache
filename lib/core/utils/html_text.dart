/// Plain-text preview of rich text (HTML from the dashboard editor), for
/// places that show a line or two, like list cards. Full rich text is
/// rendered with flutter_html on detail pages instead.
String htmlToPlainText(String html) {
  if (html.isEmpty) return '';
  return html
      // Block ends become spaces so "<p>a</p><p>b</p>" reads "a b", not "ab"
      .replaceAll(RegExp(r'<br\s*/?>|</(p|div|li|h[1-6])>', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&amp;', '&')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
