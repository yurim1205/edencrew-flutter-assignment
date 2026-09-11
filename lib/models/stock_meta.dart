class StockMeta {
  const StockMeta({
    required this.symbolCode,
    required this.stockName,
    required this.stockExchangeNameKor,
  });

  final String symbolCode;
  final String stockName;
  final String stockExchangeNameKor;

  factory StockMeta.fromJson(Map<String, dynamic> json) {
    return StockMeta(
      symbolCode: json['symbolCode'] as String,
      stockName: json['stockName'] as String,
      stockExchangeNameKor: json['stockExchangeNameKor'] as String,
    );
  }
}