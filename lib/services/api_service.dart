import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: "https://cocomastudios.com/cocoma_api")
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @POST("/api/login")
  Future<dynamic> login(
      @Body() Map<String, dynamic> body,
      );
}