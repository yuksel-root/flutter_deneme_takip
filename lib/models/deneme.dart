class DenemeModel {
  final int? denemeId;
  final int? subjectId;
  final int? falseCount;
  final String? denemeDate;
  final String? subjectName;

  DenemeModel(
      {this.denemeId,
      this.subjectId,
      this.falseCount,
      this.subjectName,
      this.denemeDate});

  Map<String, dynamic> toMap() {
    return {
      "subjectId": subjectId ?? 777,
      "denemeId": denemeId ?? 99758,
      "falseCount": falseCount ?? 999,
      "denemeDate": denemeDate ?? "nullDate",
      "subjectName": subjectName ?? "nullSubjectName",
    };
  }
}
