class Response {
  bool isSuccess;
  dynamic body;
  String? message;
  Response(this.isSuccess, this.body, this.message);
  Response.fromMap(Map<String, dynamic> map)
      : isSuccess = map["isSuccess"],
        body = map["body"],
        message = map["message"];

  Response.success(this.body)
      : isSuccess = true,
        message = null;
  Response.fail(this.message)
      : isSuccess = false,
        body = null;
}
