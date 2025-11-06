class SmsItem {
  final String id;
  final String recipient;
  final String message;
  final bool sent;
  final DateTime? addedAt;
  final DateTime? sentAt;

  SmsItem({
    required this.id,
    required this.recipient,
    required this.message,
    this.sent = false,
    this.addedAt,
    this.sentAt,
  });

  factory SmsItem.fromMap(String id, Map<String, dynamic> map) {
    return SmsItem(
      id: id,
      recipient: map['number'] ?? '',
      message: map['message'] ?? '',
      sent: map['sent'] ?? false,
      addedAt: (map['addedAt'] as Timestamp?)?.toDate(),
      sentAt: (map['sentAt'] as Timestamp?)?.toDate(),
    );
  }
}
