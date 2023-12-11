import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/custom_app_bar.dart';
import 'package:flutter_deneme_takip/core/constants/lesson_list.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_db_provider.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_tables.dart';
import 'package:flutter_deneme_takip/core/navigation/navigation_service.dart';
import 'package:flutter_deneme_takip/models/deneme.dart';
import 'package:flutter_deneme_takip/view_model/deneme_view_model.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:intl/intl.dart';
import 'package:flutter_deneme_takip/core/constants/navigation_constants.dart';

class EditDeneme extends StatefulWidget {
  final String? lessonName;
  final List<String>? subjectList;

  const EditDeneme({Key? key, this.lessonName, this.subjectList})
      : super(key: key);

  @override
  State<EditDeneme> createState() => _EditDenemeState();
}

class _EditDenemeState extends State<EditDeneme> {
  final NavigationService _navigation = NavigationService.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late String _selectedSubject;
  late String _date;
  final DateTime _now = DateTime.now();
  late String? _lessonName;
  late List<String>? _subjectList;
  late String? _initTable;
  late int? _lastSubjectId;
  late int? _lastDenemeId;

  List<bool> _shouldShowInput = [true];
  List _inputDataList = [];

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
    _inputDataList.clear();
    _subjectSelectList.clear();
    _subjectSavedList.clear();
    _subjectList = widget.subjectList;

    _selectedSubject = widget.subjectList![0];

    _lessonName = widget.lessonName;
    _date =
        DateFormat('HH:mm:ss | d MMMM EEEE', 'tr_TR').format(_now).toString();

    _initTable = initTable();
    _lastSubjectId = 0;
    _lastDenemeId = 0;
  }

  String initTable() {
    String tableName =
        LessonList.tableNames[_lessonName] ?? DenemeTables.tarihTableName;
    return tableName;
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
        appBar: CustomAppBar(
          dynamicPreferredSize: context.mediaQuery.size.height / 10,
          appBar: AppBar(
              flexibleSpace: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceEvenly,
            spacing: 10,
            children: [
              Text(
                '${widget.lessonName} Dersi Girişi',
                style: TextStyle(fontSize: 20),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _inputDataList =
                        List.generate(_falseInputCount, (index) => []);
                    _subjectSelectList = List.generate(
                        _falseInputCount, (index) => "sl${index + 1}");
                    _subjectSavedList =
                        List.generate(_falseInputCount, (index) => "dl$index");
                    _shouldShowInput =
                        List.generate(_falseInputCount, (index) => true);
                    _falseCountsIntegers =
                        List.generate(_falseInputCount, (index) => null);
                  });
                },
                child: const Text('Konu Ekle'),
              ),
            ],
          )),
        ),
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
                        for (int i = 0; i < _inputDataList.length; i++)
                          _shouldShowInput[i]
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
                                          color: Colors.red,
                                          icon: const Icon(Icons.delete),
                                          onPressed: () {
                                            setState(() {
                                              _inputDataList.removeAt(i);
                                              _shouldShowInput.removeAt(i);
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
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                DateTime now = DateTime.now();
                _date = DateFormat('HH:mm:ss | d MMMM EEEE', 'tr_TR')
                    .format(now)
                    .toString();
                _lessonName = widget.lessonName;

                /*        print("int");
                print(_falseCountsIntegers);
                print("int");

                 */
                print("str");
                print(_subjectSavedList);
                print("str");
                _lastSubjectId = await DenemeDbProvider.db
                    .getFindLastId(_initTable!, "subjectId");
                _lastDenemeId = await DenemeDbProvider.db
                    .getFindLastId(_initTable!, "denemeId");
                final int? _denemeIdClicked = (_lastDenemeId ?? 0) + 1;
                print("-------x-----\n");
                print(_lastSubjectId);
                print("-------x-----\n");
                print(_lastDenemeId);
                print("-------x-----\n");
                print(_denemeIdClicked);
                print("-------x-----\n");
                int k = 1;
                for (int i = 0; i < _inputDataList.length; i++) {
                  DenemeModel denemeModel = DenemeModel(
                      denemeId: _denemeIdClicked,
                      subjectId: (_lastSubjectId ?? 0) + k,
                      falseCount: _falseCountsIntegers[i],
                      denemeDate: _date,
                      subjectName: _subjectSavedList[i]);
                  DenemeViewModel().saveDeneme(denemeModel, _initTable!);
                  _navigation.navigateToPageClear(
                      path: NavigationConstants.homeView,
                      data: []); //still be fixed other routes

                  k++;
                }
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
