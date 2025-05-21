import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<dynamic> newsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    final uri = Uri.parse('http://localhost:6055/api/getAllNews');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          newsList = data;
          isLoading = false;
        });
      } else {
        throw Exception('Error en la respuesta del servidor');
      }
    } catch (e) {
      print('Error al obtener noticias: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildNewsCard(dynamic news) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFE9EFFF), // Fondo claro igual que el home
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              news['title'] ?? 'Sin título',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF627ECB), // Color de texto principal
              ),
            ),
            const SizedBox(height: 8),
            Text(
              news['text'] ?? '',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Desde: ${DateTime.tryParse(news['date_start'] ?? '')?.toLocal().toString().split('.')[0] ?? '---'}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const appBarColor = Color(0xfff59249);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'News',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : newsList.isEmpty
              ? const Center(child: Text('No hay noticias disponibles'))
              : ListView.builder(
                  itemCount: newsList.length,
                  itemBuilder: (context, index) {
                    return buildNewsCard(newsList[index]);
                  },
                ),
    );
  }
}
