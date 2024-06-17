import 'dart:convert';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import '../background/background.dart';

import '../const/api.dart';
import '../const/const_data.dart';
import '../controller/factory_selector.dart';
import '../model/EfficiencyDtoGet.dart';
import '../widgets/pie_chart.dart';
import 'dashboard.dart';
import 'package:http/http.dart' as http;

import 'efficiency_analysis_new.dart';

class EfficiencyAnalysisBar extends StatefulWidget {
  final int passedMonth;
  final String passedBranch;
  final double passedTargetEfficiency;
  final int passedDaysWorked;

  const EfficiencyAnalysisBar({super.key,required this.passedMonth,required this.passedBranch,required this.passedTargetEfficiency,required this.passedDaysWorked});

  @override
  State<EfficiencyAnalysisBar> createState() => _EfficiencyAnalysisBarState();
}

class _EfficiencyAnalysisBarState extends State<EfficiencyAnalysisBar> {
  var height,width;

  String? selectedFactory;
  String selectedMonth = "01 - Janauary";

  int selectedMonthInt = 0;
  FactorySelector factorySelector = FactorySelector();



  TextEditingController noOfDaysController = TextEditingController();
  TextEditingController targetEfficiencyController = TextEditingController();

  //load data variables
  List<EfficiencyDtoGet>? efficiencyData;
  List<String> uniqueStyles = [];
  List<String> uniqueLines = [];
  Map<int, String> indexToStyleMap = {};
  Map<int, String> indexToLineMap = {};





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
      final response = await http.get(Uri.parse('${API.apiUrl}api/efficiency?branchId=$selectedFactory&month=$selectedMonthInt'));

