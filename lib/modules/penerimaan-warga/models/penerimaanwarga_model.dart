class PenerimaanWarga {
  final int id;
  final String nama; 
  final String email; 
  final String nik; 
  final String jenisKelamin; 
  final String statusRegistrasi; 
  final String tanggalDibuat;
  final String? fotoIdentitasUrl; 

  const PenerimaanWarga({
    required this.id,
    required this.nama,
    required this.email,
    required this.nik,
    required this.jenisKelamin,
    required this.statusRegistrasi,
    required this.tanggalDibuat,
    this.fotoIdentitasUrl,
  });
}