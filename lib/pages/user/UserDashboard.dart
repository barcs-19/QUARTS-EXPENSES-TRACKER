import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_login/database/DatabaseHelper.dart';
import 'package:simple_login/pages/user/Widget/AnalysisWidget.dart';
import 'package:simple_login/pages/user/Widget/HomeWidget.dart';
import 'package:simple_login/pages/user/Widget/ProfileWidget.dart';

class UserDashboard extends StatefulWidget {
  UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  String email = "";
  int user_id = 0;
  double? budget = 0;
  var formattedBudget = "";
  int selected = 0;

  List<Widget> get pages => [
    HomeWidget(
      formattedBudget: formattedBudget,
      onRefresh: refreshBudget,
    ),
    AnalysisWidget(),
    ProfileWidget(),
  ];

  void getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    email = prefs.getString("email") ?? "";
    user_id = prefs.getInt("id") ?? 0;
    budget = await DatabaseHelper.GET_TOTAL_BALANCE(user_id);

    setState(() {
      formattedBudget = NumberFormat.currency(
        locale: "en-PH",
        symbol: "₱",
        decimalDigits: 2,
      ).format(budget);
    });
  }

  void refreshBudget() async {
    final total =
    await DatabaseHelper.GET_TOTAL_BALANCE(
      user_id,
    );

    setState(() {
      budget = total;

      formattedBudget =
          NumberFormat.currency(
            locale: "en-PH",
            symbol: "₱",
          ).format(budget);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 15,
            right: 15,
          ),

          child: pages[selected],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              navItem(icon: Icons.dashboard_rounded, index: 0, title: "Dashboard"),
              navItem(icon: Icons.bar_chart_rounded, index: 1, title: "Analysis"),
              navItem(icon: Icons.person_rounded, index: 2, title: "Profile"),
            ],
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text("Quarts"),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: SizedBox(
            height: 30,
            width: 30,
            child: ElevatedButton(
              onPressed: () {},
              child: Icon(Icons.person),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
              ),
            ),
          ),
        ),

      ],
    );
  }
  Widget navItem({required IconData icon, required int index, required String title}) {
    bool active = selected == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selected = index;
          print(selected);
        });
      },

      child: AnimatedContainer(
        height: 55,
        width: 100,
        duration: Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: active ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? Colors.white : Colors.grey, size: 25,),
            Text(title, style: TextStyle(color: active ? Colors.white60 : Colors.black87, fontSize: 10),)
          ],
        ),
      ),
    );
  }
}
