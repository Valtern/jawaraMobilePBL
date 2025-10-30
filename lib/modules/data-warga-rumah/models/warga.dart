import 'keluarga.dart';

class Warga {
  final Keluarga keluarga;
  final String name;
  final String nik;
  final String phoneNumber;
  final String birthPlace;
  final String birthDate;
  final String gender;
  final String bloodType;
  final String role;
  final String lastEducation;
  final String job;
  final String status;

  Warga({
    required this.keluarga,
    required this.name,
    required this.nik,
    required this.phoneNumber,
    required this.birthPlace,
    required this.birthDate,
    required this.gender,
    required this.bloodType,
    required this.role,
    required this.lastEducation,
    required this.job,
    required this.status,
  });

  String get familyName => keluarga.name;
}
