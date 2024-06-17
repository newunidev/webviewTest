import 'dart:convert';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;

import '../background/background.dart';
import '../const/api.dart';
import '../const/const_data.dart';
import '../controller/factory_selector.dart';
import '../model/EfficiencyDtoGet.dart';
import 'dashboard.dart';
import 'line_quantity_pieChart.dart';



class LineQuantityBarChart extends StatefulWidget {

  final DateTime passedDate;
  final String passedBranch;

  LineQuantityBarChart({Key?mykey, required this.passedDate,required this.passedBranch}) : super(key: mykey);



  @override
  _LineQuantityBarChart createState() => _LineQuantityBarChart();
}

class _LineQuantityBarChart extends State<LineQuantityBarChart> {


  late DateTime selectedDate;
  String selectedFactory = 'Bakamuna Factory'; // Default factory
  List<EfficiencyDtoGet>? efficiencyData;
  List<String> uniqueStyles = [];
  List<String> uniqueLines = [];
  Map<int, String> indexToStyleMap = {};
  Map<int, String> indexToLineMap = {};

  FactorySelector factorySelector = FactorySelector();

  final List<String> _branches = [
    'Bakamuna Factory',
    'Hettipola Factory',
    'Mathara Factory',
    'Piliyandala Factory',
    'Welioya Factory',
  ];

  @override
  void initState() {
    super.initState();
    //selectedDate = DateTime.now();
    selectedDate = widget.passedDate;
    selectedFactory = widget.passedBranch;
    loadData(); // Load data here
  }

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
    return BackgroundImage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            "Line Vs Quantity Analysis",
            style: TextStyle(
              color: Colors.yellowAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          flexibleSpace: Image.asset(
            'assets/images/background1.jpg',
            fit: BoxFit.cover,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
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
                      value: factorySelector.setFactoryOnUserString(),
                      dropdownColor: Colors.black,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18.00,
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedFactory = newValue;
                            loadData(); // Reload data when the factory is changed
                          });
                        }
                      },
                      items: factorySelector.setFactoryOnUser().map<DropdownMenuItem<String>>((
                          String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 70),
              // Check if efficiencyData is not null and not empty
              if (efficiencyData != null && efficiencyData!.isNotEmpty)
                Expanded(
                  child: Container(
                    height: ConstData.deviceScreenHeight/2,
                    width: ConstData.deviceScreenWidth/1.2,
                    child: BarChart(
                      BarChartData(
                        barGroups: createBarGroups(),
                        titlesData: FlTitlesData(
                          leftTitles: SideTitles(
                            showTitles: true,
                            getTextStyles: (context, value) {
                              return TextStyle(
                                color: Colors.white,
                                fontSize: 16, // Set your desired text size for bottom titles
                              );
                            },
                          ),
                          rightTitles: SideTitles(
                            showTitles: true,
                            getTextStyles: (context, value) {
                              return TextStyle(
                                color: Colors.white,
                                fontSize: 16, // Set your desired text size for bottom titles
                              );
                            },
                          ),
                          bottomTitles: SideTitles(
                            showTitles: true,
                            getTitles: (value) {
                              int index = value.toInt();
                              return index < uniqueLines.length ? uniqueLines[index] : '';
                            },
                            getTextStyles: (context, value) {
                              return TextStyle(
                                color: Colors.white,
                                fontSize: 16, // Set your desired text size for bottom titles
                              );
                            },
                          ),
                        ),

                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: const Color(0xff37434d), width: 1),
                        ),
                      ),
                    ),
                  ),
                )
              else
                Text(
                  'No data available', // You can customize this message
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(

                        icon: Icon(Icons.pie_chart_outline,color: Colors.white,),
                        onPressed: () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LineQuantityPieChart(passedDate: selectedDate,passedBranch: selectedFactory,),
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
                        'Pie Chart',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(width: 10.0,),
                      IconButton(

                        icon: Icon(Icons.stacked_line_chart,color: Colors.white,),
                        onPressed: () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LineQuantityPieChart(passedBranch: selectedFactory,passedDate: selectedDate,),
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
                  builder: (context) =>  Dashboard(),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  List<BarChartGroupData> createBarGroups() {
    return List.generate(uniqueLines.length, (index) {
      int lineActualQty = 0;
      int lineForcastQty = 0;

      // Check if the list is not empty before calculating values
      if (uniqueLines.isNotEmpty) {
        lineActualQty = calculateLineActualQuantity(uniqueLines[index]);
        lineForcastQty = calculateLineForcastQuantity(uniqueLines[index]);
        //print(uniqueLines[index]);
      } else {
        print("Error: uniqueLines is empty");
      }

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            y: lineForcastQty.toDouble(),
            colors: [Colors.blue],
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            y: lineActualQty.toDouble(),
            colors: [Colors.red],
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  int calculateLineActualQuantity(String lineNo) {
    int totalQty = 0;
    int count = 0;

    if (efficiencyData != null) {
      for (EfficiencyDtoGet efficiency in efficiencyData!) {
        if (efficiency.lineNo.toString() == lineNo) {
          //print("EFFFFFFFFFFFFFFF : ${efficiency.forecastEff}");
          totalQty += efficiency.actualPcs;
          count++;
        }
      }
    }

    return count > 0 ? totalQty : 0;
  }

  int calculateLineForcastQuantity(String lineNo) {
    int totalForcastQuantity = 0;
    int count = 0;

    if (efficiencyData != null) {
      for (EfficiencyDtoGet efficiency in efficiencyData!) {
        if (efficiency.lineNo.toString() == lineNo) {
          totalForcastQuantity += efficiency.forecastPcs;
          count++;
        }
      }
    }

    //print("forcast Efficicnecy ${totalForcastEfficiency}");
    return count > 0 ? totalForcastQuantity: 0;
    //return  totalForcastEfficiency  ;
  }
}
