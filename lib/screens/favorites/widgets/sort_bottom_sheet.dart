import 'package:flutter/material.dart';

import '../../../theme/theme.dart';

enum SortType { currentPrice, changeRate, name }

/// 정렬 바텀시트를 띄우는 함수.
/// 사용자가 옵션을 선택하면 그 값을 반환하고, 아무것도 안 고르고 닫으면 null을 반환함.
Future<SortType?> showSortBottomSheet(BuildContext context, SortType current) {
  return showModalBottomSheet<SortType>(
    context: context,
    backgroundColor: context.colors.surfaceRaised,
    builder: (BuildContext context) {
      return SortBottomSheetContent(current: current);
    },
  );
}

class SortBottomSheetContent extends StatelessWidget {
  const SortBottomSheetContent({super.key, required this.current});

  final SortType current;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(dimens.space5, dimens.space4, dimens.space5, dimens.space2),
            child: Text(
              '정렬',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 18,
                fontWeight: AppTypography.bold,
              ),
            ),
          ),
          _SortOption(
            label: '현재가순',
            selected: current == SortType.currentPrice,
            onTap: () => Navigator.pop(context, SortType.currentPrice),
          ),
          _SortOption(
            label: '등락률순',
            selected: current == SortType.changeRate,
            onTap: () => Navigator.pop(context, SortType.changeRate),
          ),
          _SortOption(
            label: '가나다순',
            selected: current == SortType.name,
            onTap: () => Navigator.pop(context, SortType.name),
          ),
        ],
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
      contentPadding: EdgeInsets.symmetric(horizontal: dimens.space5),
      title: Text(
        label,
        style: TextStyle(
          color: selected ? colors.textPrimary : colors.textSecondary,
          fontSize: 16,
          fontWeight: AppTypography.regular,
        ),
      ),
      trailing: selected ? Icon(Icons.check, color: colors.textPrimary, size: dimens.iconMd) : null,
    );
  }
}