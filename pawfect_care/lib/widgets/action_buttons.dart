import 'package:flutter/material.dart';

import 'package:pawfect_care/utils/context_extension.dart';

class CustomActionButtons extends StatelessWidget {
  const CustomActionButtons({
    super.key,
    required this.isSubmitting,
    required this.onCancel,
    required this.onSubmit,
  });

  final bool isSubmitting;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: IconButton.outlined(
                onPressed: () {
                  isSubmitting
                      ? context.showSnackBar("please wait...")
                      : onCancel();
                },
                icon: const Icon(Icons.close),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 50,
              child: IconButton.filled(
                onPressed: () {
                  isSubmitting
                      ? context.showSnackBar("please wait...")
                      : onSubmit();
                },
                icon: isSubmitting
                    ? SizedBox(
                        height: 16.0,
                        width: 16.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.check),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
