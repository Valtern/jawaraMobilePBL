import '../models/keluarga.dart';
import '../models/rumah.dart';
import '../models/warga.dart';

class DataWargaRumahSamples {
  DataWargaRumahSamples._();

  static final List<Rumah> rumahList = [
    Rumah(address: 'Jl. Merdeka No. 10'),
    Rumah(address: 'Jl. Sudirman No. 5'),
    Rumah(address: 'Jl. Pahlawan No. 12'),
  ];

  static final List<Keluarga> keluargaList = [
    Keluarga(
      name: 'Keluarga A',
      leader: 'John Doe',
      rumah: rumahList[0],
      isActive: true,
    ),
    Keluarga(
      name: 'Keluarga B',
      leader: 'Jane Smith',
      rumah: rumahList[1],
      isActive: false,
    ),
    Keluarga(
      name: 'Keluarga C',
      leader: 'Michael Johnson',
      rumah: rumahList[2],
      isActive: true,
    ),
  ];

  static final List<Warga> wargaList = [
    Warga(
      keluarga: keluargaList[0],
      name: 'John Doe',
      nik: '1234567890123456',
      phoneNumber: '081234567890',
      birthPlace: 'City A',
      birthDate: '1 Januari 1990',
      gender: 'Laki-laki',
      bloodType: 'O',
      role: 'Kepala Keluarga',
      lastEducation: 'SMA',
      job: 'Pegawai',
      status: 'Menikah',
    ),
    Warga(
      keluarga: keluargaList[0],
      name: 'Mary Doe',
      nik: '1234567890123457',
      phoneNumber: '081234567891',
      birthPlace: 'City A',
      birthDate: '5 Mei 1992',
      gender: 'Perempuan',
      bloodType: 'A',
      role: 'Ibu Rumah Tangga',
      lastEducation: 'S1',
      job: 'Guru',
      status: 'Menikah',
    ),
    Warga(
      keluarga: keluargaList[1],
      name: 'Jane Smith',
      nik: '6543210987654321',
      phoneNumber: '089876543210',
      birthPlace: 'City B',
      birthDate: '1 Februari 1990',
      gender: 'Perempuan',
      bloodType: 'B',
      role: 'Kepala Keluarga',
      lastEducation: 'S2',
      job: 'Wiraswasta',
      status: 'Belum Menikah',
    ),
  ];
}
