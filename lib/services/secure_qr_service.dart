import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../models/secure_qr_token.dart';

class SecureQrService {
  SecureQrService({
    required String signingSecret,
    Duration tokenTtl = const Duration(seconds: 30),
    DateTime Function()? now,
  }) : _signingSecret = signingSecret,
       _tokenTtl = tokenTtl,
       _now = now ?? DateTime.now;

  static const tokenPrefix = 'ssaqr';
  static const currentVersion = 1;

  final String _signingSecret;
  final Duration _tokenTtl;
  final DateTime Function() _now;

  String issueToken({
    required String sessionId,
    required String timetableEntryId,
    required String teacherId,
    String? nonce,
    DateTime? issuedAt,
  }) {
    final issued = issuedAt ?? _now();
    final token = SecureQrToken(
      version: currentVersion,
      sessionId: sessionId,
      timetableEntryId: timetableEntryId,
      teacherId: teacherId,
      nonce: nonce ?? _nonce(),
      issuedAt: issued,
      expiresAt: issued.add(_tokenTtl),
    );

    final payload = _base64UrlJson(token.toClaims());
    final signature = _signature(payload);
    return '$tokenPrefix.$currentVersion.$payload.$signature';
  }

  SecureQrValidationResult verifyToken({
    required String rawToken,
    String? expectedSessionId,
    DateTime? now,
  }) {
    final parts = rawToken.split('.');
    if (parts.length != 4 || parts[0] != tokenPrefix) {
      return SecureQrValidationResult.invalid('Invalid QR token format.');
    }

    final version = int.tryParse(parts[1]);
    if (version != currentVersion) {
      return SecureQrValidationResult.invalid('Unsupported QR token version.');
    }

    final payload = parts[2];
    final signature = parts[3];
    final expectedSignature = _signature(payload);
    if (!_constantTimeEquals(signature, expectedSignature)) {
      return SecureQrValidationResult.invalid('QR token signature is invalid.');
    }

    final claims = _decodePayload(payload);
    if (claims == null) {
      return SecureQrValidationResult.invalid('QR token payload is invalid.');
    }

    final token = SecureQrToken.fromClaims(claims);
    if (token.sessionId.isEmpty ||
        token.teacherId.isEmpty ||
        token.nonce.isEmpty ||
        token.issuedAt.millisecondsSinceEpoch == 0 ||
        token.expiresAt.millisecondsSinceEpoch == 0) {
      return SecureQrValidationResult.invalid(
        'QR token is missing required claims.',
      );
    }

    if (expectedSessionId != null &&
        expectedSessionId.isNotEmpty &&
        token.sessionId != expectedSessionId) {
      return SecureQrValidationResult.invalid(
        'QR token is for another session.',
      );
    }

    final checkedAt = now ?? _now();
    if (!checkedAt.isBefore(token.expiresAt)) {
      return SecureQrValidationResult.invalid('QR token has expired.');
    }

    if (token.issuedAt.isAfter(checkedAt.add(const Duration(seconds: 5)))) {
      return SecureQrValidationResult.invalid(
        'QR token was issued in the future.',
      );
    }

    return SecureQrValidationResult.valid(token);
  }

  String _signature(String payload) {
    final hmac = Hmac(sha256, utf8.encode(_signingSecret));
    return base64Url.encode(hmac.convert(utf8.encode(payload)).bytes);
  }

  static String _base64UrlJson(Map<String, dynamic> claims) {
    final sorted = SplayTreeMap<String, dynamic>.from(claims);
    return base64Url.encode(utf8.encode(jsonEncode(sorted)));
  }

  static Map<String, dynamic>? _decodePayload(String payload) {
    try {
      final json = utf8.decode(base64Url.decode(payload));
      final decoded = jsonDecode(json);
      if (decoded is! Map<String, dynamic>) return null;
      return decoded;
    } catch (_) {
      return null;
    }
  }

  static bool _constantTimeEquals(String a, String b) {
    final aBytes = utf8.encode(a);
    final bBytes = utf8.encode(b);
    var diff = aBytes.length ^ bBytes.length;
    final length = min(aBytes.length, bBytes.length);
    for (var i = 0; i < length; i++) {
      diff |= aBytes[i] ^ bBytes[i];
    }
    return diff == 0;
  }

  static String _nonce() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }
}
