/// @file lib/data/datasources/firebase_datasource.dart
/// @brief Firebase data source implementing Firestore database operations
/// @author Chatly Development Team
/// @date 2025-12-08
///
/// This file implements the FirebaseDatasource class that handles all Firestore
/// database operations for the Chatly application. It provides CRUD operations
/// for user profiles, messages, chats, and other application data with proper
/// error handling and security considerations.

import 'package:chatly/core/errors/exceptions.dart';
import 'package:chatly/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Get user document by UID
  Future<DocumentSnapshot> getUserDocument(String uid) async {
    try {
      return await _firestore.collection('users').doc(uid).get();
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'get user document');
    } catch (e) {
      throw DatabaseException('Failed to get user document: ${e.toString()}');
    }
  }
  
  /// Create user document
  Future<void> createUserDocument(UserModel userModel) async {
    try {
      await _firestore.collection('users').doc(userModel.uid).set(
        userModel.toFirestore(),
        SetOptions(merge: true),
      );
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'create user document');
    } catch (e) {
      throw DatabaseException('Failed to create user document: ${e.toString()}');
    }
  }
  
  /// Update user document
  Future<void> updateUserDocument(UserModel updatedProfile) async {
    try {
      await _firestore.collection('users').doc(updatedProfile.uid).update(
        updatedProfile.toFirestore(),
      );
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'update user document');
    } catch (e) {
      throw DatabaseException('Failed to update user document: ${e.toString()}');
    }
  }
  
  /// Set username for user
  Future<void> setUsername(String uid, String username) async {
    try {
      // Check if username exists first
      final usernameQuery = await _firestore
          .collection('usernames')
          .doc(username.toLowerCase())
          .get();
      
      if (usernameQuery.exists) {
        final existingUid = usernameQuery.data()?['uid'];
        if (existingUid != uid) {
          throw ChatlyException('Username already taken');
        }
      }
      
      // Update user document
      await _firestore.collection('users').doc(uid).update({
        'username': username,
      });
      
      // Update username mapping
      await _firestore.collection('usernames').doc(username.toLowerCase()).set({
        'uid': uid,
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'set username');
    } catch (e) {
      throw DatabaseException('Failed to set username: ${e.toString()}');
    }
  }
  
  /// Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final usernameDoc = await _firestore
          .collection('usernames')
          .doc(username.toLowerCase())
          .get();
      
      return !usernameDoc.exists;
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'check username availability');
    } catch (e) {
      throw DatabaseException('Failed to check username availability: ${e.toString()}');
    }
  }
  
  /// Update last seen timestamp
  Future<void> updateLastSeen(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      // Don't throw exception for this operation - it's not critical
      if (FirebaseCore.instance.options.logLevel == Level.debug) {
        print('Warning: Failed to update last seen: ${e.toString()}');
      }
    } catch (e) {
      if (FirebaseCore.instance.options.logLevel == Level.debug) {
        print('Warning: Failed to update last seen: ${e.toString()}');
      }
    }
  }
  
  /// Delete user document
  Future<void> deleteUserDocument(String uid) async {
    try {
      final batch = _firestore.batch();
      
      // Delete user document
      batch.delete(_firestore.collection('users').doc(uid));
      
      // Delete user's username mapping
      final userDoc = await getUserDocument(uid);
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final username = userData['username'] as String?;
        if (username != null) {
          batch.delete(_firestore.collection('usernames').doc(username.toLowerCase()));
        }
      }
      
      // TODO: Delete user's messages, chats, and other related data
      
      await batch.commit();
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'delete user document');
    } catch (e) {
      throw DatabaseException('Failed to delete user document: ${e.toString()}');
    }
  }
  
  /// Get user by username
  Future<UserModel?> getUserByUsername(String username) async {
    try {
      final usernameDoc = await _firestore
          .collection('usernames')
          .doc(username.toLowerCase())
          .get();
      
      if (!usernameDoc.exists) return null;
      
      final userData = usernameDoc.data() as Map<String, dynamic>;
      final uid = userData['uid'] as String;
      
      final userDoc = await getUserDocument(uid);
      if (!userDoc.exists) return null;
      
      return UserModel.fromFirestore(userDoc);
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'get user by username');
    } catch (e) {
      throw DatabaseException('Failed to get user by username: ${e.toString()}');
    }
  }
  
  /// Handle Firebase exceptions and convert to meaningful errors
  ChatlyException _handleFirebaseException(FirebaseException e, String operation) {
    switch (e.code) {
      case 'permission-denied':
        return PermissionException('Insufficient permissions to $operation');
      case 'not-found':
        return NotFoundException('Resource not found for $operation');
      case 'already-exists':
        return ChatlyException('Resource already exists for $operation');
      case 'failed-precondition':
        return ChatlyException('Operation failed precondition for $operation');
      case 'cancelled':
        return ChatlyException('Operation was cancelled for $operation');
      case 'resource-exhausted':
        return ChatlyException('Resource limit exceeded for $operation');
      case 'deadline-exceeded':
        return TimeoutException('Operation timed out for $operation');
      case 'invalid-argument':
        return ValidationException('Invalid argument for $operation');
      case 'unavailable':
        return NetworkException('Service unavailable for $operation');
      case 'internal':
        return DatabaseException('Internal server error for $operation');
      default:
        return DatabaseException('Database error during $operation: ${e.message}');
    }
  }
  
  /// Batch write operation
  Future<void> batchWrite(BatchWrite batch) async {
    try {
      await batch.commit();
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'batch write');
    } catch (e) {
      throw DatabaseException('Failed to execute batch write: ${e.toString()}');
    }
  }
  
  /// Create batch write
  BatchWrite createBatch() {
    return _firestore.batch();
  }
  
  /// Get collection reference
  CollectionReference getCollection(String collectionName) {
    return _firestore.collection(collectionName);
  }
  
  /// Get document reference
  DocumentReference getDocument(String collectionName, String docId) {
    return _firestore.collection(collectionName).doc(docId);
  }
  
  /// TODO: Implement data pagination for large collections
  /// TODO: Add offline persistence support
  /// TODO: Implement real-time listeners with proper cleanup
  /// WARNING: Always validate data before writing to Firestore
}
