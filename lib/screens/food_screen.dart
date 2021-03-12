import 'dart:convert';

import 'package:cnc_flutter_app/connections/db_helper.dart';
import 'package:cnc_flutter_app/models/food_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fraction/fraction.dart';
import 'package:flutter_picker/flutter_picker.dart';

class FoodPage extends StatefulWidget {
  Food selection;
  String selectedDate;

  FoodPage(Food selection, String selectedDate) {
    this.selection = selection;
    this.selectedDate = selectedDate;
  }

  @override
  FoodProfile createState() => FoodProfile(selection, selectedDate);
}

class FoodProfile extends State<FoodPage> {
  Food currentFood;
  String selectedDate;

  bool showFat = false;
  bool showCarbs = false;
  bool showFraction = true;
  bool switched = false;

  DateTime entryTime = DateTime.now();

  // DateTime entryTime = new DateTime(1, 1, 1, 13, 29);
  double portion = 1;
  double actualPortion = 1;
  String servingAsFraction = '1';
  String actualServingAsFraction;
  int initialFirstSelection = 1;
  int initialSecondSelection = 0;
  int initialTimeFirstSelection = 1;
  int initialTimeSecondSelection = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController portionCtl = new TextEditingController();
  final TextEditingController dateCtl = new TextEditingController();

  var dropdownOptions = new Map();

  FoodProfile(Food selection, String selectedDate) {
    currentFood = selection;
    this.selectedDate = selectedDate;

    if (portion <= 1 || portion % 1 == 0) {
      servingAsFraction = portion.toFraction().toString();
      actualServingAsFraction = portion.toFraction().toString();
    } else {
      servingAsFraction = portion.toMixedFraction().toString();
      actualServingAsFraction = portion.toMixedFraction().toString();
    }
    portionCtl.text = actualServingAsFraction;
    String hour = '';
    String minute = '';
    String tod = '';
    if (entryTime.hour == 12) {
      hour = entryTime.hour.toString();
      tod = 'PM';
    } else if (entryTime.hour > 12) {
      hour = (entryTime.hour - 12).toString();
      tod = 'PM';
    } else {
      hour = entryTime.hour.toString();
      if (entryTime.hour == 0) {
        hour = '12';
      }
      tod = 'AM';
    }
    if (entryTime.minute < 10) {
      minute = '0' + entryTime.minute.toString();
    } else {
      minute = entryTime.minute.toString();
    }

    dateCtl.text = hour + ':' + minute + ' ' + tod;

    String temp = portion.toString();
    initialFirstSelection = int.parse(temp.split(".")[0]);
    temp = portion.toString().split(".")[1];
    if (double.parse(temp) == 25) {
      initialSecondSelection = 1;
    } else if (double.parse(temp) == 5) {
      initialSecondSelection = 2;
    } else if (double.parse(temp) == 75) {
      initialSecondSelection = 3;
    } else {
      initialSecondSelection = 0;
    }
  }

  var pickerData = '''
[
    [ 
        "0",
        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "7",
        "8",
        "9"
    ],
    [
        "",
        "1/4",
        "1/2",
        "3/4"
    ]
]
    ''';

  var data = '''
[
    [
         "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "7",
        "8",
        "9",
        "10",
        "11",
        "12"
    ],
    [
       "00",
        "01",
        "02",
        "03",
        "04",
        "05",
        "06",
        "07",
        "08",
        "09",
        "10",
        "11",
        "12",
        "13",
        "14",
        "15",
        "16",
        "17",
        "18",
        "19",
        "20",
        "21",
        "22",
        "23",
        "24",
        "25",
        "26",
        "27",
        "28",
        "29",
        "30",
        "31",
        "32",
        "33",
        "34",
        "35",
        "36",
        "37",
        "38",
        "39",
        "40",
        "41",
        "42",
        "43",
        "44",
        "45",
        "46",
        "47",
        "48",
        "49",
        "50",
        "51",
        "52",
        "53",
        "54",
        "55",
        "56",
        "57",
        "58",
        "59"
    ],
    [
        "AM",
        "PM"
    ]
]
    ''';

