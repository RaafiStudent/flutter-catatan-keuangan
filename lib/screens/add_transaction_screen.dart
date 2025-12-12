import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';

class AddTransactionScreen extends StatefulWidget {
  // Menerima data jika ini adalah proses EDIT
  final TransactionModel? transactionToEdit;

  const AddTransactionScreen({super.key, this.transactionToEdit});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedType = 'pemasukan';
  DateTime _selectedDate = DateTime.now(); // Tanggal & Jam saat ini (WIB otomatis dari HP)
  TimeOfDay _selectedTime = TimeOfDay.now(); // Jam saat ini

  @override
  void initState() {
    super.initState();
    // LOGIKA PINTAR: Cek apakah ini Edit? Jika ya, isi form dengan data lama
    if (widget.transactionToEdit != null) {
      _titleController.text = widget.transactionToEdit!.title;
      _amountController.text = widget.transactionToEdit!.amount.toString();
      _selectedType = widget.transactionToEdit!.type;
      
      // Ambil Tanggal & Jam dari Database
      DateTime dbDate = DateTime.parse(widget.transactionToEdit!.date);
      _selectedDate = dbDate;
      _selectedTime = TimeOfDay(hour: dbDate.hour, minute: dbDate.minute);
    }
  }

  // Pilih Tanggal
  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        // Gabungkan tanggal baru dengan jam yang sudah dipilih
        _selectedDate = DateTime(
          pickedDate.year, pickedDate.month, pickedDate.day,
          _selectedTime.hour, _selectedTime.minute
        );
      });
    });
  }

  // Pilih Jam (WIB)
  void _presentTimePicker() {
    showTimePicker(
      context: context,
      initialTime: _selectedTime,
    ).then((pickedTime) {
      if (pickedTime == null) return;
      setState(() {
        _selectedTime = pickedTime;
        // Update jam di variabel _selectedDate
        _selectedDate = DateTime(
          _selectedDate.year, _selectedDate.month, _selectedDate.day,
          pickedTime.hour, pickedTime.minute,
        );
      });
    });
  }

  void _submitData() {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) return;

    final enteredTitle = _titleController.text;
    final enteredAmount = int.parse(_amountController.text);
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    // Simpan Tanggal BESERTA Jamnya (toString menyimpan format lengkap yyyy-MM-dd HH:mm:ss)
    if (widget.transactionToEdit == null) {
      provider.addTransaction(
        enteredTitle, enteredAmount, _selectedDate.toString(), _selectedType,
      );
    } else {
      provider.updateTransaction(
        widget.transactionToEdit!.id!, 
        enteredTitle, enteredAmount, _selectedDate.toString(), _selectedType,
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transactionToEdit == null ? 'Tambah Data' : 'Edit Data'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Keterangan (Contoh: Beli Pulsa)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Nominal (Rp)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            
            // --- INPUT WAKTU PINTAR ---
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Waktu Transaksi:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 5),
                      Text(
                        // Format Tanggal + Jam (WIB)
                        DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(_selectedDate),
                        style: TextStyle(fontSize: 18, color: Colors.blue[900], fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.calendar_month), onPressed: _presentDatePicker, tooltip: "Ubah Tanggal"),
                IconButton(icon: const Icon(Icons.access_time), onPressed: _presentTimePicker, tooltip: "Ubah Jam"),
              ],
            ),
            const Divider(height: 30),

            // --- PILIHAN TIPE ---
            Row(
              children: [
                Expanded(child: _buildTypeButton('pemasukan', 'Pemasukan', Colors.green)),
                const SizedBox(width: 10),
                Expanded(child: _buildTypeButton('pengeluaran', 'Pengeluaran', Colors.red)),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _submitData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(widget.transactionToEdit == null ? 'SIMPAN DATA' : 'UPDATE DATA'),
            ),
          ],
        ),
      ),
    );
  }

  // Widget tombol kustom biar rapi
  Widget _buildTypeButton(String type, String label, Color color) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: color, width: 2) : null,
        ),
        child: Center(
          child: Text(label, style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54, 
            fontWeight: FontWeight.bold
          )),
        ),
      ),
    );
  }
}