import 'package:advanced_mobile_programming_app/app/models/product.dart';
import 'package:advanced_mobile_programming_app/app/utils/api_client.dart';

class ProductService {
  Future<List<Product>> getAll({String? search}) async {
    final apiClient = ApiClient('Products.search');

    if (search != null && search.isNotEmpty) {
      apiClient.addQuery('q', search);
    }

    final response = await apiClient.get();

    final result = <Product>[];

    dynamic data = response['products'];

    if (data is! List) {
      data = response['data'];
    }

    if (data is! List) {
      return result;
    }

    for (final item in data) {
      if (item is Map) {
        result.add(Product.fromJson(item));
      }
    }

    return result;
  }
}
