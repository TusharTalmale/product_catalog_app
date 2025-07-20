import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:product_catalog_app/models/product_model.dart';
import 'package:logger/logger.dart'; 

part 'api_service.g.dart'; 

@RestApi(baseUrl: "https://fakestoreapi.com/")
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  static ApiService create() {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          Logger().d('REQUEST[${options.method}] => PATH: ${options.path}');
          Logger().d('Headers: ${options.headers}');
          Logger().d('Data: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          Logger().d('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          Logger().d('Data: ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          Logger().e('ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
          Logger().e('Error message: ${e.message}');
          if (e.response != null) {
            Logger().e('Error response data: ${e.response?.data}');
          }
          return handler.next(e);
        },
      ),
    );
    return ApiService(dio);
  }

  @GET("/products")
  Future<List<Product>> getProducts();

  @GET("/products/{id}")
  Future<Product> getProductById(@Path("id") int id);
}
