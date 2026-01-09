import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:archive/archive.dart';
import 'package:brotli/brotli.dart';

class Request {
  static const _gzipDecoder = GZipDecoder();
  static const _brotilDecoder = BrotliDecoder();

  static final Request _instance = Request._internal();
  static late final Dio dio;

  factory Request() => _instance;

  /*
   * config it and create
   */
  Request._internal() {
    //BaseOptions、Options、RequestOptions 都可以配置参数，优先级别依次递增，且可以根据优先级别覆盖参数
    BaseOptions options = BaseOptions(
      //请求基地址,可以包含子路径
      //连接服务器超时时间，单位是毫秒.
      connectTimeout: const Duration(milliseconds: 10000),
      //响应流上前后两次接受到数据的间隔，单位为毫秒。
      receiveTimeout: const Duration(milliseconds: 10000),
      //Http请求头.
      headers: {
        'user-agent': 'Dart/3.6 (dart:io)', // Http2Adapter不会自动添加标头
        // 'accept-encoding': 'br,gzip',
      },
      responseDecoder: _responseDecoder,
      // Http2Adapter没有自动解压
      persistentConnection: true,
    );

    late final String systemProxyHost;
    late final int? systemProxyPort;

    final http11Adapter = IOHttpClientAdapter(
      createHttpClient: () => HttpClient()
        ..idleTimeout = const Duration(seconds: 15)
        ..autoUncompress = false, // Http2Adapter没有自动解压, 统一行为
    );

    dio = Dio(options)..httpClientAdapter = http11Adapter;

    // 日志拦截器 输出请求、响应内容
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: false,
          requestHeader: false,
          responseHeader: false,
        ),
      );
    }

    dio
      ..transformer = BackgroundTransformer()
      ..options.validateStatus = (int? status) {
        return status != null && status >= 200 && status < 300;
      };
  }

  /*
   * get请求
   */
  Future<Response> get<T>(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.get<T>(
        url,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {


      return Response(
        data: {'message': e}, // 将自定义 Map 数据赋值给 Response 的 data 属性
        statusCode: e.response?.statusCode ?? -1,
        requestOptions: e.requestOptions,
      );
    }
  }

  /*
   * post请求
   */
  Future<Response> post<T>(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    // if (kDebugMode) debugPrint('post-data: $data');
    try {
      return await dio.post<T>(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      return Response(
        data: {}, // 将自定义 Map 数据赋值给 Response 的 data 属性
        statusCode: e.response?.statusCode ?? -1,
        requestOptions: e.requestOptions,
      );
    }
  }

  /*
   * 下载文件
   */
  Future<Response> downloadFile(
    String urlPath,
    String savePath, {
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.download(
        urlPath,
        savePath,
        cancelToken: cancelToken,
        // onReceiveProgress: (int count, int total) {
        // 进度
        // if (kDebugMode) debugPrint("$count $total");
        // },
      );
      // if (kDebugMode) debugPrint('downloadFile success: ${response.data}');
    } on DioException catch (e) {
      // if (kDebugMode) debugPrint('downloadFile error: $e');
      return Response(
        statusCode: e.response?.statusCode ?? -1,
        requestOptions: e.requestOptions,
      );
    }
  }

  static List<int> responseBytesDecoder(
    List<int> responseBytes,
    Map<String, List<String>> headers,
  ) => switch (headers['content-encoding']?.firstOrNull) {
    'gzip' => _gzipDecoder.decodeBytes(responseBytes),
    'br' => _brotilDecoder.convert(responseBytes),
    _ => responseBytes,
  };

  static String _responseDecoder(
    List<int> responseBytes,
    RequestOptions options,
    ResponseBody responseBody,
  ) {
    return utf8.decode(
      responseBytesDecoder(responseBytes, responseBody.headers),
      allowMalformed: true,
    );
  }
}
