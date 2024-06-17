import 'dart:convert';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;


import '../const/api.dart';
import '../const/const_data.dart';
import '../controller/factory_selector.dart';
import '../model/EfficiencyDtoGet.dart';
import '../widgets/flexible_space_app_bar.dart';
import 'dashboard.dart';

//pdf imports
//pdf
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'dart:io';
import 'package:open_file/open_file.dart';

class AllDataNew extends StatefulWidget {
  const AllDataNew({super.key});

  @override
  State<AllDataNew> createState() => _AllDataNewState();
}

class _AllDataNewState extends State<AllDataNew> {
  var height,width;
  FactorySelector factorySelector = FactorySelector();

  //List<Map<String, dynamic>>? efficiencyData;
  List<EfficiencyDtoGet> efficiencyList = [];
  //EfficiencyDtoGet efficiencyDtoGet = EfficiencyDtoGet();

  List<EfficiencyDtoGet> filteredList = [];

  TextEditingController searchController = TextEditingController();




  DateTime selectedDate = DateTime.now();
  String? selectedFactory; // Default factory
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
    selectedDate = DateTime.now();

    loadData(); // Load data here
  }


  //create PDF Method
  Future<void> generateEfficiencyPDF(List<EfficiencyDtoGet> data) async {
    final pdf = pdfWidgets.Document();

    pdf.addPage(
      pdfWidgets.Page(
        orientation: pdfWidgets.PageOrientation.landscape,
        build: (context) {
          final List<pdfWidgets.TableRow> tableRows = [];

          // Headers
          tableRows.add(pdfWidgets.TableRow(
            children: [
              for (var header in [
                'Style',
                'Date',
                'Branch ',
                'Line ',
                'PO ',
                'Qty',
                'MO',
                'HEL',
                'Iron',
                'SMV',
                'CM',
                'FPCS',
                'F SAH',
                'F EFF',
                'A PCS',
                'A SAH',
                'A EFF',
                'Income',
              ])
                pdfWidgets.Container(
                  padding: pdfWidgets.EdgeInsets.all(5),
                  child: pdfWidgets.Text(

                    header,
                    style: pdfWidgets.TextStyle(fontWeight: pdfWidgets.FontWeight.bold,fontSize: 8.0),
                  ),
                ),
            ],
          ));

          // Data rows
          for (final EfficiencyDtoGet efficiency in data) {
            final List<String> rowValues = [
              efficiency.style,
              DateFormat('yyyy-MM-dd').format(efficiency.date.toLocal()),
              efficiency.branchId,
              efficiency.lineNo.toString(),
              efficiency.poNo,
              efficiency.qty.toString(),
              efficiency.mo.toString(),
              efficiency.hel.toString(),
              efficiency.iron.toString(),
              efficiency.smv.toString(),
              efficiency.cm.toString(),
              efficiency.forecastPcs.toString(),
              efficiency.forecastSah.toString(),
              (efficiency.forecastEff * 100).toStringAsFixed(2),

              efficiency.actualPcs.toString(),
              efficiency.actualSah.toString(),
              (efficiency.actualEff * 100).toStringAsFixed(2),
              efficiency.income.toString(),
            ];

            final List<pdfWidgets.Widget> rowWidgets = rowValues
                .map((value) => pdfWidgets.Container(
              padding: pdfWidgets.EdgeInsets.all(5),
              child: pdfWidgets.Text(
                value,
                style: pdfWidgets.TextStyle(
                  fontSize: 5.0, // Adjust the font size as needed
                ),
              ),
            ))
                .toList();

            tableRows.add(pdfWidgets.TableRow(
              children: rowWidgets,
            ));
          }

          return pdfWidgets.Table(
            columnWidths: {
              0: pdfWidgets.FixedColumnWidth(300), // Style
              1: pdfWidgets.FixedColumnWidth(300), // Date
              2: pdfWidgets.FixedColumnWidth(300), // Branch ID
              3: pdfWidgets.FixedColumnWidth(300), // Line No
              4: pdfWidgets.FixedColumnWidth(300), // PO No
              5: pdfWidgets.FixedColumnWidth(300), // Qty
              6: pdfWidgets.FixedColumnWidth(300), // MO
              7: pdfWidgets.FixedColumnWidth(300), // HEL
              8: pdfWidgets.FixedColumnWidth(300), // Iron
              9: pdfWidgets.FixedColumnWidth(300), // SMV
              10: pdfWidgets.FixedColumnWidth(300), // CM
              11: pdfWidgets.FixedColumnWidth(300), // Forecast PCS
              12: pdfWidgets.FixedColumnWidth(300), // Forecast SAH
              13: pdfWidgets.FixedColumnWidth(300), // Forecast EFF
              14: pdfWidgets.FixedColumnWidth(300), // Actual PCS
              15: pdfWidgets.FixedColumnWidth(300), // Actual SAH
              16: pdfWidgets.FixedColumnWidth(300), // Actual EFF
              17: pdfWidgets.FixedColumnWidth(300), // Income
            },
            defaultVerticalAlignment: pdfWidgets.TableCellVerticalAlignment.middle,
            border: pdfWidgets.TableBorder.all(),
            children: tableRows,
          );
        },
      ),
    );

    final directory = await getExternalStorageDirectory();
    final documentsDirectory = Directory('${directory!.path}/Documents');

    // Create the 'Documents' directory if it doesn't exist
    if (!await documentsDirectory.exists()) {
      await documentsDirectory.create(recursive: true);
    }

    final filePath = '${documentsDirectory.path}/efficiency_example.pdf';

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    OpenFile.open(filePath); // Open the PDF file after saving

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF saved at: $filePath'),
      ),
    );
  }



