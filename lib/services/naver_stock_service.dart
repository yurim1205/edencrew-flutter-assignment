import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/stock_meta.dart';
import '../models/stock_search_result.dart';
import '../models/stock_realtime_price.dart';

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
}