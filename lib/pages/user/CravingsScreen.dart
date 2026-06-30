import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_login/database/DatabaseHelper.dart';
import 'package:simple_login/model/CravingsModel.dart';
import 'package:simple_login/model/ExpensesModel.dart';
import 'package:simple_login/model/ResourceModel.dart';
import 'package:sqflite/sqflite.dart';

class CravingsScreen extends StatefulWidget {
  final Function()? refreshDashboard;
  const CravingsScreen({super.key, this.refreshDashboard});

  @override
  State<CravingsScreen> createState() => _CravingsScreenState();
}

class _CravingsScreenState extends State<CravingsScreen> {
  final title = TextEditingController();
  final location = TextEditingController();
  final amount = TextEditingController();
  final cravings_amount = TextEditingController();
  List<CravingsModel> cravings = [];
  var id = 0;

  Future<void> init_user() async {
    final prefs = await SharedPreferences.getInstance();
    var init_id = await prefs.getInt('id');
    var init_cravings = await DatabaseHelper.GET_ALL_CRAVINGS(init_id!);

    setState(() {
      id = init_id;
      cravings = init_cravings;
    });
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
  void initState() {
    // TODO: implement initState
    super.initState();
    init_user();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cravings"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 10),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return buildDismissible(index, context);
                  },
                  separatorBuilder: (context, index) => SizedBox(height: 0),
                  itemCount: cravings.length,
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) {
              return buildPadding(context);
            },
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Padding buildPadding(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),

      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(20, 12, 20, 24),

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
                  Icons.favorite_border,
                  color: Colors.green,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.3),
                  borderRadius: BorderRadius.all(
                    Radius.circular(100),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Cravings",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                "Save cravings to buy for later",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black45,
                ),
              ),
              SizedBox(height: 25),
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
              SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),

                  onPressed: () async {
                    int result = await DatabaseHelper.CREATE_CRAVINGS(
                      CravingsModel(
                        title: title.text.trim(),
                        location: location.text.trim(),
                        amount: double.tryParse(amount.text) ?? 0,

                        id: id,
                      ),
                    );

                    if (result > 0) {
                      Navigator.pop(context, true);
                      init_user();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Craving added")),
                      );
                    }
                  },

                  child: Text("Save Craving", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Dismissible buildDismissible(int index, BuildContext context) {
    return Dismissible(
      key: Key(cravings[index].cravings_id.toString()),
      direction: DismissDirection.horizontal,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: EdgeInsets.only(left: 24),
        child: Row(
          children: [
            Icon(Icons.payments_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "Satisfied",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: EdgeInsets.symmetric(vertical: 6),

        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(18),
        ),

        padding: EdgeInsets.only(right: 24),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,

          children: [
            Text(
              "Delete",

              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(width: 8),
            Icon(Icons.delete_forever, color: Colors.white),
          ],
        ),
      ),

      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await showPayResourceDialog(cravings[index]);
          return false;
        }

        if (direction == DismissDirection.endToStart) {
          await DatabaseHelper.DELETE_CRAVINGS(cravings[index].cravings_id);
          setState(() {
            cravings.removeAt(index);
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Deleted")));
          return true;
        }
        return false;
      },

      child: Container(
        margin: EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(18),
        ),

        child: Padding(
          padding: EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.favorite_border, color: Colors.green),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cravings[index].title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),

                        SizedBox(width: 4),

                        Expanded(
                          child: Text(
                            cravings[index].location,

                            maxLines: 1,

                            overflow: TextOverflow.ellipsis,

                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Amount",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  Text(
                  BudgetFormatter(double.tryParse(cravings[index].amount.toString())!),
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> showPayResourceDialog(CravingsModel craving) async {
    List<Resourcemodel> resources = await DatabaseHelper.GET_RESOURCE(id);
    int? selectedResource;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom),

              child: Column(
                mainAxisSize: MainAxisSize.min,

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
                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(14),

                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(
                            14,
                          ),
                        ),

                        child: Column(
                          children: [
                            Text(
                              "Amount to pay",
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),

                            SizedBox(height: 6),

                            Text(
                              BudgetFormatter(
                                double.tryParse(craving.amount.toString())!,
                              ),

                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 26,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 18),
                      TextFormField(
                        // controller: cravings_amount,
                        initialValue: craving.amount.toString(),
                        onChanged: (value) {
                          craving.amount = value;
                        },
                        keyboardType:
                        TextInputType.numberWithOptions(
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
                      SizedBox(height: 18),

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
                              setModalState(() {
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
                    ],
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                        ),
                      onPressed: () async {
                        if (selectedResource == null) {
                          return;
                        }

                        bool deducted = await DatabaseHelper.DEDUCT_BALANCE(
                          id,
                          selectedResource!,
                          double.tryParse(craving.amount.toString())!,
                        );

                        if (!deducted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Insufficient balance")),
                          );
                          Navigator.pop(context);
                          return;
                        }

                        await DatabaseHelper.CREATE_EXPENSES(
                          ExpensesModel(
                            title: craving.title,
                            location: craving.location,
                            amount: craving.amount,
                            id: id,
                            resources_id: selectedResource,

                            date: DateFormat(
                              "MMMM dd, yyyy hh:mm:ss a",
                            ).format(DateTime.now()),
                          ),
                        );

                        await DatabaseHelper.DELETE_CRAVINGS(
                          craving.cravings_id,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Cravings successfully satisfied")),
                        );

                        Navigator.pop(context);
                        widget.refreshDashboard?.call();
                        init_user();
                      },
                      child: Text("Confirm Payment"),
                    ),
                  ),
                  SizedBox(height: 15,)
                ],
              ),
            );
          },
        );
      },
    );
  }
}
