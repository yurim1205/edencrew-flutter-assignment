import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceBase,
      body: const Center(child: Text('관심 화면 - 작업 예정')),
    );
  }
}