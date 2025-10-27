import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIChatService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _apiKey = dotenv.env['GEMINI_API_KEY'];

  Future<String> getResponse(String query) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      return '⚠️ Missing API Key. Please check your .env file.';
    }

    try {
      final user = _auth.currentUser;
      if (user == null) return "⚠️ No admin is logged in.";

      final adminId = user.uid;

      //  جلب بيانات الموظفين الخاصين بالادمن الي مسجل دخول فقط
      final employeesSnapshot = await _firestore
          .collection('admins')
          .doc(adminId)
          .collection('employees')
          .get();

      //  نحول بيانات Firestore لتكون JSON-safe (نتجنب Timestamp)
      final employeesList = employeesSnapshot.docs.map((e) {
        final data = e.data();

        // نحول أي Timestamp لتاريخ نصي
        final safeData = data.map((key, value) {
          if (value is Timestamp) {
            return MapEntry(key, value.toDate().toIso8601String());
          }
          return MapEntry(key, value);
        });

        return {'id': e.id, ...safeData};
      }).toList();

      //  إعداد نموذج Gemini
      final model = GenerativeModel(
        model: 'models/gemini-2.5-pro',
        apiKey: _apiKey!,
      );

      //  إعداد الـ prompt الذي سيرسله إلى الذكاء الاصطناعي
      final prompt =
          '''
You are an intelligent HR assistant for an admin.
The admin can ask or instruct you to:
- "Add employee named Ali with salary 600"
- "Update Ahmed's salary to 750"
- "Delete employee called Sara"
- "List all employees with their salaries"
- "Who has the highest salary?"

You must return a **valid JSON** in this exact format:
{
  "action": "add_employee" | "edit_employee" | "delete_employee" | "query_info",
  "employee_name": "Name if applicable",
  "fields": {"salary": 500, "position": "cashier"},
  "answer": "Human readable reply"
}

Here is the admin’s employee data:
${jsonEncode(employeesList)}

Now interpret this user query:
"$query"
''';

      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text ?? "⚠️ No response from model.";
      print("🤖 Gemini raw output:\n$text");

      //  نحاول تحليل الرد كـ JSON
      final json = _tryParseJson(text);
      if (json == null) return text;

      final action = json['action']?.toString();
      final name = json['employee_name']?.toString().trim();
      final fields = Map<String, dynamic>.from(json['fields'] ?? {});
      final answer = json['answer']?.toString() ?? '';

      final employeesRef = _firestore
          .collection('admins')
          .doc(adminId)
          .collection('employees');

      //  إضافة موظف جديد
      if (action == "add_employee" && name != null && name.isNotEmpty) {
        await employeesRef.add({
          "name": name,
          ...fields,
          "createdAt": FieldValue.serverTimestamp(),
        });
        return "✅ Added new employee '$name'.\n\n$answer";
      }

      //  تعديل بيانات موظف
      if (action == "edit_employee" && name != null && name.isNotEmpty) {
        QueryDocumentSnapshot<Map<String, dynamic>>? target;
        for (var doc in employeesSnapshot.docs) {
          final docName = doc.data()['name']?.toString().toLowerCase();
          if (docName == name.toLowerCase()) {
            target = doc;
            break;
          }
        }

        if (target == null) {
          return "⚠️ Employee '$name' not found.";
        }

        await target.reference.update(fields);
        return "✅ Updated '$name'.\n\n$answer";
      }

      //  حذف موظف
      if (action == "delete_employee" && name != null && name.isNotEmpty) {
        QueryDocumentSnapshot<Map<String, dynamic>>? target;
        for (var doc in employeesSnapshot.docs) {
          final docName = doc.data()['name']?.toString().toLowerCase();
          if (docName == name.toLowerCase()) {
            target = doc;
            break;
          }
        }

        if (target == null) {
          return "⚠️ Employee '$name' not found.";
        }

        await target.reference.delete();
        return "🗑️ Deleted employee '$name'.\n\n$answer";
      }

      //  استعلام فقط (كم عدد الموظفين؟ أعلى راتب؟)
      return answer.isNotEmpty ? answer : "✅ Done.";
    } catch (e, s) {
      print("🔥 ERROR: $e\n$s");
      return "⚠️ Error: $e";
    }
  }

  //  دالة لتحليل JSON من رد الذكاء الاصطناعي
  Map<String, dynamic>? _tryParseJson(String text) {
    try {
      final cleaned = text
          .trim()
          .replaceAll("```json", "")
          .replaceAll("```", "")
          .replaceAll("\n", " ")
          .trim();
      return jsonDecode(cleaned);
    } catch (e) {
      print("❌ JSON parse error: $e");
      return null;
    }
  }
}
