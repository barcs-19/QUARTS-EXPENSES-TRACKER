import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_login/database/DatabaseHelper.dart';
import 'package:simple_login/model/ResourceModel.dart';

class ResourcesScreen extends StatefulWidget {
  final Function()? onUpdate;

  ResourcesScreen({super.key, this.onUpdate});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  List<Resourcemodel> resources = [];
  int id = 0;

  final title = TextEditingController();
  final balance = TextEditingController();

  void init_resources() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    int init_id = await prefs.getInt("id") ?? 0;
    List<Resourcemodel> init_resources = await DatabaseHelper.GET_RESOURCE(
      init_id,
    );

    setState(() {
      id = init_id;
      resources = init_resources;
    });
  }

  String formatted_budget(double budget) {
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
    init_resources();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Resources"), centerTitle: true,),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (context) {
                            final resources_balance = TextEditingController(
                              text: resources[index].balance.toString(),
                            );

                            Future<void> updateBalance(int index) async {
                              int result =
                                  await DatabaseHelper.UPDATE_RESOURCES_BALANCE(
                                    resources[index].resources_id!,
                                    double.tryParse(resources_balance.text) ??
                                        0,
                                  );

                              if (!mounted) return;
                              Navigator.pop(context);
                              init_resources();
                              widget.onUpdate?.call();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    result > 0
                                        ? "Balance updated"
                                        : "Update failed",
                                  ),
                                ),
                              );
                            }

                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(
                                  context,
                                ).viewInsets.bottom,
                                left: 16,
                                right: 16,
                                top: 16,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: Padding(
                                  padding: EdgeInsets.only(),

                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: 20),

                                      CircleAvatar(
                                        radius: 32,
                                        backgroundColor: Colors.blue
                                            .withOpacity(.1),
                                        child: Icon(
                                          Icons.account_balance_wallet,
                                          color: Colors.blue,
                                          size: 32,
                                        ),
                                      ),

                                      SizedBox(height: 12),

                                      Text(
                                        "Update Balance",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      SizedBox(height: 5),

                                      Text(
                                        resources[index].title!,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 15,
                                        ),
                                      ),

                                      SizedBox(height: 20),

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
                                              "Current Balance",
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),

                                            SizedBox(height: 6),

                                            Text(
                                              formatted_budget(
                                                resources[index].balance!,
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
                                        controller: resources_balance,
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
                                        onFieldSubmitted: (_) async {
                                          await updateBalance(index);
                                        },
                                      ),
                                      SizedBox(height: 18),

                                      SizedBox(
                                        width: double.infinity,
                                        height: 55,
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,

                                            padding: EdgeInsets.symmetric(
                                              vertical: 15,
                                            ),

                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),

                                          onPressed: () async {
                                            await updateBalance(index);
                                          },

                                          label: Text("Save Changes"),
                                        ),
                                      ),

                                      SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.05),
                              blurRadius: 14,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),

                        child: Padding(
                          padding: EdgeInsets.all(18),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.blueAccent,
                                  size: 28,
                                ),
                              ),
                              SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      resources[index].title!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      "Available balance",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      formatted_budget(
                                        resources[index].balance!,
                                      ),
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(.08),
                                  shape: BoxShape.circle,
                                ),

                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => SizedBox(height: 5),
                  itemCount: resources.length,
                ),
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (context) {
                        return Padding(
                          padding: EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 10,
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Form(
                                child: Column(
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
                                        Icons.account_balance_wallet,
                                        color: Colors.blueAccent,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent.withOpacity(
                                          0.3,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(100),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "Resources",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      "add sources for money",
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
                                      controller: balance,
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
                                    SizedBox(height: 20,),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          int result =
                                          await DatabaseHelper.CREATE_RESOURCES(
                                            new Resourcemodel(
                                              title: title.text.trim(),
                                              balance:
                                              double.tryParse(balance.text) ??
                                                  0.0,
                                              id: id,
                                            ),
                                          );
                                          if (!(result > 0)) return;

                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Success")),
                                          );
                                          widget.onUpdate?.call();

                                          Navigator.pop(context, true);
                                          setState(() {
                                            init_resources();
                                          });
                                        },
                                        child: Text("Confirm"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20,),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Text("Add resources"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
