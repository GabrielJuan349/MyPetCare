import 'package:flutter/material.dart';
import 'report.dart';
import 'requests.dart';

class PetReports extends StatefulWidget {
  final String idPet;

  const PetReports({super.key, required this.idPet});

  @override
  State<PetReports> createState() => _PetReportsState();
}

class _PetReportsState extends State<PetReports> {
  late Future<List<ReportMessage>> petReportsFuture;

  @override
  void initState() {
    super.initState();
    petReportsFuture = getReportsByPet(widget.idPet);
  }

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
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: FutureBuilder<List<ReportMessage>>(
        future: petReportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No reports available"));
          }

          final petReportsList = snapshot.data!;
          return ListView.builder(
            itemCount: petReportsList.length,
            itemBuilder: (context, index) {
              final report = petReportsList[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9EFFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.reportName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.message,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    Text(
                      report.formattedDate,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
