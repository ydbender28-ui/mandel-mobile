class LedgerRowDto {
  final int? id;
  final String? txDate;
  final int? invoice;
  final String? status;
  final String? invType;
  final double amount;
  final String? notes;
  final bool isPDC;
  final String? txType;
  final double runningBalance;
  final String? payMethod;
  final String? checkNum;
  final String? postDate;
  final bool? isOpen;

  const LedgerRowDto({
    this.id,
    this.txDate,
    this.invoice,
    this.status,
    this.invType,
    required this.amount,
    this.notes,
    required this.isPDC,
    this.txType,
    required this.runningBalance,
    this.payMethod,
    this.checkNum,
    this.postDate,
    this.isOpen,
  });

  factory LedgerRowDto.fromJson(Map<String, dynamic> json) {
    return LedgerRowDto(
      id: json['id'],
      txDate: json['txDate']?.toString(),
      invoice: json['invoice'],
      status: json['status'],
      invType: json['invType'],
      amount: (json['amount'] ?? 0).toDouble(),
      notes: json['notes'],
      isPDC: json['isPDC'] == true || json['isPDC'] == 1,
      txType: json['txType'],
      runningBalance: (json['runningBalance'] ?? 0).toDouble(),
      payMethod: json['payMethod'],
      checkNum: json['checkNum'],
      postDate: json['postDate']?.toString(),
      isOpen: json['isOpen'] == null ? null : (json['isOpen'] == true || json['isOpen'] == 1),
    );
  }

  bool get isPayment => invType == 'PAY';
  bool get isCredit => invType == 'REF';
  bool get isInvoice => invType != 'PAY' && invType != 'REF';
}
