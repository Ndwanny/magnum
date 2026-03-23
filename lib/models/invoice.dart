class Invoice {
  final String id;
  final String invoiceNumber;
  final String clientName;
  final double amount;
  final String currency;
  final String status;      // 'Paid' | 'Pending' | 'Overdue'
  final DateTime issuedDate;
  final DateTime dueDate;
  final List<InvoiceItem> items;

  const Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.clientName,
    required this.amount,
    required this.currency,
    required this.status,
    required this.issuedDate,
    required this.dueDate,
    required this.items,
  });
}

class InvoiceItem {
  final String description;
  final int quantity;
  final double unitPrice;

  const InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;
}
