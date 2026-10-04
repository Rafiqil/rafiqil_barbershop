import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/schedule.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final user = context.watch<AuthProvider>().user;

    if (data.loading) {
      return const _DashboardSkeleton();
    }

    return LayoutBuilder(builder: (context, c) {
      final width = c.maxWidth;
      int cols = 4;
      if (width < 1200) cols = 2;
      if (width < 560) cols = 1;
      final twoCol = width >= 1000;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Halo, ${user?.name ?? 'Rafiqil'} 👋',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text(
                          Formatters.tanggalLengkap(DateTime.now()),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13.5),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.store_mall_directory_outlined,
                      color: AppColors.accentSoft, size: 44),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats grid
            GridView.count(
              crossAxisCount: cols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: cols == 1 ? 2.0 : (cols == 2 ? 1.5 : 1.55),
              children: [
                StatCard(
                  label: 'Omset Hari Ini',
                  value: Formatters.rupiah(data.totalOmsetHariIni),
                  icon: Icons.payments_outlined,
                  color: AppColors.success,
                  background: AppColors.successSoft,
                ),
                StatCard(
                  label: 'Omset Bulan Ini',
                  value: Formatters.rupiahCompact(data.totalOmsetBulanIni),
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppColors.accent,
                  background: AppColors.warningSoft,
                  trend: '+12%',
                ),
                StatCard(
                  label: 'Jadwal Hari Ini',
                  value: '${data.jadwalHariIni}',
                  icon: Icons.calendar_today_outlined,
                  color: AppColors.info,
                  background: AppColors.infoSoft,
                ),
                StatCard(
                  label: 'Transaksi Bulan Ini',
                  value: '${data.transaksiBulanIni}',
                  icon: Icons.receipt_long_outlined,
                  color: AppColors.primary,
                  background: const Color(0xFFEDEFF2),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Chart + side widgets
            if (twoCol)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _RevenueChart(data: data)),
                    const SizedBox(width: 20),
                    Expanded(flex: 2, child: _TopServices(data: data)),
                  ],
                ),
              )
            else ...[
              _RevenueChart(data: data),
              const SizedBox(height: 20),
              _TopServices(data: data),
            ],
            const SizedBox(height: 20),
            _UpcomingSchedules(data: data),
            const SizedBox(height: 8),
          ],
        ),
      );
    });
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  const _Panel({required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12.5)),
          ],
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  final DataProvider data;
  const _RevenueChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final series = data.omset7Hari;
    final maxVal = series.fold<int>(0, (m, e) => e.value > m ? e.value : m);
    final maxY = (maxVal == 0 ? 100000 : maxVal * 1.25);

    return _Panel(
      title: 'Omset 7 Hari Terakhir',
      subtitle: 'Total transaksi lunas per hari',
      child: SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            maxY: maxY.toDouble(),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => AppColors.primaryDark,
                getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                  Formatters.rupiahCompact(rod.toY),
                  const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12),
                ),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxY / 4,
              getDrawingHorizontalLine: (_) =>
                  const FlLine(color: AppColors.border, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (i < 0 || i >= series.length) {
                      return const SizedBox();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        Formatters.hariSingkat(series[i].key),
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: [
              for (int i = 0; i < series.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: series[i].value.toDouble(),
                      width: 18,
                      borderRadius: BorderRadius.circular(6),
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, AppColors.accentSoft],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopServices extends StatelessWidget {
  final DataProvider data;
  const _TopServices({required this.data});

  @override
  Widget build(BuildContext context) {
    final top = data.layananTerlaris;
    final maxVal = top.isEmpty
        ? 1
        : top.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return _Panel(
      title: 'Layanan Terlaris',
      subtitle: 'Berdasarkan jumlah transaksi',
      child: top.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('Belum ada data layanan.',
                  style: TextStyle(color: AppColors.textSecondary)),
            )
          : Column(
              children: [
                for (final e in top)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(e.key,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                            ),
                            Text('${e.value}x',
                                style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: e.value / maxVal,
                            minHeight: 7,
                            backgroundColor: AppColors.background,
                            valueColor:
                                const AlwaysStoppedAnimation(AppColors.accent),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

class _UpcomingSchedules extends StatelessWidget {
  final DataProvider data;
  const _UpcomingSchedules({required this.data});

  @override
  Widget build(BuildContext context) {
    final items = data.jadwalMendatang;
    return _Panel(
      title: 'Jadwal Mendatang',
      subtitle: 'Reservasi pelanggan terdekat',
      child: items.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('Tidak ada jadwal mendatang.',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            )
          : Column(
              children: [
                for (final s in items) ...[
                  Row(
                    children: [
                      Container(
                        width: 46,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(Formatters.jam(s.startTime),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 13)),
                            Text(Formatters.hariSingkat(s.startTime),
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.customerName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.5)),
                            Text('${s.serviceName} • ${s.barberName}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                      _scheduleBadge(s.status),
                    ],
                  ),
                  if (s != items.last)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1),
                    ),
                ],
              ],
            ),
    );
  }

  Widget _scheduleBadge(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.ongoing:
        return StatusBadge.warning(status.label, icon: Icons.timelapse);
      case ScheduleStatus.upcoming:
        return StatusBadge.info(status.label, icon: Icons.schedule);
      case ScheduleStatus.done:
        return StatusBadge.success(status.label, icon: Icons.check);
      case ScheduleStatus.cancelled:
        return StatusBadge.danger(status.label, icon: Icons.close);
    }
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    int cols = 4;
    if (width < 1200) cols = 2;
    if (width < 560) cols = 1;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(height: 90, radius: 20),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: cols == 1 ? 2.0 : (cols == 2 ? 1.5 : 1.55),
            children: List.generate(
                4, (_) => const ShimmerBox(height: 120, radius: 18)),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(flex: 3, child: ShimmerBox(height: 280, radius: 18)),
              SizedBox(width: 20),
              Expanded(flex: 2, child: ShimmerBox(height: 280, radius: 18)),
            ],
          ),
        ],
      ),
    );
  }
}
