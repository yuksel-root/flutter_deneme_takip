import 'package:flutter/material.dart';
import 'package:flutter_deneme_takip/components/custom_app_bar.dart';
import 'package:flutter_deneme_takip/core/constants/lesson_list.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_db_provider.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_tables.dart';
import 'package:flutter_deneme_takip/core/navigation/navigation_service.dart';
import 'package:flutter_deneme_takip/core/notifier/bottom_navigation_notifier.dart';
import 'package:flutter_deneme_takip/models/deneme.dart';
import 'package:flutter_deneme_takip/view/tabbar_views/bottom_tabbar_view.dart';
import 'package:flutter_deneme_takip/view_model/deneme_view_model.dart';
import 'package:flutter_deneme_takip/core/extensions/context_extensions.dart';
import 'package:intl/intl.dart';
import 'package:flutter_deneme_takip/core/constants/navigation_constants.dart';
import 'package:flutter_deneme_takip/components/alert_dialog.dart';
import 'package:provider/provider.dart';

class InsertDeneme extends StatefulWidget {
  final String? lessonName;
  final List<String>? subjectList;

  const InsertDeneme({Key? key, this.lessonName, this.subjectList})
      : super(key: key);

  @override
  State<InsertDeneme> createState() => _EditDenemeState();
}

class _EditDenemeState extends State<InsertDeneme> {
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

  bool _isAlertOpen = false;

  List<String?> _subjectSavedList = [];
  Set<String>? setSavedSubjects = {};

  final TextEditingController? falseInputCountController =
      TextEditingController();

  late int? _falseInputCount;
  List<int?> _falseCountsIntegers = [];

  @override
  void initState() {
    super.initState();
    _falseCountsIntegers.clear();
    _subjectSavedList.clear();

    _subjectList = widget.subjectList;

    _selectedSubject = widget.subjectList![0];
    _lessonName = widget.lessonName;
    _falseInputCount = _subjectList!.length;
    _date =
        DateFormat('HH:mm:ss | d MMMM EEEE', 'tr_TR').format(_now).toString();

    _initTable = initTable();
    _lastSubjectId = 0;
    _lastDenemeId = 0;
    inputOlustur();
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

  void inputOlustur() {
    print("InputCount");
    print(_falseInputCount);
    print("InputCount");

    _falseCountsIntegers = List.generate(_falseInputCount!, (index) => null);
    _subjectSavedList = List.generate(_falseInputCount!, (index) => null);
  }

  @override
  Widget build(BuildContext context) {
    final denemeProv = Provider.of<DenemeViewModel>(context, listen: true);
    final bottomTabProv =
        Provider.of<BottomNavigationProvider>(context, listen: true);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: CustomAppBar(
            dynamicPreferredSize: context.mediaQuery.size.height / 14,
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
                  elevatedButtons(context, denemeProv, bottomTabProv),
                ]))),
        body: Padding(
          padding: EdgeInsets.all(context.dynamicW(0.00714)),
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
                        for (int i = 0; i < _falseCountsIntegers.length; i++)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: inputFalseCount(context, i)),
                                ],
                              ),
                              SizedBox(
                                height: context.dynamicH(0.0428),
                              ),
                            ],
                          ),
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
    // DenemeViewModel().printFunct("f", f);
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      autofocus: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen boş bırakmayın';
        }

        return null;
      },
      onChanged: (value) {
        try {
          _falseCountsIntegers[index] = (int.parse(value));
          _subjectSavedList[index] = (_subjectList![index]);
        } catch (e) {
          DenemeViewModel().printFunct("onChanged catch", e);
        }
      },
      decoration: InputDecoration(
        hintText: "Konu Yanlış Sayısı",
        label: Text(
          _subjectList![index],
          style: TextStyle(fontSize: 14),
        ),
        icon: buildContaierIconField(
            context, Icons.assignment_rounded, Colors.purple),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black)),
        border: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black)),
      ),
    );
  }

  SizedBox elevatedButtons(BuildContext context, DenemeViewModel denemeProv,
      BottomNavigationProvider bottomProv) {
    return SizedBox(
        height: context.dynamicH(0.0571), //40px
        child: ElevatedButton.icon(
            icon: const Icon(color: Colors.green, Icons.save),
            label: Text(" Kaydet ",
                style: TextStyle(
                    color: Colors.white,
                    fontSize:
                        context.dynamicH(0.00571) * context.dynamicW(0.01))),
            onPressed: () async {
              DateTime now = DateTime.now();

              _date = DateFormat('HH:mm:ss | d MMMM EEEE', 'tr_TR')
                  .format(now)
                  .toString();

              _lessonName = widget.lessonName;
              _lastSubjectId = await DenemeDbProvider.db
                  .getFindLastId(_initTable!, "subjectId");
              _lastDenemeId = await DenemeDbProvider.db
                  .getFindLastId(_initTable!, "denemeId");
              final int? _denemeIdClicked = (_lastDenemeId ?? 0) + 1;
              int k = 1;
              denemeProv.printFunct("subjectList", _subjectSavedList);
              denemeProv.printFunct("falseCounters", _falseCountsIntegers);
              for (int i = 0; i < _falseCountsIntegers.length; i++) {
                if (_subjectSavedList[i] != null) {
                  print("İF");
                  print(_subjectSavedList[i]);
                  print(_falseCountsIntegers[i]); //BUNLARA GİRMİYOR

                  DenemeModel denemeModel = DenemeModel(
                      denemeId: _denemeIdClicked,
                      subjectId: (_lastSubjectId ?? 0) + k,
                      falseCount: _falseCountsIntegers[i],
                      denemeDate: _date,
                      subjectName: _subjectSavedList[i]);

                  denemeProv.saveDeneme(denemeModel, _initTable!);
                  bottomProv.setCurrentIndex(0);
                  print(bottomProv.getCurrentIndex);
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

  _showDialog(BuildContext context, String title, String content) {
    AlertView alert = AlertView(
      title: title,
      content: content,
      continueFunction: () => {
        Navigator.of(context).pop(),
      },
    );

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
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
