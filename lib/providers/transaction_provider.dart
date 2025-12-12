import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/transaction_model.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];

  // Getter: Agar data bisa diambil dari UI
  List<TransactionModel> get transactions => _transactions;

  // Fungsi: Ambil semua data dari Database saat aplikasi dibuka
  Future<void> fetchTransactions() async {
    _transactions = await DatabaseHelper.instance.readAllTransactions();
    notifyListeners(); // Memberitahu UI bahwa data sudah berubah
  }

  // Fungsi: Tambah Transaksi Baru
  Future<void> addTransaction(String title, int amount, String date, String type) async {
    final newTransaction = TransactionModel(
      title: title,
      amount: amount,
      date: date,
      type: type,
    );

    await DatabaseHelper.instance.create(newTransaction);
    await fetchTransactions(); // Refresh data setelah nambah
  }

  // Fungsi: Hapus Transaksi
  Future<void> deleteTransaction(int id) async {
    await DatabaseHelper.instance.delete(id);
    await fetchTransactions(); // Refresh data setelah hapus
  }

  // Fungsi: Update Transaksi
  Future<void> updateTransaction(TransactionModel transaction) async {
    await DatabaseHelper.instance.update(transaction);
    await fetchTransactions();
  }

  // --- LOGIKA PERHITUNGAN TOTAL ---

  // Hitung Total Pemasukan
  int get totalPemasukan {
    var total = 0;
    for (var item in _transactions) {
      if (item.type == 'pemasukan') {
        total += item.amount;
      }
    }
    return total;
  }

  // Hitung Total Pengeluaran
  int get totalPengeluaran {
    var total = 0;
    for (var item in _transactions) {
      if (item.type == 'pengeluaran') {
        total += item.amount;
      }
    }
    return total;
  }
}