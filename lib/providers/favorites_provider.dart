import 'package:flutter_riverpod/flutter_riverpod.dart';

// 관심종목으로 등록된 종목 코드 집합 (Set이라 중복 걱정 없음)
class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier() : super(<String>{});

  bool isFavorite(String symbol) => state.contains(symbol);

  void toggle(String symbol) {
    if (state.contains(symbol)) {
      state = {...state}..remove(symbol);
    } else {
      state = {...state, symbol};
    }
  }

  void add(String symbol) {
    state = {...state, symbol};
  }

  void remove(String symbol) {
    state = {...state}..remove(symbol);
  }
}

final StateNotifierProvider<FavoritesNotifier, Set<String>> favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>(
  (StateNotifierProviderRef<FavoritesNotifier, Set<String>> ref) => FavoritesNotifier(),
);