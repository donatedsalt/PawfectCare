import 'package:flutter/material.dart';
import 'brand_colors.dart';

class StorePageFloatingActionButton extends StatelessWidget {
  final int itemCount;
  final VoidCallback onPressed;

  const StorePageFloatingActionButton({
    super.key,
    required this.itemCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        FloatingActionButton(
          backgroundColor: BrandColors.accentGreen,
          onPressed: onPressed,
          child: const Icon(Icons.shopping_basket, color: Colors.white),
        ),
        if (itemCount > 0)
          Positioned(
            right: -2,
            top: -2,
            child: CircleAvatar(
              radius: 12,
              backgroundColor: Colors.red,
              child: Text(
                itemCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }
}
