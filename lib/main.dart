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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:jawarapbl/modules/auth/pages/face_enrollment_page.dart';
import 'package:jawarapbl/modules/auth/pages/face_login_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF5F3FFF);
    const accentPink = Color(0xFFFF6FD8);
    const softBackground = Color(0xFFF5F3FF);

    final baseTheme = ThemeData(
      fontFamily: 'Poppins',
      colorScheme: const ColorScheme.light(
        primary: primaryPurple,
        secondary: accentPink,
        background: softBackground,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: Color(0xFF1B1B33),
        onSurface: Color(0xFF1B1B33),
      ),
      scaffoldBackgroundColor: softBackground,
      useMaterial3: true,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jawara Pintar',

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', ''), Locale('id', '')],

      theme: baseTheme.copyWith(
        textTheme: baseTheme.textTheme.copyWith(
          headlineSmall: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B1B33),
          ),
          titleMedium: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B1B33),
          ),
          bodyMedium: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Color(0xFF4B4B6A),
          ),
          labelLarge: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 6,
          shadowColor: Colors.black.withOpacity(0.06),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryPurple,
            foregroundColor: Colors.white,
            elevation: 3,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryPurple,
            side: const BorderSide(color: primaryPurple, width: 1.4),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: primaryPurple, width: 1.6),
          ),
          labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF7B7B9A)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          foregroundColor: Color(0xFF1B1B33),
        ),
      ),
      initialRoute: '/login',
      routes: {
        // Auth Routes
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/face-enroll': (context) {
          final userId = ModalRoute.of(context)!.settings.arguments as int;
          return FaceEnrollmentPage(userId: userId);
        },
        '/face-login': (context) => const FaceLoginPage(),
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
