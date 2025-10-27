import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool _loading = true;
  int totalEmployees = 0;
  double totalPayroll = 0;
  double highestSalary = 0;
  String topEmployee = "";

  @override
  void initState() {
    super.initState();
    _generateReport();
  }

  Future<void> _generateReport() async {
    final adminId = _auth.currentUser!.uid;
    final employeesRef = _firestore
        .collection('admins')
        .doc(adminId)
        .collection('employees');
    final employeesSnapshot = await employeesRef.get();

    double payrollSum = 0;
    double highest = 0;
    String top = "";

    for (var emp in employeesSnapshot.docs) {
      final data = emp.data();
      final salary = (data['salary'] as num?)?.toDouble() ?? 0;
      payrollSum += salary;
      if (salary > highest) {
        highest = salary;
        top = data['name'] ?? "Unknown";
      }
    }

    setState(() {
      totalEmployees = employeesSnapshot.size;
      totalPayroll = payrollSum;
      highestSalary = highest;
      topEmployee = top;
      _loading = false;
    });
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
          "Reports Overview",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blueGrey),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _reportTile(
                    Icons.people,
                    "Total Employees",
                    "$totalEmployees",
                    Colors.indigo,
                  ),
                  _reportTile(
                    Icons.attach_money,
                    "Total Payroll",
                    "${totalPayroll.toStringAsFixed(2)} JD",
                    Colors.teal,
                  ),
                  _reportTile(
                    Icons.star,
                    "Highest Salary",
                    "${highestSalary.toStringAsFixed(2)} JD ($topEmployee)",
                    Colors.orangeAccent,
                  ),
                  const SizedBox(height: 28),
                  _chartsSection(),
                ],
              ),
            ),
    );
  }

  Widget _chartsSection() {
    if (totalEmployees == 0 || totalPayroll == 0) {
      return Text(
        "No data to display charts.",
        style: GoogleFonts.poppins(color: Colors.blueGrey.shade600),
      );
    }

    final remaining = totalPayroll - highestSalary;
    final percent = (highestSalary / totalPayroll) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Visual Summary",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.blueGrey.shade900,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _chartCard(
                title: "Salary Distribution",
                chart: PieChart(
                  PieChartData(
                    centerSpaceRadius: 26,
                    sectionsSpace: 1.5,
                    sections: [
                      PieChartSectionData(
                        color: Colors.orangeAccent,
                        value: highestSalary,
                        title: "${percent.toStringAsFixed(1)}%",
                        radius: 34,
                        titleStyle: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      PieChartSectionData(
                        color: Colors.teal.shade400,
                        value: remaining,
                        title: "",
                        radius: 30,
                      ),
                    ],
                  ),
                ),
                legendItems: const [
                  _LegendItem(color: Colors.orangeAccent, label: "Top Salary"),
                  _LegendItem(color: Colors.teal, label: "Others"),
                ],
                footer:
                    "Top earner: $topEmployee (${percent.toStringAsFixed(1)}%)",
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _chartCard(
                title: "Employees vs Payroll",
                chart: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (totalPayroll / 1000).ceilToDouble() + 1,
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 26,
                          getTitlesWidget: (v, _) {
                            final labels = ["Employees", "Payroll"];
                            return Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                labels[v.toInt()],
                                style: GoogleFonts.poppins(
                                  color: Colors.blueGrey.shade700,
                                  fontSize: 11,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(
                            toY: totalEmployees.toDouble(),
                            color: Colors.indigo,
                            width: 14,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: totalPayroll / 1000,
                            color: Colors.teal,
                            width: 14,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                legendItems: const [
                  _LegendItem(color: Colors.indigo, label: "Employees"),
                  _LegendItem(color: Colors.teal, label: "Payroll (k JD)"),
                ],
                footer: "Comparison between staff count and total payroll.",
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _chartCard({
    required String title,
    required Widget chart,
    required String footer,
    required List<_LegendItem> legendItems,
  }) {
    return Container(
      height: 220,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300.withOpacity(0.6),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-2, -2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.blueGrey.shade900,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Center(child: SizedBox(height: 85, child: chart)),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 4,
            children: legendItems,
          ),
          const SizedBox(height: 6),
          Text(
            footer,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.blueGrey.shade700,
              fontSize: 11.2,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportTile(IconData icon, String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300.withOpacity(0.6),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-2, -2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey.shade900,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10.8,
            color: Colors.blueGrey.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
