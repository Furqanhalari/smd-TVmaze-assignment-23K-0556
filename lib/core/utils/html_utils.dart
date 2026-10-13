/// Helpers for the HTML that TVMaze puts in summaries (e.g. `<p><b>Title</b> ...</p>`).
class HtmlUtils {
  HtmlUtils._();

  static final RegExp _tags = RegExp(r'<[^>]*>');

  /// Removes HTML tags and decodes common entities.
  /// Returns an empty string for null input.
  static String strip(String? html) {
    if (html == null) return '';
    return html
        .replaceAll(_tags, '')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ')
        .trim();
  }
}
