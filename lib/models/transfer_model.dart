class Transfer {
  final int id;
  final String name;
  final String transferId;
  final String cpf;
  final double sentAmount;
  final double originalAmount;
  final double mintFees;
  final String paymentId;
  final bool completedTransfer;
  final bool processing;
  final String receivedTxid;
  final String? sentTxid;
  final String? receipt;
  final int? userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double receivedAmount;

  Transfer({
    required this.id,
    required this.name,
    required this.transferId,
    required this.cpf,
    required this.sentAmount,
    required this.originalAmount,
    required this.mintFees,
    required this.paymentId,
    required this.completedTransfer,
    required this.processing,
    required this.receivedTxid,
    this.sentTxid,
    this.receipt,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.receivedAmount,
  });

  factory Transfer.fromJson(Map<String, dynamic> json) {
    return Transfer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      transferId: json['transfer_id'] ?? '',
      cpf: json['cpf'] ?? '',
      sentAmount: (json['sent_amount'] != null) ? double.parse(json['sent_amount']) : 0.0,
      originalAmount: (json['original_amount'] != null) ? double.parse(json['original_amount']) : 0.0,
      mintFees: (json['mint_fees'] != null) ? double.parse(json['mint_fees']) : 0.0,
      paymentId: json['payment_id'] ?? '',
      completedTransfer: json['completed_transfer']?.toString().toLowerCase() == 'true',
      processing: json['processing']?.toString().toLowerCase() == 'true',
      receivedTxid: json['received_txid'] ?? '',
      sentTxid: json['sent_txid'],
      receipt: json['receipt'],
      userId: json['user_id'],
      receivedAmount: (json['amount_received_by_user'] != null) ? double.parse(json['amount_received_by_user']) : 0.0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Transfer.empty() : this(
    id: 0,
    name: '',
    transferId: '',
    cpf: '',
    sentAmount: 0.0,
    originalAmount: 0.0,
    mintFees: 0.0,
    paymentId: '',
    completedTransfer: false,
    processing: false,
    receivedTxid: '',
    sentTxid: '',
    receipt: '',
    userId: 0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    receivedAmount: 0.0,
  );
}
