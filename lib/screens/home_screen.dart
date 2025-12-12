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
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Keuangan Pintar', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        actions: [
          // Dropdown Filter Waktu
          Consumer<TransactionProvider>(
            builder: (context, provider, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    dropdownColor: Colors.blue[800],
                    value: provider.filterTime,
                    icon: const Icon(Icons.calendar_month, color: Colors.white),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    items: ['Hari Ini', 'Minggu Ini', 'Bulan Ini', 'Tahun Ini', 'Semua'].map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) provider.setFilterTime(newValue);
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
              // --- 1. AREA TOTAL (SELALU TAMPIL) ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    Text('Sisa Saldo (${provider.filterTime})', style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 5),
                    Text(
                      currencyFormat.format(provider.totalPemasukan - provider.totalPengeluaran),
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
                            child: Column(children: [
                              const Text('Pemasukan', style: TextStyle(color: Colors.white70)),
                              Text(currencyFormat.format(provider.totalPemasukan), style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                            ]),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
                            child: Column(children: [
                              const Text('Pengeluaran', style: TextStyle(color: Colors.white70)),
                              Text(currencyFormat.format(provider.totalPengeluaran), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                            ]),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              // --- 2. FILTER TOMBOL (SEMUA / MASUK / KELUAR) ---
              Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFilterChip(provider, 'Semua'),
                    const SizedBox(width: 10),
                    _buildFilterChip(provider, 'Pemasukan'),
                    const SizedBox(width: 10),
                    _buildFilterChip(provider, 'Pengeluaran'),
                  ],
                ),
              ),

              // --- 3. DAFTAR RIWAYAT ---
              Expanded(
                child: provider.transactions.isEmpty
                    ? Center(child: Text('Belum ada data ${provider.filterType.toLowerCase()}.', style: TextStyle(color: Colors.grey[500])))
                    : ListView.builder(
                        itemCount: provider.transactions.length,
                        itemBuilder: (context, index) {
                          final item = provider.transactions[index];
                          final isExpense = item.type == 'pengeluaran';
                          DateTime date = DateTime.parse(item.date);

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              // Ikon Jenis
                              leading: CircleAvatar(
                                backgroundColor: isExpense ? Colors.red[50] : Colors.green[50],
                                child: Icon(isExpense ? Icons.arrow_downward : Icons.arrow_upward, color: isExpense ? Colors.red : Colors.green),
                              ),
                              // Judul & Tanggal Jam
                              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                DateFormat('dd MMM yyyy • HH:mm', 'id_ID').format(date),
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                              // Nominal
                              trailing: Text(
                                currencyFormat.format(item.amount),
                                style: TextStyle(
                                  color: isExpense ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15
                                ),
                              ),
                              // TAP untuk EDIT
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AddTransactionScreen(transactionToEdit: item),
                                  ),
                                );
                              },
                              // TEKAN LAMA untuk HAPUS
                              onLongPress: () {
                                showDialog(
                                  context: context, 
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Hapus Data?'),
                                    content: Text('Hapus "${item.title}"?'),
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
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Catat Baru"),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
          );
        },
      ),
    );
  }

  // Widget Tombol Filter Kecil (Pill shape)
  Widget _buildFilterChip(TransactionProvider provider, String label) {
    bool isSelected = provider.filterType == label;
    return GestureDetector(
      onTap: () => provider.setFilterType(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[800] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.blue[800]! : Colors.grey[300]!),
          boxShadow: isSelected ? [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))] : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}