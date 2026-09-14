import 'package:flutter/material.dart';

import '../../../theme/theme.dart';

enum PricePeriod { oneMonth, threeMonths, sixMonths, oneYear }

extension PricePeriodX on PricePeriod {
  String get label {
    switch (this) {
      case PricePeriod.oneMonth:
        return '1개월';
      case PricePeriod.threeMonths:
        return '3개월';
      case PricePeriod.sixMonths:
        return '6개월';
      case PricePeriod.oneYear:
        return '1년';
    }
  }

  // 한 페이지 = 10거래일 기준, 필요한 페이지 수
  int get requiredPage {
    switch (this) {
      case PricePeriod.oneMonth:
        return 3;
      case PricePeriod.threeMonths:
        return 7;
      case PricePeriod.sixMonths:
        return 13;
      case PricePeriod.oneYear:
        return 26;
    }
  }
}

class PeriodTabs extends StatelessWidget {
  const PeriodTabs({super.key, required this.selected, required this.onChanged});

  final PricePeriod selected;
  final ValueChanged<PricePeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: dimens.space5, vertical: dimens.space3),
      child: Row(
        children: PricePeriod.values.map((PricePeriod period) {
          final bool isSelected = period == selected;
          return Padding(
            padding: EdgeInsets.only(right: dimens.space2),
            child: GestureDetector(
              onTap: () => onChanged(period),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: dimens.space4, 
                    vertical: dimens.space3
                ),
                decoration: BoxDecoration(
                  color: isSelected ? colors.accentBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(dimens.radiusSm),
                  
                ),
                child: Text(
                  period.label,
                  style: TextStyle(
                    color: isSelected ? colors.accentDefault : colors.textSecondary,
                    fontSize: 13,
                    fontWeight: isSelected ? AppTypography.medium : AppTypography.regular,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}