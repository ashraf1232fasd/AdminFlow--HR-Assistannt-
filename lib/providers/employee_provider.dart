import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/employee_service.dart';

class EmployeeProvider with ChangeNotifier {
  final EmployeeService _service = EmployeeService();

  Stream<QuerySnapshot<Map<String, dynamic>>> getEmployees() {
    return _service.getEmployeesStream();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getPayrolls(String empId) {
    return _service.getPayrollsStream(empId);
  }

  Future<void> addEmployee(String name, String position, double salary) async {
    await _service.addEmployee(name: name, position: position, salary: salary);
  }

  Future<void> addPayroll(String empId, String month, double base, double bonus, double ded) async {
    await _service.addPayroll(
      employeeId: empId,
      month: month,
      baseSalary: base,
      bonuses: bonus,
      deductions: ded,
    );
  }

  Future<void> deleteEmployee(String empId) async {
    await _service.deleteEmployee(empId);
  }

  Future<void> updateEmployee(String empId, Map<String, dynamic> data) async {
    await _service.updateEmployee(empId, data);
  }
}
