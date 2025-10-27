import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/employee_provider.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final String employeeId;
  final Map<String, dynamic> employeeData;

  const EmployeeDetailScreen({
    super.key,
    required this.employeeId,
    required this.employeeData,
  });

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  late TextEditingController _nameController;
  late TextEditingController _positionController;
  late TextEditingController _salaryController;
  bool _editing = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.employeeData['name']);
    _positionController = TextEditingController(
      text: widget.employeeData['position'],
    );
    _salaryController = TextEditingController(
      text: widget.employeeData['salary'].toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final employeeProvider = Provider.of<EmployeeProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFE9EEF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE9EEF5),
        elevation: 0,
        title: Text(
          _editing
              ? "Edit Employee"
              : widget.employeeData['name'] ?? "Employee Details",
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: Icon(
              _editing ? Icons.close : Icons.edit,
              color: Colors.blueGrey.shade700,
            ),
            onPressed: () => setState(() => _editing = !_editing),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () async {
              final confirm = await showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Delete Employee"),
                  content: const Text(
                    "Are you sure you want to delete this employee?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                setState(() => _loading = true);
                try {
                  await employeeProvider.deleteEmployee(widget.employeeId);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Employee deleted successfully"),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    Navigator.pop(context);
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error deleting: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                setState(() => _loading = false);
              }
            },
          ),
        ],
      ),

      floatingActionButton: !_editing
          ? FloatingActionButton.extended(
              backgroundColor: Colors.teal.shade600,
              icon: const Icon(Icons.add),
              label: const Text("Add Payroll"),
              onPressed: () => _showAddPayrollDialog(context, employeeProvider),
            )
          : null,

      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blueGrey),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildField(
                    "Name",
                    _nameController,
                    Icons.person,
                    editable: _editing,
                  ),
                  const SizedBox(height: 20),
                  _buildField(
                    "Position",
                    _positionController,
                    Icons.work,
                    editable: _editing,
                  ),
                  const SizedBox(height: 20),
                  _buildField(
                    "Salary",
                    _salaryController,
                    Icons.attach_money,
                    editable: _editing,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 40),
                  if (_editing)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A5298),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text(
                        "Save Changes",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        setState(() => _loading = true);
                        try {
                          await employeeProvider
                              .updateEmployee(widget.employeeId, {
                                'name': _nameController.text.trim(),
                                'position': _positionController.text.trim(),
                                'salary':
                                    double.tryParse(
                                      _salaryController.text.trim(),
                                    ) ??
                                    0,
                              });
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Employee updated successfully"),
                                backgroundColor: Colors.green,
                              ),
                            );
                            setState(() => _editing = false);
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error updating: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                        setState(() => _loading = false);
                      },
                    ),
                ],
              ),
            ),
    );
  }

  //  نموذج إدخال الراتب
  Future<void> _showAddPayrollDialog(
    BuildContext context,
    EmployeeProvider provider,
  ) async {
    final formKey = GlobalKey<FormState>();
    final monthController = TextEditingController();
    final baseController = TextEditingController();
    final bonusController = TextEditingController();
    final deductController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("Add Payroll"),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _formField("Month", monthController),
                _formField("Base Salary", baseController, isNumber: true),
                _formField("Bonuses", bonusController, isNumber: true),
                _formField("Deductions", deductController, isNumber: true),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await provider.addPayroll(
                  widget.employeeId,
                  monthController.text.trim(),
                  double.tryParse(baseController.text) ?? 0,
                  double.tryParse(bonusController.text) ?? 0,
                  double.tryParse(deductController.text) ?? 0,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Payroll added successfully"),
                      backgroundColor: Colors.teal,
                    ),
                  );
                  Navigator.pop(ctx);
                }
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Widget _formField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (val) => val == null || val.isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool editable = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(4, 4),
            blurRadius: 8,
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-4, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        enabled: editable,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueGrey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 14,
          ),
        ),
      ),
    );
  }
}