  showPickerModal(BuildContext context) {
    new Picker(
        adapter: PickerDataAdapter<String>(
            pickerdata: new JsonDecoder().convert(pickerData), isArray: true),
        changeToFirst: false,
        hideHeader: false,
        selecteds: [initialFirstSelection, initialSecondSelection],
        onSelect: (Picker picker, int index, List<int> selected) {
          int firstNumber = int.parse(picker.getSelectedValues()[0]);
          double secondNumber;
          if (picker.getSelectedValues()[1] == '1/4') {
            secondNumber = 0.25;
          } else if (picker.getSelectedValues()[1] == '1/2') {
            secondNumber = 0.5;
          } else if (picker.getSelectedValues()[1] == '3/4') {
            secondNumber = 0.75;
          } else {
            secondNumber = 0;
          }
          portion = secondNumber + firstNumber;
          this.setState(() {
            // stateText = picker.adapter.toString();
          });
        },
        onCancel: () {
          portion = actualPortion;
          servingAsFraction = actualServingAsFraction;
          portionCtl.text = actualServingAsFraction;
          setState(() {});
        },
        onConfirm: (Picker picker, List value) {
          int firstNumber = int.parse(picker.getSelectedValues()[0]);
          double secondNumber;
          if (picker.getSelectedValues()[1] == '1/4') {
            secondNumber = 0.25;
          } else if (picker.getSelectedValues()[1] == '1/2') {
            secondNumber = 0.5;
          } else if (picker.getSelectedValues()[1] == '3/4') {
            secondNumber = 0.75;
          } else {
            secondNumber = 0;
          }

          portion = secondNumber + firstNumber;
          String temp = portion.toString();
          initialFirstSelection = int.parse(portion.toString().split(".")[0]);
          temp = portion.toString().split(".")[1];
          if (double.parse(temp) == 25) {
            initialSecondSelection = 1;
          } else if (double.parse(temp) == 5) {
            initialSecondSelection = 2;
          } else if (double.parse(temp) == 75) {
            initialSecondSelection = 3;
          } else {
            initialSecondSelection = 0;
          }
          actualPortion = portion;
          if (portion <= 1 || portion % 1 == 0) {
            servingAsFraction = portion.toFraction().toString();
            actualServingAsFraction = portion.toFraction().toString();
          } else {
            servingAsFraction = portion.toMixedFraction().toString();
            actualServingAsFraction = portion.toMixedFraction().toString();
          }
          portionCtl.text = actualServingAsFraction;
          setState(() {});
        }).showModal(this.context); //_scaffoldKey.currentState);
  }

  saveNewEntry() async {
    var db = new DBHelper();
    var time = entryTime.toString().substring(0, 19);
    time = time.split(" ")[1];
    var dateTime = selectedDate + " " + time;
    print(dateTime);
    var response = await db.saveNewFoodLogEntry(
        dateTime, selectedDate, 1, currentFood.id, portion);
  }

  _pickTime() async {
    TimeOfDay t = await showTimePicker(
        context: context,
        initialTime:
            new TimeOfDay(hour: entryTime.hour, minute: entryTime.minute),
        initialEntryMode: TimePickerEntryMode.input,
        helpText: 'Time of Meal'
        // cancelText: 'testing'

        );
    if (t != null)
      setState(() {
        String hour = '';
        String minute = '';
        String tod = '';
        if (t.hour == 12) {
          hour = t.hour.toString();
          tod = 'PM';
        } else if (t.hour > 12) {
          hour = (t.hour - 12).toString();
          tod = 'PM';
        } else {
          hour = t.hour.toString();
          if (t.hour == 0) {
            hour = '12';
          }
          tod = 'AM';
        }
        if (t.minute < 10) {
          minute = '0' + t.minute.toString();
        } else {
          minute = t.minute.toString();
        }

        dateCtl.text = hour + ':' + minute + ' ' + tod;
        entryTime = new DateTime(
            entryTime.year, entryTime.month, entryTime.day, t.hour, t.minute);
        print('Time of Day in food = ' + t.toString());
      });
  }

  getIcon(x) {
    if(x) {
      return Icon(Icons.keyboard_arrow_up);
    }
    Icon(Icons.keyboard_arrow_down);
  }

