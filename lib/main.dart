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
import 'package:jawarapbl/screens/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jawara Pintar',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', ''), Locale('id', '')],
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6938EF),
          primary: const Color(0xFF6938EF),
          secondary: const Color(0xFFA29BFE),
          surface: Colors.white,
          background: const Color(0xFFF8F9FA),
          error: const Color(0xFFE74C3C),
          brightness: Brightness.light,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: Colors.black.withOpacity(0.05),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6938EF),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF6938EF),
            side: const BorderSide(color: Color(0xFF6938EF), width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF6938EF),
            textStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6938EF), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE74C3C)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE74C3C), width: 2),
          ),
          labelStyle: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        primarySwatch: Colors.deepPurple,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          iconTheme: const IconThemeData(color: Color(0xFF2D3436)),
          titleTextStyle: const TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF2D3436),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
          displayMedium: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
          displaySmall: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
          headlineLarge: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
          headlineSmall: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
          titleLarge: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
          titleSmall: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(fontFamily: 'Poppins'),
          bodyMedium: TextStyle(fontFamily: 'Poppins'),
          bodySmall: TextStyle(fontFamily: 'Poppins'),
          labelLarge: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
          labelMedium: TextStyle(fontFamily: 'Poppins'),
          labelSmall: TextStyle(fontFamily: 'Poppins'),
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
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
