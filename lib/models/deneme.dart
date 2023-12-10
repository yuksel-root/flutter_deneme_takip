class DenemeModel {
  final int? falseCount;
  final String? denemeDate;
  final String? subjectName;
  DenemeModel({this.falseCount, this.subjectName, this.denemeDate});

  Map<String, dynamic> toMap() {
    return ({
      "falseCount": falseCount ?? 999,
      "denemeDate": denemeDate ?? "nullDate",
      "subjectName": subjectName ?? "nullSubjectName",
    });
  }
}
