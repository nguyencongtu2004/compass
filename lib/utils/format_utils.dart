class FormatUtils {
  /// Get time ago in a human-readable format.
  /// For example, "2 days ago", "3 hours ago", "5 minutes ago", or "Just now".
  static String getTimeAgo(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inDays > 0) {
      return '${duration.inDays} ngày trước';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} giờ trước';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
  /// Get a short version of time ago, suitable for compact displays.
  /// For example, "2d", "3h", "5m", or "Just now".
  static String getShortTimeAgo(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inDays > 0) {
      return '${duration.inDays}d';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return 'Vừa xong';
    }
  }

  /// Format message time for chat (show time for today, date for older)
  static String formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      // Show time for today's messages
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // Show "Hôm qua" for yesterday's messages
      return 'Hôm qua ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      // Show date for older messages
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}