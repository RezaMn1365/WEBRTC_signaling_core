// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PhoneNumbersHistoryAdapter extends TypeAdapter<PhoneNumbersHistory> {
  @override
  final int typeId = 0;

  @override
  PhoneNumbersHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PhoneNumbersHistory(
      ownNumber: fields[0] as String?,
      numbers: (fields[1] as List?)?.cast<String>(),
      time: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PhoneNumbersHistory obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.ownNumber)
      ..writeByte(1)
      ..write(obj.numbers)
      ..writeByte(2)
      ..write(obj.time);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhoneNumbersHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
