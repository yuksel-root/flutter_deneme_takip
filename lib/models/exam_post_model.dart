class ExamPostModel {
  final String tableName;
  final String userId;
  final List<Map<String, dynamic>>? tableData;

  ExamPostModel({
    required this.userId,
    required this.tableName,
    this.tableData,
  });

  factory ExamPostModel.fromJson(Map<String, dynamic> json) {
    return ExamPostModel(
      userId: json['userId'] ?? "",
      tableName: json['tableName'] ?? "",
      tableData: List<Map<String, dynamic>>.from(json['tableData'] ?? []),
    );
  }
}
