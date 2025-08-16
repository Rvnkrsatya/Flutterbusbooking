class VrlBlockSeatResponse {
  final int blockId;
  final int status;
  final String message;

  VrlBlockSeatResponse({
    required this.blockId,
    required this.status,
    required this.message,
  });

  factory VrlBlockSeatResponse.fromJson(Map<String, dynamic> json) {
    return VrlBlockSeatResponse(
      blockId: json['BlockID'] ?? 0,
      status: json['Status'] ?? 0,
      message: json['Message'] ?? '',
    );
  }
}

class VrlBlockSeatApiResponse {
  final int status;
  final String message;
  final List<VrlBlockSeatResponse> data;

  VrlBlockSeatApiResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory VrlBlockSeatApiResponse.fromJson(Map<String, dynamic> json) {
    return VrlBlockSeatApiResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => VrlBlockSeatResponse.fromJson(e))
          .toList() ??
          [],
    );
  }
}