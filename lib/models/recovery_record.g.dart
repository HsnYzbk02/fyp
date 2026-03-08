// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recovery_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecoveryRecordAdapter extends TypeAdapter<RecoveryRecord> {
  @override
  final int typeId = 1;

  @override
  RecoveryRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecoveryRecord(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      overallScore: fields[2] as double,
      sleepQuality: fields[3] as double,
      sleepDurationHours: fields[4] as double,
      hrv: fields[5] as double,
      restingHeartRate: fields[6] as double,
      hydrationLevel: fields[7] as double,
      recommendations: (fields[8] as List).cast<String>(),
      muscleGroupRecovery: (fields[9] as Map).cast<String, double>(),
      aiSummary: fields[10] as String,
      notificationSent: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, RecoveryRecord obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.overallScore)
      ..writeByte(3)
      ..write(obj.sleepQuality)
      ..writeByte(4)
      ..write(obj.sleepDurationHours)
      ..writeByte(5)
      ..write(obj.hrv)
      ..writeByte(6)
      ..write(obj.restingHeartRate)
      ..writeByte(7)
      ..write(obj.hydrationLevel)
      ..writeByte(8)
      ..write(obj.recommendations)
      ..writeByte(9)
      ..write(obj.muscleGroupRecovery)
      ..writeByte(10)
      ..write(obj.aiSummary)
      ..writeByte(11)
      ..write(obj.notificationSent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecoveryRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
