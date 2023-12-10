import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_db_provider.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_tables.dart';
import 'package:flutter_deneme_takip/models/deneme.dart';
import 'package:flutter_deneme_takip/view_model/deneme_view_model.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:intl/intl.dart';

class EditDeneme extends StatefulWidget {
  final String? lessonName;
  final List<String>? subjectList;

  const EditDeneme({Key? key, this.lessonName, this.subjectList})
      : super(key: key);

  @override
  State<EditDeneme> createState() => _EditDenemeState();
}

class _EditDenemeState extends State<EditDeneme> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late String _selectedSubject;
  String? _savedSubject;
  late String _date;
  final DateTime _now = DateTime.now();
  late String? _lessonName;
  late List<String>? _subjectList;

  List<bool> _shouldShowSubject = [true];
  List _subjectDataList = [];
  List<String> _subjectSelectList = ["Konu Seçiniz"];

  List<String> _subjectSavedList = ["s"];

  final TextEditingController? falseInputCountController =
      TextEditingController();

  int _falseInputCount = 1;
  List<int?> _falseCountsIntegers = [];

  @override
  void initState() {
    super.initState();
    _falseCountsIntegers.clear();
    _subjectDataList.clear();
    _subjectSelectList.clear();
    _subjectSavedList.clear();
    _subjectList = widget.subjectList;

    _selectedSubject = widget.subjectList![0];

    _lessonName = widget.lessonName;
    _date =
        DateFormat('HH:mm:ss | d MMMM EEEE', 'tr_TR').format(_now).toString();
  }

  @override
  void dispose() {
    super.dispose();
    falseInputCountController!.dispose();
  }

  Map<int, TextEditingController> falseCountControllers = {};

  @override
  Widget build(BuildContext context) {
    //final denemeProvs = Provider.of<DenemeViewModel>(context, listen: true);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text('${widget.lessonName} Deneme Girişi')),
        body: Padding(
          padding: EdgeInsets.all(context.dynamicW(0.0375)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 50,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(child: falseInputCounter(context)),
                        for (int i = 0; i < _subjectDataList.length; i++)
                          _shouldShowSubject[i]
                              ? Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                            child: inputFalseCount(context, i)),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () {
                                            setState(() {
                                              _subjectDataList.removeAt(i);
                                              _shouldShowSubject.removeAt(i);
                                              _falseCountsIntegers.removeAt(i);
                                              _subjectSelectList.removeAt(i);
                                              _subjectSavedList.removeAt(i);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: context.dynamicH(0.0428),
                                    ),
                                    subjectDropDownButton(i),
                                    SizedBox(
                                      height: context.dynamicH(0.0428),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _subjectDataList = List.generate(
                                  _falseInputCount, (index) => []);
                              _subjectSelectList = List.generate(
                                  _falseInputCount,
                                  (index) => "sl${index + 1}");
                              _subjectSavedList = List.generate(
                                  _falseInputCount, (index) => "dl$index");
                              _shouldShowSubject = List.generate(
                                  _falseInputCount, (index) => true);
                              _falseCountsIntegers = List.generate(
                                  _falseInputCount, (index) => null);
                            });
                          },
                          child: const Text('Konu Ekle'),
                        ),
                        SizedBox(
                          height: context.dynamicH(0.0428),
                        ),
                        elevatedButtons(context),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField inputFalseCount(BuildContext context, int index) {
    final f = _falseCountsIntegers[index];
    final controller = TextEditingController(text: f?.toString());
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen boş bırakmayın';
        }

        return null;
      },
      onChanged: (value) {
        _falseCountsIntegers[index] = (int.parse(value));
      },
      onSaved: (value) {
        _falseCountsIntegers[index] = (int.parse(value!));
      },
      decoration: InputDecoration(
        hintText: "Konu Yanlış Sayısı",
        icon: buildContaierIconField(context, Icons.error_outline, Colors.red),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black)),
        border: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black)),
      ),
    );
  }

  TextFormField falseInputCounter(BuildContext context) {
    return TextFormField(
      controller: falseInputCountController,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen boş bırakmayın';
        }

        return null;
      },
      onChanged: (value) {
        _falseInputCount = int.parse(value);
      },
      onSaved: (value) {
        _falseInputCount = int.parse(value!);
      },
      decoration: InputDecoration(
        hintText: 'Gireceğiniz konu sayısı',
        icon: buildContaierIconField(
            context, Icons.assignment_rounded, const Color(0xff551a8b)),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black)),
        border: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black)),
      ),
    );
  }

  DropdownButtonFormField<String> subjectDropDownButton(int index) {
    return DropdownButtonFormField<String>(
      dropdownColor: Colors.white,
      value: _selectedSubject,
      items: _subjectList!
          .map((String? value) => DropdownMenuItem(
                value: value!,
                child: Text(value),
              ))
          .toList(),
      onSaved: (String? newValue) {
        _subjectSavedList[index] = newValue!;
      },
      onChanged: (String? newValue) {
        if (newValue != null) {
          _subjectSelectList[index] = newValue;
        } else {
          print("null dropDown error");
        }
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        print(_subjectSavedList);

        if (value == null || value.isEmpty) {
          return 'Lütfen bir konu seçiniz';
        }
        return null;
      },
    );
  }

  SizedBox elevatedButtons(BuildContext context) {
    return SizedBox(
        height: context.dynamicH(0.0714), //50px
        child: ElevatedButton.icon(
            icon: const Icon(color: Colors.green, Icons.save),
            label: Text(" Kaydet ",
                style: TextStyle(
                    color: Colors.white,
                    fontSize:
                        context.dynamicH(0.00571) * context.dynamicW(0.01))),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                DateTime now = DateTime.now();
                _date = DateFormat('HH:mm:ss | d MMMM EEEE', 'tr_TR')
                    .format(now)
                    .toString();
                _lessonName = widget.lessonName;
                print("int");
                print(_falseCountsIntegers);
                print("int");

                print("str");
                print(_subjectSavedList);
                print("str");

                for (int i = 0; i < _falseInputCount; i++) {
                  print("faleS");
                  print(_falseCountsIntegers[i]);
                  print("faleS");
                  DenemeModel denemeModel = DenemeModel(
                      falseCount: _falseCountsIntegers[i],
                      denemeDate: _date,
                      subjectName: _subjectSavedList[i]);
                  switch (_lessonName) {
                    case "Tarih":
                      print("Tarhis secs");
                      DenemeViewModel()
                          .saveDeneme(denemeModel, DenemeTables.tarihTableName);
                      break;
                    case "Matematik":
                      DenemeViewModel()
                          .saveDeneme(denemeModel, DenemeTables.mathTableName);
                      break;
                    default:
                  }
                }

                print("db veri");
                final deneme = DenemeDbProvider.db.getDeneme();
                print(deneme);
                print("db veri");
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: const StadiumBorder(),
              foregroundColor: Colors.black,
            )));
  }

  Container buildContaierIconField(
      BuildContext context, IconData icon, Color iconColor) {
    return Container(
      height: context.dynamicW(0.05),
      width: context.dynamicW(0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(context.dynamicW(0.0025)),
      child: Icon(icon, color: iconColor),
    );
  }
}
