import 'package:flutter/material.dart';
import 'package:screen_recorder/data/model/video_info.dart';
import 'package:screen_recorder/utils/screen_utils.dart';
import 'package:share_plus/share_plus.dart';

class RecordedVideoTile extends StatelessWidget {
  const RecordedVideoTile(
      {super.key, required this.videoInfo, required this.videoTime});

  final VideoInfo videoInfo;
  final String videoTime;

  @override
  Widget build(BuildContext context) {
    final screenUtil = ScreenUtil(context);

    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            _buildThumbnail(context),
            const SizedBox(width: 16),
            Expanded(child: _buildVideoDetails(screenUtil)),
            const SizedBox(
              width: 16,
            ),
            IconButton(
              onPressed: () {
                Share.share(videoInfo.path);
              },
              icon: Icon(
                Icons.ios_share_rounded,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Thumbnail widget
  Widget _buildThumbnail(BuildContext context) {
    return CircleAvatar(
      radius: ScreenUtil(context).screenWidth * 0.1,
      backgroundColor: Colors.transparent,
      child: videoInfo.thumbnail ??
          const Icon(Icons.videocam, size: 50, color: Colors.grey),
    );
  }

  // Video details (title, size, date, etc.)
  Widget _buildVideoDetails(ScreenUtil screenUtil) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(),
        _buildInfoRow(screenUtil),
      ],
    );
  }

  // Title with ellipsis handling
  Widget _buildTitle() {
    return Text(
      videoInfo.title.split('-').first,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  // Info row with size and date
  Widget _buildInfoRow(ScreenUtil screenUtil) {
    return Row(
      children: [
        _buildSizeInfo(),
        screenUtil.smallHS,
        _buildDateInfo(),
      ],
    );
  }

  // Video size and storage info
  Widget _buildSizeInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoIconText(
          icon: Icons.sd_storage_outlined,
          text: '${videoInfo.size?.toStringAsFixed(2) ?? 0} MB',
        ),
        _buildInfoIconText(
          icon: Icons.timelapse,
          text: '${videoInfo.duration?.toInt() ?? 0} seconds',
        ),
      ],
    );
  }

  // Date and time info
  Widget _buildDateInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoIconText(
          icon: Icons.calendar_month_outlined,
          text: videoInfo.date.split(' ').first,
        ),
        _buildInfoIconText(
          icon: Icons.timer_sharp,
          text: videoTime,
        ),
      ],
    );
  }

  // Reusable widget for icon and text
  Widget _buildInfoIconText({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.white),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Colors.white),
        ),
      ],
    );
  }
}
