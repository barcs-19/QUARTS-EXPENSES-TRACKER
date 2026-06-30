import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_login/database/DatabaseHelper.dart';
import 'package:simple_login/model/ResourceModel.dart';
import 'package:simple_login/pages/user/ResourcesScreen.dart';

class AnalysisWidget extends StatefulWidget {
  final Function()? refreshDashboard;
  const AnalysisWidget({super.key, this.refreshDashboard});

  @override
  State<AnalysisWidget> createState() => _AnalysisWidgetState();
}

class _AnalysisWidgetState extends State<AnalysisWidget> {
  List<Resourcemodel> resources = [];
  int user_id = 0;

  final List<Color> colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
  ];

  void init_data() async {
    print("object");
    final prefs = await SharedPreferences.getInstance();
    int init_user_id = await prefs.getInt("id") ?? 0;
    final init_resources = await DatabaseHelper.GET_RESOURCE(init_user_id);

    setState(() {
      user_id = init_user_id;
      resources = init_resources;
      print(resources.toList());
      print("das");
    });
    widget.refreshDashboard?.call();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init_data();
  }

  Future<String> GET_RESOURCES_NAME(int resources_id) {
    return DatabaseHelper.GET_RESOURCES_NAME(resources_id);
  }

  String BudgetFormatter(double budget) {
    String formattedBudget = NumberFormat.currency(
      locale: "en-PH",
      symbol: "₱",
      decimalDigits: 2,
    ).format(budget);
    return formattedBudget;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(decoration: BackgroundContainer(6), child: buildPadding()),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BackgroundContainer(2),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Text("Cravings"),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 45,
                    ),
                    child: Text(
                      "10",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BackgroundContainer(2),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Text("Expenses"),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 45,
                    ),
                    child: Text(
                      "10",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BackgroundContainer(2),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Text("Resources"),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 45,
                    ),
                    child: Text(
                      "10",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  BoxDecoration BackgroundContainer(double blurRadius) {
    return BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black26.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: blurRadius,
        ),
      ],
    );
  }

  Padding buildPadding() {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: GestureDetector(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (_) => ResourcesScreen(onUpdate: init_data,)));
        },
        child: Row(
          children: [
            if (resources.length == 1 &&
                (resources.first.balance as num).toDouble() <= 0)
              Expanded(
                child: SizedBox(
                  height: 160,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.blue, size: 40),
                      Text("Add cash to view graph"),
                    ],
                  ),
                ),
              )
            else ...[
              Expanded(
                flex: 1,
                child: Container(
                  height: 160,
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 2,
                      sectionsSpace: 6,
                      sections: List.generate(resources.length, (index) {
                        final item = resources[index];
                        return PieChartSectionData(
                          value: item.balance?.toDouble() ?? 0,
                          title: "",
                          color: colors[index % colors.length],
                          radius: 55,
                          titleStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: SizedBox(
                    height: 160,

                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...List.generate(resources.length, (index) {
                        return Row(
                          children: [
                            Container(
                              height: 15,
                              width: 15,
                              color: colors[index % colors.length],
                            ),
                            SizedBox(width: 5),
                            Text(resources[index].title.toString()),
                            Spacer(),
                            Text(
                              BudgetFormatter(
                                (resources[index].balance as num).toDouble(),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                )
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
