import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/stock_meta.dart';
import '../../models/stock_realtime_price.dart';
import '../../providers/favorites_provider.dart';
import '../../services/naver_stock_service.dart';
import '../../theme/theme.dart';
import 'widgets/stock_detail_header.dart';
import 'widgets/current_price_section.dart';  
import '../../models/daily_price.dart';
import '../../providers/daily_price_provider.dart';
import 'widgets/period_tabs.dart';
import 'widgets/price_summary_section.dart';
import 'widgets/daily_price_table.dart';

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

  PricePeriod _selectedPeriod = PricePeriod.oneMonth;
  List<DailyPrice> _dailyPrices = [];
  bool _chartLoading = false;

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

      _loadDailyPrices(_selectedPeriod);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '데이터를 불러오지 못했습니다.';
        _loading = false;
      });
    }
  }

   Future<void> _loadDailyPrices(PricePeriod period) async {
    setState(() => _chartLoading = true);

    final List<DailyPrice> prices = await ref
        .read(dailyPriceProvider.notifier)
        .getPricesUpToPage(widget.symbol, period.requiredPage);

    if (!mounted) return;
    setState(() {
      _dailyPrices = prices;
      _chartLoading = false;
    });
  }

    void _onPeriodChanged(PricePeriod period) {
    setState(() => _selectedPeriod = period);
    _loadDailyPrices(period);
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
     return SingleChildScrollView(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
            if (_price != null) CurrentPriceSection(price: _price!),
            PeriodTabs(selected: _selectedPeriod, onChanged: _onPeriodChanged),
            if (_chartLoading)
            const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
            ),
            if (_price != null) PriceSummarySection(price: _price!),
            if (_dailyPrices.isNotEmpty) DailyPriceTable(prices: _dailyPrices),
        ],
      ),
    );
  }
}