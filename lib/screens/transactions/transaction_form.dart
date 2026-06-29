import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/seed_data.dart';
import '../../models/customer.dart';
import '../../models/transaction.dart';
import '../../providers/data_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';

Future<void> showTransactionForm(BuildContext context,
    {BarberTransaction? existing}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TransactionForm(existing: existing),
  );
}

class _TransactionForm extends StatefulWidget {
  final BarberTransaction? existing;
  const _TransactionForm({this.existing});

  @override
  State<_TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<_TransactionForm> {
  Customer? _customer;
  final Set<String> _selectedServices = {};
  String _barber = SeedData.barbers.first;
  PaymentMethod _method = PaymentMethod.cash;
  TransactionStatus _status = TransactionStatus.paid;
  bool _saving = false;
  bool _showCustomerError = false;
  bool _showServiceError = false;

  bool get isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final data = context.read<DataProvider>();
    final e = widget.existing;
    if (e != null) {
      _customer = data.customerById(e.customerId);
      _selectedServices.addAll(e.serviceIds);
      _barber = e.barberName;
      _method = e.method;
      _status = e.status;
    }
  }

  int get _total {
    final services = context.read<DataProvider>().services;
    return services
        .where((s) => _selectedServices.contains(s.id))
        .fold(0, (sum, s) => sum + s.price);
  }

  Future<void> _save() async {
    setState(() {
      _showCustomerError = _customer == null;
      _showServiceError = _selectedServices.isEmpty;
    });
    if (_customer == null || _selectedServices.isEmpty) return;

    setState(() => _saving = true);
    final data = context.read<DataProvider>();
    final services = data.services
        .where((s) => _selectedServices.contains(s.id))
        .toList();

    if (isEdit) {
      final updated = widget.existing!.copyWith(
        customerId: _customer!.id,
        customerName: _customer!.name,
        barberName: _barber,
        serviceIds: services.map((s) => s.id).toList(),
        serviceNames: services.map((s) => s.name).toList(),
        total: _total,
        method: _method,
        status: _status,
      );
      Navigator.pop(context);
      await data.updateTransaction(updated);
      _toast('Transaksi diperbarui.');
    } else {
      final trx = BarberTransaction(
        id: data.genId('trx'),
        invoiceNo: data.nextInvoiceNo(),
        customerId: _customer!.id,
        customerName: _customer!.name,
        barberName: _barber,
        serviceIds: services.map((s) => s.id).toList(),
        serviceNames: services.map((s) => s.name).toList(),
        total: _total,
        method: _method,
        status: _status,
        createdAt: DateTime.now(),
      );
      Navigator.pop(context);
      await data.addTransaction(trx);
      _toast('Transaksi ${trx.invoiceNo} dibuat.');
    }
  }

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final customers = data.customers;
    final services = data.activeServices;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
          maxWidth: 560,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(isEdit ? 'Edit Transaksi' : 'Transaksi Baru',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),

              _label('Pelanggan'),
              DropdownButtonFormField<Customer>(
                value: _customer,
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: 'Pilih pelanggan',
                  prefixIcon: const Icon(Icons.person_outline),
                  errorText: _showCustomerError ? 'Pilih pelanggan' : null,
                ),
                items: customers
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.name,
                              overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (c) => setState(() {
                  _customer = c;
                  _showCustomerError = false;
                }),
              ),
              const SizedBox(height: 16),

              _label('Layanan'),
              if (services.isEmpty)
                const Text('Belum ada layanan aktif.',
                    style: TextStyle(color: AppColors.textSecondary))
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: services.map((s) {
                    final sel = _selectedServices.contains(s.id);
                    return FilterChip(
                      label: Text('${s.name} • ${Formatters.rupiah(s.price)}'),
                      selected: sel,
                      showCheckmark: false,
                      onSelected: (v) => setState(() {
                        v
                            ? _selectedServices.add(s.id)
                            : _selectedServices.remove(s.id);
                        _showServiceError = false;
                      }),
                      selectedColor: AppColors.accentSoft.withOpacity(.6),
                      backgroundColor: AppColors.background,
                      labelStyle: TextStyle(
                          fontSize: 12.5,
                          color: sel ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: sel ? FontWeight.w600 : FontWeight.w500),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                            color: sel ? AppColors.accent : AppColors.border),
                      ),
                    );
                  }).toList(),
                ),
              if (_showServiceError)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text('Pilih minimal satu layanan',
                      style: TextStyle(color: AppColors.danger, fontSize: 12)),
                ),
              const SizedBox(height: 16),

              _label('Barber'),
              DropdownButtonFormField<String>(
                value: _barber,
                isExpanded: true,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.badge_outlined)),
                items: SeedData.barbers
                    .map((b) =>
                        DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                onChanged: (b) => setState(() => _barber = b!),
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Pembayaran'),
                        DropdownButtonFormField<PaymentMethod>(
                          value: _method,
                          isExpanded: true,
                          items: PaymentMethod.values
                              .map((m) => DropdownMenuItem(
                                  value: m, child: Text(m.label)))
                              .toList(),
                          onChanged: (m) => setState(() => _method = m!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Status'),
                        DropdownButtonFormField<TransactionStatus>(
                          value: _status,
                          isExpanded: true,
                          items: TransactionStatus.values
                              .map((s) => DropdownMenuItem(
                                  value: s, child: Text(s.label)))
                              .toList(),
                          onChanged: (s) => setState(() => _status = s!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Text('Total',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    const Spacer(),
                    Text(Formatters.rupiah(_total),
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: Text(isEdit ? 'Simpan' : 'Buat Transaksi'),
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

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 13.5)),
      );
}
