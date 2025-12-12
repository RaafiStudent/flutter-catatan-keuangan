import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import './add_transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load data saat aplikasi pertama kali dibuka
    Provider.of<TransactionProvider>(context, listen: false).fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    // Format Uang Rupiah
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Keuangan Boss'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // --- KARTU TOTAL SALDO ---
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue[800],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(blurRadius: 5, color: Colors.grey.withOpacity(0.5))],
                ),
                child: Column(
                  children: [
                    const Text('Sisa Saldo Anda', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 5),
                    Text(
                      currencyFormat.format(provider.totalPemasukan - provider.totalPengeluaran),
                      style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Pemasukan', style: TextStyle(color: Colors.white70)),
                            Text(currencyFormat.format(provider.totalPemasukan), style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Pengeluaran', style: TextStyle(color: Colors.white70)),
                            Text(currencyFormat.format(provider.totalPengeluaran), style: const TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),

              // --- DAFTAR RIWAYAT TRANSAKSI ---
              Expanded(
                child: provider.transactions.isEmpty
                    ? const Center(child: Text('Belum ada transaksi, Boss.'))
                    : ListView.builder(
                        itemCount: provider.transactions.length,
                        itemBuilder: (context, index) {
                          final item = provider.transactions[index];
                          final isExpense = item.type == 'pengeluaran';
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isExpense ? Colors.red[100] : Colors.green[100],
                                child: Icon(
                                  isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                                  color: isExpense ? Colors.red : Colors.green,
                                ),
                              ),
                              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(DateFormat('dd MMM yyyy').format(DateTime.parse(item.date))),
                              trailing: Text(
                                currencyFormat.format(item.amount),
                                style: TextStyle(
                                  color: isExpense ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15
                                ),
                              ),
                              // Geser ke kiri untuk hapus
                              onLongPress: () {
                                provider.deleteTransaction(item.id!);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      // Tombol Tambah (Floating Action Button)
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
          );
        },
      ),
    );
  }
}