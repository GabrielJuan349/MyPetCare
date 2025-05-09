import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  final List<Map<String, String>> faqs = [
    {
      'question': '¿Con qué frecuencia debo llevar a mi mascota al veterinario?',
      'answer': 'Se recomienda una revisión al menos una vez al año, o más si tiene condiciones especiales.'
    },
    {
      'question': '¿Qué vacunas básicas necesita mi mascota?',
      'answer': 'Las vacunas básicas incluyen rabia, parvovirus, moquillo y leptospirosis. Consulta al veterinario para un plan personalizado.'
    },
    {
      'question': '¿Cuáles son los signos de que mi mascota está enferma?',
      'answer': 'Pérdida de apetito, comportamiento inusual, vómitos, diarrea o letargo son signos comunes de enfermedad.'
    },
    {
      'question': '¿Es necesario desparasitar a mi mascota?',
      'answer': 'Sí, tanto perros como gatos deben ser desparasitados regularmente, al menos cada 3 meses.'
    },
    {
      'question': '¿Qué alimentos están prohibidos para perros y gatos?',
      'answer': 'Evita chocolate, cebolla, ajo, uvas, pasas, cafeína y alimentos con alto contenido de grasa o sal.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xfff59249),
        title: Text("FAQs"),
        centerTitle: true,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return ExpansionTile(
            title: Text(
              faqs[index]['question']!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(faqs[index]['answer']!),
              ),
            ],
          );
        },
      ),
    );
  }
}
