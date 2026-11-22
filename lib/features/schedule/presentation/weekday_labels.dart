import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// SCH-03 NFR-11. Rows are stored Monday first: row i is ISO weekday i + 1.
class WeekdayLabels {
  const WeekdayLabels._(this.locale, this.firstDay);

  factory WeekdayLabels.of(BuildContext context) => WeekdayLabels._(
    Localizations.localeOf(context).toString(),
    MaterialLocalizations.of(context).firstDayOfWeekIndex,
  );

  final String locale;

  // 0 = Sunday, as `MaterialLocalizations.firstDayOfWeekIndex`.
  final int firstDay;

  // 1 Jan 2024 was a Monday.
  static DateTime _day(int row) => DateTime(2024, 1, 1 + row);

  String full(int row) => DateFormat.EEEE(locale).format(_day(row));

  String short(int row) => DateFormat.E(locale).format(_day(row));
}
