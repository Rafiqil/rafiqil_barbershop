import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/schedule.dart';
import '../../providers/data_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/page_header.dart';
import '../../widgets/status_badge.dart';
import 'schedule_form.dart';

class SchedulesScreen extends StatefulWidget {
  const SchedulesScreen({super.key});

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  ScheduleStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    var list = data.schedules;
    if (_filter != null) {
      list = list.where((s) => s.status == _filter).toList();
    }

    // Kelompokkan berdasarkan tanggal.
    final grouped = <String, List<Schedule>>{};
    for (final s in list) {
      final key = Formatters.tanggalLengkap(s.startTime);
      grouped.putIfAbsent(key, () => []).add(s);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: PageHeader(
            title: 'Jadwal',
            subtitle: '${data.jadwalHariIni} reservasi hari ini',
            action: ElevatedButton.icon(
              onPressed: data.loading ? null : () => showScheduleForm(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Buat Jadwal'),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _chip('Semua', null),
                _chip('Terjadwal', ScheduleStatus.upcoming),
                _chip('Berlangsung', ScheduleStatus.ongoing),
                _chip('Selesai', ScheduleStatus.done),
                _chip('Dibatalkan', ScheduleStatus.cancelled),
              ],
            ),
          ),
        ),
        Expanded(
          child: data.loading
              ? const ListSkeleton()
              : list.isEmpty
                  ? (data.schedules.isEmpty
                      ? EmptyState(
                          icon: Icons.calendar_today_outlined,
                          title: 'Belum ada jadwal',
                          message:
                              'Buat reservasi pertama untuk pelanggan Anda agar antrean lebih teratur.',
                          actionLabel: 'Buat Jadwal',
                          onAction: () => showScheduleForm(context),
                        )
                      : const EmptyState(
                          icon: Icons.event_busy,
                          title: 'Tidak ada jadwal',
                          message:
                              'Tidak ada jadwal dengan status yang dipilih.',
                        ))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      children: [
                        for (final entry in grouped.entries) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 12),
                            child: Text(entry.key,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: AppColors.textSecondary)),
                          ),
                          ...entry.value.map((s) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ScheduleCard(schedule: s),
                              )),
                        ],
                      ],
                    ),
        ),
      ],
    );
  }

  Widget _chip(String label, ScheduleStatus? status) {
    final selected = _filter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _filter = status),
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 13),
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
              color: selected ? AppColors.primary : AppColors.border),
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final Schedule schedule;
  const _ScheduleCard({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final data = context.read<DataProvider>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.accentSoft.withOpacity(.35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(Formatters.jam(schedule.startTime),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.primary)),
                Text('${schedule.durationMinutes}m',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(schedule.customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                    ),
                    const SizedBox(width: 8),
                    _badge(schedule.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${schedule.serviceName} • ${schedule.barberName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12.5)),
                if (schedule.note != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.sticky_note_2_outlined,
                          size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(schedule.note!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textMuted)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            onSelected: (v) async {
              if (v == 'edit') {
                showScheduleForm(context, existing: schedule);
              } else if (v == 'ongoing') {
                data.setScheduleStatus(schedule.id, ScheduleStatus.ongoing);
              } else if (v == 'done') {
                data.setScheduleStatus(schedule.id, ScheduleStatus.done);
              } else if (v == 'cancel') {
                data.setScheduleStatus(schedule.id, ScheduleStatus.cancelled);
              } else if (v == 'delete') {
                final ok = await showConfirmDialog(context,
                    title: 'Hapus jadwal?',
                    message:
                        'Jadwal ${schedule.customerName} akan dihapus permanen.');
                if (ok && context.mounted) {
                  data.deleteSchedule(schedule.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Jadwal dihapus.')));
                }
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 10),
                    Text('Edit')
                  ])),
              if (schedule.status == ScheduleStatus.upcoming)
                const PopupMenuItem(
                    value: 'ongoing',
                    child: Row(children: [
                      Icon(Icons.play_circle_outline,
                          size: 18, color: AppColors.warning),
                      SizedBox(width: 10),
                      Text('Mulai')
                    ])),
              if (schedule.status != ScheduleStatus.done)
                const PopupMenuItem(
                    value: 'done',
                    child: Row(children: [
                      Icon(Icons.check_circle_outline,
                          size: 18, color: AppColors.success),
                      SizedBox(width: 10),
                      Text('Selesai')
                    ])),
              if (schedule.status != ScheduleStatus.cancelled)
                const PopupMenuItem(
                    value: 'cancel',
                    child: Row(children: [
                      Icon(Icons.cancel_outlined, size: 18),
                      SizedBox(width: 10),
                      Text('Batalkan')
                    ])),
              const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete_outline,
                        size: 18, color: AppColors.danger),
                    SizedBox(width: 10),
                    Text('Hapus', style: TextStyle(color: AppColors.danger))
                  ])),
            ],
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _badge(ScheduleStatus status) {
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
