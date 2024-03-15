class SubjectModel {
  final int? subjectId;
  final String? subjectName;
  final int? lessonId;
  final int? subjectIndex;

  SubjectModel(
      {this.subjectId, this.subjectName, this.subjectIndex, this.lessonId});

  Map<String, dynamic> toMap() {
    return {
      "subject_id": subjectId ?? 777,
      "subject_name": subjectName ?? "nullSubject",
      "lesson_id": lessonId ?? 777,
      "subject_index": subjectIndex ?? 0,
    };
  }

  SubjectModel fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      subjectId: json['subject_id'] ?? 999,
      subjectName: json['subject_name'] ?? "nullSub",
      lessonId: json['lesson_id'] ?? 999,
      subjectIndex: json['subject_index'] ?? 0,
    );
  }
}
