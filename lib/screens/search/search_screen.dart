import 'package:flutter/material.dart';
import '../../theme/theme.dart';

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/stock_search_result.dart';
import '../../providers/favorites_provider.dart';
import '../../services/naver_stock_service.dart';
import '../stock_detail/stock_detail_screen.dart';

final NaverStockService _service = NaverStockService();

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

   @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
    final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  String _keyword = '';
  List<StockSearchResult> _results = [];
  bool _searched = false; // 검색을 한 번이라도 시도했는지 (초기 vs 결과없음 구분용)

  String? _toastMessage;
  Timer? _toastTimer;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    _toastTimer?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    setState(() => _keyword = value);

    if (value.isEmpty) {
      setState(() {
        _results = [];
        _searched = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final List<StockSearchResult> results = await _service.searchStocks(value);
      if (!mounted) return;
      setState(() {
        _results = results;
        _searched = true;
      });
    });
  }

   void _showToast(String message) {
    _toastTimer?.cancel();
    setState(() => _toastMessage = message);
    _toastTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _toastMessage = null);
    });
  }

    void _toggleFavorite(StockSearchResult result) {
    final bool wasAlreadyFavorite = ref.read(favoritesProvider).containsKey(result.code);

    ref.read(favoritesProvider.notifier).toggle(
          FavoriteStock(symbol: result.code, name: result.name, typeName: result.typeName),
        );

    _showToast(wasAlreadyFavorite ? '관심이 해제되었습니다' : '관심이 등록되었습니다');
  }

  @override
  Widget build(BuildContext context) {
     final AppColors colors = context.colors;
     final AppDimens dimens = context.dimens;
     final Map<String, FavoriteStock> favorites = ref.watch(favoritesProvider);

     return Scaffold(
          backgroundColor: colors.surfaceBase,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    dimens.space5,
                    dimens.space4,
                    dimens.space5,
                    dimens.space3,
                  ),
                  child: _SearchField(
                    controller: _controller,
                    onChanged: _onChanged,
                    onClear: () => _onChanged(''),
                  ),
                ),
                Expanded(
                  child: _buildBody(colors, favorites),
                ),
              ],
            ),
            if (_toastMessage != null)
              Positioned(
                left: dimens.space5,
                right: dimens.space5,
                bottom: dimens.space4,
                child: _Toast(message: _toastMessage!),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBody(AppColors colors, Map<String, FavoriteStock> favorites) {
    if (_keyword.isEmpty) {
      return const _InitialView();
    }
    if (_searched && _results.isEmpty) {
      return _NoResultView(keyword: _keyword);
    }
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (BuildContext context, int index) {
        final StockSearchResult result = _results[index];
        final bool isFavorite = favorites.containsKey(result.code);
        return _SearchResultTile(
          result: result,
          keyword: _keyword,
          isFavorite: isFavorite,
          onTapFavorite: () => _toggleFavorite(result),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => StockDetailScreen(symbol: result.code),
              ),
            );
          }
        );
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged, required this.onClear});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Container(
      height: 44,
      padding: EdgeInsets.symmetric(horizontal: dimens.space3),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(dimens.radiusMd),
        border: Border.all(color: colors.borderSubtle, width: dimens.borderHairline),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.search, size: dimens.iconMd, color: colors.textTertiary),
          SizedBox(width: dimens.space2),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(color: colors.textPrimary, fontSize: 15),
              decoration: InputDecoration(
                hintText: '종목명 또는 종목코드',
                hintStyle: TextStyle(color: colors.textTertiary, fontSize: 15),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onClear();
              },
              child: Icon(Icons.close, size: dimens.iconSm, color: colors.textTertiary),
            ),
        ],
      ),
    );
  }
}

class _InitialView extends StatelessWidget {
  const _InitialView();

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.search, size: 48, color: colors.textDisabled),
          SizedBox(height: dimens.space4),
          Text(
            '종목을 검색해 보세요',
             style: TextStyle(
                color: colors.textSecondary,
                fontSize: 24, 
                fontWeight: AppTypography.bold,
              ),
          ),
          SizedBox(height: dimens.space2),
          Text(
            '종목명 또는 종목코드 6자리로\n검색하실 수 있습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textTertiary, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _NoResultView extends StatelessWidget {
  const _NoResultView({required this.keyword});
  final String keyword;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.search_off, size: 48, color: colors.textDisabled),
          SizedBox(height: dimens.space4),
          Text(
            '검색 결과가 없습니다',
            style: TextStyle(
                color: colors.textSecondary,
                fontSize: 24, 
                fontWeight: AppTypography.bold,
              ),
          ),
          SizedBox(height: dimens.space2),
          Text(
            "'$keyword'와\n일치하는 검색 결과를 찾지 못했습니다.",
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textTertiary, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.result,
    required this.keyword,
    required this.isFavorite,
    required this.onTapFavorite,
    required this.onTap,
  });

  final StockSearchResult result;
  final String keyword;
  final bool isFavorite;
  final VoidCallback onTapFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: dimens.rowMinHeight,
        padding: EdgeInsets.symmetric(horizontal: dimens.space5),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colors.borderSubtle, width: dimens.borderHairline)),
        ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _highlightedName(colors),
              SizedBox(height: dimens.space1),
              Text(
                '${result.code} · ${result.typeName}',
                style: TextStyle(color: colors.textTertiary, fontSize: 12),
              ),
            ],
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
    );
  }

  // 종목명 안에서 검색어와 일치하는 부분을 강조색으로 표시
  Widget _highlightedName(AppColors colors) {
    final String name = result.name;
    final int index = name.indexOf(keyword);

    if (keyword.isEmpty || index == -1) {
      return Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis, 
        style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: AppTypography.medium),
      );
    }

    return RichText(
      maxLines: 1, 
      overflow: TextOverflow.ellipsis, 
      text: TextSpan(
        style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: AppTypography.medium),
        children: <TextSpan>[
          TextSpan(text: name.substring(0, index)),
          TextSpan(
            text: name.substring(index, index + keyword.length),
            style: TextStyle(color: colors.searchHighlight),
          ),
          TextSpan(text: name.substring(index + keyword.length)),
        ],
      ),
    );
  }
}

class _Toast extends StatelessWidget {
  const _Toast({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    final bool isRegister = message.contains('등록');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: dimens.space4, vertical: dimens.space3),
      decoration: BoxDecoration(
        color: colors.surfaceOverlay,
        borderRadius: BorderRadius.circular(dimens.radiusMd),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            isRegister ? Icons.star : Icons.star_border,
            color: isRegister ? colors.favoriteActive : colors.textSecondary,
            size: dimens.iconSm,
          ),
          SizedBox(width: dimens.space2),
          Text(
            message,
            style: TextStyle(
              color: colors.textPrimary, 
              fontSize: 14,
              fontWeight: AppTypography.bold,
              ),
          ),
        ],
      ),
    );
  }
}