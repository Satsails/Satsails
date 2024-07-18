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
      id: json['id'],
      name: json['name'],
      transferId: json['transfer_id'],
      cpf: json['cpf'],
      sentAmount: double.parse(json['sent_amount']),
      originalAmount: double.parse(json['original_amount']),
      mintFees: double.parse(json['mint_fees']),
      paymentId: json['payment_id'],
      completedTransfer: json['completed_transfer'].toString().toLowerCase() == 'true',
      processing: json['processing'].toString().toLowerCase() == 'true',
      receivedTxid: json['received_txid'],
      sentTxid: json['sent_txid'],
      receipt: json['receipt'],
      userId: json['user_id'] != null ? json['user_id'] : null,
      receivedAmount: double.parse(json['amount_received_by_user']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}