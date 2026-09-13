import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/stock_meta.dart';
import '../../models/stock_realtime_price.dart';
import '../../providers/favorites_provider.dart';
import '../../services/naver_stock_service.dart';
import '../../theme/theme.dart';
import 'widgets/stock_detail_header.dart';

final NaverStockService _service = NaverStockService();

class StockDetailScreen extends ConsumerStatefulWidget {
  const StockDetailScreen({super.key, required this.symbol});

  final String symbol;

  @override
  ConsumerState<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends ConsumerState<StockDetailScreen> {
  StockMeta? _meta;
  StockRealtimePrice? _price;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final StockMeta meta = await _service.getStockMeta(widget.symbol);
      final Map<String, StockRealtimePrice> prices = await _service.getRealtimePrices([widget.symbol]);

      if (!mounted) return;
      setState(() {
        _meta = meta;
        _price = prices[widget.symbol];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '데이터를 불러오지 못했습니다.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final Map<String, FavoriteStock> favorites = ref.watch(favoritesProvider);
    final bool isFavorite = favorites.containsKey(widget.symbol);

    return Scaffold(
      backgroundColor: colors.surfaceBase,
      body: SafeArea(
        child: Column(
            children: <Widget>[
            if (_meta != null)
              StockDetailHeader(
                stockName: _meta!.stockName,
                symbol: _meta!.symbolCode,
                typeName: _meta!.stockExchangeNameKor,
                isFavorite: isFavorite,
                onTapFavorite: () {
                  ref.read(favoritesProvider.notifier).toggle(
                        FavoriteStock(
                          symbol: _meta!.symbolCode,
                          name: _meta!.stockName,
                          typeName: _meta!.stockExchangeNameKor,
                        ),
                      );
                  },
              )
            else
              Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: colors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(
                 child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!, style: TextStyle(color: colors.textSecondary)))
                      : _buildContent(colors, isFavorite),
                    ),
                   ],      
                ),
            ),
        );
    }

  Widget _buildContent(AppColors colors, bool isFavorite) {
    return Center(
      child: Text(
        '${_meta!.stockName} 상세 화면 작업 예정',
        style: TextStyle(color: colors.textPrimary),
      ),
    );
  }
}