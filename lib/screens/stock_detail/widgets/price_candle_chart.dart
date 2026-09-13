import 'package:candlesticks/candlesticks.dart';
import 'package:flutter/material.dart';

import '../../../models/daily_price.dart';
import '../../../theme/theme.dart';

class PriceCandleChart extends StatelessWidget {
  const PriceCandleChart({super.key, required this.prices});

  final List<DailyPrice> prices;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    final List<Candle> candles = prices.map((DailyPrice p) {
      final DateTime date = DateTime(
        int.parse(p.date.substring(0, 4)),
        int.parse(p.date.substring(4, 6)),
        int.parse(p.date.substring(6, 8)),
      );
      return Candle(
        date: date,
        open: p.openPrice.toDouble(),
        high: p.highPrice.toDouble(),
        low: p.lowPrice.toDouble(),
        close: p.closePrice.toDouble(),
        volume: p.accumulatedTradingVolume.toDouble(),
      );
    }).toList();

    return SizedBox(
      height: 260,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: dimens.space5),
        child: Candlesticks(
          candles: candles,
          style: CandleSticksStyle.dark(
            chartBackgroundColor: colors.surfaceBase,
            candleBullColor: colors.chartLineUp,
            candleBearColor: colors.chartLineDown,
            // 시안에 없는 부가 UI는 배경과 같은 색으로 맞춰 시각적으로 숨김
            gridLineColor: Colors.transparent,
            axisTextColor: Colors.transparent,
            volumeBullColor: Colors.transparent,
            volumeBearColor: Colors.transparent,
            priceIndicatorBullBackgroundColor: Colors.transparent,
            priceIndicatorBearBackgroundColor: Colors.transparent,
            priceIndicatorTextColor: Colors.transparent,
            scaleButtonActiveBackgroundColor: Colors.transparent,
            scaleButtonActiveTextColor: Colors.transparent,
            scaleButtonInactiveBackgroundColor: Colors.transparent,
            scaleButtonInactiveTextColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}