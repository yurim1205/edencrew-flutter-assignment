import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/stock_realtime_price.dart';
import '../services/naver_stock_service.dart';
import 'favorites_provider.dart';

final NaverStockService _service = NaverStockService();

// 관심종목 코드 목록을 감시하다가, 바뀔 때마다 실시간 시세를 새로 조회
// FutureProvider: 비동기 작업의 결과를 담는 provider
final FutureProvider<Map<String, StockRealtimePrice>> favoritesPricesProvider =
    FutureProvider<Map<String, StockRealtimePrice>>((ref) async {
  final Map<String, FavoriteStock> favorites = ref.watch(favoritesProvider);
  if (favorites.isEmpty) return {};
  return _service.getRealtimePrices(favorites.keys.toList());
});