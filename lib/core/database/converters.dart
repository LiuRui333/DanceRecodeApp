import 'package:drift/drift.dart';

final class UtcDateTimeConverter extends TypeConverter<DateTime, DateTime> {
  const UtcDateTimeConverter();

  @override
  DateTime fromSql(DateTime fromDb) => fromDb.toUtc();

  @override
  DateTime toSql(DateTime value) => value.toUtc();
}
