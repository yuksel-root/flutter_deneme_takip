class DenemePostModel {
  final String tableName;
  final String userId;
  final List<Map<String, dynamic>>? tableData;

  DenemePostModel({
    required this.userId,
    required this.tableName,
    this.tableData,
  });

  factory DenemePostModel.fromJson(Map<String, dynamic> json) {
    return DenemePostModel(
      userId: json['userId'] ?? "",
      tableName: json['tableName'] ?? "",
      tableData: List<Map<String, dynamic>>.from(json['tableData'] ?? []),
    );
  }
}
