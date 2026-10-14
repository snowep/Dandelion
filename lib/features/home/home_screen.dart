import 'package:flutter/material.dart';
import 'package:dandelion/shared/widgets/primary_button.dart';
import 'package:dandelion/shared/widgets/sliver_app_bar_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBarWidget(title: 'Dandelion Home'),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Welcome to Dandelion', style: TextStyle(fontSize: 24)),
                const SizedBox(height: 8),
                const Text('Your personal library dashboard.'),
                const SizedBox(height: 16),
                PrimaryButton(
                  text: 'Get Started',
                  onPressed: () {},
                  semanticLabel: 'Get started button',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
