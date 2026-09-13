import 'package:flutter/material.dart';

import '../../../models/stock_realtime_price.dart';
import '../../../theme/theme.dart';
import '../../../utils/number_formatter.dart';

class PriceSummarySection extends StatelessWidget {
  const PriceSummarySection({super.key, required this.price});

  final StockRealtimePrice price;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: dimens.space5, vertical: dimens.space3),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _SummaryBox(label: '시가', value: NumberFormatter.comma(price.open), colors: colors, dimens: dimens)),
              SizedBox(width: dimens.space2),
              Expanded(child: _SummaryBox(label: '고가', value: NumberFormatter.comma(price.high), colors: colors, dimens: dimens)),
              SizedBox(width: dimens.space2),
              Expanded(child: _SummaryBox(label: '저가', value: NumberFormatter.comma(price.low), colors: colors, dimens: dimens)),
            ],
          ),
          SizedBox(height: dimens.space2),
          Row(
            children: [
              Expanded(child: _SummaryBox(label: '거래량', value: NumberFormatter.volumeInThousands(price.accumulatedVolume), colors: colors, dimens: dimens)),
              SizedBox(width: dimens.space2),
              Expanded(child: _SummaryBox(label: '시가총액', value: NumberFormatter.marketCapInJo(price.marketCap), colors: colors, dimens: dimens)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  const _SummaryBox({
    required this.label,
    required this.value,
    required this.colors,
    required this.dimens,
  });

  final String label;
  final String value;
  final AppColors colors;
  final AppDimens dimens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dimens.space3, vertical: dimens.space3),
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        borderRadius: BorderRadius.circular(dimens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: AppTypography.regular),
          ),
          SizedBox(height: dimens.space1),
          Text(
            value,
            style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: AppTypography.medium),
          ),
        ],
      ),
    );
  }
}