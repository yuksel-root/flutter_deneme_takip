class ExamDetailModel {
  final int? examDetailId;
  final int? examId;
  final int? subjectId;
  final int? lessonId;
  final int? falseCount;

  ExamDetailModel({
    this.examDetailId,
    this.examId,
    this.subjectId,
    this.lessonId,
    this.falseCount,
  });

  Map<String, dynamic> toMap() {
    return {
      "examId": examId ?? 777,
      "subjectId": subjectId ?? 777,
      "lessonId": lessonId ?? 777,
      "falseCount": falseCount ?? 999,
    };
  }
}
