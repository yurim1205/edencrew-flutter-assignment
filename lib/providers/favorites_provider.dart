import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteStock {
  const FavoriteStock({required this.symbol, required this.name, required this.typeName});
  final String symbol;
  final String name;
  final String typeName; // "코스피" 등
}

// 관심종목으로 등록된 종목 코드 집합 (Set이라 중복 걱정 없음)
class FavoritesNotifier extends StateNotifier<Map<String,FavoriteStock>> {
  FavoritesNotifier() : super(<String, FavoriteStock>{});

  bool isFavorite(String symbol) => state.containsKey(symbol);

  void toggle(FavoriteStock stock) {
    if (state.containsKey(stock.symbol)) {
      state = {...state}..remove(stock.symbol);
    } else {
      state = {...state, stock.symbol: stock};
    }
  }
  
  void remove(String symbol) {
    state = {...state}..remove(symbol);
  }
}

final StateNotifierProvider<FavoritesNotifier, Set<String>> favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>(
  (StateNotifierProviderRef<FavoritesNotifier, Set<String>> ref) => FavoritesNotifier(),
);