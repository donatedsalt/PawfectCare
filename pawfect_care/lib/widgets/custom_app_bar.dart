import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar(this.text, {super.key, this.showBack = false});

  final String text;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withAlpha(200),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (showBack)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (showBack) const SizedBox(width: 48),
        ],
      ),
    );
  }
}
