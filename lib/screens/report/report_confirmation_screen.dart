import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../home/citizen_home_screen.dart';

class ReportConfirmationScreen extends StatefulWidget {
  final String trackingId;
  final String category;
  final String location;
  final String priority;
  final bool isAnonymous;

  const ReportConfirmationScreen({
    super.key,
    required this.trackingId,
    required this.category,
    required this.location,
    required this.priority,
    this.isAnonymous = false,
  });

  @override
  State<ReportConfirmationScreen> createState() =>
      _ReportConfirmationScreenState();
}

class _ReportConfirmationScreenState extends State<ReportConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _priorityColor {
    switch (widget.priority.toLowerCase()) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  void _copyTrackingId() {
    Clipboard.setData(ClipboardData(text: widget.trackingId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tracking ID copied: ${widget.trackingId}'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const CitizenHomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Step indicator
                  _buildStepIndicator(),
                  const SizedBox(height: 40),
                  // Success icon
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 64,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Report Submitted!',
                    style: AppTextStyles.h2.copyWith(color: AppColors.success),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your report has been submitted to the district office. You\'ll receive updates as your case progresses.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Tracking ID card
                  _buildTrackingCard(),
                  const SizedBox(height: 20),
                  // Summary card
                  _buildSummaryCard(),
                  const SizedBox(height: 28),
                  // Timeline
                  _buildNextSteps(),
                  const SizedBox(height: 36),
                  // Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _goHome,
                      icon: const Icon(
                        Icons.home_outlined,
                        color: AppColors.textWhite,
                      ),
                      label: Text('Back to Home', style: AppTextStyles.button),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.textWhite,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _copyTrackingId,
                      icon: const Icon(
                        Icons.copy_outlined,
                        color: AppColors.primaryBlue,
                      ),
                      label: Text(
                        'Copy Tracking ID',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        side: const BorderSide(color: AppColors.primaryBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _stepDot(1, 'Details', done: true),
        _stepLine(filled: true),
        _stepDot(2, 'Evidence', done: true),
        _stepLine(filled: true),
        _stepDot(3, 'Submitted', done: true, active: true),
      ],
    );
  }

  Widget _stepDot(int step, String label, {bool done = false, bool active = false}) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: done ? AppColors.success : AppColors.inputBorder,
            shape: BoxShape.circle,
          ),
          child: Icon(
            done ? Icons.check : Icons.circle,
            color: AppColors.textWhite,
            size: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: done ? AppColors.success : AppColors.textTertiary,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _stepLine({required bool filled}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: filled ? AppColors.success : AppColors.inputBorder,
      ),
    );
  }

  Widget _buildTrackingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tag, size: 16, color: AppColors.primaryBlue),
              const SizedBox(width: 6),
              Text(
                'Your Tracking ID',
                style: AppTextStyles.inputLabel.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                widget.trackingId,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryBlue,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _copyTrackingId,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.copy, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Copy',
                        style: AppTextStyles.buttonSmall.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Save this ID to track and reference your report.',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report Summary',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _summaryRow(Icons.category_outlined, 'Category', widget.category),
          const SizedBox(height: 10),
          _summaryRow(Icons.location_on_outlined, 'Location', widget.location),
          const SizedBox(height: 10),
          _summaryRow(
            Icons.flag_outlined,
            'Priority',
            widget.priority,
            valueColor: _priorityColor,
          ),
          if (widget.isAnonymous) ...[
            const SizedBox(height: 10),
            _summaryRow(Icons.shield_outlined, 'Privacy', 'Anonymous Report'),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildNextSteps() {
    const steps = [
      _Step(
        icon: Icons.upload_file_outlined,
        color: AppColors.success,
        title: 'Submitted',
        subtitle: 'Your report is now in the system',
        done: true,
      ),
      _Step(
        icon: Icons.search_outlined,
        color: AppColors.info,
        title: 'Under Review',
        subtitle: 'District office will review within 24–48h',
        done: false,
      ),
      _Step(
        icon: Icons.engineering_outlined,
        color: AppColors.warning,
        title: 'Field Assignment',
        subtitle: 'A field officer will be assigned',
        done: false,
      ),
      _Step(
        icon: Icons.check_circle_outline,
        color: AppColors.success,
        title: 'Resolved',
        subtitle: 'You will be notified when done',
        done: false,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What happens next?', style: AppTextStyles.h4.copyWith(fontSize: 16)),
        const SizedBox(height: 16),
        ...steps.asMap().entries.map((e) {
          final i = e.key;
          final step = e.value;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: step.done
                          ? step.color
                          : step.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: step.done
                          ? null
                          : Border.all(
                              color: step.color.withOpacity(0.3),
                              width: 1.5,
                            ),
                    ),
                    child: Icon(
                      step.icon,
                      size: 18,
                      color: step.done ? Colors.white : step.color,
                    ),
                  ),
                  if (i < steps.length - 1)
                    Container(
                      width: 2,
                      height: 36,
                      color: AppColors.inputBorder,
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: step.done
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        step.subtitle,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

class _Step {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool done;

  const _Step({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.done,
  });
}
