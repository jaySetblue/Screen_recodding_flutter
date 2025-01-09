import 'package:flutter/material.dart';
import 'package:screen_recorder/utils/screen_utils.dart';
import 'package:showcaseview/showcaseview.dart';

class MyShowcaseWidget extends StatelessWidget {
  final GlobalKey showcaseKey;
  final String title;
  final String description;
  final VoidCallback onCancel;
  final VoidCallback onNext;
  final Widget child;
  final String onNextText;
  final String onCancelText;

  const MyShowcaseWidget({
    required this.showcaseKey,
    required this.title,
    required this.description,
    required this.onCancel,
    required this.onNext,
    required this.child,
    super.key,
    required this.onNextText,
    required this.onCancelText,
  });

  @override
  Widget build(BuildContext context) {
    return Showcase.withWidget(
      targetBorderRadius: BorderRadius.circular(20),
      key: showcaseKey,
      height: 150,
      width: 250,
      container: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              softWrap: true,
              maxLines: 5,
            ),
            Text(
              description,
              style: const TextStyle(
                fontSize: 10,
              ),
              softWrap: true,
              maxLines: 15,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: onCancel,
                  child: Text(
                    onCancelText,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                ScreenUtil(context).largeHS,
                ScreenUtil(context).largeHS,
                ScreenUtil(context).largeHS,
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(padding: EdgeInsets.all(12)),
                  onPressed: onNext,
                  label: Text(
                    onNextText,
                    style: TextStyle(fontSize: 12),
                  ),
                  icon: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                  ),
                  iconAlignment: IconAlignment.end,
                ),
              ],
            ),
          ],
        ),
      ),
      child: child,
    );
  }
}
