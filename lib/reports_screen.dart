import 'package:flutter/material.dart';
import 'package:lis_project/report.dart';
import 'package:lis_project/report_detail_screen.dart';

class PetReports extends StatefulWidget {
   List<ReportMessage>? petReports;

   PetReports({super.key, this.petReports});

   @override
   State<PetReports> createState() => _PetReportsState();
}


class _PetReportsState extends State<PetReports> {
  List<ReportMessage> petReportsList = [
    ReportMessage("Laboratory results", "This is a long text that is going to resume what you'll find on the particular report"),
    ReportMessage("Vaccination calendar", "This is a long text that is going to resume what you'll find on the particular report"),
    ReportMessage("Illness diagnosis", "This is a long text that is going to resume what you'll find on the particular report"),
  ];

  @override
  void initState() {
    super.initState();
  }

  _PetReportsState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reports"),
        foregroundColor: Colors.white,
        centerTitle: true,
        backgroundColor: Color(0xfff59249),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
          actions: [
            IconButton(
              icon: Icon(Icons.person, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
      ),
      body: ListView.builder(
        itemCount: petReportsList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportDetailScreen(report: petReportsList[index]),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFE9EFFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          petReportsList[index].reportName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          petReportsList[index].message,
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );  
  }
}