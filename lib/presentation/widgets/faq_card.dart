import 'package:flutter/material.dart';
import 'package:screen_recorder/data/model/faq.dart';
import 'package:screen_recorder/utils/screen_utils.dart';

class FaqCard extends StatelessWidget {
  const FaqCard({super.key, required this.faq});
  final FAQ faq;

  @override
  Widget build(BuildContext context) {
    final screenUtil = ScreenUtil(context);
    double cardHeight = screenUtil.screenHeight * 0.2;
    const double padding = 15;

    // Get screen width for proportional text size
    final double screenWidth = screenUtil.screenWidth;

    // Calculate max lines for question
    int getMaxLines(String text, double availableHeight, double fontSize) {
      // Create a TextPainter to measure text
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(fontSize: fontSize),
        ),
        textDirection: TextDirection.ltr,
        maxLines: null,
      )..layout(maxWidth: screenWidth - (padding * 2));

      // Height of a single line of text
      final double lineHeight = textPainter.preferredLineHeight;

      // Calculate maximum lines based on available height
      return (availableHeight / lineHeight).floor();
    }

    // Max lines for the question and answer
    final int maxQuestionLines =
        getMaxLines(faq.question, cardHeight * 0.3, 16); // 30% of card height
    final int maxAnswerLines =
        getMaxLines(faq.answer, cardHeight * 0.6, 14); // 60% of card height

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(faq.question),
              content: Text(faq.answer),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(15),
        height: screenUtil.screenHeight * 0.2,
        width: screenUtil.screenWidth * 0.5,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              faq.question,
              maxLines: maxQuestionLines,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black,
              ),
            ),
            // const SizedBox(
            //   height: 10,
            // ),
            Text(
              faq.answer,
              maxLines: maxAnswerLines,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
