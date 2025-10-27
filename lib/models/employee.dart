class Employee {
  String id;
  String name;
  String position;
  double salary;

  Employee({
    required this.id,
    required this.name,
    required this.position,
    required this.salary,
  });

  // تحويل من Firestore إلى اوبجيكت
  factory Employee.fromMap(Map<String, dynamic> data, String documentId) {
    return Employee(
      id: documentId,
      name: data['name'] ?? '',
      position: data['position'] ?? '',
      salary: (data['salary'] ?? 0).toDouble(),
    );
  }

  // تحويل إلى Map لتخزينه في Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'position': position,
      'salary': salary,
    };
  }
}
