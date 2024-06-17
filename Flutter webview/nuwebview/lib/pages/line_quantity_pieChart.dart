import 'dart:convert';
import 'dart:math';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


import 'dart:math' as math;

import '../background/background.dart';
import '../const/api.dart';
import '../const/const_data.dart';
import '../controller/factory_selector.dart';
import '../model/EfficiencyDtoGet.dart';
import 'package:http/http.dart' as http;

import '../widgets/flexible_space_app_bar.dart';
import 'dashboard.dart';
import 'line_quantity_barChart.dart';


class LineQuantityPieChart extends StatefulWidget {
  final DateTime passedDate;
  final String passedBranch;

  const LineQuantityPieChart({super.key, required this.passedDate,required this.passedBranch});


  @override
  State<LineQuantityPieChart> createState() => _LineQuantityPieChartState();
}

class _LineQuantityPieChartState extends State<LineQuantityPieChart> {
  late DateTime selectedDate;
  List<EfficiencyDtoGet>? efficiencyData;
  List<String> uniqueStyles = [];
  List<String> uniqueLines = [];
  Map<int, String> indexToStyleMap = {};
  Map<int, String> indexToLineMap = {};
  String? selectedFactory;

  FactorySelector factorySelector = FactorySelector();





  void initState() {
    super.initState();
    //selectedDate = DateTime.now();
    selectedDate = widget.passedDate;
    selectedFactory = widget.passedBranch;
    loadData(); // Load data here
  }

  final List<String> _branches = [
    'Bakamuna Factory',
    'Hettipola Factory',
    'Mathara Factory',
    'Piliyandala Factory',
    'Welioya Factory',
  ];

  //PIE chart Legend Labels
  final pieChartLegendLabels = <String, String>{
    "Flutter": "Flutter legend",
    "React": "React legend",
    "Xamarin": "Xamarin legend",
    "Ionic": "Ionic legend",
  };
  final colorList = <Color>[
    const Color(0xfffdcb6e),
    const Color(0xff0984e3),
    const Color(0xfffd79a8),
    const Color(0xffe17055),
    const Color(0xff6c5ce7),
  ];



