import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:math' show min;

// Model class for ledger entry
class LedgerEntry {
  String? groupName;
  String? ledgerName;
  double? openingBalance;
  String? drCr;
  List<BillEntry> bills = [];
  String? address;
  String? state;
  String? country;
  String? pincode;

  Map<String, dynamic> toJson() {
    return {
      'groupName': groupName,
      'ledgerName': ledgerName,
      'openingBalance': openingBalance,
      'drCr': drCr,
      'bills': bills.map((bill) => bill.toJson()).toList(),
      'address': address,
      'state': state,
      'country': country,
      'pincode': pincode,
      'createdAt': FieldValue.serverTimestamp(), // Add timestamp for sorting
    };
  }
}

// Model class for bill entry
class BillEntry {
  DateTime? date;
  String? billName;
  double? amount;
  String? drCr;

  Map<String, dynamic> toJson() {
    return {
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'billName': billName,
      'amount': amount,
      'drCr': drCr,
    };
  }
}

class ExcelImportScreen extends StatefulWidget {
  const ExcelImportScreen({super.key});

  @override
  State<ExcelImportScreen> createState() => _ExcelImportScreenState();
}

class _ExcelImportScreenState extends State<ExcelImportScreen> {
  bool _isLoading = false;
  String _status = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> importExcelToFirestore() async {
    try {
      setState(() {
        _isLoading = true;
        _status = 'Selecting file...';
      });

      // Step 1: Pick an Excel file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null) {
        setState(() => _status = 'Reading file...');

        // Step 2: Read the Excel file
        var file = File(result.files.single.path!);
        var bytes = file.readAsBytesSync();
        var excel = Excel.decodeBytes(bytes);

        // Step 3: Create a batch for efficient writes
        var batch = _firestore.batch();

        // Step 4: Process the data
        setState(() => _status = 'Processing data...');

        Map<String, LedgerEntry> ledgerEntries = {};

        for (var table in excel.tables.keys) {
          var rows = excel.tables[table]!.rows;

          // Skip header row
          for (int i = 1; i < rows.length; i++) {
            var row = rows[i];

            // Check if row has enough cells
            if (row.isEmpty) continue;

            // Extract basic ledger information
            String groupName = row[0]?.value?.toString() ?? '';
            String ledgerName = row[1]?.value?.toString() ?? '';

            // Skip empty rows
            if (groupName.isEmpty && ledgerName.isEmpty) continue;

            // Create or get existing ledger entry
            if (!ledgerEntries.containsKey(ledgerName)) {
              var entry = LedgerEntry()
                ..groupName = groupName
                ..ledgerName = ledgerName;

              // Safely parse opening balance
              if (row.length > 2 && row[2]?.value != null) {
                String balanceStr = row[2]?.value.toString().replaceAll(',', '') ?? '0';
                entry.openingBalance = double.tryParse(balanceStr);
              }

              // Safely get Dr/Cr
              entry.drCr = row.length > 3 ? row[3]?.value?.toString() : null;

              // Safely get address information
              var addressParts = <String>[];

              // Collect address parts from available cells
              for (var j = 8; j < min(row.length, 11); j++) {
                var cellValue = row[j]?.value;
                if (cellValue != null) {
                  addressParts.add(cellValue.toString());
                }
              }

              entry.address = addressParts.join(', ');

              // Set state, country if available
              if (row.length > 7) {
                entry.state = row[7]?.value?.toString();
              }
              if (row.length > 8) {
                entry.country = row[8]?.value?.toString();
              }

              ledgerEntries[ledgerName] = entry;
            }

            // Process bill information if present
            if (row.length > 4 && row[4]?.value != null) {
              var bill = BillEntry()
                ..date = _parseDate(row[4]?.value?.toString() ?? '')
                ..billName = row.length > 5 ? row[5]?.value?.toString() : null
                ..amount = row.length > 6 ?
                double.tryParse(row[6]?.value?.toString().replaceAll(',', '') ?? '0') : null
                ..drCr = row.length > 7 ? row[7]?.value?.toString() : null;

              ledgerEntries[ledgerName]?.bills.add(bill);
            }
          }
        }

        // Step 5: Upload to Firestore
        setState(() => _status = 'Uploading to Firestore...');

        // Create a new collection for this import with timestamp
        String collectionName = 'ledger_entries_${DateTime.now().millisecondsSinceEpoch}';

        for (var entry in ledgerEntries.values) {
          if (entry.ledgerName != null && entry.ledgerName!.isNotEmpty) {
            // Create a document reference with a unique ID
            var docRef = _firestore.collection(collectionName).doc();
            batch.set(docRef, entry.toJson());
          }
        }

        // Commit the batch
        await batch.commit();

        setState(() => _status = 'Import completed successfully!\nCollection: $collectionName');
      } else {
        setState(() => _status = 'No file selected.');
      }
    } catch (e) {
      debugPrint(e.toString());
      setState(() => _status = 'Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  DateTime? _parseDate(String dateStr) {
    try {
      // Assuming date format is dd/MMM/yyyy
      var parts = dateStr.split('/');
      if (parts.length == 3) {
        var months = {
          'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
          'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
        };
        return DateTime(
            int.parse(parts[2]),
            months[parts[1]] ?? 1,
            int.parse(parts[0])
        );
      }
    } catch (e) {
      debugPrint('Date parsing error: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Excel to Firestore Import'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              const SizedBox(height: 20),
              Text(
                _status,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : importExcelToFirestore,
                child: const Text('Import Excel to Firestore'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}