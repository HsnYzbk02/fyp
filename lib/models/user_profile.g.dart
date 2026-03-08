// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 2;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      name: fields[0] as String,
      age: fields[1] as int,
      weightKg: fields[2] as double,
      heightCm: fields[3] as double,
      fitnessLevel: fields[4] as String,
      primaryGoals: (fields[5] as List).cast<String>(),
      favoriteWorkouts: (fields[6] as List).cast<String>(),
      targetSleepHours: fields[7] as int,
      hasAppleWatch: fields[8] as bool,
      appleWatchModel: fields[9] as String?,
      notificationsEnabled: fields[10] as bool,
      dailyWaterTargetMl: fields[11] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.age)
      ..writeByte(2)
      ..write(obj.weightKg)
      ..writeByte(3)
      ..write(obj.heightCm)
      ..writeByte(4)
      ..write(obj.fitnessLevel)
      ..writeByte(5)
      ..write(obj.primaryGoals)
      ..writeByte(6)
      ..write(obj.favoriteWorkouts)
      ..writeByte(7)
      ..write(obj.targetSleepHours)
      ..writeByte(8)
      ..write(obj.hasAppleWatch)
      ..writeByte(9)
      ..write(obj.appleWatchModel)
      ..writeByte(10)
      ..write(obj.notificationsEnabled)
      ..writeByte(11)
      ..write(obj.dailyWaterTargetMl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
