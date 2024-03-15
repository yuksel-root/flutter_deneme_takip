class ExamModel {
  final int? examId;
  final String? examName;
  final String? examDate;

  ExamModel({this.examId, this.examName, this.examDate});

  Map<String, dynamic> toMap() {
    return {
      "examId": examId ?? 777,
      "examName": examName ?? "nullDName",
      "examDate": examDate ?? "nullDate",
    };
  }
}
