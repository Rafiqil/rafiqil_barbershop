import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/customer.dart';
import '../../providers/data_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/page_header.dart';
import 'customer_form.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();

    final all = data.customers;
    final filtered = _query.isEmpty
        ? all
        : all
            .where((c) =>
                c.name.toLowerCase().contains(_query.toLowerCase()) ||
                c.phone.contains(_query) ||
                (c.email ?? '').toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: PageHeader(
            title: 'Pelanggan',
            subtitle: '${all.length} pelanggan terdaftar',
            action: ElevatedButton.icon(
              onPressed: data.loading ? null : () => _openForm(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah Pelanggan'),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: SearchField(
            hint: 'Cari nama, telepon, atau email...',
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: data.loading
              ? const ListSkeleton()
              : filtered.isEmpty
                  ? (all.isEmpty
                      ? EmptyState(
                          icon: Icons.people_outline,
                          title: 'Belum ada pelanggan',
                          message:
                              'Tambahkan pelanggan pertama Anda untuk mulai mencatat kunjungan dan riwayat.',
                          actionLabel: 'Tambah Pelanggan',
                          onAction: () => _openForm(context),
                        )
                      : const EmptyState(
                          icon: Icons.search_off,
                          title: 'Tidak ditemukan',
                          message:
                              'Tidak ada pelanggan yang cocok dengan pencarian Anda.',
                        ))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _CustomerCard(
                        customer: filtered[i],
                        onEdit: () => _openForm(context, existing: filtered[i]),
                        onDelete: () => _delete(context, filtered[i]),
                      ),
                    ),
        ),
      ],
    );
  }

  void _openForm(BuildContext context, {Customer? existing}) {
    showCustomerForm(context, existing: existing);
  }

  Future<void> _delete(BuildContext context, Customer c) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Hapus pelanggan?',
      message:
          'Data "${c.name}" akan dihapus permanen. Tindakan ini tidak dapat dibatalkan.',
    );
    if (ok && context.mounted) {
      context.read<DataProvider>().deleteCustomer(c.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pelanggan "${c.name}" dihapus.')),
      );
    }
  }
}

class _CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _CustomerCard({
    required this.customer,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.accentSoft.withOpacity(.5),
            child: Text(
              Formatters.inisial(customer.name),
              style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 14,
                  runSpacing: 2,
                  children: [
                    _meta(Icons.phone_outlined, customer.phone),
                    if (customer.email != null)
                      _meta(Icons.email_outlined, customer.email!),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 14,
                  runSpacing: 2,
                  children: [
                    _meta(Icons.repeat, '${customer.visits} kunjungan'),
                    if (customer.lastVisit != null)
                      _meta(Icons.history,
                          'Terakhir ${Formatters.tanggal(customer.lastVisit!)}'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            onSelected: (v) {
              if (v == 'edit') onEdit();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 10),
                    Text('Edit')
                  ])),
              PopupMenuItem(
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

  Widget _meta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12.5)),
      ],
    );
  }
}
