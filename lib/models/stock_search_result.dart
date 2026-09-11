class StockSearchResult {
  const StockSearchResult({
    required this.id,
    required this.code,
    required this.name,
    required this.typeName,
  });

  final String id; // "domestic:005930"
  final String code;
  final String name;
  final String typeName;

  static StockSearchResult? fromJson(Map<String, dynamic> json) {
    final String code = json['code'] as String? ?? '';
    final String nationCode = json['nationCode'] as String? ?? '';
    final String category = json['category'] as String? ?? '';

    final bool isDomesticStock = nationCode == 'KOR' && category == 'stock';
    final bool isSixDigitCode = RegExp(r'^\d{6}$').hasMatch(code);

    if (!isDomesticStock || !isSixDigitCode) return null;

    return StockSearchResult(
      id: 'domestic:$code',
      code: code,
      name: json['name'] as String? ?? '',
      typeName: json['typeName'] as String? ?? '',
    );
  }

  static List<StockSearchResult> listFromJson(Map<String, dynamic> json) {
    final List<dynamic> items = json['items'] as List<dynamic>? ?? [];
    return items
        .map((dynamic item) => StockSearchResult.fromJson(item as Map<String, dynamic>))
        .whereType<StockSearchResult>()
        .toList();
  }
}