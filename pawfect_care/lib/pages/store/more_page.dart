import 'package:flutter/material.dart';
import 'package:pawfect_care/pages/vet/home_page.dart';

class MorePageStore extends StatelessWidget {
  const MorePageStore({super.key});

  final List<String> options = const ['Profile', 'Settings', 'Help', 'Logout'];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: options.length,
      itemBuilder: (_, index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [BrandColors.primaryBlue, BrandColors.cardBlue]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(options[index],
              style: const TextStyle(color: BrandColors.textWhite)),
        );
      },
    );
  }
}
