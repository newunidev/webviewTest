import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;



import '../const/api.dart';
import '../const/const_data.dart';
import '../const/ui_constant.dart';
import '../controller/factory_selector.dart';
import '../model/EfficiencyDtoGet.dart';
import '../model/EfficiencyIncomeDto.dart';
import '../model/LineStyleDto.dart';
import '../model/TargetHoulryDataDto.dart';
import '../widgets/BlinkingExclamation.dart';
import '../widgets/blinking_dot.dart';
import '../widgets/blinking_icon.dart';
import '../widgets/flexible_space_app_bar.dart';
import 'dashboard.dart';

//pdf imports
//pdf
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'dart:io';
import 'package:open_file/open_file.dart';

class LandscapeCostBoardData extends StatefulWidget {
  const LandscapeCostBoardData({super.key});

  @override
  State<LandscapeCostBoardData> createState() => _LandscapeCostBoardDataState();
}

class _LandscapeCostBoardDataState extends State<LandscapeCostBoardData> {
  var height,width;
  FactorySelector factorySelector = FactorySelector();
  Color tableColumnColor =Colors.black;
  Color blinkingDotColor1 = Colors.green;
  Color blinkingDotColor2 = Colors.green;
  Color blinkingDotColor3 = Colors.green;
  Color blinkingDotColor4 = Colors.green;
  Color blinkingDotColor5 = Colors.green;
  Color blinkingDotColor6 = Colors.green;
  Color blinkingDotColor7 = Colors.green;
  Color blinkingDotColor8 = Colors.green;
  Color blinkingDotColor9 = Colors.green;
  Color blinkingDotColor10 = Colors.green;
  bool isBeforeDate = false;
  bool isDataRowSelected = false;

  TextEditingController targetIncomeController = TextEditingController();
  TextEditingController noOfWorkingDaysController = TextEditingController(text: 1.toString());
  double dayout = 1;
  int _enteredWorkingDays = 1;
  double finalDayOut = 0;
  double cumlativeValue = 0.0;

  //for selection event of the table
  double selectedAchievement = 0;
  double selectedDayOut = 0;


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

  //time tanges
  late Timer _timer;
  //late Timer _autoRefreshTime;
  late DateTime _currentTime = DateTime.now();
  int remainingHours = 10;

  //table configurations
  List<int> lineNumbers = [];
  List<String> styles = [];

  //List<Map<String, dynamic>>? efficiencyData;
  List<EfficiencyIncomeDTO> efficiencyIncomeList = [];
  //EfficiencyDtoGet efficiencyDtoGet = EfficiencyDtoGet();

  List<EfficiencyDtoGet> filteredList = [];
  List<TargetHourlyDto> hourlyData = [];


  TextEditingController searchController = TextEditingController();




  DateTime selectedDate = DateTime.now();
  String? selectedFactory; // Default factory
  String selectedMonth = "01 - Janauary";
  int selectedMonthInt = 0;
  //List<EfficiencyDTORetrieve>? efficiencyData;
  List<String> uniqueStyles = [];
  List<String> uniqueLines = [];
  Map<int, String> indexToStyleMap = {};
  Map<int, String> indexToLineMap = {};

  List<String> _branches = [
    'Bakamuna Factory',
    'Hettipola Factory',
    'Mathara Factory',
    'Piliyandala Factory',
    'Welioya Factory',
  ];


