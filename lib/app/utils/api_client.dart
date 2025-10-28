import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  static const baseUrl = 'https://dummyjson.com';

  static const endpoints = <String, String>{
    'Quotes.getAll': 'quotes',
    'Quotes.getRandom': 'quotes/random',
    'Quotes.getRandomWithCount': 'quotes/random/:count',
    'Posts.getAll': 'posts',
    'Posts.getById': 'posts/:id',
    'Users.getAll': 'users',
    'Users.getById': 'users/:id',
    'Products.getAll': 'products',
    'Products.getById': 'products/:id',
    'Products.search': 'products/search',

    // Error simulation
    'Error.withStatus': 'http/:status',
    'Error.withStatusAndLabel': 'http/:status/:label',
  };

  Map<String, String> headers;
  Map<String, String> queries;
  Map<String, String> params;
  final String endpoint;

  ApiClient(
    String endpointKey, {
    Map<String, String>? headers,
    Map<String, String>? queries,
    Map<String, String>? params,
  }) : endpoint = endpoints[endpointKey] ?? endpointKey,
       headers = headers ?? {},
       queries = queries ?? {},
       params = params ?? {};

  void addHeader(String key, String value) {
    headers[key] = value;
  }

  void addQuery(String key, String value) {
    queries[key] = value;
  }

  void addParam(String key, String value) {
    params[key] = value;
  }

  Uri get url {
    String url = '$baseUrl/$endpoint';

    params.forEach((key, value) {
      url = url.replaceAll(':$key', value);
    });

    if (queries.isNotEmpty) {
      final queryString = queries.entries
          .map(
            (entry) =>
                '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}',
          )
          .join('&');
      url += '?$queryString';
    }

    return Uri.parse(url);
  }

  Future<Map<String, dynamic>> get() async {
    final response = await http.get(url, headers: headers);

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post({dynamic body}) async {
    if (body != null && body is Map) {
      headers['Content-Type'] = 'application/json';
      body = jsonEncode(body);
    }

    final response = await http.post(url, headers: headers, body: body);

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put({dynamic body}) async {
    if (body != null && body is Map) {
      headers['Content-Type'] = 'application/json';
      body = jsonEncode(body);
    }

    final response = await http.put(url, headers: headers, body: body);

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete({dynamic body}) async {
    if (body != null && body is Map) {
      headers['Content-Type'] = 'application/json';
      body = jsonEncode(body);
    }

    final response = await http.delete(url, headers: headers, body: body);

    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final responseCode = response.statusCode;
    final responseBody = response.body;

    dynamic decodedBody;
    try {
      decodedBody = responseBody.isNotEmpty ? jsonDecode(responseBody) : null;
    } catch (_) {
      decodedBody = responseBody;
    }

    if (responseCode >= 400) {
      String errorMessage = 'Gagal memuat data, silakan coba lagi.';

      if (decodedBody is Map) {
        final error = decodedBody['error'] ?? decodedBody['message'];

        if (error is String) {
          errorMessage = error;
        } else if (error is Map) {
          errorMessage = error['error'] ?? error['message'] ?? errorMessage;
        }
      } else if (decodedBody is String) {
        errorMessage = decodedBody;
      }

      throw errorMessage;
    }

    if (decodedBody is Map<String, dynamic>) {
      return decodedBody;
    }

    return <String, dynamic>{'data': decodedBody};
  }
}