      //print(response.s)

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
      } else {
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

    //print("Passed Branch is : ${widget.passedBranch}");
    selectedFactory = widget.passedBranch;
    targetEfficiencyController.text=widget.passedTargetEfficiency.toString();
    noOfDaysController.text=widget.passedDaysWorked.toString();
    //selectedMonth = '01-January';
    selectedMonthInt= widget.passedMonth;
    selectedMonth = months[widget.passedMonth-1];
    loadData(widget.passedMonth);

    //selectedMonth = widget.passedMonth.toString();
    factorySelector.setFactoryOnUserString();
    //_branches = ['Hettipola'];//factorySelector.setFactoryOnUser();

  }
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    Color myColor = Color(0xFF000035);
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
                                color: Colors.orange,
                                size: 30.0,

                              ),
                            ),
                            Text("Efficiency Calculator",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.orangeAccent,fontSize: 18.0),),
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
                              dropdownColor: Colors.black,
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
                                      if(targetEfficiencyController.text.isNotEmpty && noOfDaysController.text.isNotEmpty){
                                        //calculateTotalActualEfficiency();
                                        //calculateAverageEfficiency();
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
                              hint: const Text('Select Branch'),
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
                                      if(targetEfficiencyController.text.isNotEmpty && noOfDaysController.text.isNotEmpty){
                                        //calculateAverageEfficiency();
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
                  scrollDirection: Axis.vertical,

                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.0),
                        child: TextField(

                          readOnly: false,

                          decoration: InputDecoration(


                              labelText: 'Target Efficiency :   ${selectedFactory}',
                              labelStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: ConstData.deviceScreenWidth/30),
                              border: OutlineInputBorder(),
                              prefixText: 'Efficiency   :',
                              prefixStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0,
                              )
                          ),
                          controller: targetEfficiencyController,//TextEditingController(text: 10000000.toString()),
                          onChanged: (String inputValue){
                            if(inputValue.isNotEmpty){
                              //monthlyTarget = double.parse(inputValue);
                              setState(() {

                              });
                            }else{
                              targetEfficiencyController.text = 0.toString();
                            }

                          },
                          style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                          ],
                        ),
                      ),
                      SizedBox(height: 10,),
                      Container(
                        padding: EdgeInsets.all(10.0),
                        child: TextField(

                          readOnly: false,

                          decoration: InputDecoration(


                              labelText: 'No Of Days Worked :  ${selectedFactory}',
                              labelStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: ConstData.deviceScreenWidth/30),
                              border: OutlineInputBorder(),
                              prefixText: 'Days   :',
                              prefixStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0,
                              )
                          ),
                          controller: noOfDaysController,//TextEditingController(text: 10000000.toString()),
                          onChanged: (String inputValue){
                            if(inputValue.isNotEmpty){
                              //noOfDaysController.text = double.parse(inputValue).toString();
                              setState(() {
                                calculateAverageEfficiency();

                              });
                            }else{
                              noOfDaysController.text = 0.toString();
                            }

                          },
                          style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.0,),

                      SizedBox(height: 2.0,),
                      Container(
                        height: ConstData.deviceScreenHeight/2,
                        width: ConstData.deviceScreenWidth/1.5,//
                        // Set the height as needed

                        child: showPieChart
                            ? BarChart(
                          BarChartData(
                            titlesData: FlTitlesData(
                              leftTitles: SideTitles(
                                showTitles: true,
                                getTextStyles: (context, value) {
                                  return TextStyle(
                                    color: Colors.white,
                                    fontSize: 16, // Set your desired text size for tooltips
                                  );
                                },
                              ),
                            ),
                            barGroups: createBarGroups(),

                          ),
                        )
                            : BarChart(
                          BarChartData(
                            titlesData: FlTitlesData(
                              leftTitles: SideTitles(
                                showTitles: true,
                                getTextStyles: (context, value) {
                                  return TextStyle(
                                    color: Colors.white,
                                    fontSize: 16, // Set your desired text size for tooltips
                                  );
                                },
                              ),
                              rightTitles: SideTitles(
                                showTitles: true,
                                getTextStyles: (context, value) {
                                  return TextStyle(
                                    color: Colors.white,
                                    fontSize: 16, // Set your desired text size for tooltips
                                  );
                                },
                              ),
                            ),
                            barGroups: createBarGroups(),
                          ),
                        ),
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 45.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.pie_chart, color: Colors.white),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EfficiencyAnalysisNew(passedMonth: selectedMonthInt,passedBranch: selectedFactory!,passedTargetEfficiency: double.parse(targetEfficiencyController.text),passedDaysWorked: int.parse(noOfDaysController.text))//NewLineAnalysisPage(),
                                  ),
                                );
                              },
                              iconSize: ConstData.deviceScreenWidth/20,
                            ),
                            SizedBox(width: 5.0),

                            Text(
                              'Pie Chart',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 10.0),
                            IconButton(
                                icon: Icon(Icons.bar_chart, color: Colors.white),
                                onPressed: () {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //       builder: (context) => EfficiencyAnalysisBar()//NewLineAnalysisPage(),
                                  //   ),
                                  // );
                                },
                                iconSize: ConstData.deviceScreenWidth/20
                            ),
                            SizedBox(width: 5.0),
                            Text(
                              'Bar Chart',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // Add other icons and text for Bar Chart and Line Chart here
                          ],
                        ),
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
  double calculateTotalActualEfficiency(){
    //print("AWA");
    double totalActualEfficiency =0.0;

    if(efficiencyData!=null){
      for(EfficiencyDtoGet efficiencyDtoRetrieve in efficiencyData!){
        totalActualEfficiency += efficiencyDtoRetrieve.actualEff;
      }
    }
    print("total Efficiency : ${double.parse((totalActualEfficiency*100).toStringAsFixed(2))}");
    return double.parse(totalActualEfficiency.toStringAsFixed(2));
  }

  //calculate average efficiency

  double calculateAverageEfficiency(){
    double noOfDays = noOfDaysController.text.isEmpty
        ? 0.0 // Set a default value if the text is empty
        : double.tryParse(noOfDaysController.text) ?? 0.0;
    double averageEfficiency =0.0;

    if(noOfDaysController.text.isNotEmpty){

      if(selectedFactory == 'Bakamuna Factory'){
        averageEfficiency = calculateTotalActualEfficiency()/noOfDays/4;
      }else if(selectedFactory == 'Hettipola Factory'){
        averageEfficiency = calculateTotalActualEfficiency()/noOfDays/6;
      }else if(selectedFactory == 'Mathara Factory'){
        averageEfficiency = calculateTotalActualEfficiency()/noOfDays/4;
      }else if(selectedFactory == 'Piliyandala Factory'){
        averageEfficiency = calculateTotalActualEfficiency()/noOfDays;
      }else if(selectedFactory == 'Welioya Factory'){
        averageEfficiency = calculateTotalActualEfficiency()/noOfDays/2;
      }

    }

    print(selectedFactory);
    print("Average Efficiency :${averageEfficiency*100}");
    return double.parse((averageEfficiency*100).toStringAsFixed(2));
  }


  //calculate total income of the given Month







  // List<PieChartSectionData> createPieSections() {
  //   // Generate data for pie chart sections based on efficiencyData
  //   // You need to modify this part based on your actual data structure
  //   List<PieChartSectionData> sections = [];
  //
  //   double targetEfficiency = targetEfficiencyController.text.isEmpty
  //       ? 0.0 // Set a default value if the text is empty
  //       : double.tryParse(targetEfficiencyController.text) ?? 0.0;
  //
  //
  //
  //   for (int index = 0; index < 1; index++) {
  //     //double ave =calculateRequiredIncomeRatePerDay();
  //
  //     // uniqueLines[index]);
  //
  //     sections.add(
  //       PieChartSectionData(
  //         color: Colors.red,
  //         value: double.parse(calculateAverageEfficiency().toString()),
  //         title: 'Current  -> ${double.parse(calculateAverageEfficiency().toString())}',
  //         titleStyle: TextStyle(
  //             fontWeight: FontWeight.bold,
  //             fontSize: 14.0,
  //             color: Colors.black
  //         ),
  //         radius: 120,
  //         titlePositionPercentageOffset: 0.6,
  //       ),
  //     );
  //
  //     sections.add(
  //       PieChartSectionData(
  //           color: Colors.blue,
  //
  //           value: targetEfficiency,
  //           title: 'Target- > ${targetEfficiency}',
  //           titleStyle: TextStyle(
  //               fontWeight: FontWeight.bold,
  //               fontSize: 18.0,
  //               color: Colors.white
  //           ),
  //           radius: 120,
  //           titlePositionPercentageOffset: 0.6,
  //           borderSide: BorderSide(
  //             color: Colors.transparent, // Set your desired border color
  //             width: 2.0,
  //           )
  //       ),
  //     );
  //   }
  //
  //   return sections;
  // }

  List<BarChartGroupData> createBarGroups() {
    List<BarChartGroupData> barGroups = [];

    double targetEfficiency = targetEfficiencyController.text.isEmpty
        ? 0.0 // Set a default value if the text is empty
        : double.tryParse(targetEfficiencyController.text) ?? 0.0;

    barGroups.add(
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            y: double.parse(calculateAverageEfficiency().toString()),
            colors: [Colors.red],
            width: ConstData.deviceScreenWidth/30


          ),
          BarChartRodData(
            y: targetEfficiency,
            colors: [Colors.blue],
              width: ConstData.deviceScreenWidth/30

          ),
        ],
        showingTooltipIndicators: [0, 1],
      ),
    );

    return barGroups;
  }

}
