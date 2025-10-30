import 'rumah.dart';

class Keluarga {
  final String name;
  final String leader;
  final Rumah rumah;
  final bool isActive;

  Keluarga({
    required this.name,
    required this.leader,
    required this.rumah,
    required this.isActive,
  });

  String get address => rumah.address;
}
