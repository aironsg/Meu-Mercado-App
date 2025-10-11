import 'package:drift/drift.dart';

class Items extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  RealColumn get estimatedPrice => real().withDefault(const Constant(0.0))();
  BoolColumn get purchased => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
