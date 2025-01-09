import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:rating_and_feedback_collector/rating_and_feedback_collector.dart';
import 'package:screen_recorder/presentation/constants/constants.dart';
import 'package:screen_recorder/presentation/constants/my_styles.dart';
import 'package:screen_recorder/utils/screen_utils.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final String supportMail = 'info@SetBlue.com';

  double _rating = 0.0;
  // List<String> _attachments = [];
  bool isHTML = false;

  final _formKey = GlobalKey<FormState>();

  Future<void> sendMail(String title, String body) async {
    final email = Email(
      body: body,
      subject: title,
      recipients: [supportMail],
      cc: [],
      bcc: [],
      isHTML: isHTML,
    );
    String platformResponse;

    try {
      await FlutterEmailSender.send(email);
      platformResponse = 'Thank you for your feedback!';
    } catch (error) {
      log(error.toString());
      platformResponse = error.toString();
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(platformResponse),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenUtil = ScreenUtil(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Feedback',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        width: screenUtil.screenWidth,
        height: screenUtil.screenHeight,
        padding: EdgeInsets.only(
            top: screenUtil.screenHeight * 0.12,
            left: screenUtil.screenWidth * 0.05,
            right: screenUtil.screenWidth * 0.05,
            bottom: 10),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Constants.homeBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What do you think of this screen recording application?',
                style: MyStyles().bodyTextStyle.copyWith(
                    color: Colors.white,
                    fontSize: screenUtil.screenWidth * 0.04),
              ),
              SizedBox(height: screenUtil.screenHeight * 0.02),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    RatingBar(
                      iconSize: 40,
                      allowHalfRating: true,
                      filledIcon: Icons.star,
                      halfFilledIcon: Icons.star_half,
                      emptyIcon: Icons.star_border,
                      filledColor: Colors.amber, // Color of filled rating units
                      emptyColor:
                          Colors.amber.shade700, // Color of empty rating units
                      currentRating: _rating, // Set initial rating value
                      onRatingChanged: (rating) {
                        // Callback triggered when the rating is changed
                        setState(() {
                          _rating = rating;
                        });
                      },
                    ),
                    screenUtil.smallVS,
                    Text('Would you like to give any suggestion?',
                        style: MyStyles()
                            .subHeaderTextStyle
                            .copyWith(color: Colors.white, fontSize: 14)),
                    screenUtil.verySmallVS,
                    TextFormField(
                      controller: _titleController,
                      toolbarOptions: ToolbarOptions(
                        copy: false,
                        paste: false,
                        cut: false,
                        selectAll: false,
                      ),
                      maxLength: 50,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.3),
                        contentPadding:
                            EdgeInsets.all(screenUtil.screenWidth * 0.04),
                        hintText: 'Title',
                        labelText: 'Title',
                        labelStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please provide a Title';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenUtil.screenHeight * 0.02),
                    TextFormField(
                      controller: _bodyController,
                      maxLength: 300,
                      maxLines: 10,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.3),
                        contentPadding:
                            EdgeInsets.all(screenUtil.screenWidth * 0.04),
                        hintText: 'Is there anything you would like to say?',
                        hintStyle: TextStyle(fontSize: 12),
                        alignLabelWithHint: true,
                        labelText: 'Suggestion',
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please provide your suggestion';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenUtil.screenHeight * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.amber),
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              if (_rating == 0.0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Please provide a rating before submitting.')),
                                );
                                return;
                              }

                              await sendMail(_titleController.text,
                                  '${_bodyController.text} \n Rating: $_rating');

                              _formKey.currentState?.reset();
                              _titleController
                                  .clear(); // Clear the title text field
                              _bodyController.clear();
                              setState(() {
                                _rating = 0.0;
                              });
                            }
                          },
                          child: Text('Submit'),
                        ),
                        screenUtil.smallHS,
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            _formKey.currentState?.reset();
                            _titleController
                                .clear(); // Clear the title text field
                            _bodyController.clear();
                            setState(() {
                              _rating = 0;
                            });
                            // Handle form submission
                          },
                          child: Text('cancel'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
