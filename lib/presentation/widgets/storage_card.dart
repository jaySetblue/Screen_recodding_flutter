import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:screen_recorder/presentation/constants/my_styles.dart';
import 'package:screen_recorder/utils/screen_utils.dart';
import 'package:disk_space_update/disk_space_update.dart';

class StorageCard extends StatefulWidget {
  const StorageCard({super.key});

  @override
  State<StorageCard> createState() => _StorageCardState();
}

class _StorageCardState extends State<StorageCard> {
  int usedSpace = 0;
  int freeSpace = 0;
  int totalSpace = 1; // Avoid division by zero
  double usedPercentage = 0.0;
  bool isLoading = true;

  Future<void> _getDiskSpace() async {
    try {
      // Fetch disk space information
      double? freeSpaceData = await DiskSpace.getFreeDiskSpace;
      double? totalSpaceData = await DiskSpace.getTotalDiskSpace;

      if (freeSpaceData != null && totalSpaceData != null) {
        int usedSpaceData = ((totalSpaceData - freeSpaceData) / 1024).toInt();

        if (mounted) {
          setState(() {
            freeSpace = (freeSpaceData / 1024).toInt();
            totalSpace = (totalSpaceData / 1024).toInt();
            usedSpace = usedSpaceData;
            usedPercentage = totalSpace > 0 ? usedSpace / totalSpace : 0.0;
          });
        }
      }
    } catch (e) {
      log('Error fetching disk space: $e',
          error: e, stackTrace: StackTrace.current);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false; // Mark loading complete
        });
      }
    }
  }

  late ScreenUtil screenUtil;

  @override
  void initState() {
    super.initState();
    _getDiskSpace();
    screenUtil = ScreenUtil(context);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 20,
      shadowColor: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator()) // Loading state
            : Row(
                children: [
                  // Circular Percent Indicator for storage usage
                  CircularPercentIndicator(
                    radius: screenUtil.width(0.12),
                    lineWidth: 10,
                    progressColor: Colors.amber.shade700,
                    backgroundColor: Colors.black,
                    percent: usedPercentage.clamp(0.0, 1.0),
                    center: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(usedPercentage * 100).toInt()}%',
                          style: MyStyles().bodyTextStyle.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Used',
                          style: MyStyles()
                              .subHeaderTextStyle
                              .copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  screenUtil.mediumHS,
                  // Storage details
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Storage',
                        style: MyStyles().subHeaderTextStyle,
                      ),
                      screenUtil.verySmallVS,
                      _buildStorageInfoRow('Free Space:', '$freeSpace GB'),
                      _buildStorageInfoRow('Total Space:', '$totalSpace GB'),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStorageInfoRow(String label, String value) {
    return Row(
      children: [
        const Icon(Icons.circle, size: 8),
        const SizedBox(width: 4),
        Text(
          '$label $value',
          style: MyStyles().bodyTextStyle.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}
