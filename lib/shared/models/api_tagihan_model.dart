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
      id: int.tryParse(json['id'].toString()) ?? 0,
      keluargaId: int.tryParse(json['keluarga_id'].toString()) ?? 0,
      kategoriIuranId: int.tryParse(json['kategori_iuran_id'].toString()) ?? 0,
      nominal: json['nominal'],
      periode: json['periode'],
      paymentStatus: json['payment_status'],
      dueDate: json['due_date'],
      createdAt: json['created_at'],
    );
  }
}