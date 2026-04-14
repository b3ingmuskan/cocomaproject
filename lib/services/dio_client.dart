import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: "https://cocomastudios.com/cocoma_api/api",
      headers: {"Accept": "application/json"},
    ),
  )..interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString("token");

        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
        }

        return handler.next(options);
      },
    ),
  );
}