import '../models/kategori_iuran.dart';
import '../models/pemasukan_lain.dart';
import '../models/tagihan.dart';

class PemasukanSamples {
  PemasukanSamples._();

  static final List<KategoriIuran> kategoriIuranList = [
    const KategoriIuran(name: 'Iuran Kebersihan', jenis: 'Wajib', nominal: 25000),
    const KategoriIuran(name: 'Iuran Keamanan', jenis: 'Wajib', nominal: 30000),
    const KategoriIuran(name: 'Iuran Sosial', jenis: 'Sukarela', nominal: 20000),
  ];

  static final List<Tagihan> tagihanList = [
    Tagihan(
      familyName: 'Keluarga Andi',
      isFamilyActive: true,
      iuran: kategoriIuranList[0],
      code: 'TAG-202401-001',
      nominal: 25000,
      periode: 'Januari 2024',
      paymentStatus: PaymentStatus.paid,
    ),
    Tagihan(
      familyName: 'Keluarga Budi',
      isFamilyActive: true,
      iuran: kategoriIuranList[1],
      code: 'TAG-202401-002',
      nominal: 30000,
      periode: 'Januari 2024',
      paymentStatus: PaymentStatus.unpaid,
    ),
    Tagihan(
      familyName: 'Keluarga Citra',
      isFamilyActive: false,
      iuran: kategoriIuranList[2],
      code: 'TAG-202401-003',
      nominal: 20000,
      periode: 'Februari 2024',
      paymentStatus: PaymentStatus.unpaid,
    ),
  ];

  static final List<PemasukanLain> pemasukanLainList = [
    const PemasukanLain(
      name: 'Donasi Acara 17 Agustus',
      jenis: 'Donasi',
      tanggal: '17 Agustus 2023',
      nominal: 150000,
    ),
    const PemasukanLain(
      name: 'Sponsor Acara Kebersihan',
      jenis: 'Sponsor',
      tanggal: '25 November 2023',
      nominal: 200000,
    ),
    const PemasukanLain(
      name: 'Penjualan Merchandise',
      jenis: 'Penjualan',
      tanggal: '2 Januari 2024',
      nominal: 120000,
    ),
  ];
}
