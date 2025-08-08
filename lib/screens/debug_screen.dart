import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/google_play_games_service.dart';
import '../services/firebase_debug_service.dart';
import '../services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  final FirebaseDebugService _debugService = FirebaseDebugService();
  final UserService _userService = UserService();
  
  Map<String, dynamic> _firebaseStatus = {};
  bool _isLoading = false;
  String _testResult = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkFirebaseStatus();
  }

  Future<void> _checkFirebaseStatus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final status = await _debugService.checkFirebaseStatus();
      setState(() {
        _firebaseStatus = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error checking Firebase status: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testFirestoreUpload() async {
    setState(() {
      _isLoading = true;
      _testResult = '';
      _errorMessage = '';
    });

    try {
      final success = await _debugService.testFirestoreUpload();
      setState(() {
        _testResult = success ? 'Upload test successful!' : 'Upload test failed!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error testing upload: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _testResult = '';
      _errorMessage = '';
    });

    try {
      final googleService = Provider.of<GooglePlayGamesService>(context, listen: false);
      final success = await googleService.signIn();
      
      if (success) {
        setState(() {
          _testResult = 'Google Sign-In successful!';
          _isLoading = false;
        });
        // Refresh Firebase status
        await _checkFirebaseStatus();
      } else {
        setState(() {
          _testResult = 'Google Sign-In failed!';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error testing Google Sign-In: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _checkPermissions() async {
    setState(() {
      _isLoading = true;
      _testResult = '';
      _errorMessage = '';
    });

    try {
      final success = await _debugService.checkFirestorePermissions();
      setState(() {
        _testResult = success ? 'Permissions check successful!' : 'Permissions check failed!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error checking permissions: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _cleanupTestData() async {
    setState(() {
      _isLoading = true;
      _testResult = '';
      _errorMessage = '';
    });

    try {
      await _debugService.cleanupTestData();
      setState(() {
        _testResult = 'Test data cleaned up successfully!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error cleaning up test data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Debug'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Firebase Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Firebase Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else ...[
                      _buildStatusItem('Firebase Initialized', _firebaseStatus['firebase_initialized']),
                      _buildStatusItem('Auth Status', _firebaseStatus['auth_status']),
                      _buildStatusItem('Firestore Accessible', _firebaseStatus['firestore_accessible']),
                      _buildStatusItem('Google Sign-In Status', _firebaseStatus['google_sign_in_status']),
                      if (_firebaseStatus['current_user'] != null)
                        _buildStatusItem('Current User', _firebaseStatus['current_user']),
                      if (_firebaseStatus['errors'].isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Errors:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        ...(_firebaseStatus['errors'] as List).map((error) => 
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Text(
                              '• $error',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Test Buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Debug Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    ElevatedButton(
                      onPressed: _isLoading ? null : _checkFirebaseStatus,
                      child: const Text('Refresh Firebase Status'),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    ElevatedButton(
                      onPressed: _isLoading ? null : _testGoogleSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Test Google Sign-In'),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    ElevatedButton(
                      onPressed: _isLoading ? null : _testFirestoreUpload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Test Firestore Upload'),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    ElevatedButton(
                      onPressed: _isLoading ? null : _checkPermissions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Check Firestore Permissions'),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    ElevatedButton(
                      onPressed: _isLoading ? null : _cleanupTestData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Cleanup Test Data'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Results
            if (_testResult.isNotEmpty || _errorMessage.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Test Results',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_testResult.isNotEmpty)
                        Text(
                          _testResult,
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (_errorMessage.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Current User Info
            Consumer<GooglePlayGamesService>(
              builder: (context, googleService, child) {
                final currentUser = FirebaseAuth.instance.currentUser;
                final googleUser = googleService.currentUser;
                
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current User Info',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (currentUser != null) ...[
                          _buildInfoItem('Firebase UID', currentUser.uid),
                          _buildInfoItem('Firebase Email', currentUser.email ?? 'N/A'),
                          _buildInfoItem('Firebase Display Name', currentUser.displayName ?? 'N/A'),
                          _buildInfoItem('Firebase Email Verified', currentUser.emailVerified.toString()),
                        ] else
                          const Text('No Firebase user authenticated'),
                        
                        const SizedBox(height: 8),
                        
                        if (googleUser != null) ...[
                          _buildInfoItem('Google ID', googleUser.id),
                          _buildInfoItem('Google Email', googleUser.email),
                          _buildInfoItem('Google Display Name', googleUser.displayName ?? 'N/A'),
                        ] else
                          const Text('No Google user signed in'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, dynamic value) {
    Color color = Colors.black;
    if (value == true) color = Colors.green;
    if (value == false) color = Colors.red;
    if (value == 'error') color = Colors.red;
    if (value == 'authenticated') color = Colors.green;
    if (value == 'not_authenticated') color = Colors.orange;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text('$label: '),
          Text(
            value?.toString() ?? 'N/A',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text('$label: '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
} 