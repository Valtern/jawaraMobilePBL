// lib/shared/models/api_tagihan_model.dart

class ApiTagihan {
  final int id;
  final int keluargaId;
  final int kategoriIuranId;
  final String nominal;
  final String periode;
  final String paymentStatus;
  final String? dueDate;
  final String createdAt;

  ApiTagihan({
    required this.id,
    required this.keluargaId,
    required this.kategoriIuranId,
    required this.nominal,
    required this.periode,
    required this.paymentStatus,
    this.dueDate,
    required this.createdAt,
  });

  factory ApiTagihan.fromJson(Map<String, dynamic> json) {
    return ApiTagihan(
      id: json['id'],
      keluargaId: json['keluarga_id'],
      kategoriIuranId: json['kategori_iuran_id'],
      nominal: json['nominal'],
      periode: json['periode'],
      paymentStatus: json['payment_status'],
      dueDate: json['due_date'],
      createdAt: json['created_at'],
    );
  }
}