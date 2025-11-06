class MutasiKeluarga {
  final int? id;
  final int keluargaId;
  final String jenisMutasi;
  final DateTime tanggalMutasi;
  final String? keterangan;
  final Keluarga? keluarga;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MutasiKeluarga({
    this.id,
    required this.keluargaId,
    required this.jenisMutasi,
    required this.tanggalMutasi,
    this.keterangan,
    this.keluarga,
    this.createdAt,
    this.updatedAt,
  });

  factory MutasiKeluarga.fromJson(Map<String, dynamic> json) {
    return MutasiKeluarga(
      id: json['id'],
      keluargaId: json['keluarga_id'] ?? 0,
      jenisMutasi: json['jenis_mutasi'] ?? '',
      tanggalMutasi: DateTime.parse(json['tanggal_mutasi']),
      keterangan: json['keterangan'],
      keluarga: json['keluarga'] != null ? Keluarga.fromJson(json['keluarga']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'keluarga_id': keluargaId,
      'jenis_mutasi': jenisMutasi,
      'tanggal_mutasi': tanggalMutasi.toIso8601String().split('T')[0],
      'keterangan': keterangan,
    };
  }
}

class Keluarga {
  final int id;
  final String namaKeluarga;
  final String nomorKk;
  final Rumah? rumah;

  Keluarga({
    required this.id,
    required this.namaKeluarga,
    required this.nomorKk,
    this.rumah,
  });

  factory Keluarga.fromJson(Map<String, dynamic> json) {
    return Keluarga(
      id: json['id'] ?? 0,
      namaKeluarga: json['nama_keluarga'] ?? '',
      nomorKk: json['nomor_kk'] ?? '',
      rumah: json['rumah'] != null ? Rumah.fromJson(json['rumah']) : null,
    );
  }
}

class Rumah {
  final int id;
  final String alamat;
  final String nomorRumah;

  Rumah({
    required this.id,
    required this.alamat,
    required this.nomorRumah,
  });

  factory Rumah.fromJson(Map<String, dynamic> json) {
    return Rumah(
      id: json['id'] ?? 0,
      alamat: json['alamat'] ?? '',
      nomorRumah: json['nomor_rumah'] ?? '',
    );
  }
}
