class StockRealtimePrice {
  const StockRealtimePrice({
    required this.symbol,
    required this.currentPrice,
    required this.previousClose,
    required this.open,
    required this.high,
    required this.low,
    required this.accumulatedVolume,
    required this.listedStockCount,
  });

  final String symbol;
  final int currentPrice;
  final int previousClose;
  final int open;
  final int high;
  final int low;
  final int accumulatedVolume;
  final int listedStockCount;

  int get changeAmount => currentPrice - previousClose;

  double get changeRate {
    if (previousClose == 0) return 0;
    return (currentPrice - previousClose) / previousClose * 100;
  }

  int get marketCap => currentPrice * listedStockCount;

  PriceDirection get direction {
    if (changeAmount > 0) return PriceDirection.up;
    if (changeAmount < 0) return PriceDirection.down;
    return PriceDirection.flat;
  }

  factory StockRealtimePrice.fromJson(Map<String, dynamic> json) {
    return StockRealtimePrice(
      symbol: json['cd'] as String,
      currentPrice: (json['nv'] as num).toInt(),
      previousClose: (json['pcv'] as num).toInt(),
      open: (json['ov'] as num).toInt(),
      high: (json['hv'] as num).toInt(),
      low: (json['lv'] as num).toInt(),
      accumulatedVolume: (json['aq'] as num).toInt(),
      listedStockCount: (json['countOfListedStock'] as num).toInt(),
    );
  }

  static Map<String, StockRealtimePrice> mapFromJson(Map<String, dynamic> json) {
    final List<dynamic> areas = json['result']['areas'] as List<dynamic>;
    final List<dynamic> datas = areas[0]['datas'] as List<dynamic>;

    final Map<String, StockRealtimePrice> result = {};
    for (final dynamic item in datas) {
      final StockRealtimePrice price = StockRealtimePrice.fromJson(item as Map<String, dynamic>);
      result[price.symbol] = price;
    }
    return result;
  }
}

enum PriceDirection { up, down, flat }