import 'package:flutter/material.dart';

import '../../../models/stock_realtime_price.dart';
import '../../../theme/theme.dart';

class CurrentPriceSection extends StatelessWidget {
  const CurrentPriceSection({super.key, required this.price});

  final StockRealtimePrice price;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    final Color directionColor = _directionColor(price.direction, colors);
    final IconData? directionIcon = _directionIcon(price.direction);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: dimens.space5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Text(
            _formatNumber(price.currentPrice),
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 32,
              fontWeight: AppTypography.bold,
            ),
          ),
          SizedBox(width: dimens.space3),
              if (directionIcon != null)
                Icon(directionIcon, size: 24, color: directionColor),
              Text(
                '${_formatNumber(price.changeAmount.abs())} (${price.changeRate.abs().toStringAsFixed(2)}%)',
                style: TextStyle(
                  color: directionColor,
                  fontSize: 15,
                  fontWeight: AppTypography.medium,
                ),
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

  IconData? _directionIcon(PriceDirection direction) {
    switch (direction) {
      case PriceDirection.up:
        return Icons.arrow_drop_up;
      case PriceDirection.down:
        return Icons.arrow_drop_down;
      case PriceDirection.flat:
        return null;
    }
  }

  String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]},',
        );
  }
}