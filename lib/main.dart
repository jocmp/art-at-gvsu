import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/featured_art_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ArtAtGvsuApp());
}

class ArtAtGvsuApp extends StatelessWidget {
  const ArtAtGvsuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FeaturedArtProvider(),
      child: MaterialApp(
        title: 'Art at GVSU',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
