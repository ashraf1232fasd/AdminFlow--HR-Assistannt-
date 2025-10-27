import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _firestore.collection('admins').doc(userCredential.user!.uid).set({
      'name': name,
      'email': email,
      'createdAt': DateTime.now(),
    });
  }

  // 🔹 تسجيل الدخول
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // 🔹 تسجيل الخروج
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 🔹 المستخدم الحالي
  User? get currentUser => _auth.currentUser;
}
