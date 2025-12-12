import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/transaction_model.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _allTransactions = [];

  // Filter Waktu Default: Bulan Ini
  String _filterTime = 'Bulan Ini';
  
  // Filter Tipe Default: Semua (Bisa diganti ke 'Pemasukan' atau 'Pengeluaran')
  String _filterType = 'Semua';

  // --- GETTER DATA UTAMA (List yang tampil di layar) ---
  List<TransactionModel> get transactions {
    DateTime now = DateTime.now();
    List<TransactionModel> tempResult = [];

    // 1. FILTER WAKTU (Time Frame)
    if (_filterTime == 'Hari Ini') {
      tempResult = _allTransactions.where((item) {
        DateTime date = DateTime.parse(item.date);
        return date.day == now.day && date.month == now.month && date.year == now.year;
      }).toList();
    } else if (_filterTime == 'Minggu Ini') {
      DateTime weekAgo = now.subtract(const Duration(days: 7));
      tempResult = _allTransactions.where((item) {
        DateTime date = DateTime.parse(item.date);
        return date.isAfter(weekAgo) && date.isBefore(now.add(const Duration(days: 1)));
      }).toList();
    } else if (_filterTime == 'Bulan Ini') {
      tempResult = _allTransactions.where((item) {
        DateTime date = DateTime.parse(item.date);
        return date.month == now.month && date.year == now.year;
      }).toList();
    } else if (_filterTime == 'Tahun Ini') {
      tempResult = _allTransactions.where((item) {
        DateTime date = DateTime.parse(item.date);
        return date.year == now.year;
      }).toList();
    } else {
      tempResult = _allTransactions; // Semua Waktu
    }

    // 2. FILTER TIPE (Income vs Expense)
    // Ini logika agar list bisa dipisah sesuai permintaan Boss
    if (_filterType == 'Pemasukan') {
      return tempResult.where((item) => item.type == 'pemasukan').toList();
    } else if (_filterType == 'Pengeluaran') {
      return tempResult.where((item) => item.type == 'pengeluaran').toList();
    }

    return tempResult; // Tampilkan Semua (Campur)
  }

  // --- Setter untuk Mengubah Filter ---
  void setFilterTime(String filter) {
    _filterTime = filter;
    notifyListeners();
  }

  void setFilterType(String type) {
    _filterType = type;
    notifyListeners();
  }

  String get filterTime => _filterTime;
  String get filterType => _filterType;

  // --- DATABASE CRUD ---

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

  // FITUR UPDATE (EDIT DATA) - Request Boss
  Future<void> updateTransaction(int id, String title, int amount, String date, String type) async {
    final updatedTransaction = TransactionModel(
      id: id,
      title: title,
      amount: amount,
      date: date,
      type: type,
    );
    await DatabaseHelper.instance.update(updatedTransaction);
    await fetchTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await DatabaseHelper.instance.delete(id);
    await fetchTransactions();
  }

  // --- LOGIKA TOTAL PINTAR ---
  // Total dihitung berdasarkan Filter WAKTU saja, mengabaikan Filter TIPE.
  // Kenapa? Agar saat Boss melihat list "Pengeluaran", tulisan "Sisa Saldo" di atas tidak jadi Nol/Aneh.
  
  List<TransactionModel> get _transactionsByTimeOnly {
     DateTime now = DateTime.now();
     if (_filterTime == 'Hari Ini') {
        return _allTransactions.where((item) {
          DateTime date = DateTime.parse(item.date);
          return date.day == now.day && date.month == now.month && date.year == now.year;
        }).toList();
     } else if (_filterTime == 'Minggu Ini') {
        DateTime weekAgo = now.subtract(const Duration(days: 7));
        return _allTransactions.where((item) {
          DateTime date = DateTime.parse(item.date);
          return date.isAfter(weekAgo) && date.isBefore(now.add(const Duration(days: 1)));
        }).toList();
     } else if (_filterTime == 'Bulan Ini') {
        return _allTransactions.where((item) {
          DateTime date = DateTime.parse(item.date);
          return date.month == now.month && date.year == now.year;
        }).toList();
     } else if (_filterTime == 'Tahun Ini') {
        return _allTransactions.where((item) {
          DateTime date = DateTime.parse(item.date);
          return date.year == now.year;
        }).toList();
     }
     return _allTransactions;
  }

  int get totalPemasukan {
    var list = _transactionsByTimeOnly; 
    var total = 0;
    for (var item in list) { 
      if (item.type == 'pemasukan') total += item.amount;
    }
    return total;
  }

  int get totalPengeluaran {
    var list = _transactionsByTimeOnly;
    var total = 0;
    for (var item in list) { 
      if (item.type == 'pengeluaran') total += item.amount;
    }
    return total;
  }
}