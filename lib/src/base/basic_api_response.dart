class BasicApiResponse {
  final bool success;
  final String? errorMessage;
  final String? message;
  final List<dynamic> missingParams;
  final dynamic data;

  BasicApiResponse.success(this.data, this.message)
      : success = true,
        errorMessage = null,
        missingParams = const [];
  BasicApiResponse.failed(this.errorMessage)
      : success = false,
        data = null,
        message = null,
        missingParams = const [];

  BasicApiResponse.missingParams(dynamic json)
      : success = false,
        errorMessage = json['message'],
        data = null,
        message = null,
        missingParams = json['data'] ?? const [];

  BasicApiResponse.fromJson(Map<String, dynamic> json)
      : success = json['success'],
        errorMessage = json['error'],
        data = json['data'],
        message = json['message'],
        missingParams = const [];

  List<String> getMissingParams() {
    if (missingParams.isEmpty) return const [];

    List<String> missings = List.empty(growable: true);

    for (var element in missingParams) {
      try {
        Map<String, dynamic> map = element;

        for (var key in map.keys) {
          missings.add(map[key]);
        }
      } catch (e) {}
    }

    return missings;
  }
}
