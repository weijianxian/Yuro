class FileSizeFormatter {
  static String format(int? size) {
    if (size == null) return '';
    const kb = 1024;
    const mb = kb * 1024;
    if (size > mb) {
      return '${(size / mb).toStringAsFixed(2)} MB';
    }
    return '${(size / kb).toStringAsFixed(2)} KB';
  }
} 