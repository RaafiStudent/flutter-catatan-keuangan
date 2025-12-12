import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedType = 'pemasukan'; // Default pilihan
  DateTime _selectedDate = DateTime.now();

  // Fungsi untuk memilih tanggal
  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  // Fungsi simpan data
  void _submitData() {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) {
      return;
    }

    final enteredTitle = _titleController.text;
    final enteredAmount = int.parse(_amountController.text);

    // Panggil Provider untuk simpan ke Database
    Provider.of<TransactionProvider>(context, listen: false).addTransaction(
      enteredTitle,
      enteredAmount,
      _selectedDate.toString(), // Simpan tanggal sebagai Text
      _selectedType,
    );

    // Kembali ke halaman Home setelah simpan
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Transaksi'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Judul (Contoh: Beli Makan)'),
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Nominal (Contoh: 15000)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tanggal: ${DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate)}',
                  ),
                ),
                TextButton(
                  onPressed: _presentDatePicker,
                  child: const Text('Pilih Tanggal', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _selectedType = 'pemasukan'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: _selectedType == 'pemasukan' ? Colors.green : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('Pemasukan', style: TextStyle(color: _selectedType == 'pemasukan' ? Colors.white : Colors.black)),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _selectedType = 'pengeluaran'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: _selectedType == 'pengeluaran' ? Colors.red : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('Pengeluaran', style: TextStyle(color: _selectedType == 'pengeluaran' ? Colors.white : Colors.black)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _submitData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('SIMPAN TRANSAKSI'),
            ),
          ],
        ),
      ),
    );
  }
}