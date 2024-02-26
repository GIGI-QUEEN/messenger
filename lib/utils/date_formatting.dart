import 'package:intl/intl.dart';

class DateFormatting {
  final _hhMM = DateFormat('HH:mm');
  final DateTime now = DateTime.now();

  String hoursMinutes(int providedDateMilliseconds) {
    final DateTime date =
        DateTime.fromMillisecondsSinceEpoch(providedDateMilliseconds);
    return _hhMM.format(date);
  }

  /* String longDate(int timeStamp) {
    final providedDate = Date
    final bool includeDayAndMonth = now.difference(timeStamp).inHours > 24;
  } */

  String formatDateTime(int providedDateMilliseconds) {
    // Convert provided date to a DateTime object
    DateTime providedDate =
        DateTime.fromMillisecondsSinceEpoch(providedDateMilliseconds);

/*   // Current date and time
  DateTime now = DateTime.now(); */

    // Check if the provided date is longer than 24 hours before the current date
    bool shouldIncludeDayAndMonth = now.difference(providedDate).inHours > 24;

    // Create a DateFormat object with the desired format
    DateFormat formatter = shouldIncludeDayAndMonth
        ? DateFormat('dd/MM HH:mm')
        : DateFormat('HH:mm');

    // Format the date using the formatter
    String formattedTime = formatter.format(providedDate);

    // Return the formatted time
    return formattedTime;
  }
}
