// splash_screen.dart - VERSÃO COM IMAGEM REAL
import 'package:flutter/material.dart';
import 'atendimento_list_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2));
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AtendimentoListPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogo(),
            
            const SizedBox(height: 30),
            
            const Text(
              'Sistema de\nAtendimentos',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            
            const SizedBox(height: 20),
            
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    try {
      return Image.asset(
        'assets/images/logo.png',
        width: 400,
        height: 400,
        fit: BoxFit.contain,
      );
    } catch (e) {
      // Fallback se não encontrar a imagem
      return Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.construction,
            size: 80,
            color: Colors.brown,
          ),
        ),
      );
    }
  }
}