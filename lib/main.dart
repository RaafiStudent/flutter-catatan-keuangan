import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import './providers/transaction_provider.dart';
import './screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi format tanggal bahasa Indonesia
  await initializeDateFormatting('id_ID', null);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Mendaftarkan Provider Transaksi di sini agar bisa diakses semua layar
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Catatan Keuangan',
        theme: ThemeData(
          // Mengatur tema warna aplikasi menjadi Biru
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          // Mengatur font default atau gaya teks jika diperlukan di masa depan
        ),
        // Menjadikan HomeScreen sebagai halaman pertama yang muncul
        home: const HomeScreen(),
      ),
    );
  }
}