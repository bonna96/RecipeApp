class Ingredient {
  final String name;
  final double amount;
  final String unit;
  final String? iconUrl;

  const Ingredient({
    required this.name,
    required this.amount,
    required this.unit,
    this.iconUrl,
  });

  /// Scale ingredient amount based on serving portions
  double getScaledAmount({required int originalServings, required int targetServings}) {
    if (originalServings <= 0) return amount;
    return (amount / originalServings) * targetServings;
  }

  /// Formatted quantity string (e.g., "400 g", "2 pcs", "1.5 tsp")
  String getFormattedAmount({required int originalServings, required int targetServings}) {
    final scaled = getScaledAmount(
      originalServings: originalServings,
      targetServings: targetServings,
    );
    // If it's a whole number, format without decimal point
    if (scaled == scaled.roundToDouble()) {
      return '${scaled.toInt()} $unit'.trim();
    }
    return '${scaled.toStringAsFixed(1)} $unit'.trim();
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'unit': unit,
      'iconUrl': iconUrl ?? '',
    };
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      name: map['name'] as String? ?? '',
      amount: (map['amount'] is num) ? (map['amount'] as num).toDouble() : 0.0,
      unit: map['unit'] as String? ?? '',
      iconUrl: map['iconUrl'] as String?,
    );
  }
}
