import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceBase,
      body: const Center(child: Text('검색 화면 - 작업 예정')),
    );
  }
}