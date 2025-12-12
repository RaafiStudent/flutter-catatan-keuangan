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
    Provider.of<TransactionProvider>(context, listen: false).fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    // Format Uang Rupiah
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keuangan Boss', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[800], // Warna lebih gelap biar elegan
        foregroundColor: Colors.white,
        actions: [
          // --- DROPDOWN FILTER WAKTU ---
          Consumer<TransactionProvider>(
            builder: (context, provider, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    dropdownColor: Colors.blue[700],
                    value: provider.filterStatus,
                    icon: const Icon(Icons.calendar_month, color: Colors.white),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    items: ['Hari Ini', 'Minggu Ini', 'Bulan Ini', 'Tahun Ini', 'Semua']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        provider.setFilter(newValue);
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // --- KARTU TOTAL SALDO (SESUAI FILTER) ---
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.fromLTRB(15, 20, 15, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[800]!, Colors.blue[500]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(blurRadius: 10, color: Colors.blue.withOpacity(0.5), offset: const Offset(0, 5))
                  ],
                ),
                child: Column(
                  children: [
                    Text('Saldo (${provider.filterStatus})', 
                      style: const TextStyle(color: Colors.white70, fontSize: 14)
                    ),
                    const SizedBox(height: 10),
                    Text(
                      currencyFormat.format(provider.totalPemasukan - provider.totalPengeluaran),
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Kotak Pemasukan
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.arrow_upward, color: Colors.greenAccent, size: 16),
                                  SizedBox(width: 5),
                                  Text('Pemasukan', style: TextStyle(color: Colors.white70)),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(currencyFormat.format(provider.totalPemasukan), 
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        // Kotak Pengeluaran
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Row(
                                children: [
                                  Text('Pengeluaran', style: TextStyle(color: Colors.white70)),
                                  SizedBox(width: 5),
                                  Icon(Icons.arrow_downward, color: Colors.redAccent, size: 16),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(currencyFormat.format(provider.totalPengeluaran), 
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              // --- LABEL RIWAYAT ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Riwayat Transaksi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("${provider.transactions.length} Data", style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),

              // --- DAFTAR RIWAYAT TRANSAKSI ---
              Expanded(
                child: provider.transactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, size: 70, color: Colors.grey[300]),
                            const SizedBox(height: 10),
                            Text('Tidak ada data di ${provider.filterStatus}', style: TextStyle(color: Colors.grey[500])),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: provider.transactions.length,
                        itemBuilder: (context, index) {
                          final item = provider.transactions[index];
                          final isExpense = item.type == 'pengeluaran';
                          
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isExpense ? Colors.red[50] : Colors.green[50],
                                child: Icon(
                                  isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: isExpense ? Colors.red : Colors.green,
                                ),
                              ),
                              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(DateFormat('dd MMM yyyy', 'id_ID').format(DateTime.parse(item.date))),
                              trailing: Text(
                                currencyFormat.format(item.amount),
                                style: TextStyle(
                                  color: isExpense ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15
                                ),
                              ),
                              onLongPress: () {
                                showDialog(
                                  context: context, 
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Hapus Data?'),
                                    content: const Text('Yakin ingin menghapus transaksi ini?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                                      TextButton(onPressed: () {
                                        provider.deleteTransaction(item.id!);
                                        Navigator.pop(ctx);
                                      }, child: const Text('Hapus', style: TextStyle(color: Colors.red))),
                                    ],
                                  )
                                );
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Tambah Data"),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
          );
        },
      ),
    );
  }
}