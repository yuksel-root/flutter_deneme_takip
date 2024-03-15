class LessonModel {
  final int? lessonId;
  final String? lessonName;
  final int? lessonIndex;

  LessonModel({
    this.lessonId,
    this.lessonName,
    this.lessonIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      "lesson_id": lessonId ?? 999,
      "lesson_name": lessonName ?? "nullLessonName",
      "lesson_index": lessonIndex ?? 0,
    };
  }

  LessonModel fromJson(Map<String, dynamic> json) {
    return LessonModel(
      lessonId: json['lesson_id'] ?? 999,
      lessonName: json['lesson_name'] ?? "nullLesson",
      lessonIndex: json['lesson_index'] ?? 0,
    );
  }
}
