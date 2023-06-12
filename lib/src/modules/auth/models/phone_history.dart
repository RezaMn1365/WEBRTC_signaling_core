import 'package:hive_flutter/adapters.dart';
part 'phone_history.g.dart';

@HiveType(typeId: 0)
class PhoneNumbersHistory extends HiveObject {
  PhoneNumbersHistory(
      {required this.ownNumber, required this.numbers, required this.time});

  @HiveField(0)
  late String? ownNumber;

  @HiveField(1)
  late List<String>? numbers;

  @HiveField(2)
  late String? time;
}
