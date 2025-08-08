import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseDebugService {
  static final FirebaseDebugService _instance = FirebaseDebugService._internal();
  factory FirebaseDebugService() => _instance;
  FirebaseDebugService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Kiểm tra trạng thái Firebase
  Future<Map<String, dynamic>> checkFirebaseStatus() async {
    Map<String, dynamic> status = {
      'firebase_initialized': false,
      'auth_status': 'unknown',
      'firestore_accessible': false,
      'current_user': null,
      'google_sign_in_status': 'unknown',
      'errors': [],
    };

    try {
      // Kiểm tra Firebase Auth
      print('=== FIREBASE DEBUG START ===');
      
      // Kiểm tra Firebase Auth initialization
      try {
        final User? currentUser = _auth.currentUser;
        status['auth_status'] = currentUser != null ? 'authenticated' : 'not_authenticated';
        status['current_user'] = currentUser?.uid;
        print('Firebase Auth Status: ${status['auth_status']}');
        print('Current User UID: ${currentUser?.uid}');
        print('Current User Email: ${currentUser?.email}');
        print('Current User Display Name: ${currentUser?.displayName}');
      } catch (e) {
        status['auth_status'] = 'error';
        status['errors'].add('Firebase Auth Error: $e');
        print('Firebase Auth Error: $e');
      }

      // Kiểm tra Google Sign-In
      try {
        final bool isSignedIn = await _googleSignIn.isSignedIn();
        status['google_sign_in_status'] = isSignedIn ? 'signed_in' : 'not_signed_in';
        print('Google Sign-In Status: ${status['google_sign_in_status']}');
        
        if (isSignedIn) {
          final GoogleSignInAccount? account = _googleSignIn.currentUser;
          print('Google Account: ${account?.email}');
          print('Google Account ID: ${account?.id}');
        }
      } catch (e) {
        status['google_sign_in_status'] = 'error';
        status['errors'].add('Google Sign-In Error: $e');
        print('Google Sign-In Error: $e');
      }

      // Kiểm tra Firestore
      try {
        // Thử đọc một document test
        final testDoc = await _firestore.collection('test').doc('connection_test').get();
        status['firestore_accessible'] = true;
        print('Firestore is accessible');
      } catch (e) {
        status['firestore_accessible'] = false;
        status['errors'].add('Firestore Error: $e');
        print('Firestore Error: $e');
      }

      status['firebase_initialized'] = true;
      print('=== FIREBASE DEBUG END ===');
      
    } catch (e) {
      status['errors'].add('General Error: $e');
      print('General Firebase Debug Error: $e');
    }

    return status;
  }

  /// Test upload lên Firestore
  Future<bool> testFirestoreUpload() async {
    try {
      print('=== TESTING FIRESTORE UPLOAD ===');
      
      // Kiểm tra user hiện tại
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('No authenticated user found!');
        return false;
      }

      print('Using User UID: ${currentUser.uid}');
      print('User Email: ${currentUser.email}');

      // Tạo test document
      final testData = {
        'test_field': 'test_value',
        'timestamp': FieldValue.serverTimestamp(),
        'user_id': currentUser.uid,
        'email': currentUser.email,
        'display_name': currentUser.displayName,
      };

      // Thử upload vào collection test
      await _firestore.collection('test').doc(currentUser.uid).set(testData);
      print('Test upload successful to /test/${currentUser.uid}');

      // Thử upload vào users collection
      await _firestore.collection('users').doc(currentUser.uid).set({
        'test_profile': {
          'displayName': currentUser.displayName,
          'email': currentUser.email,
          'uid': currentUser.uid,
          'test_timestamp': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));
      
      print('Test upload successful to /users/${currentUser.uid}');
      print('=== FIRESTORE UPLOAD TEST COMPLETED ===');
      
      return true;
    } catch (e) {
      print('Firestore Upload Test Failed: $e');
      return false;
    }
  }

  /// Kiểm tra quyền truy cập Firestore
  Future<bool> checkFirestorePermissions() async {
    try {
      print('=== CHECKING FIRESTORE PERMISSIONS ===');
      
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('No authenticated user for permission check');
        return false;
      }

      // Thử đọc user document
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      print('Can read user document: ${userDoc.exists}');

      // Thử ghi user document
      await _firestore.collection('users').doc(currentUser.uid).set({
        'permission_test': {
          'timestamp': FieldValue.serverTimestamp(),
          'test': true,
        },
      }, SetOptions(merge: true));
      print('Can write to user document: true');

      // Thử tạo subcollection
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('test_subcollection')
          .doc('test')
          .set({
        'test': true,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Can create subcollection: true');

      print('=== FIRESTORE PERMISSIONS CHECK COMPLETED ===');
      return true;
    } catch (e) {
      print('Firestore Permissions Check Failed: $e');
      return false;
    }
  }

  /// Xóa test data
  Future<void> cleanupTestData() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Xóa test document
        await _firestore.collection('test').doc(currentUser.uid).delete();
        
        // Xóa test data trong user document
        await _firestore.collection('users').doc(currentUser.uid).update({
          'test_profile': FieldValue.delete(),
          'permission_test': FieldValue.delete(),
        });
        
        // Xóa test subcollection
        final testDocs = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('test_subcollection')
            .get();
        
        for (final doc in testDocs.docs) {
          await doc.reference.delete();
        }
        
        print('Test data cleaned up successfully');
      }
    } catch (e) {
      print('Cleanup error: $e');
    }
  }
} 