import 'package:flutter/material.dart';
import 'package:screen_recorder/data/faq_data.dart';
import 'package:screen_recorder/presentation/widgets/faq_card.dart';

class Faq extends StatefulWidget {
  const Faq({super.key});

  @override
  State<Faq> createState() => _FaqState();
}

class _FaqState extends State<Faq> {
  final faqList = faqs;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: faqs.length,
      itemBuilder: (context, index) {
        return FaqCard(faq: faqs[index]);
      },
    );
  }
}
