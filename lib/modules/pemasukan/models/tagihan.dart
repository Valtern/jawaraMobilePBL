import 'kategori_iuran.dart';

enum PaymentStatus { paid, unpaid }

class Tagihan {
  final String familyName;
  final bool isFamilyActive;
  final KategoriIuran iuran;
  final String code;
  final double nominal;
  final String periode;
  final PaymentStatus paymentStatus;

  const Tagihan({
    required this.familyName,
    required this.isFamilyActive,
    required this.iuran,
    required this.code,
    required this.nominal,
    required this.periode,
    required this.paymentStatus,
  });
}