  @override
  void initState() {
    super.initState();
    targetIncomeController.text = "0";

    selectedDate = DateTime.now();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,

    ]);

    // Start the first timer for updating every second
    _startFirstTimer();

    // Start the second timer for updating every two minutes
    _startSecondTimer();
    //loadData(); // Load data here
  }
  void _startFirstTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
          setColorsForTheBlinkingDot();
        });
      }
    });
  }

  void _startSecondTimer() {
    Timer.periodic(Duration(seconds: 60), (timer) {

      if (mounted) {
        setState(() {
          print("Hello Activate ");
          //fetchLineStyles();
        });
      }
    });
  }
  @override
  void dispose() {
    // It's important to cancel the timer when the widget is disposed
    // to prevent memory leaks.
    print("I am Here On Dispose");
    _timer?.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);



    super.dispose();

  }


  //setColors for the blinking dot
  void setColorsForTheBlinkingDot(){

    DateTime currentDate = DateTime.now();
    remainingHours =10;


    //check for backdate blink light stop
    //print(selectedDate.year == currentDate.year && selectedDate.month == currentDate.month && selectedDate.day == currentDate.day);
    if(selectedDate.isBefore(currentDate)){
      //print("Came");
      blinkingDotColor1 = Colors.white;
      blinkingDotColor2 = Colors.white;
      blinkingDotColor3 = Colors.white;
      blinkingDotColor4 = Colors.white;
      blinkingDotColor5 = Colors.white;
      blinkingDotColor6 = Colors.white;
      blinkingDotColor7 = Colors.white;
      blinkingDotColor8 = Colors.white;
      blinkingDotColor9 = Colors.white;
      blinkingDotColor10 = Colors.white;
      isBeforeDate = false;
    }
    if(selectedDate.isAfter(currentDate) || (selectedDate.year == currentDate.year && selectedDate.month == currentDate.month && selectedDate.day == currentDate.day)){
      //print("Came");
      blinkingDotColor1 = Colors.green;
      blinkingDotColor2 = Colors.green;
      blinkingDotColor3 = Colors.green;
      blinkingDotColor4 = Colors.green;
      blinkingDotColor5 = Colors.green;
      blinkingDotColor6 = Colors.green;
      blinkingDotColor7 = Colors.green;
      blinkingDotColor8 = Colors.green;
      blinkingDotColor9 = Colors.green;
      blinkingDotColor10 = Colors.green;
      isBeforeDate = true;
    }


    DateTime time01 = DateTime(currentDate.year, currentDate.month, currentDate.day, 9, 30);
    DateTime time02 = DateTime(currentDate.year, currentDate.month, currentDate.day, 10, 20);
    DateTime time03 = DateTime(currentDate.year, currentDate.month, currentDate.day, 11, 15);
    DateTime time04 = DateTime(currentDate.year, currentDate.month, currentDate.day, 12, 20);
    DateTime time05 = DateTime(currentDate.year, currentDate.month, currentDate.day, 13, 35);
    DateTime time06 = DateTime(currentDate.year, currentDate.month, currentDate.day, 14, 30);
    DateTime time07 = DateTime(currentDate.year, currentDate.month, currentDate.day, 15, 25);
    DateTime time08 = DateTime(currentDate.year, currentDate.month, currentDate.day, 16, 35);
    DateTime time09 = DateTime(currentDate.year, currentDate.month, currentDate.day, 17, 30);
    DateTime time10 = DateTime(currentDate.year, currentDate.month, currentDate.day, 18, 30);

    //print("Current Date is : ${selectedDate}");
    if(_currentTime.isAfter(time01) ){
      blinkingDotColor1 = Colors.white;
      --remainingHours;
    }


    if(_currentTime.isAfter(time02) ){
      blinkingDotColor2 = Colors.white;
      --remainingHours;
    }



    if(_currentTime.isAfter(time03)){
      blinkingDotColor3 = Colors.white;
      --remainingHours;
    }


    if(_currentTime.isAfter(time04)){
      blinkingDotColor4 = Colors.white;
      --remainingHours;
    }



    if(_currentTime.isAfter(time05)){
      blinkingDotColor5 = Colors.white;
      --remainingHours;
    }
    if(_currentTime.isAfter(time06)){
      blinkingDotColor6 = Colors.white;
      --remainingHours;
    }
    if(_currentTime.isAfter(time07)){
      blinkingDotColor7 = Colors.white;
      --remainingHours;
    }
    if(_currentTime.isAfter(time08)){
      blinkingDotColor8 = Colors.white;
      --remainingHours;
    }
    if(_currentTime.isAfter(time09)){
      blinkingDotColor9 = Colors.white;
      --remainingHours;
    }
    if(_currentTime.isAfter(time10)){
      blinkingDotColor10 = Colors.white;

    }
    //print("Remaining Hours : ${remainingHours}");
  }

  //method to load styles and lines related to them






  Future<void> loadData() async {

    try {
      //print("Datess :${selectedDate}");

      //final response = await http.get(Uri.parse('${API.apiUrl}api/branchDate?date=$selectedDate&branchId=$selectedFactory'));
      final response = await http.get(Uri.parse('${API.apiUrl}api/efficiencyincomedailysumbymonthfactory?factory=${selectedFactory}&month=$selectedMonthInt'));

      //api for springframework api requests.
      //final response = await http.get(Uri.parse('http://192.168.1.149:8080/api/branchDate?date=${selectedDate}&branch_id=$selectedFactory'));



      if (response.statusCode == 200) {

        // If the server returns a 200 OK response, parse the data

        final List<dynamic> data = json.decode(response.body);

        setState(() {
          efficiencyIncomeList = data.map((item) => EfficiencyIncomeDTO.fromJson(item)).toList();
          // filteredList = List.from(efficiencyList);
          // for (var efficiency in efficiencyIncomeList) {
          //
          // }
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


  //method to call api for get income for given month and facotry
  Future<void> fetchIncome() async {
    targetIncomeController.text = 0.toString();

    try {
      //print("Datess :${selectedDate}");

      //final response = await http.get(Uri.parse('${API.apiUrl}api/branchDate?date=$selectedDate&branchId=$selectedFactory'));
      final response = await http.get(Uri.parse('${API.apiUrl}api/monthlyIncomebyfactorymonthyear?factory=${selectedFactory}&month=${selectedMonthInt}&year=${DateTime.now().year}'));

      //api for springframework api requests.
      //final response = await http.get(Uri.parse('http://192.168.1.149:8080/api/branchDate?date=${selectedDate}&branch_id=$selectedFactory'));



      if (response.statusCode == 200) {
         ;
        // If the server returns a 200 OK response, parse the data
        // Parse the JSON response
         print(response.body);
        final dynamic jsonData = json.decode(response.body);

         final double income = jsonData.isNotEmpty ? double.parse(jsonData[0]['income'].toString()) : 0.0;
         final int workingDays = jsonData.isNotEmpty ? int.parse(jsonData[0]['w_days'].toString()) : 0;
        setState(() {
          targetIncomeController.text = income.toString();
          noOfWorkingDaysController.text = workingDays.toString();
          _enteredWorkingDays = workingDays;
        });
         calculateDayout();
         calculateCumulativeSum();

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



  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    Color myColor = Color(0xFF2D1A42);

    return Scaffold(
      body:Container(
        color: myColor,


        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              SingleChildScrollView(
                //physics: NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height/25,),

                    Padding(
                      padding: EdgeInsets.only(
                        top : 0,
                        left: 13,
                        //bottom: 30
                        //right: 15,

                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            //padding: const EdgeInsets.symmetric(vertical: 1),
                            child:  DropdownButton<String>(
                              value: selectedMonth,
                              dropdownColor: myColor,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: ConstData.deviceScreenWidth/35,
                              ),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    selectedMonth = newValue;
                                    //print("Selecteed Month inttttttt ${selectedMonthInt}");


                                    //if condition for checking month selection
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

                                    // loadData(selectedMonthInt).then((_) {
                                    //   if(targetIncomeController.text.isNotEmpty && balanceRemainingController.text.isNotEmpty){
                                    //     calculateBalanceRemaining();
                                    //   }
                                    // });
                                    loadData();
                                    fetchIncome();
                                    finalDayOut = 0;

                                    //calculateCumulativeSum();
                                    noOfWorkingDaysController.text = 0.toString();


                                    //calcluateCurrentIncomeRatePerDay();
                                    //calculateRequiredIncomeRatePerDay();
                                    //loadData(); // Reload data when the factory is changed
                                  });
                                }
                              },
                              items: months.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: 10,
                                    //bottom: 40

                                  ),
                                  child: Row(
                                    children: [
                                      Text("Target Income :",style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: ConstData.deviceScreenWidth/40,
                                      ),),
                                      Expanded(
                                        child: TextField(
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: ConstData.deviceScreenWidth/45,
                                          ),
                                          controller: targetIncomeController,
                                          enabled: false,
                                          
                                        ),
                                      )
                                    ],
                                  )

                                ),
                                SizedBox(height: 12.0),
                                Padding(
                                    padding: const EdgeInsets.only(
                                      right: 10,
                                      //bottom: 40

                                    ),
                                    child: Row(
                                      children: [
                                        Text("Working Days :",style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: ConstData.deviceScreenWidth/40,
                                        ),),
                                        Expanded(
                                          child: TextField(
                                            onChanged: (String inputValue){
                                              if(inputValue.isNotEmpty){

                                                setState(() {
                                                  _enteredWorkingDays = int.parse(inputValue);
                                                  calculateDayout();
                                                  calculateCumulativeSum();
                                                  // balanceRemaining = monthlyTarget - calculateTotalIncome();
                                                  // balanceRemainingController.text = balanceRemaining.toString();
                                                  //calculateBalanceRemaining();

                                                  //======calculate Current and Required Income Rate ============//

                                                  // DateTime currentDate = DateTime.now();
                                                  //
                                                  // remainingDays =calculateRemainingDays(currentDate);
                                                  // print("Remaining Days are : $remainingDays");

                                                  //calcluateCurrentIncomeRatePerDay();
                                                  //calculateRequiredIncomeRatePerDay();

                                                });
                                              }else{
                                                noOfWorkingDaysController.text = 0.toString();
                                              }

                                            },
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: ConstData.deviceScreenWidth/45,
                                            ),
                                            controller: noOfWorkingDaysController,
                                            decoration: InputDecoration(
                                              hintText: " Enter Days Here",
                                              hintStyle: TextStyle(
                                                color: Colors.white12
                                              )
                                            ),


                                          ),
                                        )
                                      ],
                                    )

                                ),
                              ],
                            ),
                          ),
                          //SizedBox(width: 10),
                          // Dropdown to select factory
                          Expanded(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: 10,
                                    //bottom: 40

                                  ),
                                  child: DropdownButton<String>(
                                    value: selectedFactory,//factorySelector.setFactoryOnUserString(),
                                    dropdownColor: Colors.black,
                                    hint: Text('Select Branch',style: TextStyle(color: Colors.white,fontSize: width/35),),
                                    items: factorySelector.setFactoryOnUser().map((branch) {
                                      return DropdownMenuItem<String>(
                                        value: branch,
                                        child: Text(branch),
                                      );
                                    }).toList(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize:width/35,

                                    ),
                                    onChanged: (String? newValue) {

                                      if (newValue != null) {
                                        setState(() {
                                          selectedFactory = newValue;
                                          //fetchLineStyles();
                                          loadData();
                                          fetchIncome();
                                          finalDayOut = 0;
                                          noOfWorkingDaysController.text = 0.toString();
                                          if(noOfWorkingDaysController.text.isNotEmpty){
                                            print(noOfWorkingDaysController.text);
                                          }
                                          //if condition for checking month selection

                                          // Reload data when the factory is changed
                                        });
                                      }
                                    },
                                  ),

                                ),
                                SizedBox(height: 12.0),
                                Text(
                                  'Time : ${_currentTime.hour} : ${_currentTime.minute} : ${_currentTime.second}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:AppColors.yellowGold,
                                    fontSize: width/40,
                                  ),
                                )
                              ],
                            ),
                          ),

                        ],
                      ),
                    )
                  ],
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                height: height * 0.60, // Make sure 'height' is defined somewhere in your code
                width: width, // Make sure 'width' is defined somewhere in your code
                child: Row(
                  children: [
                    Expanded(
                      flex: 4, // Adjust the flex factor to control the size ratio between the table and the pie chart
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: DataTable(

                              columns: [
                                DataColumn(label: Row(children: [Text('Date',style: TextStyle(color: tableColumnColor,fontWeight: FontWeight.bold,fontSize: 20.0),),SizedBox(width: 8,),],)),
                                DataColumn(label: Text('Achievement',style: TextStyle(color: tableColumnColor,fontWeight: FontWeight.bold,fontSize: 20.0),)),
                                DataColumn(label: Text('Day Out',style: TextStyle(color: tableColumnColor,fontWeight: FontWeight.bold,fontSize: 20.0),)),
                                DataColumn(label: Text('Variance',style: TextStyle(color: tableColumnColor,fontWeight: FontWeight.bold,fontSize: 20.0),)),
                                DataColumn(label: Text('Cum Balance',style: TextStyle(color: tableColumnColor,fontWeight: FontWeight.bold,fontSize: 20.0),)),

                              ],

                              rows: efficiencyIncomeList.map((EfficiencyIncomeDTO) {
                                return DataRow(cells: [
                                  DataCell(Text(EfficiencyIncomeDTO.date.toString(),style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)),
                                  DataCell(Text(EfficiencyIncomeDTO.totalIncome.toString())),
                                  DataCell(Text(finalDayOut.toStringAsFixed(2))),
                                  DataCell(Text((EfficiencyIncomeDTO.totalIncome-finalDayOut).toStringAsFixed(2))),
                                  //DataCell(Text(EfficiencyIncomeDTO.cumalative.toStringAsFixed(2))),
                                  DataCell(
                                      Tooltip(
                                          message: 'Date  ${EfficiencyIncomeDTO.date}',
                                          textStyle : TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: AppColors.blueDark),
                                          showDuration : Duration(seconds:3),

                                        child: EfficiencyIncomeDTO.cumalative.isNegative ? BlinkingIcon(cumalative: EfficiencyIncomeDTO.cumalative) : Text("${EfficiencyIncomeDTO.cumalative.toStringAsFixed(2)}"),
                                      )
                                  ),


                                ],
                                  onSelectChanged: (selected) {
                                    if (selected!) {
                                      setState(() {
                                        isDataRowSelected = true;
                                      });
                                      updateChartData(finalDayOut, EfficiencyIncomeDTO.totalIncome); // Update chart data based on selected row
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: isDataRowSelected ? BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              bottomTitles: SideTitles(
                                showTitles: true,
                                margin: 15,
                                getTitles: (double value) {
                                  // Replace the index with appropriate labels based on your data
                                  switch (value.toInt()) {
                                    case 0:
                                      return 'Day Out';
                                    case 1:
                                      return '      Achievement';
                                    default:
                                      return '';
                                  }
                                },
                              ),
                              leftTitles: SideTitles(showTitles: false),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: [
                              BarChartGroupData(
                                x: 0,
                                barRods: [BarChartRodData(y: double.parse(selectedDayOut.toStringAsFixed(2)), colors: [Colors.red])],
                                showingTooltipIndicators: [0],
                              ),
                              BarChartGroupData(
                                x: 1,
                                barRods: [BarChartRodData(y: selectedAchievement, colors: [Colors.blue])],
                                showingTooltipIndicators: [0],
                              ),
                            ],
                          ),
                        ) : Text("No Data"),
                      ),
                    ),
                    Expanded(
                      flex: 2, // Adjust this as needed
                      child: Container(
                        // Specify a fixed size for the container holding the pie chart if necessary
                        // width: 200.0, // Example width, uncomment if needed
                        // height: 200.0, // Example height, uncomment if needed
                        padding: EdgeInsets.all(8), // Add some padding around the pie chart
                        child: PieChart(
                          PieChartData(
                            centerSpaceRadius: 10,
                            sectionsSpace: 0, // Adjust based on your needs
                            sections: [
                              PieChartSectionData(
                                radius: width/10,
                                color: Colors.red,
                                value: selectedDayOut, // Provide the dayOut value dynamically
                                title: "Target : ${selectedDayOut.toStringAsFixed(2)}",
                                titleStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                              ),
                              PieChartSectionData(
                                radius: width/10,
                                color: Colors.blue,
                                value: selectedAchievement, // Provide the achievement value dynamically
                                title: "Act : ${selectedAchievement.toStringAsFixed(2)}",
                                titleStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),

                        ),
                      ),
                    ),
                  ],
                ),
              )
              // ElevatedButton(
              //   onPressed: () async {
              //    // await generateEfficiencyPDF(efficiencyList);
              //   },
              //   child: Text('Print'),
              // ),
            ],
          ),
        ),


      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //fetchLineStyles();
        },
        tooltip: 'Fetch Users',
        child: Icon(Icons.refresh),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.deepPurple,
        height: 35.0,

        items: <Widget>[
          Icon(Icons.home, size: 20),
          Icon(Icons.list, size: 20),
          Icon(Icons.settings, size: 20),
        ],
        onTap: (index) {
          if(index == 0){
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>  Dashboard(),
              ),
            );
          }
        },
      ),
    );

  }
  void calculateDayout(){
    setState(() {
      //print("Final Day out is : $_enteredWorkingDays");
      finalDayOut = double.parse(targetIncomeController.text)/_enteredWorkingDays;
      print("Final Day out is : $finalDayOut");
    });
  }
  void calculateCumulativeSum() {
    print("Came");
    double cumulativeSum = 0;
    for (int i = 0; i < efficiencyIncomeList.length; i++) {
      double variance = efficiencyIncomeList[i].totalIncome - finalDayOut;
      cumulativeSum += variance;
      efficiencyIncomeList[i].cumalative = cumulativeSum;
    }
  }
  void updateChartData(double dayOut, double achievement) {
    setState(() {
      selectedDayOut = dayOut;
      selectedAchievement = achievement;
    });
  }
}
