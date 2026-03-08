// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutSessionAdapter extends TypeAdapter<WorkoutSession> {
  @override
  final int typeId = 0;

  @override
  WorkoutSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutSession(
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      workoutType: fields[2] as String,
      durationMinutes: fields[3] as int,
      averageHeartRate: fields[4] as double,
      maxHeartRate: fields[5] as double,
      caloriesBurned: fields[6] as double,
      hrv: fields[7] as double?,
      muscleGroupsWorked: (fields[8] as List).cast<String>(),
      perceivedExertion: fields[9] as int,
      vo2Max: fields[10] as double?,
      source: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutSession obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.workoutType)
      ..writeByte(3)
      ..write(obj.durationMinutes)
      ..writeByte(4)
      ..write(obj.averageHeartRate)
      ..writeByte(5)
      ..write(obj.maxHeartRate)
      ..writeByte(6)
      ..write(obj.caloriesBurned)
      ..writeByte(7)
      ..write(obj.hrv)
      ..writeByte(8)
      ..write(obj.muscleGroupsWorked)
      ..writeByte(9)
      ..write(obj.perceivedExertion)
      ..writeByte(10)
      ..write(obj.vo2Max)
      ..writeByte(11)
      ..write(obj.source);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
