import 'package:flutter/material.dart';
import 'package:jawarapbl/modules/auth/pages/login.dart';
import 'package:jawarapbl/modules/dashboard/pages/dashboard_tabs_page.dart';
import 'package:jawarapbl/modules/data-warga-rumah/pages/index.dart';
import 'package:jawarapbl/modules/channel-transfer/pages/channel_transfer.dart';
import 'package:jawarapbl/modules/kegiatan-broadcast/pages/index.dart';
import 'package:jawarapbl/modules/lainnya/pages/lainnya.dart';
import 'package:jawarapbl/modules/pemasukan/pages/index.dart';
import 'package:jawarapbl/modules/pengeluaran/pages/pegeluaran_tabs_page.dart';
import 'package:jawarapbl/modules/pesan-warga/pages/pesanwarga_tabs_page.dart';
import 'package:jawarapbl/modules/penerimaan-warga/pages/penerimaanwarga_tabs_page.dart';
import 'package:jawarapbl/modules/laporan-keuangan/pages/laporankeuangan_tabs_page.dart';
import 'package:jawarapbl/shared/layouts/main_layout.dart';
import 'package:jawarapbl/modules/mutasi-keluarga/pages/mutasi_keluarga_tabs_page.dart';
import 'package:jawarapbl/modules/mutasi-keluarga/pages/detail_mutasi_page.dart';
import 'package:jawarapbl/modules/mutasi-keluarga/pages/edit_mutasi_page.dart';
import 'package:jawarapbl/modules/log-aktivitas/pages/log_aktivitas_page.dart';
import 'package:jawarapbl/modules/manajemen-pengguna/pages/manajemen_pengguna_tabs_page.dart';
import 'package:jawarapbl/modules/auth/pages/register.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jawara Pintar',
      theme: ThemeData(
        cardTheme: CardThemeData(color: Colors.white),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.deepPurple,
            side: const BorderSide(color: Colors.deepPurple),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        scaffoldBackgroundColor: Colors.grey[100],
        primarySwatch: Colors.deepPurple,
      ),
      initialRoute: '/home',
      routes: {
        // Auth Routes
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) =>
            const MainLayout(body: DashboardPage(), currentIndex: 0),
        // Data Warga Rumah Routes
        '/data-warga-rumah': (context) =>
            const MainLayout(body: DataWargaRumahPage()),
        // Pemasukan Routes
        '/pemasukan': (context) => const MainLayout(
          body: PemasukanKategoriIuranPage(),
          currentIndex: 1,
        ),
        '/kegiatan-broadcast': (context) =>
            const MainLayout(body: KegiatanBroadcastPage(), currentIndex: 3),
        '/channel-transfer': (context) =>
            const MainLayout(body: ChannelTransferPage(), currentIndex: 3),
        // Pengeluaran Routes
        '/pengeluaran': (context) =>
            const MainLayout(body: PengeluaranTabsPage(), currentIndex: 2),
        '/laporan-keuangan': (context) =>
            const MainLayout(body: LaporanKeuanganTabsPage()),
        '/pesan-warga': (context) =>
            const MainLayout(body: PesanWargaTabsPage()),
        '/penerimaan-warga': (context) =>
            const MainLayout(body: PenerimaanWargaMasterPage()),
        '/mutasi-keluarga': (context) =>
            const MainLayout(body: MutasiKeluargaTabsPage()),
        '/detail-mutasi': (context) {
          final mutasiId = ModalRoute.of(context)!.settings.arguments as int;
          return DetailMutasiPage(mutasiId: mutasiId);
        },
        '/edit-mutasi': (context) {
          final mutasi = ModalRoute.of(context)!.settings.arguments as dynamic;
          return EditMutasiPage(mutasi: mutasi);
        },
        '/log-aktivitas': (context) =>
            const MainLayout(body: LogAktivitasPage()),
        '/manajemen-pengguna': (context) =>
            const MainLayout(body: ManajemenPenggunaTabsPage()),
        '/lainnya': (context) =>
            MainLayout(body: LainnyaPage(), currentIndex: 3),
      },
    );
  }
}

void main() => runApp(const MyApp());
