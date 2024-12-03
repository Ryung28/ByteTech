import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/analytics_provider.dart';

class AnalyticsErrorView extends StatelessWidget {
  const AnalyticsErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    final error = context.select((AnalyticsProvider p) => p.error);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $error'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => context.read<AnalyticsProvider>().retry(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
