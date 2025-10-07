import 'package:flutter/material.dart';
import 'package:huella/screens/auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  static const routeName = '/onboarding';
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  final items = [
    {
      'title': 'Retos diarios',
      'subtitle': 'Pequeñas acciones que generan gran impacto.',
      'icon': Icons.checklist_rounded
    },
    {
      'title': 'Mide tu impacto',
      'subtitle': 'Visualiza agua, CO₂ y residuos ahorrados.',
      'icon': Icons.show_chart_rounded
    },
    {
      'title': 'Comparte y motiva',
      'subtitle': 'Inspira a otros compartiendo tus logros.',
      'icon': Icons.people_rounded
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: items.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) {
                  final it = items[i];
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(it['icon'] as IconData, size: 96, color: const Color(0xFF4CAF50)),
                        const SizedBox(height: 24),
                        Text(it['title'] as String, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        Text(it['subtitle'] as String, textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(items.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                width: _page == i ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _page == i ? const Color(0xFF4CAF50) : Colors.grey[300],
                  borderRadius: BorderRadius.circular(6),
                ),
              )),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
              child: Row(
                children: [
                  TextButton(onPressed: () => Navigator.pushReplacementNamed(context, LoginScreen.routeName), child: const Text('Saltar')),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
                    onPressed: () {
                      if (_page == items.length - 1) {
                        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
                      } else {
                        _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      }
                    },
                    child: Text(_page == items.length - 1 ? 'Comenzar' : 'Siguiente'),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
