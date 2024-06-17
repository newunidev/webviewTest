import 'dart:math';

import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';



import '../background/background.dart';

import '../const/api.dart';
import '../const/const_data.dart';
import '../const/ui_constant.dart';
import '../controller/factory_selector.dart';
import '../model/EfficiencyDtoGet.dart';
import '../widgets/pie_chart.dart';
import 'dashboard.dart';
import 'package:http/http.dart' as http;


class SummeryIncomeNew extends StatefulWidget {
  const SummeryIncomeNew({super.key});

  @override
  State<SummeryIncomeNew> createState() => _SummeryIncomeNewState();
}

class _SummeryIncomeNewState extends State<SummeryIncomeNew> {
  var height,width;

  String? selectedFactory;
  FactorySelector factorySelector = FactorySelector();

  //String selectedFactory = 'Bakamuna Factory';
  String selectedMonth = "01 - Janauary";

  int selectedMonthInt = 0;
  double monthlyTarget = 0.0;

  double balanceRemaining = 0.0;
  TextEditingController balanceRemainingController = TextEditingController();
  TextEditingController targetIncomeController = TextEditingController();

  //load data variables
  List<EfficiencyDtoGet>? efficiencyData;
  List<String> uniqueStyles = [];
  List<String> uniqueLines = [];
  Map<int, String> indexToStyleMap = {};
  Map<int, String> indexToLineMap = {};

  //calculate Total income upto now variables
  double totalIncome =0;
  double roundedIncome =0.0;

  //========calculatoins for Required Income Rate===============//
  // Get the current date
  int remainingDays =0;
  double currentIncomeRatePerDay =0.0;
  double requiredIncomeRatePerDay = 0.0;

  bool showPieChart = false;





  // Get the last day of the current month


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

  List<String> _branches = [
    'Bakamuna Factory',
    'Hettipola Factory',
    'Mathara Factory',
    'Piliyandala Factory',
    'Welioya Factory',
  ];




