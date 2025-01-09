import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_recorder/service/provider/on_tap_countdown_provider.dart';

// Provider to manage the selected countdown duration
final countdownDurationProvider = StateProvider<int>((ref) => 3);

class CountdownDropdown extends ConsumerWidget {
  const CountdownDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the current countdown value from the provider
    final selectedDuration = ref.watch(ontapCountdownProvider);

    return DropdownButton<int>(
      value: selectedDuration,
      dropdownColor: Colors.black,
      items: const [
        DropdownMenuItem(
          value: 3,
          child: Text(
            '3s',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
        DropdownMenuItem(
          value: 5,
          child: Text(
            '5s',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
        DropdownMenuItem(
          value: 10,
          child: Text(
            '10s',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
      ],
      onChanged: (int? newValue) {
        if (newValue != null) {
          ref.read(ontapCountdownProvider.notifier).state = newValue;
        }
      },
      underline: Container(), // Optional: Remove underline
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
      style: const TextStyle(
        fontSize: 12,
        color: Colors.white,
      ),
    );
  }
}
