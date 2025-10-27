import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  late Stream<List<Map<String, dynamic>>> payrollStream;

  @override
  void initState() {
    super.initState();
    payrollStream = _getAllPayrollsStream();
  }

  Stream<List<Map<String, dynamic>>> _getAllPayrollsStream() async* {
    final adminId = _auth.currentUser!.uid;
    final employeesRef = _firestore
        .collection('admins')
        .doc(adminId)
        .collection('employees');

    await for (final employeesSnapshot in employeesRef.snapshots()) {
      List<Map<String, dynamic>> allPayrolls = [];

      for (var emp in employeesSnapshot.docs) {
        final empName = emp.data()['name'] ?? "Unnamed";
        final payrollRef = emp.reference.collection('payrolls');
        final payrollSnapshot = await payrollRef.get();

        for (var p in payrollSnapshot.docs) {
          final data = p.data();
          allPayrolls.add({
            'employeeName': empName,
            'month': data['month'] ?? '—',
            'total': data['total'] ?? 0.0,
            'bonuses': data['bonuses'] ?? 0.0,
            'deductions': data['deductions'] ?? 0.0,
            'dateCreated': (data['dateCreated'] as Timestamp?)?.toDate(),
          });
        }
      }

      allPayrolls.sort((a, b) {
        final da = a['dateCreated'] ?? DateTime.now();
        final db = b['dateCreated'] ?? DateTime.now();
        return db.compareTo(da);
      });

      yield allPayrolls;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFedf2fb),
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade900,
        elevation: 4,
        centerTitle: true,
        title: Text(
          "Payroll Overview",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: payrollStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blueGrey),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: GoogleFonts.poppins(color: Colors.redAccent),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No payroll records found.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.blueGrey.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          final payrolls = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: payrolls.length,
            itemBuilder: (context, i) {
              final p = payrolls[i];
              final date = p['dateCreated'] != null
                  ? "${p['dateCreated'].day}/${p['dateCreated'].month}/${p['dateCreated'].year}"
                  : "";

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300.withOpacity(0.6),
                      blurRadius: 8,
                      offset: const Offset(3, 3),
                    ),
                    const BoxShadow(
                      color: Colors.white,
                      offset: Offset(-3, -3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.payments_rounded,
                      color: Colors.teal,
                      size: 26,
                    ),
                  ),
                  title: Text(
                    "${p['employeeName']} — ${p['month']}",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey.shade900,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      "Bonuses: ${p['bonuses']}  |  Deductions: ${p['deductions']}\n$date",
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        color: Colors.blueGrey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade900.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${p['total']} JD",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        color: Colors.blueGrey.shade900,
                        fontSize: 15.5,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
