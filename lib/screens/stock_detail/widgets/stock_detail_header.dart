import 'package:flutter/material.dart';

import '../../../theme/theme.dart';

class StockDetailHeader extends StatelessWidget {
  const StockDetailHeader({
    super.key,
    required this.stockName,
    required this.symbol,
    required this.typeName,
    required this.isFavorite,
    required this.onTapFavorite,
  });

  final String stockName;
  final String symbol;
  final String typeName;
  final bool isFavorite;
  final VoidCallback onTapFavorite;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Column(
           children: <Widget>[ 
               Padding(
      padding: EdgeInsets.fromLTRB(dimens.space2, dimens.space2, dimens.space5, dimens.space2),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back, color: colors.textSecondary),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  stockName,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 18,
                    fontWeight: AppTypography.bold,
                  ),
                ),
                Text(
                  '$symbol · $typeName',
                  style: TextStyle(color: colors.textTertiary, fontSize: 12),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTapFavorite,
            child: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: isFavorite ? colors.favoriteActive : colors.favoriteInactive,
              size: dimens.iconMd,
            ),
          ),
        ],
      ),
    ),
    Container( 
        height: dimens.borderHairline,
        color: colors.borderSubtle,
      ),
    ],
    );
  }
}