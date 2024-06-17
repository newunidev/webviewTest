import 'dart:convert';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../const/api.dart';
import '../model/MonthlyTargetDto.dart';
import 'add_new_user2.dart';
import 'admin_dashboard.dart';
import 'package:http/http.dart' as http;

class MonthlyTarget extends StatefulWidget {
  const MonthlyTarget({super.key});

  @override
  State<MonthlyTarget> createState() => _MonthlyTargetState();
}

class _MonthlyTargetState extends State<MonthlyTarget> {
  var height,width;
  String? _selectedBranch = 'Bakamuna Factory';
  String? selectedMonth = "01 - Janauary";
  int selectedMonthInt = 0;

  String? _selectedBranchForTable = 'Bakamuna Factory';
  int? _selectedYearForTable = int.parse(DateTime.now().year.toString());

  TextEditingController incomeTextController = TextEditingController();
  TextEditingController workingDaysController = TextEditingController();

  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //loadData();
  }

  final List<String> _branches = [
    'Bakamuna Factory',
    'Hettipola Factory',
    'Mathara Factory',
    'Piliyandala Factory',
    'Welioya Factory',

  ];
  final List<String> months = [
    '01 - Janauary',
    '02 - February',
    '03 - March',
    '04 - April',
    '05 - May',
    '06 - June',
    '07 - July',
    '08 - Auguest',
    '09 - September',
    '10 - October',
    '11 - November',
    '12 - December',

  ];

  List<MonthlyTargetDto> monthlyIncomeList = [];

  void navigateToAddNewForm() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AddNewUser2()),

    );
  }



  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2), // Adjust the duration as needed
      ),
    );
  }

  Future<void> loadData() async {

    try {

      final response = await http.get(Uri.parse('${API.apiUrl}api/monthlyIncomebyfactoryyear?factory=${_selectedBranchForTable}&year=${_selectedYearForTable}'));

      //api for springframework api requests.
      //final response = await http.get(Uri.parse('http://192.168.1.149:8080/api/branchDate?date=${selectedDate}&branch_id=$selectedFactory'));



      if (response.statusCode == 200) {

        // If the server returns a 200 OK response, parse the data

        final List<dynamic> data = json.decode(response.body);

        setState(() {
          monthlyIncomeList = data.map((item) => MonthlyTargetDto.fromJson(item)).toList();

        });
      } else if (response.statusCode == 400) {
        // If the server returns a 400 Bad Request response, handle the error
        print("Unable To Load Data");
        throw Exception('Bad Request: ${json.decode(response.body)['error']}');
      } else if (response.statusCode == 500) {
        // If the server returns a 500 Internal Server Error response, handle the error
        print("Unable To Load Data");
        throw Exception('Internal Server Error');
      } else {
        // Handle other status codes if needed
        print("Unable To Load Data");
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during data loading: $e');
      // Handle other exceptions if needed
      throw Exception('Failed to load data: $e');
    }
  }


  Future<void> addMonthlyIncome(
      String? branchId,
      int year,
      int month,
      double income,
      int workingDays
      ) async {
    try {
      // Create a MonthlyTargetDto instance
      MonthlyTargetDto monthlyTarget = MonthlyTargetDto(
        factory: branchId!,
        year: year,
        month: month,
        income: income,
        workingDays: workingDays,
      );

      // Convert MonthlyTargetDto instance to JSON
      final jsonData = monthlyTarget.toJson();

      // Send a POST request to your Node.js server to insert data into the monthlyIncome table
      final response = await http.post(
        Uri.parse('${API.apiUrl}monthlyIncome'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(jsonData),
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        _showSnackBar("Added Succesfully");
        loadData();
        // Handle success accordingly
      }else if(response.statusCode == 500){
        _showSnackBar("Already Inserted Value");
      }else {
        print('Failed to add data. Status code: ${response.statusCode}');
        // Handle failure accordingly
      }
    } catch (e) {
      print('Error during data insertion: $e');
      // Handle error accordingly
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;




    return Scaffold(
      body:Container(
        color: Colors.deepPurple,


        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                ),
                height: height * 0.25,
                width: width,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(

                        padding: const EdgeInsets.only(
                          top: 25,
                          left: 15,
                          right: 15,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: (){
                                //_showModalBottomSheet(context);
                              },
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.orange,
                                size: 20.0,

                              ),
                            ),
                            Container(
                              height: 30,
                              width: 30,

                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  image: DecorationImage(
                                      image: AssetImage('assets/icons/lady_40px.png')
                                  )
                              ),


                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: width/3.5),

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Welcome to NU',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:Colors.orange,
                                fontSize: width/30,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Date : ${formattedDate}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:Colors.white38,
                                fontSize: width/30,
                              ),
                            ),
                            Text(
                              'Monthly Target',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:Colors.white38,
                                fontSize: width/20,
                              ),
                            )
                          ],
                        ),

                      )
                    ],
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    gradient: LinearGradient(
                        begin: Alignment.bottomRight,
                        colors: [
                          Colors.grey,
                          Colors.lightBlueAccent
                        ]
                    )

                ),
                height: height * 0.75,
                width: width,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Form(

                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(

                        margin: const EdgeInsets.all(24.0),
                        child: Column(
                          children: <Widget>[


                            DropdownButtonFormField<String>(
                              value: selectedMonth,

                              hint: const Text('Select Month',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
                              items: months.map((month) {
                                return DropdownMenuItem<String>(
                                  value: month,
                                  child: Text(month,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedMonth = value;
                                  // You can perform additional actions when the branch is selected
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a Month';
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: height/35,),
                            DropdownButtonFormField<String>(
                              value: _selectedBranch,

                              hint: const Text('Select Branch'),
                              items: _branches.map((branch) {
                                return DropdownMenuItem<String>(
                                  value: branch,
                                  child: Text(branch,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedBranch = value;
                                  // You can perform additional actions when the branch is selected
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a branch';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: height/35,),
                            TextFormField(
                              maxLength: 100,
                              controller: incomeTextController,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')), // Allow decimal numbers
                              ],
                              style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.monetization_on),
                                  prefixIconColor: Colors.black,

                                  hintText: 'Enter Income Amount',hintStyle: TextStyle(color: Colors.white38,fontSize: 20)

                              ),
                              validator: (value) {
                                // Email validation using a regular expression
                                if (value == null || value.isEmpty) {
                                  return 'Income is required';
                                }
                                // Regular expression for a valid email address
                                String decimalRegex = r'^\d*\.?\d*$';

                                RegExp regex = RegExp(decimalRegex);
                                if (!regex.hasMatch(value)) {
                                  return 'Enter a valid Amount';
                                }
                                return null; // Return null if the input is valid
                              },

                              onSaved: (value){

                              },
                            ),
                            SizedBox(height: height/35,),
                            TextFormField(
                              maxLength: 100,
                              controller: workingDaysController,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')), // Allow decimal numbers
                              ],
                              style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.monetization_on),
                                  prefixIconColor: Colors.black,

                                  hintText: 'Enter Working Days',hintStyle: TextStyle(color: Colors.white38,fontSize: 20)

                              ),
                              validator: (value) {
                                // Email validation using a regular expression
                                if (value == null || value.isEmpty) {
                                  return 'Working days is required';
                                }
                                // Regular expression for a valid email address
                                String decimalRegex = r'^\d*\.?\d*$';

                                RegExp regex = RegExp(decimalRegex);
                                if (!regex.hasMatch(value)) {
                                  return 'Enter a valid Amount';
                                }
                                return null; // Return null if the input is valid
                              },

                              onSaved: (value){

                              },
                            ),
                            SizedBox(height: height/35,),

                            //SizedBox(height: 50,),
                            Container(
                              child: ElevatedButton(
                                child: Text(' + Add',style: TextStyle(fontWeight: FontWeight.bold,fontSize: width/30),),
                                onPressed: (){
                                  if(_formKey.currentState!.validate()){


                                    if(selectedMonth == '01 - Janauary'){
                                      selectedMonthInt = 01;
                                      //print("Selecteed Month inttttttt ${selectedMonthInt}");
                                    }else if(selectedMonth == '02 - February'){
                                      selectedMonthInt = 02;
                                    }else if(selectedMonth == '03 - March'){
                                      selectedMonthInt = 03;
                                    }else if(selectedMonth == '04 - April'){
                                      selectedMonthInt = 04;
                                    }else if(selectedMonth == '05 - May'){
                                      selectedMonthInt = 05;
                                    }else if(selectedMonth == '06 - June'){
                                      selectedMonthInt = 06;
                                    }else if(selectedMonth == '07 - July'){
                                      selectedMonthInt = 07;
                                    }else if(selectedMonth == '08 - Auguest'){
                                      selectedMonthInt = 08;
                                    }else if(selectedMonth == '09 - September'){
                                      selectedMonthInt = 09;
                                    }else if(selectedMonth == '10 - October'){
                                      selectedMonthInt = 10;
                                    }else if(selectedMonth == '11 - November'){
                                      selectedMonthInt = 11;
                                    }else if(selectedMonth == '12 - December'){
                                      selectedMonthInt = 12;
                                    }else{
                                      selectedMonthInt = 0;
                                    }
                                    print("Income  ${incomeTextController.text}");
                                    print("Factory ${_selectedBranch}");
                                    print("Selected Month ${selectedMonth}");
                                    addMonthlyIncome(_selectedBranch,DateTime.now().year,selectedMonthInt,double.parse(incomeTextController.text),int.parse(workingDaysController.text.toString()));
                                    //registerUser(emailController.text, passwordController.text, firstNameController.text, lastNameController.text);
                                  }


                                },
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: DataTable(

                                          columns: [
                                            DataColumn(label: Row(children: [Text('Factory',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20.0),),SizedBox(width: 8,),],)),
                                            DataColumn(label: Text('Year',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20.0),)),
                                            DataColumn(label: Text('Month',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20.0),)),
                                            DataColumn(label: Text('Income',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20.0),)),
                                            DataColumn(label: Text('W Days',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20.0),)),


                                          ],

                                          rows: monthlyIncomeList.map((MonthlyTargetDto) {
                                            return DataRow(cells: [
                                              DataCell(Text(MonthlyTargetDto.factory,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: width/45),)),
                                              DataCell(Text(MonthlyTargetDto.year.toString(),style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: width/45),)),
                                              DataCell(Text(MonthlyTargetDto.month.toString(),style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: width/45),)),
                                              DataCell(Text((MonthlyTargetDto.income).toStringAsFixed(2),style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: width/45),)),
                                              DataCell(Text((MonthlyTargetDto.workingDays).toStringAsFixed(2),style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: width/45),)),
                                              //DataCell(Text(EfficiencyIncomeDTO.cumalative.toStringAsFixed(2))),



                                            ],
                                              onSelectChanged: (selected) {

                                              },
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10,),
                                Expanded(
                                  flex: 1,
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: Column(
                                          children: [
                                            // Dropdown for selecting factory
                                            DropdownButton<String>(
                                              dropdownColor: Colors.black,
                                              value: _selectedBranchForTable,
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  _selectedBranchForTable = newValue!;
                                                });
                                                loadData();
                                              },
                                              items: _branches.map<DropdownMenuItem<String>>((String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: width/45),),
                                                );
                                              }).toList(),
                                            ),
                                            // Year picker for selecting the year
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                              child: DropdownButton<int>(
                                                dropdownColor: Colors.black,
                                                value: _selectedYearForTable,
                                                onChanged: (int? newValue) {
                                                  setState(() {
                                                    _selectedYearForTable = newValue!;
                                                  });
                                                  loadData();
                                                },
                                                items: List.generate(10, (index) => DateTime.now().year + index)
                                                    .map<DropdownMenuItem<int>>((int value) {
                                                  return DropdownMenuItem<int>(
                                                    value: value,
                                                    child: Text(value.toString(),style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: width/45),),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),


      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.deepPurple,
        height: 50.0,

        items: <Widget>[
          Icon(Icons.home, size: 20),
          Icon(Icons.list, size: 20),
          Icon(Icons.settings, size: 20),
        ],
        onTap: (index) {
          if(index == 0){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>  AdminDashboard(),
              ),
            );
          }
        },
      ),
    );
  }
}
