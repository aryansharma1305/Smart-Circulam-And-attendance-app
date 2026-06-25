class SecureQrToken {
  const SecureQrToken({
    required this.version,
    required this.sessionId,
    required this.timetableEntryId,
    required this.teacherId,
    required this.nonce,
    required this.issuedAt,
    required this.expiresAt,
  });

  final int version;
  final String sessionId;
  final String timetableEntryId;
  final String teacherId;
  final String nonce;
  final DateTime issuedAt;
  final DateTime expiresAt;

  Map<String, dynamic> toClaims() => {
    'expiresAtMs': expiresAt.millisecondsSinceEpoch,
    'issuedAtMs': issuedAt.millisecondsSinceEpoch,
    'nonce': nonce,
    'sessionId': sessionId,
    'teacherId': teacherId,
    'timetableEntryId': timetableEntryId,
    'version': version,
  };

  factory SecureQrToken.fromClaims(Map<String, dynamic> claims) {
    return SecureQrToken(
      version: _intValue(claims['version']),
      sessionId: claims['sessionId'] as String? ?? '',
      timetableEntryId: claims['timetableEntryId'] as String? ?? '',
      teacherId: claims['teacherId'] as String? ?? '',
      nonce: claims['nonce'] as String? ?? '',
      issuedAt: DateTime.fromMillisecondsSinceEpoch(
        _intValue(claims['issuedAtMs']),
      ),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
        _intValue(claims['expiresAtMs']),
      ),
    );
  }

  static int _intValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class SecureQrValidationResult {
  const SecureQrValidationResult._({
    required this.isValid,
    this.token,
    this.error,
  });

  final bool isValid;
  final SecureQrToken? token;
  final String? error;

  factory SecureQrValidationResult.valid(SecureQrToken token) =>
      SecureQrValidationResult._(isValid: true, token: token);

  factory SecureQrValidationResult.invalid(String error) =>
      SecureQrValidationResult._(isValid: false, error: error);
}
