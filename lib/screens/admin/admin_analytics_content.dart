import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../state/admin_dashboard_provider.dart';

class AdminAnalyticsContent extends StatelessWidget {
  const AdminAnalyticsContent({super.key});

  static const Color _bg = Color(0xFF0F172A);
  static const Color _card = Color(0xFF1E293B);
  static const Color _textMuted = Color(0xFF94A3B8);
  static const Color _blue = AppColors.primaryBlue;
  static const Color _green = AppColors.success;

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminDashboardProvider>(
      builder: (context, provider, _) {
        return Container(
          color: _bg,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildResolutionEfficiency(provider),
                const SizedBox(height: 20),
                _buildCategoryDistribution(),
                const SizedBox(height: 20),
                _buildSectorPerformance(),
                const SizedBox(height: 24),
                _buildDownloadButton(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  // Header

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.bar_chart, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'District Analytics',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Kirehe District • Mayor',
                style: AppTextStyles.caption.copyWith(color: _textMuted),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_none,
                color: AppColors.textWhite, size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert,
                color: AppColors.textWhite, size: 22),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // Resolution Efficiency

  Widget _buildResolutionEfficiency(AdminDashboardProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Resolution Efficiency',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _blue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _blue.withOpacity(0.3)),
                ),
                child: const Text(
                  'Last 6 Months',
                  style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats row
                Row(
                  children: [
                    const Text(
                      'Solved vs. Received',
                      style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12),
                    ),
                    const Spacer(),
                    _legendDot(_blue, 'RECEIVED'),
                    const SizedBox(width: 12),
                    _legendDot(_green, 'SOLVED'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text(
                      '+12.4%',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'improvement',
                      style:
                          AppTextStyles.caption.copyWith(color: _textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Bar chart
                SizedBox(
                  height: 160,
                  child: provider.chartLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primaryBlue))
                      : BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: 140,
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (v, _) {
                                    final i = v.toInt();
                                    final data = provider.chartData;
                                    if (i < 0 || i >= data.length) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        data[i].month,
                                        style: TextStyle(
                                            color: _textMuted, fontSize: 10),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            gridData: FlGridData(
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (_) => FlLine(
                                color: _textMuted.withOpacity(0.1),
                                strokeWidth: 1,
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: List.generate(
                                provider.chartData.length, (i) {
                              final d = provider.chartData[i];
                              return BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: d.received.toDouble(),
                                    color: _blue.withOpacity(0.7),
                                    width: 10,
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4)),
                                  ),
                                  BarChartRodData(
                                    toY: d.resolved.toDouble(),
                                    color: _green.withOpacity(0.85),
                                    width: 10,
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4)),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(color: _textMuted, fontSize: 10, letterSpacing: 0.5),
        ),
      ],
    );
  }

  // Category Distribution (Donut Chart)

  Widget _buildCategoryDistribution() {
    const categories = [
      _CategoryData('Infrastructure', 420, 40, Color(0xFF1E5EFF)),
      _CategoryData('Health', 262, 25, Color(0xFF28A745)),
      _CategoryData('Water', 210, 20, Color(0xFFFFC107)),
      _CategoryData('Other', 158, 15, Color(0xFF9C27B0)),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category Distribution',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Donut chart
                SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          centerSpaceRadius: 44,
                          sectionsSpace: 2,
                          sections: categories
                              .map((c) => PieChartSectionData(
                                    color: c.color,
                                    value: c.percent.toDouble(),
                                    title: '',
                                    radius: 36,
                                  ))
                              .toList(),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'TOTAL',
                            style: TextStyle(
                                color: _textMuted,
                                fontSize: 9,
                                letterSpacing: 1),
                          ),
                          const Text(
                            '1,050',
                            style: TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Legend
                Expanded(
                  child: Column(
                    children: categories.map((c) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: c.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.name,
                                    style: const TextStyle(
                                      color: AppColors.textWhite,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${c.count} issues (${c.percent}%)',
                                    style: TextStyle(
                                        color: _textMuted, fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Sector Performance Table

  Widget _buildSectorPerformance() {
    const sectors = [
      _SectorData(1, 'Kirehe', '4.2h avg', AppColors.success),
      _SectorData(2, 'Gatore', '5.8h avg', Color(0xFF94A3B8)),
      _SectorData(3, 'Musaza', '6.1h avg', Color(0xFF94A3B8)),
      _SectorData(4, 'Nyamugari', '8.4h avg', Color(0xFF94A3B8)),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sector Performance',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'SECTOR NAME',
                          style: TextStyle(
                              color: _textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1),
                        ),
                      ),
                      Text(
                        'AVG RESPONSE',
                        style: TextStyle(
                            color: _textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
                const Divider(
                    color: Color(0xFF334155), height: 1, thickness: 1),
                ...sectors.asMap().entries.map((e) {
                  final isLast = e.key == sectors.length - 1;
                  final s = e.value;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: s.rankColor.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                s.rank.toString().padLeft(2, '0'),
                                style: TextStyle(
                                  color: s.rankColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                s.name,
                                style: const TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              s.avg,
                              style: TextStyle(
                                color: s.rankColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        const Divider(
                            color: Color(0xFF334155), height: 1, thickness: 1),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Download Button

  Widget _buildDownloadButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    const Text('Generating PDF report...'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
          },
          icon: const Icon(Icons.download_outlined,
              color: Colors.white, size: 20),
          label: const Text(
            'Download PDF Monthly Report',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _blue,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}

// Data helpers

class _CategoryData {
  final String name;
  final int count;
  final int percent;
  final Color color;
  const _CategoryData(this.name, this.count, this.percent, this.color);
}

class _SectorData {
  final int rank;
  final String name;
  final String avg;
  final Color rankColor;
  const _SectorData(this.rank, this.name, this.avg, this.rankColor);
}
