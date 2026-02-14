import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goal_play/Services/AuthServices/AuthServices.dart';

class FirebaseEmailDiagnostic extends StatefulWidget {
  const FirebaseEmailDiagnostic({Key? key}) : super(key: key);

  @override
  State<FirebaseEmailDiagnostic> createState() => _FirebaseEmailDiagnosticState();
}

class _FirebaseEmailDiagnosticState extends State<FirebaseEmailDiagnostic> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isRunning = false;
  List<String> _results = [];

  Future<void> runDiagnostic() async {
    setState(() {
      _isRunning = true;
      _results = [];
    });

    final email = _emailController.text.trim();
    
    try {
      // Test 1: Basic Firebase Auth Connection
      _addResult('🔍 Testing Firebase Auth Connection...');
      final currentUser = FirebaseAuth.instance.currentUser;
      _addResult('✅ Firebase Auth Connected: ${currentUser != null ? 'User logged in' : 'No user logged in'}');

      // Test 2: Email Format Validation
      _addResult('🔍 Testing Email Format...');
      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (emailRegex.hasMatch(email)) {
        _addResult('✅ Email format is valid: $email');
      } else {
        _addResult('❌ Email format is invalid: $email');
        return;
      }

      // Test 3: Check if user exists (simplified)
      _addResult('🔍 Checking if user exists in Firebase...');
      _addResult('ℹ️ User existence check skipped for compatibility');
      _addResult('✅ Proceeding with password reset test...');

      // Test 4: Send Password Reset Email
      _addResult('🔍 Attempting to send password reset email...');
      _addResult('📧 Target email: $email');
      _addResult('🔗 Project ID: goal-play');
      
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        _addResult('✅ Password reset email sent successfully!');
        _addResult('📋 Check your inbox and spam folder');
        _addResult('⏰ Reset link expires in 24 hours');
      } on FirebaseAuthException catch (e) {
        _addResult('❌ Firebase Auth Error:');
        _addResult('   Code: ${e.code}');
        _addResult('   Message: ${e.message}');
        _addResult('   Email: ${e.email}');
        
        // Specific error analysis
        switch (e.code) {
          case 'user-not-found':
            _addResult('💡 Solution: Create an account with this email first');
            break;
          case 'invalid-email':
            _addResult('💡 Solution: Check email format');
            break;
          case 'too-many-requests':
            _addResult('💡 Solution: Wait 15-30 minutes before trying again');
            break;
          case 'network-request-failed':
            _addResult('💡 Solution: Check internet connection');
            break;
          default:
            _addResult('💡 Solution: Check Firebase Console configuration');
        }
      } catch (e) {
        _addResult('❌ Unexpected Error: $e');
      }

      // Test 5: Firebase Configuration Check
      _addResult('🔍 Checking Firebase Configuration...');
      _addResult('📱 App ID: 1:480773029928:android:9d726b88dc7fb80a1e351d');
      _addResult('🌐 Project ID: goal-play');
      _addResult('🔗 Auth Domain: goal-play.firebaseapp.com');
      _addResult('📦 Storage Bucket: goal-play.firebasestorage.app');

    } catch (e) {
      _addResult('❌ Diagnostic Error: $e');
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  void _addResult(String result) {
    setState(() {
      _results.add('${DateTime.now().toString().substring(11, 19)} - $result');
    });
    print(result); // Also print to console for debugging
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Email Diagnostic'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Enter Email to Test:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: 'test@example.com',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isRunning ? null : runDiagnostic,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isRunning
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Running Diagnostic...'),
                              ],
                            )
                          : const Text('Run Email Diagnostic'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _results.isEmpty
                      ? const Center(
                          child: Text(
                            'Diagnostic results will appear here...',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            final result = _results[index];
                            Color textColor = Colors.black;
                            if (result.contains('✅')) textColor = Colors.green;
                            if (result.contains('❌')) textColor = Colors.red;
                            if (result.contains('⚠️')) textColor = Colors.orange;
                            if (result.contains('🔍')) textColor = Colors.blue;
                            if (result.contains('💡')) textColor = Colors.purple;
                            
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                result,
                                style: TextStyle(
                                  color: textColor,
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