  @override
  Widget build(BuildContext context) {
    String servingSizeAsFraction;
    if (switched) {
      if (portion <= 1 || portion % 1 == 0) {
        servingAsFraction = portion.toFraction().toString();
        actualServingAsFraction = portion.toFraction().toString();
      } else {
        servingAsFraction = portion.toMixedFraction().toString();
        actualServingAsFraction = portion.toMixedFraction().toString();
      }
      portionCtl.text = actualServingAsFraction;
    }
    if (currentFood.commonPortionSizeAmount > 1) {
      var x = currentFood.commonPortionSizeAmount.toMixedFraction();
      x.reduce();
      servingSizeAsFraction = x.toString().split(" ")[0];
    } else {
      var x = currentFood.commonPortionSizeAmount.toFraction();
      x.reduce();
      servingSizeAsFraction = x.toString();
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('currentFood.description'),
        ),
        body: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(children: [

            Row(
              children: <Widget>[
                // Container(
                //   width: MediaQuery.of(context).size.width / 6,
                //   height: MediaQuery.of(context).size.width / 6,
                // ),
                Expanded( // add this
                  child: Padding(
                    padding: const EdgeInsets.all(8.0), // give some padding
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min, // set it to min
                      children: <Widget>[

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Column(
                              children: [
                                Text(
                                  (currentFood.kcal * portion).round().toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 60),
                                ),
                                Text(
                                  'Calories',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 24),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                DataTable(
                                  horizontalMargin: 0,
                                  headingRowHeight: 0,
                                  dataRowHeight: 20,
                                  dividerThickness: 0,
                                  // columnSpacing: 20,

                                  columns: <DataColumn>[
                                    DataColumn(
                                      label: Text(
                                        '',
                                        style: TextStyle(fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        '',
                                        style: TextStyle(fontStyle: FontStyle.italic),
                                      ),
                                    ),

                                  ],
                                  rows: <DataRow>[
                                    DataRow(
                                      cells: <DataCell>[
                                        DataCell(Text('Fat')),
                                        DataCell(Row(
                                          children: [
                                            Text(
                                              (currentFood.fatInGrams * portion).round().toString() +
                                                  'g',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),

                                            if(showFat)... [
                                              GestureDetector(
                                                  onTap: () {
                                                    showFat = !showFat;
                                                    setState(() {});
                                                  },
                                                  child: Icon(Icons.keyboard_arrow_up))
                                            ],
                                            if(!showFat)... [
                                              GestureDetector(
                                                  onTap: () {
                                                    showFat = !showFat;
                                                    setState(() {});
                                                  },
                                                  child: Icon(Icons.keyboard_arrow_down))
                                            ],
                                          ],
                                        ),),
                                      ],
                                    ),
                                    if(showFat) ... [
                                      DataRow(
                                        cells: <DataCell>[
                                          DataCell(Text('   Sat')),
                                          DataCell(Text('43')),
                                        ],
                                      ),
                                      DataRow(
                                        cells: <DataCell>[
                                          DataCell(Text('   Pol')),
                                          DataCell(Text('27')),
                                        ],
                                      ),DataRow(
                                        cells: <DataCell>[
                                          DataCell(Text('   Mon')),
                                          DataCell(Text('27')),
                                        ],
                                      ),
                                    ],
                                    DataRow(
                                      cells: <DataCell>[
                                        DataCell(Text('Fat')),
                                        DataCell(Row(
                                          children: [
                                            Text(
                                              (currentFood.fatInGrams * portion).round().toString() +
                                                  'g',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),

                                            if(showCarbs)... [
                                              GestureDetector(
                                                  onTap: () {
                                                    showCarbs = !showCarbs;
                                                    setState(() {});
                                                  },
                                                  child: Icon(Icons.keyboard_arrow_up))
                                            ],
                                            if(!showCarbs)... [
                                              GestureDetector(
                                                  onTap: () {
                                                    showCarbs = !showCarbs;
                                                    setState(() {});
                                                  },
                                                  child: Icon(Icons.keyboard_arrow_down))
                                            ],
                                          ],
                                        ),),
                                      ],
                                    ),
                                    if(showCarbs) ... [
                                      DataRow(
                                        cells: <DataCell>[
                                          DataCell(Text('   Sug')),
                                          DataCell(Text('43')),
                                        ],
                                      ),
                                      DataRow(
                                        cells: <DataCell>[
                                          DataCell(Text('   fib')),
                                          DataCell(Text('27')),
                                        ],
                                      ),DataRow(
                                        cells: <DataCell>[
                                          DataCell(Text('   ins')),
                                          DataCell(Text('27')),
                                        ],
                                      ),
                                    ],
                                    DataRow(
                                      cells: <DataCell>[
                                        DataCell(Text('William')),
                                        DataCell(Text('27')),
                                      ],
                                    ),DataRow(
                                      cells: <DataCell>[
                                        DataCell(Text('William')),
                                        DataCell(Text('27')),
                                      ],
                                    ),DataRow(
                                      cells: <DataCell>[
                                        DataCell(Text('William')),
                                        DataCell(Text('27')),
                                      ],
                                    ),DataRow(
                                      cells: <DataCell>[
                                        DataCell(Text('William')),
                                        DataCell(Text('27')),
                                      ],
                                    ),DataRow(
                                      cells: <DataCell>[
                                        DataCell(Text('William')),
                                        DataCell(Text('27')),
                                      ],
                                    ),
                                  ],
                                )
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                //
                                //   children: [Text("test 2"),
                                //     Text("test 2"),
                                //
                                //   ],
                                // ),
                                // Text("test 2"),
                                // Text("test 2"),
                                // Text("test 2"),

                              ],
                            ),
                          ],
                        ),
                        // Text("SOME HASH KEY HERE"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Container(
            //   padding: EdgeInsets.symmetric(vertical: 15),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //     children: [
            //       Column(
            //         children: [
            //           Text(
            //             (currentFood.kcal * portion).round().toString(),
            //             style: TextStyle(
            //                 fontWeight: FontWeight.bold, fontSize: 48),
            //           ),
            //           Text(
            //             'Calories',
            //             style: TextStyle(
            //                 fontWeight: FontWeight.bold, fontSize: 18),
            //           ),
            //         ],
            //       ),
            //       Column(
            //         children: [
            //
            //
            //           Row(
            //             children: [
            //               Column(
            //                 children: [
            //                   Text(
            //                     '1',
            //                     style: TextStyle(
            //                       fontWeight: FontWeight.bold,
            //                     ),
            //                   )
            //                 ],
            //               ),
            //               Column(
            //                 children: [
            //                   Text(
            //                     '1',
            //                     style: TextStyle(
            //                       fontWeight: FontWeight.bold,
            //                     ),
            //                   )
            //                 ],
            //               ),
            //             ],
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),
            // Ink(
            //   child: ListTile(
            //     onTap: () {
            //       showFat = !showFat;
            //       setState(() {});
            //     },
            //     title: Text(
            //       'Fat ',
            //       style: TextStyle(
            //           fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
            //     ),
            //     subtitle: Text(
            //       'Tap to hide additional information ',
            //       style: TextStyle(
            //           fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
            //     ),
            //     trailing: Wrap(
            //       spacing: 12, // space between two icons
            //       children: <Widget>[
            //         Text(
            //           (currentFood.fatInGrams * portion).round().toString() +
            //               'g',
            //           style: TextStyle(fontWeight: FontWeight.bold),
            //         ), // icon-1
            //         Icon(Icons.arrow_drop_down_circle), // icon-2
            //       ],
            //     ),
            //   ),
            // ),
            // if (showFat) ...[
            //   Ink(
            //     color: Colors.grey.withOpacity(0.3),
            //     child: ListTile(
            //       title: Text(
            //         'Saturated fatty acids  ',
            //         style: TextStyle(
            //             fontWeight: FontWeight.bold,
            //             fontStyle: FontStyle.italic),
            //       ),
            //       trailing: Text(
            //         (currentFood.saturatedFattyAcidsInGrams * portion)
            //                 .round()
            //                 .toString() +
            //             'g',
            //         style: TextStyle(fontWeight: FontWeight.bold),
            //       ),
            //     ),
            //   ),
            //   Ink(
            //     color: Colors.grey.withOpacity(0.3),
            //     child: ListTile(
            //       title: Text(
            //         'Polyunsaturated fatty acids  ',
            //         style: TextStyle(
            //             fontWeight: FontWeight.bold,
            //             fontStyle: FontStyle.italic),
            //       ),
            //       trailing: Text(
            //         (currentFood.polyunsaturatedFattyAcidsInGrams * portion)
            //                 .round()
            //                 .toString() +
            //             'g',
            //         style: TextStyle(fontWeight: FontWeight.bold),
            //       ),
            //     ),
            //   ),
            //   Ink(
            //     color: Colors.grey.withOpacity(0.3),
            //     child: ListTile(
            //       title: Text(
            //         'Monounsaturated fatty acids  ',
            //         style: TextStyle(
            //             fontWeight: FontWeight.bold,
            //             fontStyle: FontStyle.italic),
            //       ),
            //       trailing: Text(
            //         (currentFood.monounsaturatedFattyAcidsInGrams * portion)
            //                 .round()
            //                 .toString() +
            //             'g',
            //         style: TextStyle(fontWeight: FontWeight.bold),
            //       ),
            //     ),
            //   ),
            // ],
            // Ink(
            //   child: ListTile(
            //     onTap: () {
            //       showCarbs = !showCarbs;
            //       setState(() {});
            //     },
            //     title: Text(
            //       'Carbohydrates ',
            //       style: TextStyle(
            //           fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
            //     ),
            //     subtitle: Text(
            //       'Tap to hide additional information ',
            //       style: TextStyle(
            //           fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
            //     ),
            //     trailing: Wrap(
            //       spacing: 12, // space between two icons
            //       children: <Widget>[
            //         Text(
            //           (currentFood.carbohydratesInGrams * portion)
            //                   .round()
            //                   .toString() +
            //               'g',
            //           style: TextStyle(fontWeight: FontWeight.bold),
            //         ), // icon-1
            //         Icon(Icons.arrow_drop_down_circle), // icon-2
            //       ],
            //     ),
            //   ),
            // ),
            // if (showCarbs) ...[
            //   Ink(
            //     color: Colors.grey.withOpacity(0.3),
            //     child: ListTile(
            //       title: Text(
            //         'Insoluble Fiber  ',
            //         style: TextStyle(
            //             fontWeight: FontWeight.bold,
            //             fontStyle: FontStyle.italic),
            //       ),
            //       trailing: Text(
            //         (currentFood.insolubleFiberInGrams * portion)
            //                 .round()
            //                 .toString() +
            //             'g',
            //         style: TextStyle(fontWeight: FontWeight.bold),
            //       ),
            //     ),
            //   ),
            //   Ink(
            //     color: Colors.grey.withOpacity(0.3),
            //     child: ListTile(
            //       title: Text(
            //         'Soluble Fiber  ',
            //         style: TextStyle(
            //             fontWeight: FontWeight.bold,
            //             fontStyle: FontStyle.italic),
            //       ),
            //       trailing: Text(
            //         (currentFood.solubleFiberInGrams * portion)
            //                 .round()
            //                 .toString() +
            //             'g',
            //         style: TextStyle(fontWeight: FontWeight.bold),
            //       ),
            //     ),
            //   ),
            //   Ink(
            //     color: Colors.grey.withOpacity(0.3),
            //     child: ListTile(
            //       title: Text(
            //         'Sugars  ',
            //         style: TextStyle(
            //             fontWeight: FontWeight.bold,
            //             fontStyle: FontStyle.italic),
            //       ),
            //       trailing: Text(
            //         (currentFood.sugarInGrams * portion).round().toString() +
            //             'g',
            //         style: TextStyle(fontWeight: FontWeight.bold),
            //       ),
            //     ),
            //   ),
            // ],
            // Ink(
            //   child: ListTile(
            //     title: Text(
            //       'Protein ',
            //       style: TextStyle(
            //           fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
            //     ),
            //     trailing: Text(
            //       (currentFood.proteinInGrams * portion).round().toString() +
            //           'g',
            //       style: TextStyle(fontWeight: FontWeight.bold),
            //     ),
            //   ),
            // ),
            // Ink(
            //   child: ListTile(
            //     title: Text(
            //       'Alcohol ',
            //       style: TextStyle(
            //           fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
            //     ),
            //     trailing: Text(
            //       (currentFood.alcoholInGrams * portion).round().toString() +
            //           'g',
            //       style: TextStyle(fontWeight: FontWeight.bold),
            //     ),
            //   ),
            // ),
            // Ink(
            //   child: ListTile(
            //     title: Text(
            //       'Calcium ',
            //       style: TextStyle(
            //           fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
            //     ),
            //     trailing: Text(
            //       (currentFood.calciumInMilligrams * portion)
            //               .round()
            //               .toString() +
            //           'mg',
            //       style: TextStyle(fontWeight: FontWeight.bold),
            //     ),
            //   ),
            // ),
            // Ink(
            //   child: ListTile(
            //     title: Text(
            //       'Sodium ',
            //       style: TextStyle(
            //           fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
            //     ),
            //     trailing: Text(
            //       (currentFood.sodiumInMilligrams * portion)
            //               .round()
            //               .toString() +
            //           'mg',
            //       style: TextStyle(fontWeight: FontWeight.bold),
            //     ),
            //   ),
            // ),
            // Ink(
            //   child: ListTile(
            //     title: Text(
            //       'Vitamin D ',
            //       style: TextStyle(
            //           fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
            //     ),
            //     trailing: Text(
            //       (currentFood.vitaminDInMicrograms * portion)
            //               .round()
            //               .toString() +
            //           'mcg',
            //       style: TextStyle(fontWeight: FontWeight.bold),
            //     ),
            //   ),
            // ),
            if (showFraction) ...[
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                        child: RaisedButton(
                      onPressed: () {
                        showFraction = true;
                        switched = true;
                        setState(() {});
                      },
                      child: Text(
                        "Fractions",
                        style:
                            TextStyle(color: Theme.of(context).highlightColor),
                      ),
                    )),
                    Expanded(
                        child: OutlineButton(
                      borderSide: BorderSide(
                          color: Theme.of(context).buttonColor,
                          style: BorderStyle.solid,
                          width: 2),
                      onPressed: () {
                        showFraction = false;
                        switched = true;
                        setState(() {});
                      },
                      child: Text("Decimal",
                          style:
                              TextStyle(color: Theme.of(context).buttonColor)),
                    )),
                  ]),
            ],
            if (!showFraction) ...[
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                        child: OutlineButton(
                      borderSide: BorderSide(
                          color: Theme.of(context).buttonColor,
                          style: BorderStyle.solid,
                          width: 2),
                      onPressed: () {
                        showFraction = true;
                        switched = true;
                        setState(() {});
                      },
                      child: Text("Fraction",
                          style:
                              TextStyle(color: Theme.of(context).buttonColor)),
                    )),
                    Expanded(
                        child: RaisedButton(
                      onPressed: () {
                        showFraction = false;
                        switched = true;
                        setState(() {});
                      },
                      child: Text(
                        "Decimal",
                        style:
                            TextStyle(color: Theme.of(context).highlightColor),
                      ),
                    )),
                  ]),
            ],
            Container(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        'Serving Size',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                      Text(
                        servingSizeAsFraction +
                            // currentFood.commonPortionSizeAmount.round().toString() +
                            " " +
                            currentFood.commonPortionSizeUnit,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'Number of Servings',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (showFraction) ...[
                        GestureDetector(
                          onTap: () => showPickerModal(context),
                          child: Container(
                            width: 175,
                            child: TextFormField(
                              enabled: false,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20.0,
                              ),
                              controller: portionCtl,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.only(bottom: 3, top: 5),
                                hintText: "# of servings",
                                isDense: true,
                              ),
                              onChanged: (text) {},
                            ),
                          ),
                        ),
                      ],
                      if (!showFraction) ...[
                        Container(
                          width: 175,
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20.0,
                              // height: 2.0,
                              // color: Colors.black
                            ),
                            initialValue: actualPortion.toStringAsFixed(2),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(4),
                              FilteringTextInputFormatter.deny(
                                  new RegExp('[ -]')),
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}'))
                            ],
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            // keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.only(bottom: 3, top: 5),
                              hintText: "# of servings",
                              isDense: true,
                              // border: InputBorder.none
                            ),
                            onChanged: (text) {
                              if (text.isNotEmpty) {
                                if (double.parse(text) > 10) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red,content: Text('Value cannot be greater than 10')));
                                  // Scaffold.of(context).showSnackBar(SnackBar(content: Text('Value cannot be greater than 10')));
                                  // portion = 1;
                                  // actualPortion = portion;
                                  //snack bar portion cannot be greater than 10
                                } else {
                                  portion = double.parse(text);
                                  actualPortion = portion;
                                }

                                print(actualPortion);
                              } else {
                                portion = 1;
                                actualPortion = portion;
                              }
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                      SizedBox(height: 8),
                      Text(
                        'Time eaten',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: _pickTime,
                        child: Container(
                          width: 175,
                          child: TextFormField(
                            enabled: false,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20.0,
                            ),
                            controller: dateCtl,
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.only(bottom: 3, top: 5),
                              hintText: "Enter time",
                              isDense: true,
                            ),
                            onChanged: (text) {},
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: ButtonTheme(
                minWidth: double.infinity,
                buttonColor: Theme.of(context).primaryColor,
                child: RaisedButton(
                  // padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('Save entry'),
                  onPressed: () {
                    saveNewEntry();
                    Navigator.pop(context, null);
                  },
                ),
              ),
            ),
          ]),
        ));
  }
}
