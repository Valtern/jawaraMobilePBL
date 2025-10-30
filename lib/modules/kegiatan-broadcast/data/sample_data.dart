import '../models/broadcast.dart';
import '../models/kegiatan.dart';

class KegiatanBroadcastSamples {
  KegiatanBroadcastSamples._();

  static final List<Kegiatan> kegiatanList = [
    const Kegiatan(
      name: 'Kerja Bakti Lingkungan',
      category: 'Kebersihan',
      personInCharge: 'Ketua RT 01',
      eventDate: '12 Januari 2024',
    ),
    const Kegiatan(
      name: 'Rapat Koordinasi RW',
      category: 'Rapat',
      personInCharge: 'Ketua RW 05',
      eventDate: '20 Januari 2024',
    ),
    const Kegiatan(
      name: 'Pelatihan UMKM',
      category: 'Pelatihan',
      personInCharge: 'Dinas UMKM Kota',
      eventDate: '5 Februari 2024',
    ),
  ];

  static final List<Broadcast> broadcastList = [
    const Broadcast(
      sender: 'Sekretariat RW',
      title: 'Pengumuman Iuran Kebersihan',
      date: '10 Januari 2024',
    ),
    const Broadcast(
      sender: 'Ketua RT 01',
      title: 'Informasi Kerja Bakti',
      date: '11 Januari 2024',
    ),
    const Broadcast(
      sender: 'Admin Jawara Pintar',
      title: 'Update Aplikasi Versi 1.1',
      date: '15 Januari 2024',
    ),
  ];
}
