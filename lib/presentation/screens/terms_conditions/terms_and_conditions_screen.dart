import 'package:flutter/material.dart';
import 'package:screen_recorder/presentation/constants/constants.dart';
import 'package:screen_recorder/utils/screen_utils.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Terms and Conditions',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        width: ScreenUtil(context).screenWidth,
        height: ScreenUtil(context).screenHeight,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Constants.homeBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: ScreenUtil(context).screenHeight * 0.12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [Text('Terms of Use')],
                ),
                Text(
                  'By using this app, you agree to the following terms and conditions:\n\n'
                  '1. The app may collect certain data related to screen recording activities.\n\n'
                  '2. You are responsible for ensuring you have permission to record the content you are capturing.\n\n'
                  '3. All recorded data will be saved in your devices downloads folder only.\n\n'
                  '4. The app may request necessary permissions to access storage ,camera and microphone.\n\n'
                  '5. The app will not be liable for any loss or damage that occurs from using the screen recording features.\n\n'
                  '6. The app reserves the right to update these terms and conditions.\n\n'
                  '7. For any issues, you can contact the us using feedback page or @ info@SetBlue.com.',
                  //almas.setblue@gmail.com,
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
