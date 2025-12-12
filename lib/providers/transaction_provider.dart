import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/transaction_model.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _allTransactions = []; // Menyimpan SEMUA data
  String _filterStatus = 'Bulan Ini'; // Default filter saat pertama buka

  // Getter data yang sudah difilter untuk ditampilkan di UI
  List<TransactionModel> get transactions {
    DateTime now = DateTime.now();

    if (_filterStatus == 'Hari Ini') {
      return _allTransactions.where((item) {
        DateTime date = DateTime.parse(item.date);
        return date.day == now.day && date.month == now.month && date.year == now.year;
      }).toList();
    } 
    else if (_filterStatus == 'Minggu Ini') {
      // Logika: 7 Hari Terakhir
      DateTime weekAgo = now.subtract(const Duration(days: 7));
      return _allTransactions.where((item) {
        DateTime date = DateTime.parse(item.date);
        return date.isAfter(weekAgo) && date.isBefore(now.add(const Duration(days: 1)));
      }).toList();
    } 
    else if (_filterStatus == 'Bulan Ini') {
      return _allTransactions.where((item) {
        DateTime date = DateTime.parse(item.date);
        return date.month == now.month && date.year == now.year;
      }).toList();
    } 
    else if (_filterStatus == 'Tahun Ini') {
      return _allTransactions.where((item) {
        DateTime date = DateTime.parse(item.date);
        return date.year == now.year;
      }).toList();
    }

    return _allTransactions; // Kalau 'Semua'
  }

  // Fungsi untuk mengubah jenis filter dari UI
  void setFilter(String filter) {
    _filterStatus = filter;
    notifyListeners(); // Kabari UI untuk refresh tampilan
  }

  String get filterStatus => _filterStatus;

  // --- DATABASE OPERATIONS ---

  Future<void> fetchTransactions() async {
    _allTransactions = await DatabaseHelper.instance.readAllTransactions();
    notifyListeners();
  }

  Future<void> addTransaction(String title, int amount, String date, String type) async {
    final newTransaction = TransactionModel(
      title: title,
      amount: amount,
      date: date,
      type: type,
    );
    await DatabaseHelper.instance.create(newTransaction);
    await fetchTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await DatabaseHelper.instance.delete(id);
    await fetchTransactions();
  }

  // --- LOGIKA TOTAL (Dihitung dari data yang SUDAH DI-FILTER) ---

  int get totalPemasukan {
    var total = 0;
    for (var item in transactions) { // Menggunakan 'transactions' (yang sudah difilter)
      if (item.type == 'pemasukan') {
        total += item.amount;
      }
    }
    return total;
  }

  int get totalPengeluaran {
    var total = 0;
    for (var item in transactions) { // Menggunakan 'transactions' (yang sudah difilter)
      if (item.type == 'pengeluaran') {
        total += item.amount;
      }
    }
    return total;
  }
}