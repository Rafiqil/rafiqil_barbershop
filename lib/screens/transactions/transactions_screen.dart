import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/transaction.dart';
import '../../providers/data_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/page_header.dart';
import '../../widgets/status_badge.dart';
import 'transaction_form.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _query = '';
  TransactionStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    var list = data.transactions;
    if (_filter != null) {
      list = list.where((t) => t.status == _filter).toList();
    }
    if (_query.isNotEmpty) {
      list = list
          .where((t) =>
              t.customerName.toLowerCase().contains(_query.toLowerCase()) ||
              t.invoiceNo.toLowerCase().contains(_query.toLowerCase()) ||
              t.barberName.toLowerCase().contains(_query.toLowerCase()))
          .toList();
    }

    final paidTotal = data.transactions
        .where((t) => t.status == TransactionStatus.paid)
        .fold<int>(0, (s, t) => s + t.total);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: PageHeader(
            title: 'Transaksi',
            subtitle:
                '${data.transactions.length} transaksi • Total lunas ${Formatters.rupiah(paidTotal)}',
            action: ElevatedButton.icon(
              onPressed:
                  data.loading ? null : () => showTransactionForm(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Transaksi Baru'),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Column(
            children: [
              SearchField(
                hint: 'Cari invoice, pelanggan, atau barber...',
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _chip('Semua', null),
                    _chip('Lunas', TransactionStatus.paid),
                    _chip('Menunggu', TransactionStatus.pending),
                    _chip('Batal', TransactionStatus.cancelled),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: data.loading
              ? const ListSkeleton()
              : list.isEmpty
                  ? (data.transactions.isEmpty
                      ? EmptyState(
                          icon: Icons.receipt_long_outlined,
                          title: 'Belum ada transaksi',
                          message:
                              'Catat transaksi pertama untuk mulai melihat laporan omset Anda.',
                          actionLabel: 'Transaksi Baru',
                          onAction: () => showTransactionForm(context),
                        )
                      : const EmptyState(
                          icon: Icons.search_off,
                          title: 'Tidak ditemukan',
                          message:
                              'Tidak ada transaksi yang cocok dengan filter/pencarian.',
                        ))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) =>
                          _TransactionCard(trx: list[i]),
                    ),
        ),
      ],
    );
  }

  Widget _chip(String label, TransactionStatus? status) {
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

class _TransactionCard extends StatelessWidget {
  final BarberTransaction trx;
  const _TransactionCard({required this.trx});

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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.receipt_long_outlined,
                    color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(trx.customerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 15)),
                        ),
                        const SizedBox(width: 8),
                        _statusBadge(trx.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${trx.invoiceNo} • ${trx.barberName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12.5)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(Formatters.rupiah(trx.total),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.primary)),
                  const SizedBox(height: 2),
                  Text(trx.method.label,
                      style: const TextStyle(
                          fontSize: 11.5, color: AppColors.textSecondary)),
                ],
              ),
              PopupMenuButton<String>(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onSelected: (v) async {
                  if (v == 'edit') {
                    showTransactionForm(context, existing: trx);
                  } else if (v == 'paid') {
                    data.setTransactionStatus(trx.id, TransactionStatus.paid);
                  } else if (v == 'cancel') {
                    data.setTransactionStatus(
                        trx.id, TransactionStatus.cancelled);
                  } else if (v == 'delete') {
                    final ok = await showConfirmDialog(context,
                        title: 'Hapus transaksi?',
                        message:
                            'Transaksi ${trx.invoiceNo} akan dihapus permanen.');
                    if (ok && context.mounted) {
                      data.deleteTransaction(trx.id);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Transaksi ${trx.invoiceNo} dihapus.')));
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
                  if (trx.status != TransactionStatus.paid)
                    const PopupMenuItem(
                        value: 'paid',
                        child: Row(children: [
                          Icon(Icons.check_circle_outline,
                              size: 18, color: AppColors.success),
                          SizedBox(width: 10),
                          Text('Tandai Lunas')
                        ])),
                  if (trx.status != TransactionStatus.cancelled)
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
                        Text('Hapus',
                            style: TextStyle(color: AppColors.danger))
                      ])),
                ],
                icon: const Icon(Icons.more_vert,
                    color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: trx.serviceNames
                      .map((n) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(n,
                                style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textSecondary)),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(width: 8),
              Text(Formatters.tanggalJam(trx.createdAt),
                  style: const TextStyle(
                      fontSize: 11.5, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(TransactionStatus s) {
    switch (s) {
      case TransactionStatus.paid:
        return StatusBadge.success(s.label, icon: Icons.check);
      case TransactionStatus.pending:
        return StatusBadge.warning(s.label, icon: Icons.schedule);
      case TransactionStatus.cancelled:
        return StatusBadge.danger(s.label, icon: Icons.close);
    }
  }
}