  //load data from the db
  Future<void> loadData(int month) async {
    //print("loged fact in const data ${ConstData.selectedFactoryDefault}");
    try {
      print('Month is : $selectedMonthInt');
      final response = await http.get(Uri.parse('${API.apiUrl}api/efficiency?branchId=$selectedFactory&month=$selectedMonthInt'));

      //api request for SpringFramework Api Requests
      //final response = await http.get(Uri.parse('http://192.168.1.149:8080/api/efficiencyBranchDate?branch_id=$selectedFactory&month=$selectedMonthInt'));



      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the data
        final List<dynamic> decodedData = json.decode(response.body);

        if (decodedData.isNotEmpty) {
          efficiencyData = decodedData.map((item) => EfficiencyDtoGet.fromJson(item)).toList();

          uniqueLines = List<String>.from(efficiencyData!.map((efficiency) => efficiency.lineNo.toString()).toSet().toList());
          for(String lines in uniqueLines){
            print("Lines are : $lines");
          }
          //efficiencyData = decodedData.map((item) => EfficiencyDtoGet.fromJson(item)).toList();
          //print(decodedData);

          // Create the indexToStyleMap

          for (int i = 0; i < uniqueLines.length; i++) {
            indexToLineMap[i] = uniqueLines[i];
          }
        } else {
          print("No data available for the given date and factory");
          efficiencyData = null;
        }
      } else if (response.statusCode == 400) {
        // If the server returns a 400 Bad Request response, handle the error
        throw Exception('Bad Request: ${json.decode(response.body)['error']}');
      } else if (response.statusCode == 500) {
        // If the server returns a 500 Internal Server Error response, handle the error
        throw Exception('Internal Server Error');
      } else if(response.statusCode ==204){efficiencyData = null;}else {
        // Handle other status codes if needed
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during data loading: $e');
      // Handle other exceptions if needed
      throw Exception('Failed to load data: $e');
    }

    setState(() {}); // Trigger a rebuild to update the UI
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData(0);

    factorySelector.setFactoryOnUserString();
    //_branches = ['Hettipola'];//factorySelector.setFactoryOnUser();

  }
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    Color myColor = Color(0xFF000035);
    Color titleTextColor = Color(0xFFF5A906);
    print("Selected Factory check is : ${selectedFactory}");
    return Scaffold(
      body:Container(
        color: myColor,


        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: myColor,
                ),
                height: height/5,
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
                                color: AppColors.yellowGold,
                                size: 30.0,

                              ),
                            ),
                            Text("Income Calculators",style: TextStyle(fontWeight: FontWeight.bold,color:  AppColors.yellowGold,fontSize: 18.0),),
                            Container(
                              height: 40,
                              width: 40,

                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  image: DecorationImage(
                                      image: AssetImage('assets/icons/lady_40px.png')
                                  )
                              ),


                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top : height/80,
                            left: 20,
                            right: 40
                          //right: 15,

                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DropdownButton<String>(
                              value: selectedMonth,
                              dropdownColor: myColor,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: ConstData.deviceScreenWidth/25,
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

                                    loadData(selectedMonthInt).then((_) {
                                      if(targetIncomeController.text.isNotEmpty && balanceRemainingController.text.isNotEmpty){
                                        calculateBalanceRemaining();
                                      }
                                    });



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
                            SizedBox(width: 40),
                            // Dropdown to select factory

                            DropdownButton<String>(

                              value: selectedFactory,//factorySelector.setFactoryOnUserString(),
                              dropdownColor: Colors.black,
                              hint: const Text('Select Branch',style: TextStyle(color: Colors.white),),
                              items: factorySelector.setFactoryOnUser().map((branch) {
                                return DropdownMenuItem<String>(
                                  value: branch,
                                  child: Text(branch),
                                );
                              }).toList(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: ConstData.deviceScreenWidth/25,
                              ),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    selectedFactory = newValue;

                                    //if condition for checking month selection
                                    if(selectedMonth == '01 - Janauary'){
                                      selectedMonthInt = 01;
                                      print("Selecteed Month inttttttt ${selectedMonthInt}");
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

                                    loadData(selectedMonthInt).then((_) {
                                      if(targetIncomeController.text.isNotEmpty && balanceRemainingController.text.isNotEmpty){
                                        calculateBalanceRemaining();
                                      }
                                    });
                                    // Reload data when the factory is changed
                                  });
                                }
                              },
                            ),


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
                        begin: Alignment.topCenter,
                        colors: [
                          Colors.black26,
                          Colors.lightBlueAccent
                        ]
                    )

                ),
                height: height,
                width: width,
                child: SingleChildScrollView(
                   child: Column(
                     children: [
                       Container(
                         padding: EdgeInsets.all(10.0),
                         child: TextField(

                           readOnly: false,

                           decoration: InputDecoration(


                               labelText: 'Monthly Target Value  ${selectedFactory}',
                               labelStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 20),
                               border: OutlineInputBorder(),
                               prefixText: 'USD   :',
                               prefixStyle: TextStyle(
                                 color: Colors.white,
                                 fontWeight: FontWeight.bold,
                                 fontSize: 15.0,
                               )
                           ),
                           controller: targetIncomeController,//TextEditingController(text: 10000000.toString()),
                           onChanged: (String inputValue){
                             if(inputValue.isNotEmpty){
                               monthlyTarget = double.parse(inputValue);
                               setState(() {
                                 // balanceRemaining = monthlyTarget - calculateTotalIncome();
                                 // balanceRemainingController.text = balanceRemaining.toString();
                                 calculateBalanceRemaining();

                                 //======calculate Current and Required Income Rate ============//

                                 // DateTime currentDate = DateTime.now();
                                 //
                                 // remainingDays =calculateRemainingDays(currentDate);
                                 // print("Remaining Days are : $remainingDays");

                                 //calcluateCurrentIncomeRatePerDay();
                                 //calculateRequiredIncomeRatePerDay();

                               });
                             }else{
                               balanceRemainingController.text = 0.toString();
                             }

                           },
                           style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                           inputFormatters: [
                             FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                           ],
                         ),
                       ),
                       SizedBox(height: 30.0,),
                       Container(
                         padding: EdgeInsets.all(10.0),
                         child: TextField(

                           readOnly: true,
                           decoration: InputDecoration(


                               labelText: 'Income Up To Now :  ${selectedFactory}',
                               labelStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 20),
                               border: OutlineInputBorder(),
                               prefixText: 'USD   :',
                               prefixStyle: TextStyle(
                                 color: Colors.white,
                                 fontWeight: FontWeight.bold,
                                 fontSize: 15.0,
                               )                    ),
                           controller: TextEditingController(text:calculateTotalIncome().toString() ),
                           style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),

                         ),
                       ),
                       SizedBox(height: 30.0,),
                       Container(
                         decoration: BoxDecoration(

                           borderRadius: BorderRadius.only(
                             topLeft: Radius.circular(30),
                             topRight: Radius.circular(30),
                           ),
                         ),
                         //color: Colors.white,
                         padding: EdgeInsets.all(10.0),
                         child: Column(
                           children: [
                             TextField(

                               readOnly: true,
                               decoration: InputDecoration(


                                   labelText: 'Balence Remaining :  ${selectedFactory}',
                                   labelStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 20),
                                   border: OutlineInputBorder(),
                                   prefixText: 'USD   :',
                                   prefixStyle: TextStyle(
                                     color: Colors.white,
                                     fontWeight: FontWeight.bold,
                                     fontSize: 15.0,
                                   )
                               ),
                               controller: balanceRemainingController,
                               style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                             ),
                             Text('Ongoing Daily Income is USD : ${double.parse(currentIncomeRatePerDay.toStringAsFixed(2))}',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                             Text('To acheive the target USD  ${double.parse(requiredIncomeRatePerDay.toStringAsFixed(2))} must Earn Per Day',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                           ],
                         ),
                       ),
                       SizedBox(height: 18.0,),
                       Container(
                         height: ConstData.deviceScreenHeight/2.7,
                         width: ConstData.deviceScreenWidth/1.5,//
                         // Set the height as needed

                         child: showPieChart
                             ? PieChartWidget(
                           createPieChartSections: createPieSections,
                         )
                             : PieChartWidget(createPieChartSections: createPieSectionsForMonthlyIncome),
                         // Center(
                         //   // Your alternative content when not showing PieChartWidget
                         //   child: Text(
                         //     'Other Content',
                         //     style: TextStyle(
                         //       color: Colors.white,
                         //       fontWeight: FontWeight.bold,
                         //     ),
                         //   ),
                         // ),
                       ),
                       Row(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           IconButton(
                             icon: Icon(Icons.pie_chart, color: Colors.white),
                             iconSize: ConstData.deviceScreenWidth/20,
                             onPressed: () {
                               setState(() {
                                 showPieChart = true;
                               });
                             },
                           ),
                           SizedBox(width: 5.0),
                           Text(
                             'Day Income Prediction',
                             style: TextStyle(
                               color: Colors.white,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                           SizedBox(width: 10.0),
                           IconButton(
                             icon: Icon(Icons.bar_chart, color: Colors.white),
                             iconSize: ConstData.deviceScreenWidth/20,
                             onPressed: () {
                               setState(() {
                                 showPieChart = false;
                               });
                             },
                           ),
                           SizedBox(width: 5.0),
                           Text(
                             'Income',
                             style: TextStyle(
                               color: Colors.white,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                           // Add other icons and text for Bar Chart and Line Chart here
                         ],
                       ),
                     ],
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
                builder: (context) =>  Dashboard(),
              ),
            );
          }
        },
      ),
    );
  }

  void calculateBalanceRemaining(){
    balanceRemaining = monthlyTarget - calculateTotalIncome();
    balanceRemainingController.text = double.parse(balanceRemaining.toStringAsFixed(2)).toString();


  }

  //calculate total income of the given Month
  double calculateTotalIncome(){
    double totalIncome =0;
    double roundedIncome =0.0;

    if(efficiencyData != null){
      for(EfficiencyDtoGet efficiencyDTORetrieve in efficiencyData!){
        totalIncome += efficiencyDTORetrieve.income;
      }
    }
    roundedIncome = double.parse(totalIncome.toStringAsFixed(2));
    return roundedIncome;
  }

  int calculateRemainingDays(DateTime currentDate) {
    // Get the last day of the current month
    int remainingDays;
    int lastDayOfMonth = DateTime(currentDate.year, currentDate.month + 1, 0).day;
    if(currentDate.day == 29 && lastDayOfMonth ==29){
      remainingDays = 1;
    }else if(currentDate.day == 30 && lastDayOfMonth ==30){
      remainingDays = 1;
    }else if(currentDate.day == 31 && lastDayOfMonth ==31){
      remainingDays = 1;
    }else{
      remainingDays = lastDayOfMonth - currentDate.day;
    }
    // Calculate the remaining days in the month
    return remainingDays;
  }

  double calcluateCurrentIncomeRatePerDay(){


    currentIncomeRatePerDay =(calculateTotalIncome()/DateTime.now().day);//*DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day;
    print("Current Income Rate Per Day   : ${currentIncomeRatePerDay}");
    return double.parse(currentIncomeRatePerDay.toStringAsPrecision(2));


  }

  double calculateRequiredIncomeRatePerDay(){
    if(targetIncomeController.text.isNotEmpty)
      requiredIncomeRatePerDay = ((double.parse(targetIncomeController.text))-calculateTotalIncome())/calculateRemainingDays(DateTime.now());
    print("Hello : ${calculateRemainingDays(DateTime.now())}");
    print("Required Income here Rate Per Day   : $requiredIncomeRatePerDay");
    return double.parse(requiredIncomeRatePerDay.toStringAsPrecision(2));
  }

  List<PieChartSectionData> createPieSections() {
    // Generate data for pie chart sections based on efficiencyData
    // You need to modify this part based on your actual data structure
    List<PieChartSectionData> sections = [];

    for (int index = 0; index < 1; index++) {

      double requieredRate =calculateRequiredIncomeRatePerDay();
      print("Required Incomes Rate Per Day 01  : $requieredRate");
      double currentRate = calcluateCurrentIncomeRatePerDay();
      // uniqueLines[index]);

      sections.add(
        PieChartSectionData(
          color: Colors.red,
          value: double.parse(requiredIncomeRatePerDay.toStringAsFixed(2)),
          title: 'Required -> ${double.parse(requiredIncomeRatePerDay.toStringAsFixed(2))}',
          titleStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ConstData.deviceScreenWidth/28,
              color: Colors.black
          ),
          radius: min(
            ConstData.deviceScreenHeight / 2.7,
            ConstData.deviceScreenWidth / 1.5,
          ) / 2,
          titlePositionPercentageOffset: 0.6,
        ),
      );

      sections.add(
        PieChartSectionData(
            color: Colors.blue,
            value: double.parse(currentIncomeRatePerDay.toStringAsFixed(2)),
            title: 'Current- > ${double.parse(currentIncomeRatePerDay.toStringAsFixed(2))}',
            titleStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ConstData.deviceScreenWidth/28,
                color: Colors.white
            ),
            radius: min(
              ConstData.deviceScreenHeight / 2.7,
              ConstData.deviceScreenWidth / 1.5,
            ) / 2,
            titlePositionPercentageOffset: 0.6,

            borderSide: BorderSide(
              color: Colors.transparent, // Set your desired border color
              width: 2.0,
            )
        ),
      );
    }

    return sections;
  }
  List<PieChartSectionData> createPieSectionsForMonthlyIncome() {
    // Generate data for pie chart sections based on efficiencyData
    // You need to modify this part based on your actual data structure
    List<PieChartSectionData> sections = [];

    for (int index = 0; index < 1; index++) {
      // double requieredRate =calculateRequiredIncomeRatePerDay();
      // double currentRate = calcluateCurrentIncomeRatePerDay();
      // uniqueLines[index]);

      sections.add(
        PieChartSectionData(
          color: Colors.red,
          value: balanceRemaining.toDouble(),
          title: 'USD:${double.parse(balanceRemaining.toStringAsFixed(2))}',
          titleStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ConstData.deviceScreenWidth/28,
              color: Colors.black
          ),
          radius: min(
            ConstData.deviceScreenHeight / 2.7,
            ConstData.deviceScreenWidth / 1.5,
          ) / 2,//ConstData.deviceScreenWidth/4.2,
          titlePositionPercentageOffset: 0.6,
        ),
      );

      sections.add(
        PieChartSectionData(
            color: Colors.blue,
            value: calculateTotalIncome().toDouble(),
            title: 'USD:${calculateTotalIncome()}',
            titleStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ConstData.deviceScreenWidth/28,
                color: Colors.white
            ),
            radius: min(
              ConstData.deviceScreenHeight / 2.7,
              ConstData.deviceScreenWidth / 1.5,
            ) / 2,//ConstData.deviceScreenWidth/4.2,
            titlePositionPercentageOffset: 0.6,
            borderSide: BorderSide(
              color: Colors.transparent, // Set your desired border color
              width: 2.0,
            )
        ),
      );
    }

    return sections;
  }
}
