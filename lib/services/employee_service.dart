import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmployeeService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _employeeCollection {
    final adminId = _auth.currentUser!.uid;
    return _firestore.collection('admins').doc(adminId).collection('employees');
  }

  //  إضافة موظف جديد
  Future<void> addEmployee({
    required String name,
    required String position,
    required double salary,
  }) async {
    await _employeeCollection.add({
      'name': name,
      'position': position,
      'salary': salary,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  //  جلب جميع الموظفين كـ Stream (تحديث لحظي)
  Stream<QuerySnapshot<Map<String, dynamic>>> getEmployeesStream() {
    return _employeeCollection
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  //  تحديث بيانات موظف
  Future<void> updateEmployee(
    String employeeId,
    Map<String, dynamic> data,
  ) async {
    await _employeeCollection.doc(employeeId).update(data);
  }

  //  حذف موظف مع جميع الـ payrolls التابعة له
  Future<void> deleteEmployee(String employeeId) async {
    final empRef = _employeeCollection.doc(employeeId);
    final payrollsRef = empRef.collection('payrolls');

    //  جلب جميع سجلات الرواتب
    final payrollsSnapshot = await payrollsRef.get();

    //  حذف جميع الـ payrolls واحدة واحدة
    for (var doc in payrollsSnapshot.docs) {
      await doc.reference.delete();
    }

    //  بعد حذف الرواتب → حذف الموظف نفسه
    await empRef.delete();
  }

  //  إضافة راتب لموظف (داخل Subcollection payrolls)
  Future<void> addPayroll({
    required String employeeId,
    required String month,
    required double baseSalary,
    double bonuses = 0,
    double deductions = 0,
  }) async {
    final total = baseSalary + bonuses - deductions;

    await _employeeCollection.doc(employeeId).collection('payrolls').add({
      'month': month,
      'baseSalary': baseSalary,
      'bonuses': bonuses,
      'deductions': deductions,
      'total': total,
      'dateCreated': FieldValue.serverTimestamp(),
    });
  }

  //  جلب جميع الرواتب لموظف معين (تحديث لحظي)
  Stream<QuerySnapshot<Map<String, dynamic>>> getPayrollsStream(
    String employeeId,
  ) {
    return _employeeCollection
        .doc(employeeId)
        .collection('payrolls')
        .orderBy('dateCreated', descending: true)
        .snapshots();
  }
}
