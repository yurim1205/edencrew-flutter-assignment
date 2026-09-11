import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/stock_meta.dart';
import '../models/stock_search_result.dart';
import '../models/stock_realtime_price.dart';

// HTML 파싱 + EUC-KR 디코딩
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:charset_converter/charset_converter.dart';

import '../models/daily_price.dart';


// NaverStockService: 네이버 서버에 실제로 요청을 보내고, 받은 응답을 DTO로 변환해서 돌려주는 것
class NaverStockService {
  static const Map<String, String> _headers = {
    'User-Agent':
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
  };

  /// 1. 검색 자동완성
  Future<List<StockSearchResult>> searchStocks(String query) async {
    final Uri uri = Uri.parse('https://ac.stock.naver.com/ac').replace(
      queryParameters: {
        'q': query,
        'target': 'stock,ipo,index,marketindicator',
      },
    );

    final http.Response response = await http.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('검색 API 호출 실패: ${response.statusCode}');
    }

    final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
    return StockSearchResult.listFromJson(json);
  }

  /// 3. 종목 메타데이터
  Future<StockMeta> getStockMeta(String symbol) async {
    final Uri uri = Uri.parse(
      'https://stock.naver.com/api/securityFe/api/fchart/domestic/stock/$symbol',
    );

    final http.Response response = await http.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('메타데이터 API 호출 실패: ${response.statusCode}');
    }

    final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
    return StockMeta.fromJson(json);
  }

  /// 2. 실시간 시세 (여러 종목 한 번에 조회)
  Future<Map<String, StockRealtimePrice>> getRealtimePrices(List<String> symbols) async {
    if (symbols.isEmpty) return {};

    final String query = 'SERVICE_ITEM:${symbols.join(',')}';
    final Uri uri = Uri.parse('https://polling.finance.naver.com/api/realtime').replace(
      queryParameters: {'query': query},
    );

    final http.Response response = await http.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('실시간 시세 API 호출 실패: ${response.statusCode}');
    }

    final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
    return StockRealtimePrice.mapFromJson(json);
  }

  Future<DailyPriceResult> getDailyPrices(String symbol, int page) async {
    final Uri uri = Uri.parse('https://finance.naver.com/item/sise_day.naver').replace(
      queryParameters: {
        'code': symbol,
        'page': '$page',
      },
    );

    final http.Response response = await http.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('일별 시세 API 호출 실패: ${response.statusCode}');
    }

    // 응답 바이트를 EUC-KR로 디코딩
    final String html = await CharsetConverter.decode('EUC-KR', response.bodyBytes);

    return _parseDailyPriceHtml(html);
  }

  DailyPriceResult _parseDailyPriceHtml(String html) {
    final dom.Document document = html_parser.parse(html);
    final List<dom.Element> rows = document.querySelectorAll('table.type2 tr');

    final List<DailyPrice> prices = [];

    for (final dom.Element row in rows) {
      final List<dom.Element> cells = row.querySelectorAll('td');
      // 데이터가 있는 행만 처리 (빈 행, 헤더 행 제외)
      if (cells.length < 7) continue;

      final String dateText = cells[0].text.trim();
      if (dateText.isEmpty) continue;

      // "2026.09.11" → "20260911" 로 정규화
      final String normalizedDate = dateText.replaceAll('.', '');

      final int? close = _parseNum(cells[1].text);
      final int? open = _parseNum(cells[3].text);
      final int? high = _parseNum(cells[4].text);
      final int? low = _parseNum(cells[5].text);
      final int? volume = _parseNum(cells[6].text);

      if (close == null || open == null || high == null || low == null || volume == null) {
        continue;
      }

      prices.add(DailyPrice(
        date: normalizedDate,
        closePrice: close,
        openPrice: open,
        highPrice: high,
        lowPrice: low,
        accumulatedTradingVolume: volume,
      ));
    }

    // 마지막 페이지 번호 추출 (페이지네이션 영역의 "맨뒤" 링크에서)
    final dom.Element? lastPageLink = document.querySelector('table.Nnavi td.pgRR a');
    int lastPage = 1;
    if (lastPageLink != null) {
      final String? href = lastPageLink.attributes['href'];
      final RegExpMatch? match = RegExp(r'page=(\d+)').firstMatch(href ?? '');
      if (match != null) {
        lastPage = int.parse(match.group(1)!);
      }
    }

    return DailyPriceResult(prices: prices, lastPage: lastPage);
  }

  // "258,750" 같은 쉼표 포함 숫자 문자열을 정수로 변환
  int? _parseNum(String text) {
    final String cleaned = text.trim().replaceAll(',', '');
    if (cleaned.isEmpty) return null;
    return int.tryParse(cleaned);
  }
}

class DailyPriceResult {
  const DailyPriceResult({required this.prices, required this.lastPage});
  final List<DailyPrice> prices;
  final int lastPage;
}