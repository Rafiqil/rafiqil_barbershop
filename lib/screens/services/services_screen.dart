import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/service.dart';
import '../../providers/data_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/page_header.dart';
import '../../widgets/status_badge.dart';
import 'service_form.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final all = data.services;
    final filtered = _query.isEmpty
        ? all
        : all
            .where((s) =>
                s.name.toLowerCase().contains(_query.toLowerCase()) ||
                s.description.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: PageHeader(
            title: 'Layanan',
            subtitle: '${all.where((s) => s.active).length} aktif • ${all.length} total',
            action: ElevatedButton.icon(
              onPressed: data.loading ? null : () => showServiceForm(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah Layanan'),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: SearchField(
            hint: 'Cari layanan...',
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: data.loading
              ? const ListSkeleton()
              : filtered.isEmpty
                  ? (all.isEmpty
                      ? EmptyState(
                          icon: Icons.content_cut,
                          title: 'Belum ada layanan',
                          message:
                              'Tambahkan layanan/jasa barbershop seperti potong rambut, cukur jenggot, dan lainnya.',
                          actionLabel: 'Tambah Layanan',
                          onAction: () => showServiceForm(context),
                        )
                      : const EmptyState(
                          icon: Icons.search_off,
                          title: 'Tidak ditemukan',
                          message: 'Tidak ada layanan yang cocok.',
                        ))
                  : _grid(context, filtered),
        ),
      ],
    );
  }

  Widget _grid(BuildContext context, List<BarberService> items) {
    return LayoutBuilder(builder: (context, c) {
      int cols = 3;
      if (c.maxWidth < 1100) cols = 2;
      if (c.maxWidth < 640) cols = 1;
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: cols == 1 ? 2.4 : 1.45,
        ),
        itemCount: items.length,
        itemBuilder: (context, i) => _ServiceCard(service: items[i]),
      );
    });
  }
}

class _ServiceCard extends StatelessWidget {
  final BarberService service;
  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    final data = context.read<DataProvider>();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.accentSoft.withOpacity(.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(service.icon, color: AppColors.accent),
              ),
              const Spacer(),
              service.active
                  ? StatusBadge.success('Aktif')
                  : StatusBadge.danger('Nonaktif'),
              PopupMenuButton<String>(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onSelected: (v) async {
                  if (v == 'edit') {
                    showServiceForm(context, existing: service);
                  } else if (v == 'toggle') {
                    data.toggleServiceActive(service.id);
                  } else if (v == 'delete') {
                    final ok = await showConfirmDialog(
                      context,
                      title: 'Hapus layanan?',
                      message:
                          'Layanan "${service.name}" akan dihapus permanen.',
                    );
                    if (ok && context.mounted) {
                      data.deleteService(service.id);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Layanan "${service.name}" dihapus.')));
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
                  PopupMenuItem(
                      value: 'toggle',
                      child: Row(children: [
                        Icon(
                            service.active
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18),
                        const SizedBox(width: 10),
                        Text(service.active ? 'Nonaktifkan' : 'Aktifkan')
                      ])),
                  const PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline,
                            size: 18, color: AppColors.danger),
                        SizedBox(width: 10),
                        Text('Hapus',
                            style: TextStyle(color: AppColors.danger))
                      ])),
                ],
                icon: const Icon(Icons.more_vert,
                    color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(service.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 4),
          Expanded(
            child: Text(service.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12.5, height: 1.4)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(Formatters.rupiah(service.price),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.primary)),
              const Spacer(),
              Icon(Icons.schedule, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text('${service.durationMinutes} mnt',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12.5)),
            ],
          ),
        ],
      ),
    );
  }
}
