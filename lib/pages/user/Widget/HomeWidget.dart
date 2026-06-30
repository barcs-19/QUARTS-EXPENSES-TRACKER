import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_login/database/DatabaseHelper.dart';
import 'package:simple_login/model/ExpensesModel.dart';
import 'package:simple_login/model/ResourceModel.dart';
import 'package:simple_login/pages/user/BugetTipsScreen.dart';
import 'package:simple_login/pages/user/CravingsScreen.dart';
import 'package:simple_login/pages/user/ExpensesScreen.dart';
import 'package:simple_login/pages/user/ResourcesScreen.dart';

class HomeWidget extends StatefulWidget {
  String formattedBudget = "";
  final Function()? onRefresh;

  HomeWidget({super.key, required this.formattedBudget, this.onRefresh});

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  List<Resourcemodel> resources = [];
  List<ExpensesModel> expenses = [];
  List<ExpensesModel> todayExpenses = [];

  int user_id = 0;
  String currentDateHeader = DateFormat("MMMM dd, yyyy").format(DateTime.now());

  final List<Color> colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
  ];

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

  void init_data() async {
    final prefs = await SharedPreferences.getInstance();
    int init_user_id = await prefs.getInt("id") ?? 0;
    final init_resources = await DatabaseHelper.GET_RESOURCE(init_user_id);
    final init_expenses = await DatabaseHelper.GET_ALL_EXPENSES(init_user_id);

    setState(() {
      user_id = init_user_id;
      resources = init_resources;
      expenses = init_expenses;

      final today = DateTime.now();

      todayExpenses = expenses.where((expense) {
        DateTime expenseDate = DateFormat(
          "MMMM dd, yyyy hh:mm:ss a",
        ).parse(expense.date.toString());

        return expenseDate.year == today.year &&
            expenseDate.month == today.month &&
            expenseDate.day == today.day;
      }).toList();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init_data();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BudgetContainer(context),
          SizedBox(height: 15),
          NavigationButtons(context),
          SizedBox(height: 15),
          Divider(),
          SizedBox(height: 15),
          Text(
            "Payment Sources",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 120,
            width: double.infinity,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: ((context, index) {
                return Container(
                  margin: EdgeInsets.only(right: 5),
                  width: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: colors[index % colors.length]
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(resources[index].title.toString(), style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w700, fontSize: 18),),
                        Spacer(),
                        Row(
                          children: [
                            Text("balance: ", style: TextStyle(color: Colors.white60, fontSize: 14),),
                            Text(BudgetFormatter((resources[index].balance as num).toDouble()), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              }),
              separatorBuilder: (_, _) => SizedBox(width: 10),
              itemCount: resources.length,
            ),
          ),
          SizedBox(height: 15),
          SizedBox(height: 15),
          Row(
            children: [
              Text("Today Expenses",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Spacer(),
              Text(
                currentDateHeader,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          if (todayExpenses.length == 0)
            SizedBox(
              width: double.infinity,
              height: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.gpp_good_rounded, color: Colors.blue, size: 40,),
                  Text("No expenses todays"),
                ],
              ),
            ),
          ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [buildExpensesCard(index)],
              );
            },
            separatorBuilder: (context, index) => SizedBox(height: 5),
            itemCount: todayExpenses.length,
          ),
          SizedBox(height: 25),
        ],
      ),
    );
  }

  SizedBox NavigationButtons(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                  width: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ResourcesScreen(onUpdate: widget.onRefresh),
                        ),
                      );
                      if (result == true) {}
                    },
                    child: Icon(Icons.wallet, size: 30, color: Colors.blue),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5,),
                Text("Resources", style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          SizedBox(
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                  width: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CravingsScreen(
                            refreshDashboard: widget.onRefresh,
                          ),
                        ),
                      );
                    },
                    child: Icon(Icons.fastfood, size: 30, color: Colors.blue),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5,),
                Text("Cravings", style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          SizedBox(
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                  width: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ExpensesScreen(reloadDashboard: widget.onRefresh),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.attach_money,
                      size: 30,
                      color: Colors.blue,
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5,),
                Text("Expenses", style: TextStyle(fontSize: 12)),              ],
            ),
          ),
          SizedBox(
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                  width: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BudgetTipScreen(),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.tips_and_updates,
                      size: 30,
                      color: Colors.blue,
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5,),
                Text("Budget Tips", style: TextStyle(fontSize: 12)),              ],
            ),
          ),
        ],
      ),
    );
  }

  Container BudgetContainer(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Budget",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.formattedBudget,
                    style: TextStyle(
                      color: Colors.white.withOpacity(1),
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ResourcesScreen()),
                        );
                      },
                      child: Text(
                        "Add cash",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildExpensesCard(int index) {
    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),

      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              todayExpenses[index].title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              todayExpenses[index].location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              BudgetFormatter(
                                (todayExpenses[index].amount as num).toDouble(),
                              ),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 5),
            Divider(),
            SizedBox(height: 5),

            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  size: 18,
                  color: Colors.grey,
                ),

                SizedBox(width: 6),

                Expanded(
                  child: FutureBuilder<String>(
                    future: GET_RESOURCES_NAME(
                      todayExpenses[index].resources_id,
                    ),

                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? "Loading...",
                        style: TextStyle(color: Colors.grey[700]),
                      );
                    },
                  ),
                ),

                Icon(Icons.schedule, size: 18, color: Colors.grey),

                SizedBox(width: 5),

                Text(
                  todayExpenses[index].date,

                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
