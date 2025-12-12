import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import ini untuk Formatter Input
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transactionToEdit;

  const AddTransactionScreen({super.key, this.transactionToEdit});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedType = 'pemasukan';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    // LOGIKA PINTAR: Cek apakah ini Edit?
    if (widget.transactionToEdit != null) {
      _titleController.text = widget.transactionToEdit!.title;
      
      // FORMAT DUIT (Biar pas Edit, angkanya ada titiknya. Contoh: 15.000)
      final formattedAmount = NumberFormat.decimalPattern('id_ID').format(widget.transactionToEdit!.amount);
      _amountController.text = formattedAmount;
      
      _selectedType = widget.transactionToEdit!.type;
      
      DateTime dbDate = DateTime.parse(widget.transactionToEdit!.date);
      _selectedDate = dbDate;
      _selectedTime = TimeOfDay(hour: dbDate.hour, minute: dbDate.minute);
    }
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = DateTime(
          pickedDate.year, pickedDate.month, pickedDate.day,
          _selectedTime.hour, _selectedTime.minute
        );
      });
    });
  }

  void _presentTimePicker() {
    showTimePicker(
      context: context,
      initialTime: _selectedTime,
    ).then((pickedTime) {
      if (pickedTime == null) return;
      setState(() {
        _selectedTime = pickedTime;
        _selectedDate = DateTime(
          _selectedDate.year, _selectedDate.month, _selectedDate.day,
          pickedTime.hour, pickedTime.minute,
        );
      });
    });
  }

  void _submitData() {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) return;

    // BERSIHKAN TITIK SEBELUM DISIMPAN
    // Karena "10.000" itu String, Database butuh Integer (10000)
    final cleanAmountString = _amountController.text.replaceAll('.', ''); 
    final enteredAmount = int.parse(cleanAmountString);
    
    final enteredTitle = _titleController.text;
    final provider = Provider.of<TransactionProvider>(context, listen: false);

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
              decoration: const InputDecoration(
                labelText: 'Keterangan (Contoh: Beli Pulsa)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            
            // --- INPUT DUIT ALA BANK (ADA TITIKNYA) ---
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Nominal',
                prefixText: 'Rp ', // Ada tulisan Rp di depannya
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              // Ini Bagian Ajaibnya:
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Cuma boleh angka
                CurrencyInputFormatter(), // Memanggil class formatter buatan kita di bawah
              ],
            ),
            const SizedBox(height: 20),
            
            // --- INPUT WAKTU ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5)
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Waktu Transaksi:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 5),
                        Text(
                          DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(_selectedDate),
                          style: TextStyle(fontSize: 16, color: Colors.blue[900], fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.calendar_month, color: Colors.blue), onPressed: _presentDatePicker),
                  IconButton(icon: const Icon(Icons.access_time, color: Colors.blue), onPressed: _presentTimePicker),
                ],
              ),
            ),
            const SizedBox(height: 20),

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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(widget.transactionToEdit == null ? 'SIMPAN DATA' : 'UPDATE DATA', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String type, String label, Color color) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? color : Colors.grey[300]!, width: isSelected ? 0 : 1),
          boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Center(
          child: Text(label, style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600], 
            fontWeight: FontWeight.bold
          )),
        ),
      ),
    );
  }
}

// --- CLASS TAMBAHAN: FORMATTER MATA UANG (ALA BANK) ---
// Class ini bertugas mencegat ketikan Boss, lalu memberi titik otomatis
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Kalau kosong, biarkan kosong
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // 1. Hapus semua karakter aneh (selain angka)
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // 2. Ubah jadi angka integer
    int value = int.parse(newText);
    
    // 3. Format jadi Ribuan (Indonesian Locale)
    final formatter = NumberFormat.decimalPattern('id_ID');
    String newString = formatter.format(value);

    // 4. Kembalikan teks baru dengan kursor ada di paling kanan
    return newValue.copyWith(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}