//search feature
  void _filterData(String searchTerm) {
    setState(() {
      filteredList = efficiencyList.where((efficiency) {
        return efficiency.style.toLowerCase().contains(searchTerm.toLowerCase()) ||
            efficiency.poNo.toLowerCase().contains(searchTerm.toLowerCase());
      }).toList();
    });
  }

  Future<void> loadData() async {

    try {
      //print("Datess :${selectedDate}");

      final response = await http.get(Uri.parse('${API.apiUrl}api/branchDate?date=$selectedDate&branchId=$selectedFactory'));

      //api for springframework api requests.
      //final response = await http.get(Uri.parse('http://192.168.1.149:8080/api/branchDate?date=${selectedDate}&branch_id=$selectedFactory'));



      if (response.statusCode == 200) {

        // If the server returns a 200 OK response, parse the data
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          efficiencyList = data.map((item) => EfficiencyDtoGet.fromJson(item)).toList();
          filteredList = List.from(efficiencyList);
          for (var efficiency in efficiencyList) {
            print(DateFormat('yyyy-MM-dd HH:mm:ss').format(efficiency.date.toLocal()));
          }
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
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    Color myColor = Color(0xFF2D1A42);
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
                                    
                                    
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top : 0,
                              left: 13,
                              //right: 15,

                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  //padding: const EdgeInsets.symmetric(vertical: 1),
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
                                          size:40.0,
                                          color: Colors.white, // Adjust the color as needed
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          '${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: width*.04,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 40),
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

                                                //if condition for checking month selection

                                                // Reload data when the factory is changed
                                              });
                                            }
                                          },
                                        ),
                                        // child: DropdownButton<String>(
                                        //   value: factorySelector.setFactoryOnUserString(),
                                        //   hint:const Text("Select Factory", style: TextStyle(color: Colors.white),),
                                        //   borderRadius:BorderRadius.circular(10.0),
                                        //   icon: Icon(Icons.factory_rounded,color: Colors.red,),
                                        //
                                        //
                                        //   dropdownColor: myColor,
                                        //   // decoration: InputDecoration(
                                        //   //   filled: true,
                                        //   //   fillColor: Colors.white,
                                        //   //   hintText: 'Select Branch',
                                        //   //   //contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        //   //   border: OutlineInputBorder(
                                        //   //     borderRadius: BorderRadius.circular(10.0),
                                        //   //   ),
                                        //   //   enabledBorder: OutlineInputBorder(
                                        //   //     borderSide: BorderSide(color: Colors.black),
                                        //   //     borderRadius: BorderRadius.circular(10.0),
                                        //   //   ),
                                        //   //   // focusedBorder: OutlineInputBorder(
                                        //   //   //   borderSide: BorderSide(color: Colors.white),
                                        //   //   //   borderRadius: BorderRadius.circular(10.0),
                                        //   //   // ),
                                        //   // ),
                                        //   items: factorySelector.setFactoryOnUser().map((branch) {
                                        //     return DropdownMenuItem<String>(
                                        //       value: branch,
                                        //       child: Text(
                                        //         branch,
                                        //         style: TextStyle(color: Colors.white, fontSize: width/25,fontWeight: FontWeight.bold),
                                        //       ),
                                        //     );
                                        //   }).toList(),
                                        //   onChanged: (value) {
                                        //     setState(() {
                                        //       selectedFactory = value;
                                        //       loadData();
                                        //     });
                                        //   },
                                        // ),
                                      ),
                                      SizedBox(height: 12.0),
                                      Container(
                                        height: ConstData.deviceScreenHeight/12,

                                        width: ConstData.deviceScreenWidth/3,
                                        padding: EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color.fromRGBO(225, 95, 27, 0.3),
                                              blurRadius: 40,
                                            )
                                          ],
                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                        ),
                                        child: TextField(
                                          controller: searchController,
                                          onChanged: (value) {
                                            _filterData(value);
                                          },
                                          decoration: InputDecoration(
                                            hintStyle: TextStyle(
                                              color: Colors.grey,
                                            ),
                                            hintText: "Search Here",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
                        // gradient: LinearGradient(
                        //     begin: Alignment.topCenter,
                        //     colors: [
                        //       Colors.black26,
                        //       Colors.lightBlueAccent
                        //     ]
                        // )
              
                    ),
                    height: height * 0.75,
                    width: width,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,

                      child: Column(
                        children: [
                          Container(

                            child: Padding(

                              padding: const EdgeInsets.all(20.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: [
                                    DataColumn(label: Text('STYLE',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 18.0),)),
                                    DataColumn(label: Text('DATE',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 18.0),)),
                                    DataColumn(label: Text('BRANCH NAME',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 18.0),)),
                                    DataColumn(label: Text('Line No',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 18.0),)),
                                    DataColumn(label: Text('PO No',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 18.0),)),
                                    DataColumn(label: Text('Qty',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 18.0),)),
                                    DataColumn(label: Text('MO',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 18.0),)),
                                    DataColumn(label: Text('HEL',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 18.0),)),
                                    DataColumn(label: Text('Iron',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 18.0),)),
                                    DataColumn(label: Text('SMV',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 18.0),)),
                                    DataColumn(label: Text('CM',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 18.0),)),
                                    DataColumn(label: Text('Forecast PCS',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 18.0),)),
                                    DataColumn(label: Text('Forecast SAH',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 18.0),)),
                                    DataColumn(label: Text('Forecast EFF',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 18.0),)),
                                    DataColumn(label: Text('Actual PCS',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 18.0),)),
                                    DataColumn(label: Text('Actual SAH',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 18.0),)),
                                    DataColumn(label: Text('Actual EFF',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 18.0),)),
                                    DataColumn(label: Text('Income',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 18.0),)),
                                    // Add more DataColumn widgets for additional fields
                                  ],
                                  rows: filteredList.map((efficiency) {

                                    return DataRow(cells: [
                                      DataCell(Text(efficiency.style)),
                                      DataCell(Text(DateFormat('yyyy-MM-dd').format(efficiency.date.toLocal()))),
                                      DataCell(Text(efficiency.branchId)),
                                      DataCell(Text(efficiency.lineNo.toString())),
                                      DataCell(Text(efficiency.poNo)),
                                      DataCell(Text(efficiency.qty.toString())),
                                      DataCell(Text(efficiency.mo.toString())),
                                      DataCell(Text(efficiency.hel.toString())),
                                      DataCell(Text(efficiency.iron.toString())),
                                      DataCell(Text(efficiency.smv.toString())),
                                      DataCell(Text(efficiency.cm.toString())),
                                      DataCell(Text(efficiency.forecastPcs.toString())),
                                      DataCell(Text(efficiency.forecastSah.toString())),
                                      DataCell(Text((efficiency.forecastEff*100).toStringAsFixed(2)+' %')),
                                      DataCell(Text(efficiency.actualPcs.toString())),
                                      DataCell(Text(efficiency.actualSah.toString())),
                                      DataCell(Text((efficiency.actualEff*100).toStringAsFixed(2)+' %')),
                                      DataCell(Text(efficiency.income.toString())),
                                    ]);
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await generateEfficiencyPDF(efficiencyList);
                            },
                            child: Text('Print'),
                          ),
                        ],
                      ),

                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await generateEfficiencyPDF(efficiencyList);
                    },
                    child: Text('Print'),
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
}
