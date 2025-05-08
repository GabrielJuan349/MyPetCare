import 'package:flutter/material.dart';
import 'package:lis_project/report.dart';

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
        title: const Text("Reports"),
        foregroundColor: Colors.white,
        centerTitle: true,
        backgroundColor: const Color(0xfff59249),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
      ),
      body: ListView.builder(
        itemCount: petReportsList.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE9EFFF),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        petReportsList[index].message,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}