import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:screen_recorder/presentation/constants/constants.dart';
import 'package:screen_recorder/utils/screen_utils.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});
  final String supportMail = 'info@SetBlue.com';
  final bool isHTML = false;

  Future<void> sendMail(BuildContext context) async {
    final email = Email(
      body: '',
      subject: '',
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

    if (!context.mounted) return;

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
          'Privacy Policy',
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
            bottom: 20,
            left: 20,
            right: 20),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Constants.homeBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Effective Date: ${Constants.effectiveDate}',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              screenUtil.veryVerySmallVS,
              Text(
                Constants.privacyPolicyStart,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
                textAlign: TextAlign.justify,
              ),
              screenUtil.smallVS,
              Text(
                '1. Information we may collect',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                Constants.informationWeMayCollect,
                style: TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.justify,
              ),
              Text(
                '2. How we may use your information',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                Constants.howWeMayUseYourInformation,
                style: TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.justify,
              ),
              Text(
                '3. Sharing your information',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                Constants.sharingYourInformation,
                style: TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.justify,
              ),
              Text(
                '4. Data Security',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                Constants.dataSecurity,
                style: TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.justify,
              ),
              Text(
                '5. Your choices',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                Constants.yourChoices,
                style: TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.justify,
              ),
              Text(
                '6. Third-party services',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                Constants.thirdPartyServices,
                style: TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.justify,
              ),
              Text(
                '7. Childrens privacy',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                Constants.childrensPrivacy,
                style: TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.justify,
              ),
              Text(
                '8. Updates to this privacy policy',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                Constants.updatesToThisPrivacy,
                style: TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.justify,
              ),
              Text(
                '9. Contact Us',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                Constants.contactUs,
                style: TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.justify,
              ),
              Row(
                children: [
                  Text(
                    'Email:',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextButton(
                      onPressed: () {
                        sendMail(context);
                      },
                      child: Text('info@SetBlue.com')),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
