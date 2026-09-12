import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/stock_realtime_price.dart';
import '../../providers/favorites_price_provider.dart';
import '../../providers/favorites_provider.dart';

import '../../theme/theme.dart';

enum SortType { currentPrice, changeRate, name }

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  SortType _sortType = SortType.name;

  String get _sortLabel {
    switch (_sortType) {
      case SortType.currentPrice:
        return '현재가순';
      case SortType.changeRate:
        return '등락률순';
      case SortType.name:
        return '가나다순';
    }
  }

  void _openSortSheet() {
     final AppColors colors = context.colors;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surfaceRaised,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _SortOption(
                label: '현재가순',
                selected: _sortType == SortType.currentPrice,
                onTap: () => setState(() {
                  _sortType = SortType.currentPrice;
                  Navigator.pop(context);
                }),
              ),
              _SortOption(
                label: '등락률순',
                selected: _sortType == SortType.changeRate,
                onTap: () => setState(() {
                  _sortType = SortType.changeRate;
                  Navigator.pop(context);
                }),
              ),
              _SortOption(
                label: '가나다순',
                selected: _sortType == SortType.name,
                onTap: () => setState(() {
                  _sortType = SortType.name;
                  Navigator.pop(context);
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
   final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    final Map<String, FavoriteStock> favorites = ref.watch(favoritesProvider);
    final AsyncValue<Map<String, StockRealtimePrice>> pricesAsync =
        ref.watch(favoritesPricesProvider);

    List<FavoriteStock> sortedFavorites = favorites.values.toList();
    final Map<String, StockRealtimePrice> prices = pricesAsync.valueOrNull ?? {};

    switch (_sortType) {
      case SortType.name:
        sortedFavorites.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortType.currentPrice:
        sortedFavorites.sort((a, b) {
          final int? pa = prices[a.symbol]?.currentPrice;
          final int? pb = prices[b.symbol]?.currentPrice;
          if (pa == null || pb == null) return 0;
          return pb.compareTo(pa);
        });
        break;
      case SortType.changeRate:
        sortedFavorites.sort((a, b) {
          final double? ra = prices[a.symbol]?.changeRate;
          final double? rb = prices[b.symbol]?.changeRate;
          if (ra == null || rb == null) return 0;
          return rb.compareTo(ra);
        });
        break;
    }

    return Scaffold(
      backgroundColor: colors.surfaceBase,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(
                dimens.space5,
                dimens.space4,
                dimens.space5,
                dimens.space3,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '관심',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 22,
                      fontWeight: AppTypography.bold,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: _openSortSheet,
                        child: Row(
                          children: <Widget>[
                            Text(
                              _sortLabel,
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 14,
                                fontWeight: AppTypography.medium,
                              ),
                            ),
                            SizedBox(width: dimens.space1),
                            Icon(Icons.keyboard_arrow_down, size: dimens.iconSm, color: colors.textSecondary),
                          ],
                        ),
                      ),
                      SizedBox(width: dimens.space3),
                      GestureDetector(
                        onTap: () => ref.invalidate(favoritesPricesProvider),
                        child: Icon(Icons.refresh, size: dimens.iconMd, color: colors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: favorites.isEmpty
                  ? const _EmptyView()
                  : ListView.builder(
                      itemCount: sortedFavorites.length,
                      itemBuilder: (BuildContext context, int index) {
                        final FavoriteStock stock = sortedFavorites[index];
                        final StockRealtimePrice? price = prices[stock.symbol];
                        return _FavoriteStockTile(stock: stock, price: price);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  const _SortOption({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return ListTile(
      onTap: onTap,
      title: Text(
        label,
        style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: AppTypography.regular),
      ),
      trailing: selected ? Icon(Icons.check, color: colors.accentDefault, size: dimens.iconMd) : null,
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.star_border, size: 48, color: colors.textDisabled),
          SizedBox(height: dimens.space4),
          Text(
            '관심 종목이 없습니다',
            style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: AppTypography.medium),
          ),
          SizedBox(height: dimens.space2),
          Text(
            '검색 탭에서 종목을 찾아\n별 아이콘을 눌러 추가해 주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textTertiary, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _FavoriteStockTile extends StatelessWidget {
  const _FavoriteStockTile({required this.stock, required this.price});

  final FavoriteStock stock;
  final StockRealtimePrice? price;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Container(
      height: dimens.rowMinHeight,
      padding: EdgeInsets.symmetric(horizontal: dimens.space5),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.borderSubtle, width: dimens.borderHairline)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                stock.name,
                style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: AppTypography.medium),
              ),
              SizedBox(height: dimens.space1),
              Text(
                '${stock.symbol} · ${stock.typeName}',
                style: TextStyle(color: colors.textTertiary, fontSize: 12),
              ),
            ],
          ),
          price == null
              ? _SkeletonBox(colors: colors)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      _formatPrice(price!.currentPrice),
                      style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: AppTypography.medium),
                    ),
                    SizedBox(height: dimens.space1),
                    Text(
                      _formatChange(price!),
                      style: TextStyle(
                        color: _directionColor(price!.direction, colors),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Color _directionColor(PriceDirection direction, AppColors colors) {
    switch (direction) {
      case PriceDirection.up:
        return colors.priceUpText;
      case PriceDirection.down:
        return colors.priceDownText;
      case PriceDirection.flat:
        return colors.priceFlatText;
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]},',
        );
  }

  String _formatChange(StockRealtimePrice price) {
    final String sign = price.changeAmount > 0 ? '+' : '';
    final String amount = price.changeAmount.abs().toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]},',
        );
    final String rate = price.changeRate.abs().toStringAsFixed(2);
    return '$sign${price.changeAmount < 0 ? '-' : ''}$amount ($sign${price.changeRate < 0 ? '-' : ''}$rate%)';
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 20,
      decoration: BoxDecoration(
        color: colors.feedbackSkeleton,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}