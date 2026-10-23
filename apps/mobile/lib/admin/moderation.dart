enum ModerationTarget { account, offer }

String? moderationReasonError(String? value) {
  final reason = value?.trim() ?? '';
  return reason.length < 5 || reason.length > 300
      ? 'Give a reason of 5–300 characters.'
      : null;
}

/// Append-only local record. Server enforcement is required for production.
class ModerationRecord {
  const ModerationRecord({
    required this.target,
    required this.targetId,
    required this.restricted,
    required this.reason,
    required this.at,
    required this.adminId,
  });
  final ModerationTarget target;
  final String targetId;
  final bool restricted;
  final String reason;
  final DateTime at;
  final String adminId;

  Map<String, Object?> toJson() => {
    'target': target.name,
    'targetId': targetId,
    'restricted': restricted,
    'reason': reason,
    'at': at.toUtc().toIso8601String(),
    'adminId': adminId,
  };

  factory ModerationRecord.fromJson(Map<String, dynamic> json) {
    final record = ModerationRecord(
      target: ModerationTarget.values.byName(json['target'] as String),
      targetId: json['targetId'] as String,
      restricted: json['restricted'] as bool,
      reason: json['reason'] as String,
      at: DateTime.parse(json['at'] as String),
      adminId: json['adminId'] as String,
    );
    if (record.targetId.isEmpty ||
        record.adminId.isEmpty ||
        moderationReasonError(record.reason) != null ||
        record.reason != record.reason.trim()) {
      throw const FormatException('Invalid moderation record.');
    }
    return record;
  }
}
