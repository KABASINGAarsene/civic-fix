import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/dashboard_models.dart';

class ReportDetailScreen extends StatefulWidget {
  final ReportDetailData report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  bool _hasLiked = false;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.report.likes;
  }

  void _toggleLike() {
    setState(() {
      _hasLiked = !_hasLiked;
      _likeCount += _hasLiked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusBanner(),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTrackingId(),
                        const SizedBox(height: 20),
                        _buildTitleAndCategory(),
                        const SizedBox(height: 16),
                        _buildDescription(),
                        const SizedBox(height: 20),
                        _buildLocationRow(),
                        const SizedBox(height: 16),
                        _buildEngagementRow(),
                        if (widget.report.photoUrl != null) ...[
                          const SizedBox(height: 24),
                          _buildPhoto(),
                        ],
                        const SizedBox(height: 28),
                        _buildSectionLabel('Status Timeline'),
                        const SizedBox(height: 20),
                        _buildTimeline(),
                        const SizedBox(height: 28),
                        _buildSectionLabel('Report Info'),
                        const SizedBox(height: 16),
                        _buildMetaRow(
                          Icons.calendar_today_outlined,
                          'Submitted',
                          widget.report.submittedDate,
                        ),
                        const SizedBox(height: 14),
                        _buildMetaRow(
                          Icons.access_time,
                          'Last Updated',
                          widget.report.lastUpdate,
                        ),
                        const SizedBox(height: 14),
                        _buildMetaRow(
                          Icons.person_outline,
                          'Assigned To',
                          widget.report.assignedTo ?? 'Awaiting assignment',
                        ),
                        const SizedBox(height: 32),
                        _buildHelpCard(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Custom App Bar

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        color: AppColors.backgroundWhite,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(child: Text('Report Details', style: AppTextStyles.h3)),
            IconButton(
              icon: const Icon(
                Icons.copy_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              tooltip: 'Copy Tracking ID',
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(text: widget.report.trackingId),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Tracking ID copied: ${widget.report.trackingId}',
                    ),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Status Banner

  Widget _buildStatusBanner() {
    final config = _statusConfig(widget.report.status);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: config.bgColor,
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: config.dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            config.label.toUpperCase(),
            style: AppTextStyles.badge.copyWith(
              color: config.textColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          Text(
            'Updated ${widget.report.lastUpdate}',
            style: AppTextStyles.caption.copyWith(color: config.textColor),
          ),
        ],
      ),
    );
  }

  // Tracking ID

  Widget _buildTrackingId() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.tag, size: 16, color: AppColors.primaryBlue),
          const SizedBox(width: 8),
          Text(
            'Tracking ID: ',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            widget.report.trackingId,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Clipboard.setData(
              ClipboardData(text: widget.report.trackingId),
            ),
            child: Text(
              'Copy',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Title & Category

  Widget _buildTitleAndCategory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.report.categoryIcon,
                size: 13,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 5),
              Text(
                widget.report.category,
                style: AppTextStyles.badge.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(widget.report.title, style: AppTextStyles.h3),
      ],
    );
  }

  // Description

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: AppTextStyles.inputLabel.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.report.description,
          style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
        ),
      ],
    );
  }

  // Location

  Widget _buildLocationRow() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: AppColors.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.report.location,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Engagement Row

  Widget _buildEngagementRow() {
    return Row(
      children: [
        // Like button
        GestureDetector(
          onTap: _toggleLike,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _hasLiked
                  ? AppColors.primaryBlue.withOpacity(0.08)
                  : AppColors.backgroundGrey,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _hasLiked
                    ? AppColors.primaryBlue.withOpacity(0.3)
                    : AppColors.inputBorder,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _hasLiked ? Icons.thumb_up : Icons.thumb_up_off_alt,
                  size: 16,
                  color: _hasLiked
                      ? AppColors.primaryBlue
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  '$_likeCount upvotes',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _hasLiked
                        ? AppColors.primaryBlue
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Comments count
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.backgroundGrey,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.inputBorder, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.comment_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                '${widget.report.comments} comments',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Photo

  Widget _buildPhoto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photo Evidence',
          style: AppTextStyles.inputLabel.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            widget.report.photoUrl!,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.textTertiary,
                  size: 40,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Section Label

  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Text(label, style: AppTextStyles.h4.copyWith(fontSize: 16)),
        const SizedBox(width: 12),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }

  // Status Timeline

  Widget _buildTimeline() {
    final steps = [
      _TimelineStep('Submitted', Icons.upload_outlined, ReportStatus.submitted),
      _TimelineStep('In Review', Icons.search_outlined, ReportStatus.inReview),
      _TimelineStep(
        'In Progress',
        Icons.build_outlined,
        ReportStatus.inProgress,
      ),
      _TimelineStep(
        'Resolved',
        Icons.check_circle_outline,
        ReportStatus.resolved,
      ),
    ];

    final statusOrder = [
      ReportStatus.submitted,
      ReportStatus.inReview,
      ReportStatus.inProgress,
      ReportStatus.resolved,
    ];
    final currentIndex = statusOrder.indexOf(widget.report.status);
    // Fallback: reported maps to submitted visually
    final effectiveIndex = currentIndex < 0 ? 0 : currentIndex;

    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final stepIndex = i ~/ 2;
          final isPast = stepIndex < effectiveIndex;
          return Expanded(
            child: Container(
              height: 2,
              color: isPast ? AppColors.primaryBlue : AppColors.inputBorder,
            ),
          );
        }

        final stepIndex = i ~/ 2;
        final step = steps[stepIndex];
        final isPast = stepIndex < effectiveIndex;
        final isCurrent = stepIndex == effectiveIndex;

        return Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrent
                    ? AppColors.primaryBlue
                    : isPast
                    ? AppColors.primaryBlue.withOpacity(0.15)
                    : AppColors.backgroundGrey,
                border: isCurrent
                    ? null
                    : Border.all(
                        color: isPast
                            ? AppColors.primaryBlue.withOpacity(0.3)
                            : AppColors.inputBorder,
                        width: 1.5,
                      ),
              ),
              child: Icon(
                step.icon,
                size: 18,
                color: isCurrent
                    ? AppColors.textWhite
                    : isPast
                    ? AppColors.primaryBlue
                    : AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              step.label,
              style: AppTextStyles.badge.copyWith(
                color: isCurrent
                    ? AppColors.primaryBlue
                    : isPast
                    ? AppColors.primaryBlue.withOpacity(0.7)
                    : AppColors.textTertiary,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      }),
    );
  }

  // Meta Row

  Widget _buildMetaRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textTertiary),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  // Help Card

  Widget _buildHelpCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.verified_user,
              color: AppColors.textWhite,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'We\'re on it',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'You\'ll receive a notification when your report status changes.',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Status Config Helper

  _StatusConfig _statusConfig(ReportStatus status) {
    switch (status) {
      case ReportStatus.submitted:
        return _StatusConfig(
          label: 'Submitted',
          bgColor: AppColors.info.withOpacity(0.08),
          dotColor: AppColors.info,
          textColor: AppColors.info,
        );
      case ReportStatus.inReview:
        return _StatusConfig(
          label: 'In Review',
          bgColor: AppColors.warning.withOpacity(0.1),
          dotColor: AppColors.warning,
          textColor: const Color(0xFF996600),
        );
      case ReportStatus.inProgress:
        return _StatusConfig(
          label: 'In Progress',
          bgColor: AppColors.primaryBlue.withOpacity(0.07),
          dotColor: AppColors.primaryBlue,
          textColor: AppColors.primaryBlue,
        );
      case ReportStatus.resolved:
      case ReportStatus.reported:
        return _StatusConfig(
          label: status == ReportStatus.resolved ? 'Resolved' : 'Reported',
          bgColor: AppColors.success.withOpacity(0.08),
          dotColor: AppColors.success,
          textColor: AppColors.success,
        );
    }
  }
}

// Supporting Types

class _TimelineStep {
  final String label;
  final IconData icon;
  final ReportStatus status;

  const _TimelineStep(this.label, this.icon, this.status);
}

class _StatusConfig {
  final String label;
  final Color bgColor;
  final Color dotColor;
  final Color textColor;

  const _StatusConfig({
    required this.label,
    required this.bgColor,
    required this.dotColor,
    required this.textColor,
  });
}
