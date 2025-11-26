class ApiResponse<T> {
  final String status;
  final String? message;
  final T? data;
  final int? count;

  ApiResponse({
    required this.status,
    this.message,
    this.data,
    this.count,
  });

  bool get isSuccess => status == 'success';

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      status: json['status'] as String,
      message: json['message'] as String?,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      count: json['count'] as int?,
    );
  }
}
