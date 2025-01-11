// ignore_for_file: unused_local_variable

import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailVerificationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  static const String senderEmail = "galabin.brandonjames28@gmail.com"; // Replace with your sender email
  static const String senderName = "BJbrandonjames#28";
  
  static const String _emailPassword = "jmfv baip nsks eifa";
  
  // Generate a 6-digit OTP
  String generateOTP() {
    return (100000 + Random().nextInt(899999)).toString();
  }

  // Send OTP via custom email
  Future<void> sendOTPEmail(String userEmail, String otp) async {
    try {
      debugPrint('Sending OTP email to: $userEmail with OTP: $otp');
      final smtpServer = gmail(senderEmail, _emailPassword);

      final message = Message()
        ..from = Address(senderEmail, senderName)
        ..recipients.add(userEmail)
        ..subject = 'Marine Guard - Email Verification Code'
        ..html = '''
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h1 style="color: #1a73e8;">Marine Guard Email Verification</h1>
            <p>Hello,</p>
            <p>Thank you for registering with Marine Guard. To verify your email address, please use the following code:</p>
            <div style="background-color: #f5f5f5; padding: 15px; border-radius: 5px; text-align: center; margin: 20px 0;">
              <h2 style="color: #1a73e8; letter-spacing: 5px; margin: 0;">$otp</h2>
            </div>
            <p><strong>Important:</strong></p>
            <ul>
              <li>This code will expire in 10 minutes</li>
              <li>If you didn't request this verification, please ignore this email</li>
            </ul>
            <p>Best regards,<br>Marine Guard Team</p>
            <hr>
            <p style="font-size: 12px; color: #666;">
              This is an automated message, please do not reply to this email.
            </p>
          </div>
        ''';

      final sendReport = await send(message, smtpServer);
      debugPrint('Email sent successfully: ${sendReport.toString()}');
    } catch (e) {
      debugPrint('Error sending verification email: $e');
      throw Exception('Failed to send verification email. Please try again.');
    }
  }

  // Verify OTP
  Future<bool> verifyOTP(String uid, String otp) async {
    try {
      debugPrint('Verifying OTP for Firebase UID: $uid with entered OTP: $otp');
      
      // Find the user document with matching firebaseUID
      var userQuery = await _firestore
          .collection('users')
          .where('firebaseUID', isEqualTo: uid)
          .get();

      if (userQuery.docs.isEmpty) {
        debugPrint('User document not found for firebaseUID: $uid');
        return false;
      }

      String userDocId = userQuery.docs.first.id;
      final userData = userQuery.docs.first.data();
      debugPrint('Found user document with ID: $userDocId');
      
      final verification = userData['verification'] as Map<String, dynamic>?;
      if (verification == null) {
        debugPrint('No verification data found for user');
        return false;
      }

      final storedOTP = verification['otp'] as String?;
      final createdAt = (verification['createdAt'] as Timestamp?)?.toDate();
      
      if (storedOTP == null || createdAt == null) {
        debugPrint('Invalid verification data');
        return false;
      }
      
      debugPrint('Stored OTP: $storedOTP, Created at: $createdAt');
      
      // Check if OTP is expired (10 minutes validity)
      final timeDifference = DateTime.now().difference(createdAt).inMinutes;
      debugPrint('Time since OTP creation: $timeDifference minutes');
      
      if (timeDifference > 10) {
        debugPrint('OTP expired for user: $userDocId (created $timeDifference minutes ago)');
        return false;
      }

      if (otp == storedOTP) {
        debugPrint('OTP matched! Updating verification status');
        // Update verification status in user document
        await _firestore.collection('users').doc(userDocId).update({
          'emailVerified': true,
          'verification.verified': true,
        });
        debugPrint('Successfully updated verification status');
        return true;
      }
      
      debugPrint('OTP did not match. Entered: $otp, Stored: $storedOTP');
      return false;
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      return false;
    }
  }

  // Resend OTP
  Future<String> resendOTP(String uid) async {
    try {
      debugPrint('Resending OTP for Firebase UID: $uid');
      // Find the user document with matching firebaseUID
      var userQuery = await _firestore
          .collection('users')
          .where('firebaseUID', isEqualTo: uid)
          .get();

      if (userQuery.docs.isEmpty) {
        debugPrint('User document not found for Firebase UID: $uid');
        throw Exception('User not found');
      }

      final userDoc = userQuery.docs.first;
      final email = userDoc.data()['email'] as String?;
      final userDocId = userDoc.id;
      
      debugPrint('Found user document. ID: $userDocId, Email: $email');
      
      if (email == null) {
        debugPrint('No email found in user document');
        throw Exception('User email not found');
      }

      final newOTP = generateOTP();
      debugPrint('Generated new OTP: $newOTP');
      
      // Update verification data in user document
      await _firestore.collection('users').doc(userDocId).update({
        'verification': {
          'otp': newOTP,
          'createdAt': FieldValue.serverTimestamp(),
          'verified': false,
          'attempts': 0
        }
      });
      
      // Send email with new OTP
      await sendOTPEmail(email, newOTP);
      
      debugPrint('Successfully sent and saved new OTP');
      return newOTP;
    } catch (e) {
      debugPrint('Error resending OTP: $e');
      throw Exception('Failed to resend verification code');
    }
  }

  // Check if user is verified
  Future<bool> isUserVerified(String uid) async {
    try {
      // Find the user document with matching firebaseUID
      var userQuery = await _firestore
          .collection('users')
          .where('firebaseUID', isEqualTo: uid)
          .get();

      if (userQuery.docs.isEmpty) {
        return false;
      }

      String userDocId = userQuery.docs.first.id;
      final userData = userQuery.docs.first.data();
      final verification = userData['verification'] as Map<String, dynamic>?;
      return verification?['verified'] ?? false;
    } catch (e) {
      debugPrint('Error checking verification status: $e');
      return false;
    }
  }
}
