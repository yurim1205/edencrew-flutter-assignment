import 'package:flutter/material.dart';

import '../../../models/daily_price.dart';
import '../../../theme/theme.dart';
import '../../../utils/number_formatter.dart';

class DailyPriceTable extends StatelessWidget {
  const DailyPriceTable({super.key, required this.prices});

  final List<DailyPrice> prices;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: dimens.space5, vertical: dimens.space3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '일별 시세',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 17,
              fontWeight: AppTypography.bold,
            ),
          ),
          SizedBox(height: dimens.space3),
          _HeaderRow(colors: colors, dimens: dimens),
          for (int i = 0; i < prices.length; i++)
            _DataRow(
              price: prices[i],
              previousClose: i + 1 < prices.length ? prices[i + 1].closePrice : null,
              colors: colors,
              dimens: dimens,
            ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.colors, required this.dimens});

  final AppColors colors;
  final AppDimens dimens;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = TextStyle(
      color: colors.textSecondary,
      fontSize: 13,
      fontWeight: AppTypography.regular,
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: dimens.space2),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('날짜', style: style)),
          Expanded(flex: 3, child: Text('종가', style: style, textAlign: TextAlign.right)),
          Expanded(flex: 3, child: Text('등락', style: style, textAlign: TextAlign.right)),
          Expanded(flex: 4, child: Text('거래량', style: style, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.price,
    required this.previousClose,
    required this.colors,
    required this.dimens,
  });

  final DailyPrice price;
  final int? previousClose;
  final AppColors colors;
  final AppDimens dimens;

  @override
  Widget build(BuildContext context) {
    final int change = previousClose != null ? price.closePrice - previousClose! : 0;

    final Color changeColor;
    final String changeText;
    if (change > 0) {
      changeColor = colors.priceUpText;
      changeText = '+${NumberFormatter.comma(change)}';
    } else if (change < 0) {
      changeColor = colors.priceDownText;
      changeText = '-${NumberFormatter.comma(change.abs())}';
    } else {
      changeColor = colors.priceFlatText;
      changeText = '0';
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: dimens.space3),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.borderSubtle, width: dimens.borderHairline)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              NumberFormatter.dateMMDD(price.date),
              style: TextStyle(color: colors.textSecondary, fontSize: 15, fontWeight: AppTypography.regular),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              NumberFormatter.comma(price.closePrice),
              textAlign: TextAlign.right,
              style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: AppTypography.medium),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              changeText,
              textAlign: TextAlign.right,
              style: TextStyle(color: changeColor, fontSize: 15, fontWeight: AppTypography.regular),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              NumberFormatter.comma(price.accumulatedTradingVolume),
              textAlign: TextAlign.right,
              style: TextStyle(color: colors.textSecondary, fontSize: 15, fontWeight: AppTypography.regular),
            ),
          ),
        ],
      ),
    );
  }
}