  Future<void> loadData() async {
    try {
      final response = await http.get(Uri.parse('${API.apiUrl}api/branchDate?date=$selectedDate&branchId=$selectedFactory'));


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
          print(decodedData);

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
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    //double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Line Vs Quantity Analysis",
          style: TextStyle(
            color: Colors.yellowAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.analytics_outlined,color: Colors.white,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        flexibleSpace: FlexibleSpaceAppBar(),
      ),
      body: BackgroundImage(

        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                     Expanded(
                       child: TextButton(
                          onPressed: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null && pickedDate !=
                                selectedDate) {
                              setState(() {
                                uniqueStyles = [];
                                selectedDate = pickedDate;
                                loadData(); // Reload data when the date is changed
                              });
                            }
                          },
                          child: Column(
                            children: [
                              Icon(
                                Icons.calendar_month,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Select Date: ${DateFormat('yyyy-MM-dd').format(
                                    selectedDate)}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                     ),

                    SizedBox(width: 5),
                    // Dropdown to select factory
                    Expanded(

                      child: DropdownButton<String>(
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
                              loadData();

                              // Reload data when the factory is changed
                            });
                          }
                        },
                      ),
                      // child: DropdownButton<String>(
                      //   value: selectedFactory,//factorySelector.setFactoryOnUserString(),
                      //   dropdownColor: Colors.black,
                      //   hint: const Text('Select Branch'),
                      //   style: TextStyle(
                      //     fontWeight: FontWeight.bold,
                      //     color: Colors.white,
                      //     fontSize: 18.00,
                      //
                      //   ),
                      //   onChanged: (String? newValue) {
                      //     if (newValue != null) {
                      //       setState(() {
                      //         selectedFactory = newValue;
                      //         loadData(); // Reload data when the factory is changed
                      //       });
                      //     }
                      //   },
                      //   items: factorySelector.setFactoryOnUser().map((branch) {
                      //     return DropdownMenuItem<String>(
                      //       value: branch,
                      //       child: Text(
                      //         branch,
                      //         style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04),
                      //       ),
                      //     );
                      //   }).toList(),
                      // ),
                    )
                  ],
                ),
                SizedBox(height: 70),

                // Display the pie chart here
                Container(
                  height: ConstData.deviceScreenHeight/2, //
                  // Set the height as needed
                  child: PieChart(


                    PieChartData(

                        sections: createPieSections(),
                        sectionsSpace: 0,
                        centerSpaceRadius: 0,
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: Colors.black, // Set your desired border color
                            width: 2.0, // Set your desired border width
                          ),
                        )
                      // Add other configurations as needed
                    ),

                  ),
                ),
                SizedBox(height: 10.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Container(

                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(

                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child:Text(

                            "Actual Quantity",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,

                            ),
                          )
                      ),
                    ),
                    SizedBox(width: 8), // Adjust the spacing between the containers
                    Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child:Text(
                          "Forecasted Quantity",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,

                          ),
                        )
                    ),
                  ],
                ),

                //add chart selection Buttons
                SizedBox(height: 20,),

                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(

                          icon: Icon(Icons.bar_chart,color: Colors.white,),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LineQuantityBarChart(passedDate: selectedDate,passedBranch: selectedFactory!,),
                              ),
                            );

                          },
                          iconSize: ConstData.deviceScreenWidth/20, // Set the icon size as needed
                          splashRadius: 24.0, // Set the splash radius as needed
                          color: Colors.blue, // Set the icon color as needed
                          // ButtonStyle for circular shape


                        ),
                        SizedBox(height: 8.0), // Adjust the space between Icon and Text
                        Text(
                          'Bar Chart',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(width: 10.0,),
                        IconButton(

                          icon: Icon(Icons.stacked_line_chart,color: Colors.white,),
                          onPressed: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => LineQuantityLineChart(passedDate: selectedDate, passedBranch: selectedFactory),
                            //   ),
                            // );

                          },
                          iconSize: ConstData.deviceScreenWidth/20, // Set the icon size as needed
                          splashRadius: 24.0, // Set the splash radius as needed
                          color: Colors.blue, // Set the icon color as needed
                          // ButtonStyle for circular shape


                        ),
                        SizedBox(height: 8.0), // Adjust the space between Icon and Text
                        Text(
                          'Line Chart',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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

      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.deepPurple,
        height: 50.0,
        animationCurve: Curves.easeInOut,
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
          }else if(index == 2){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>  Dashboard()//SettingsPage(),
              ),
            );
          }
        },
      ),
    );
  }

  List<PieChartSectionData> createPieSections() {
    // Generate data for pie chart sections based on efficiencyData
    // You need to modify this part based on your actual data structure
    List<PieChartSectionData> sections = [];

    for (int index = 0; index < uniqueLines.length; index++) {
      int lineActualQuantity = calculateLineActualQuantity(uniqueLines[index]);
      int lineForecastedQuantity = calculateLineForecastedQuantity(
          uniqueLines[index]);

      sections.add(
        PieChartSectionData(
          color: Colors.red,
          value: lineActualQuantity.toDouble(),
          title: 'L ${indexToLineMap[index]} -> $lineActualQuantity',

          titleStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ConstData.deviceScreenWidth/40,
              color: Colors.black
          ),
          radius: min(
            ConstData.deviceScreenHeight / 2.7,
            ConstData.deviceScreenWidth / 1.5,
          ) / 2,
          titlePositionPercentageOffset: 0.8,
        ),
      );

      sections.add(
        PieChartSectionData(
            color: Colors.blue,
            value: lineForecastedQuantity.toDouble(),
            title: 'L ${indexToLineMap[index]} - > $lineForecastedQuantity',
            titleStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ConstData.deviceScreenWidth/40,
                color: Colors.white
            ),
            radius: min(
              ConstData.deviceScreenHeight / 2.7,
              ConstData.deviceScreenWidth / 1.5,
            ) / 2,
            titlePositionPercentageOffset: 0.5,
            borderSide: BorderSide(
              color: Colors.transparent, // Set your desired border color
              width: 2.0,
            )
        ),
      );
    }

    return sections;
  }


  int calculateLineActualQuantity(String lineNo) {
    int quantity = 0;

    if (efficiencyData != null) {
      for (EfficiencyDtoGet efficiency in efficiencyData!) {
        if (efficiency.lineNo.toString() == lineNo) {
          quantity += efficiency.actualPcs;
        }
      }
    }

    return quantity;
  }

  int calculateLineForecastedQuantity(String lineNo) {
    int quantity = 0;

    if (efficiencyData != null) {
      for (EfficiencyDtoGet efficiency in efficiencyData!) {
        if (efficiency.lineNo.toString() == lineNo) {
          quantity += efficiency.forecastPcs;
        }
      }
    }

    return quantity;
  }
}
