import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/daily_price.dart';
import '../services/naver_stock_service.dart';

final NaverStockService _service = NaverStockService();

/// 종목별로 이미 받아온 페이지들을 기억해두는 캐시 상태
class DailyPriceState {
  const DailyPriceState({
    this.pagesBySymbol = const {},
    this.lastPageBySymbol = const {},
  });

  /// symbol -> { page번호: 그 페이지의 DailyPrice 목록 }
  final Map<String, Map<int, List<DailyPrice>>> pagesBySymbol;

  /// symbol -> 마지막 페이지 번호
  final Map<String, int> lastPageBySymbol;

  DailyPriceState copyWith({
    Map<String, Map<int, List<DailyPrice>>>? pagesBySymbol,
    Map<String, int>? lastPageBySymbol,
  }) {
    return DailyPriceState(
      pagesBySymbol: pagesBySymbol ?? this.pagesBySymbol,
      lastPageBySymbol: lastPageBySymbol ?? this.lastPageBySymbol,
    );
  }
}

class DailyPriceNotifier extends StateNotifier<DailyPriceState> {
  DailyPriceNotifier() : super(const DailyPriceState());

  /// 특정 종목의 1~[neededPage]까지의 데이터를 반환.
  /// 이미 캐시에 있는 페이지는 재사용하고, 없는 페이지만 새로 요청함.
  Future<List<DailyPrice>> getPricesUpToPage(String symbol, int neededPage) async {
    final Map<int, List<DailyPrice>> cachedPages =
        Map<int, List<DailyPrice>>.from(state.pagesBySymbol[symbol] ?? {});

    final int? knownLastPage = state.lastPageBySymbol[symbol];
    final int pageLimit =
        knownLastPage != null ? neededPage.clamp(1, knownLastPage) : neededPage;

    for (int page = 1; page <= pageLimit; page++) {
      // 이미 캐시에 있으면 건너뜀 — 재요청하지 않음
      if (cachedPages.containsKey(page)) continue;

      final DailyPriceResult result = await _service.getDailyPrices(symbol, page);
      cachedPages[page] = result.prices;

      // 마지막 페이지 정보를 처음 알게 된 시점에 저장
      if (!state.lastPageBySymbol.containsKey(symbol)) {
        state = state.copyWith(
          lastPageBySymbol: {...state.lastPageBySymbol, symbol: result.lastPage},
        );
      }

      // lastPage보다 큰 페이지는 더 요청하지 않도록 루프 중단
      if (page >= result.lastPage) break;
    }

    state = state.copyWith(
      pagesBySymbol: {...state.pagesBySymbol, symbol: cachedPages},
    );

    // 페이지 순서대로 정렬해서 하나의 리스트로 합침
    final List<int> sortedPageKeys = cachedPages.keys.toList()..sort();
    return sortedPageKeys.expand((int page) => cachedPages[page]!).toList();
  }
}

final StateNotifierProvider<DailyPriceNotifier, DailyPriceState> dailyPriceProvider =
    StateNotifierProvider<DailyPriceNotifier, DailyPriceState>(
  (StateNotifierProviderRef<DailyPriceNotifier, DailyPriceState> ref) => DailyPriceNotifier(),
);