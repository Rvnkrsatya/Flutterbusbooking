class CheckoutResponse {
  final bool success;
  final Order order;

  CheckoutResponse({
    required this.success,
    required this.order,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutResponse(
      success: json['success'],
      order: Order.fromJson(json['order']), // <-- Fix here
    );
  }
}

class Order {
  final int amount;
  final int amountDue;
  final int amountPaid;
  final int attempts;
  final int createdAt;
  final String currency;
  final String entity;
  final String id;
  final Notes notes;
  final String? offerId;
  final String receipt;
  final String status;

  Order({
    required this.amount,
    required this.amountDue,
    required this.amountPaid,
    required this.attempts,
    required this.createdAt,
    required this.currency,
    required this.entity,
    required this.id,
    required this.notes,
    this.offerId,
    required this.receipt,
    required this.status,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      amount: json['amount'],
      amountDue: json['amount_due'],
      amountPaid: json['amount_paid'],
      attempts: json['attempts'],
      createdAt: json['created_at'],
      currency: json['currency'],
      entity: json['entity'],
      id: json['id'],
      notes: Notes.fromJson(json['notes']), // ✅ Map, not list
      offerId: json['offer_id'],
      receipt: json['receipt'],
      status: json['status'],
    );
  }
}

class Notes {
  final String blockId;

  Notes({required this.blockId});

  factory Notes.fromJson(Map<String, dynamic> json) {
    return Notes(
      blockId: json['blockId'],
    );
  }
}
