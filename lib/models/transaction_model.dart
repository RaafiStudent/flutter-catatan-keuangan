class TransactionModel {
  final int? id;
  final String title;   // Contoh: "Beli Bakso"
  final int amount;     // Contoh: 15000
  final String date;    // Contoh: "2023-12-12"
  final String type;    // "pemasukan" atau "pengeluaran"

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
  });

  // Mengubah data ke bentuk Map (untuk disimpan ke Database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date,
      'type': type,
    };
  }

  // Mengubah data dari Database ke bentuk Asli (untuk ditampilkan di Aplikasi)
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: map['date'],
      type: map['type'],
    );
  }
}