extension DurationExtensions on Duration {
  String getFormattedMinuteSecondPosition() {
    String twoDigits(int n) {
      if (n >= 10) return '$n';
      return '0$n';
    }

    var twoDigitMinutes = twoDigits(inMinutes.remainder(60));
    var twoDigitSeconds = twoDigits(inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }
}
