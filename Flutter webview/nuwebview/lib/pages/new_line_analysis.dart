import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../background/background.dart';
import '../const/api.dart';
import '../const/const_data.dart';
import '../controller/factory_selector.dart';
import '../model/EfficiencyDtoGet.dart';
import '../widgets/flexible_space_app_bar.dart';
import 'dashboard.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class NewLineAnalysisPage extends StatefulWidget {
  @override
  _NewLineAnalysisPage createState() => _NewLineAnalysisPage();
}

class _NewLineAnalysisPage extends State<NewLineAnalysisPage> {
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
    selectedDate = DateTime.now();
    //loadData(); // Load data here
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
            'Line Vs Efficiency Chart',
            style: TextStyle(
              color: Colors.yellowAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          flexibleSpace: FlexibleSpaceAppBar(),
          // shape: const RoundedRectangleBorder(
          //   borderRadius: BorderRadius.only(
          //     bottomLeft: Radius.circular(25),
          //     bottomRight: Radius.circular(25),
          //   ),
          // ),

        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
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
                        if (pickedDate != null && pickedDate != selectedDate) {
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
                            color: Colors.red,
                            size: 50.0,// Adjust the color as needed
                          ),
                          SizedBox(width: 8),
                          Text(
                            '  ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
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
                  SizedBox(width: 10),
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
                      items: factorySelector.setFactoryOnUser().map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              if (efficiencyData != null && efficiencyData!.isNotEmpty)


                Expanded(


                  child: Container(
                    height: ConstData.deviceScreenHeight/2,
                    width: ConstData.deviceScreenWidth/1.2,
                    child: BarChart(
                      BarChartData(

                        barGroups: createBarGroups(),

                        titlesData: FlTitlesData(
                          leftTitles: SideTitles(showTitles: true,getTextStyles: (context, value) {
                            // Change text color based on value
                            Color textColor = value > 0 ? Colors.white : Colors.white;

                            return TextStyle(
                              color: textColor,
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold
                            );
                          },),
                          bottomTitles: SideTitles(

                            showTitles: true,
                            getTextStyles: (context, value) {
                              // Change text color based on value
                              Color textColor = value > 0 ? Colors.white : Colors.white;

                              return TextStyle(
                                  color: textColor,
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.bold
                              );
                            },
                            getTitles: (value) {

                              int index = value.toInt();
                              return index < uniqueLines.length ? uniqueLines[index] : '';
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

  //change the color of x and y axix


  List<BarChartGroupData> createBarGroups() {


    return List.generate(uniqueLines.length, (index) {
      double lineEfficiency = 0.0;
      double lineforcastEff = 0.0;

      // Check if the list is not empty before calculating values
      if (uniqueLines.isNotEmpty) {
        lineEfficiency = calculateLineEfficiency(uniqueLines[index]);
        lineforcastEff = calculateLineForcastEfficiency(uniqueLines[index]);
        //print(uniqueLines[index]);
      } else {
        print("Error: uniqueLines is empty");
      }

      return BarChartGroupData(

        x: index,
        barRods: [
          BarChartRodData(
            y: lineforcastEff * 100,
            colors: [Colors.green],
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            y: lineEfficiency * 100,
            colors: [Colors.blue],
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  double calculateLineEfficiency(String lineNo) {
    double totalEfficiency = 0.0;
    int count = 0;


    if (efficiencyData != null) {
      for (EfficiencyDtoGet efficiency in efficiencyData!) {
        if (efficiency.lineNo.toString() == lineNo) {
          //print("EFFFFFFFFFFFFFFF : ${efficiency.forecastEff}");
          totalEfficiency += efficiency.actualEff;
          count++;
        }
      }
    }

    return count > 0 ? totalEfficiency : 0.0; ;
  }
  double calculateLineForcastEfficiency(String lineNo) {
    double totalForcastEfficiency = 0.0;
    int count = 0;

    if (efficiencyData != null) {
      for (EfficiencyDtoGet efficiency in efficiencyData!) {
        if (efficiency.lineNo.toString() == lineNo) {
          totalForcastEfficiency += efficiency.forecastEff;
          count++;
        }
      }
    }

    //print("forcast Efficicnecy ${totalForcastEfficiency}");
    return count > 0 ? totalForcastEfficiency: 0.0;
    //return  totalForcastEfficiency  ;
  }
}
