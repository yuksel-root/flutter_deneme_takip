import 'package:flutter_deneme_takip/core/local_database/deneme_tables.dart';

class LessonList {
  static const List<String> turkceSubject = <String>[
    "Konu Seçiniz",
    "Sözcükte Anlam",
    "Cümlenin Anlam",
    "Sözcük Türleri",
    "Sözcükte Yapı",
    "Cümlenin Ögeleri",
    "Ses Olayları",
    "Yazım Kuralları",
    "Noktalama İşaretleri",
    "Paragrafta Anlam",
    "Paragrafta Anlatım Yolları, Biçimleri",
    "Sözel Mantık",
  ];

  static const List<String> historySubjects = <String>[
    "Konu Seçiniz",
    "İslamiyet’ten Önceki Türk Devletleri",
    "İlk Müslüman Türk Devletleri",
    "Osmanlı Devleti Siyasi",
    "Osmanlı Devleti Kültür ve Uygarlık",
    "Kurtuluş Savaşı Hazırlık Dönemi",
    "Kurtuluş Savaşı Cepheleri",
    "Devrim Tarihi",
    "Atatürk Dönemi İç ve Dış Politika",
    "Atatürk İlkeleri Konusu",
    "Çağdaş Türk ve Dünya Tarihi"
  ];

  static const List<String> mathSubject = <String>[
    "Konu Seçiniz.",
    "Temel Kavramlar",
    "Rasyonel Sayılar",
    "Ondalık Sayılar",
    "Basit Eşitsizlikler",
    "Mutlak Değer",
    "Üslü Sayılar",
    "Köklü Sayılar",
    "Çarpanlara Ayırma",
    "Denklem Çözme",
    "Sayı Problemleri",
    "Yaş Problemleri",
    "Hareket Problemleri",
    "Yüzde Kar-Zarar, Faiz Problemleri",
    "Bağıntı ve Fonksiyon",
    "İşlem",
    "Olasılık",
    "Sayısal Mantık ",
  ];

  static const List<String> cografySubject = <String>[
    "Konu Seçiniz",
    "Türkiye Coğrafi Konumu",
    "Türkiye’nin Yer şekilleri Su Örtüsü",
    "Türkiye’nin İklimi Ve Bitki Örtüsü",
    "Toprak Ve Doğa Çevre",
    "Türkiye’nin Beşeri Coğrafyası",
    "Tarım Konusu",
    "Madenler Ve Enerji Kaynakları",
    "Sanayi Konusu",
    "Ulaşım Konusu",
    "Turizm Konusu",
  ];

  static const List<String> vatandasSubject = <String>[
    "Konu Seçiniz",
    "Hukukun Temel Kavramları",
    "Devlet Biçimleri Demokrasi Ve Kuvvetler Ayrılığı",
    "Anayasa Hukukuna Giriş Temel Kavramlar Ve Türk Anayasa Tarihi",
    "1982 Anayasasının Temel İlkeleri",
    "Yasama",
    "Yürütme",
    "Yargı",
    "Temel Hak Ve Hürriyetler",
    "İdare Hukuku Ve",
    "Uluslararası Kuruluşlar Ve Güncel Olaylar",
  ];

  static const List<String> lessonNameList = <String>[
    "Tarih",
    "Matematik",
    "Türkçe",
    "Coğrafya",
    "Vatandaşlık",
  ];

  static const Map<String, String> tableNames = {
    "Tarih": DenemeTables.tarihTableName,
    "Matematik": DenemeTables.mathTableName,
    "Vatandaşlık": DenemeTables.vatandasTableName,
    "Coğrafya": DenemeTables.cografyaTableName,
    "Türkçe": DenemeTables.turkceTableName,
  };

  static const List<dynamic> denemeTarih = <dynamic>[
    {
      "denemeId": [1, 2, 3, 4, 5],
      "subjects": [
        "İslamiyet’ten Önceki Türk Devletleri",
        "İlk Müslüman Türk Devletleri",
        "Osmanlı Devleti Siyasi",
        "Osmanlı Devleti Kültür ve Uygarlık",
        "Kurtuluş Savaşı Hazırlık Dönemi",
      ],
      "falseCount": [1, 2, 3, 4, 5],
    },
    {
      "denemeId": [6, 7, 8, 9, 10],
      "subjects": [
        "Kurtuluş Savaşı Cepheleri",
        "Devrim Tarihi",
        "Atatürk Dönemi İç ve Dış Politikai",
        "Atatürk İlkeleri Konusu",
        "Çağdaş Türk ve Dünya Tarihi"
      ],
      "falseCount": [5, 6, 7, 8, 9, 10],
    }
  ];
}
