
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_login/database/DatabaseHelper.dart';
import 'package:simple_login/model/ExpensesModel.dart';
import 'package:simple_login/model/ResourceModel.dart';

class ExpensesScreen extends StatefulWidget {
  final Function()? reloadDashboard;

  const ExpensesScreen({super.key, this.reloadDashboard});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final title = TextEditingController();
  final location = TextEditingController();
  final amount = TextEditingController();

  List<ExpensesModel> expenses = [];
  var id = 0;

  void init_user() async {
    final prefs = await SharedPreferences.getInstance();
    var init_id = await prefs.getInt('id') ?? 0;
    var init_expenses = await DatabaseHelper.GET_ALL_EXPENSES(init_id);

    setState(() {
      id = init_id;
      expenses = init_expenses;
    });
  }

  Future<String> GET_RESOURCES_NAME(int resources_id) {
    return DatabaseHelper.GET_RESOURCES_NAME(resources_id);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init_user();
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
    return Scaffold(
      appBar: AppBar(title: Text("Expenses")),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 20),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    DateTime currentDate = DateFormat(
                      "MMMM dd, yyyy hh:mm:ss a",
                    ).parse(expenses[index].date);
                    String currentHeader = DateFormat(
                      "MMMM dd, yyyy",
                    ).format(currentDate);
                    bool showHeader = true;

                    if (index > 0) {
                      DateTime previousDate = DateFormat(
                        "MMMM dd, yyyy hh:mm:ss a",
                      ).parse(expenses[index - 1].date.toString());
                      String previousHeader = DateFormat(
                        "MMMM dd, yyyy",
                      ).format(previousDate);
                      showHeader = currentHeader != previousHeader;
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showHeader)
                          Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            child: Text(
                              currentHeader,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                        buildExpensesCard(index),
                      ],
                    );
                  },
                  separatorBuilder: (context, index) => SizedBox(height: 5),
                  itemCount: expenses.length,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          List<Resourcemodel> resources = await DatabaseHelper.GET_RESOURCE(id);
          int? selectedResource;

          showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, modalSetSatte) {
                  return Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 10,
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),

                    child: SizedBox(
                      width: double.infinity,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 50,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            SizedBox(height: 25),
                            Container(
                              height: 50,
                              width: 50,
                              child: Icon(
                                Icons.attach_money,
                                color: Colors.red,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.3),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(100),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Expenses",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              "Record your expenses",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black45,
                              ),
                            ),
                            SizedBox(height: 25),
                            //inputs
                            Form(
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: title,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.title),
                                      hint: Text("Title"),
                                      filled: true,
                                      fillColor: Colors.white.withOpacity(0.9),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  TextFormField(
                                    controller: location,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.location_on_sharp),
                                      hint: Text("Location"),
                                      filled: true,
                                      fillColor: Colors.white.withOpacity(0.9),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  TextFormField(
                                    controller: amount,
                                    keyboardType: TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),

                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d*\.?\d*'),
                                      ),
                                    ],
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.payments),
                                      hint: Text("Amount"),
                                      filled: true,
                                      fillColor: Colors.white.withOpacity(0.9),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Divider(),
                                  SizedBox(height: 15),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.account_balance_wallet),
                                          SizedBox(width: 8),
                                          Text(
                                            "Choose payment source",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12),

                                      ...resources.map((r) {
                                        bool selected =
                                            selectedResource == r.resources_id;

                                        return Padding(
                                          padding: EdgeInsets.only(bottom: 5),

                                          child: InkWell(
                                            onTap: () {
                                              modalSetSatte(() {
                                                selectedResource =
                                                    r.resources_id;
                                              });
                                            },

                                            child: AnimatedContainer(
                                              duration: Duration(
                                                milliseconds: 180,
                                              ),

                                              padding: EdgeInsets.all(15),
                                              decoration: BoxDecoration(
                                                color: selected
                                                    ? Colors.blue
                                                    : Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),

                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(.04),
                                                    blurRadius: 10,
                                                  ),
                                                ],
                                              ),

                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,

                                                      children: [
                                                        Text(
                                                          "${BudgetFormatter(r.balance!)}",
                                                          style: TextStyle(
                                                            color: selected
                                                                ? Colors.white
                                                                : Colors.black,

                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),

                                                        SizedBox(height: 2),

                                                        Text(
                                                          r.title!,

                                                          style: TextStyle(
                                                            color: selected
                                                                ? Colors.white70
                                                                : Colors
                                                                      .black54,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  AnimatedSwitcher(
                                                    duration: Duration(
                                                      milliseconds: 150,
                                                    ),

                                                    child: selected
                                                        ? Icon(
                                                            Icons.check_circle,
                                                            color: Colors.white,
                                                            key: ValueKey(true),
                                                          )
                                                        : Icon(
                                                            Icons
                                                                .radio_button_unchecked,
                                                            color: Colors.grey,
                                                            key: ValueKey(
                                                              false,
                                                            ),
                                                          ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                      SizedBox(height: 15,),
                                      SizedBox(
                                        height: 55,
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            print("objecjt");
                                            final expenses = ExpensesModel(
                                              title: title.text,
                                              location: location.text,
                                              amount: double.tryParse(amount.text),
                                              date: DateFormat("MMMM dd, yyyy hh:mm:ss a").format(DateTime.now()),
                                              id: id,
                                              resources_id: selectedResource
                                            );

                                            print(expenses.toMap());
                                            final result = await DatabaseHelper.CREATE_EXPENSES(expenses);
                                            print(result > 0 ? "success" : "Failed");

                                            await DatabaseHelper.DEDUCT_BALANCE(id, selectedResource!, double.tryParse(amount.text)!);
                                            Navigator.pop(context);
                                            init_user();
                                            widget.reloadDashboard!.call();
                                          },
                                          child: Text("Confirm"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blueAccent,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
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
                              expenses[index].title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              expenses[index].location,
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
                                (expenses[index].amount as num).toDouble(),
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
                    future: GET_RESOURCES_NAME(expenses[index].resources_id),

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
                  expenses[index].date,

                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ElevatedButton buildElevatedButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        int result = await DatabaseHelper.CREATE_EXPENSES(
          ExpensesModel(
            title: title.text,
            location: location.text,
            amount: double.tryParse(amount.text) ?? 0,
            id: id,
            date: DateFormat('MMMM dd, yyyy hh:mm:ss a').format(DateTime.now()),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text((result > 0) ? "Success" : "failed")),
        );
        if (result > 0) {
          await DatabaseHelper.DEDUCT_BALANCE(
            id,
            3,
            double.tryParse(amount.text) ?? 0,
          );
          widget.reloadDashboard?.call();
        }
      },
      child: Text("Add expenses"),
    );
  }
}
