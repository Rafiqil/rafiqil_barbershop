import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/customer.dart';
import '../../providers/data_provider.dart';
import '../../theme/app_theme.dart';

/// Menampilkan form tambah/edit pelanggan sebagai bottom sheet/dialog responsif.
Future<void> showCustomerForm(BuildContext context, {Customer? existing}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CustomerForm(existing: existing),
  );
}

class _CustomerForm extends StatefulWidget {
  final Customer? existing;
  const _CustomerForm({this.existing});

  @override
  State<_CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<_CustomerForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _note;
  bool _saving = false;

  bool get isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _phone = TextEditingController(text: e?.phone ?? '');
    _email = TextEditingController(text: e?.email ?? '');
    _note = TextEditingController(text: e?.note ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final data = context.read<DataProvider>();
    final messenger = ScaffoldMessenger.of(context);

    if (isEdit) {
      final updated = widget.existing!.copyWith(
        name: _name.text.trim(),
        phone: _phone.text.trim(),
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      Navigator.pop(context); // tutup dulu (optimistic UI)
      await data.updateCustomer(updated);
      messenger.showSnackBar(
          const SnackBar(content: Text('Perubahan disimpan.')));
    } else {
      final c = Customer(
        id: data.genId('cust'),
        name: _name.text.trim(),
        phone: _phone.text.trim(),
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        joinedAt: DateTime.now(),
      );
      Navigator.pop(context);
      await data.addCustomer(c);
      messenger.showSnackBar(
          SnackBar(content: Text('Pelanggan "${c.name}" ditambahkan.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: 560,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
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
                Text(isEdit ? 'Edit Pelanggan' : 'Tambah Pelanggan',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                    isEdit
                        ? 'Perbarui informasi pelanggan.'
                        : 'Lengkapi data pelanggan baru.',
                    style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 24),
                _label('Nama Lengkap'),
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                      hintText: 'mis. Andi Pratama',
                      prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                _label('Nomor Telepon'),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                      hintText: 'mis. 081234567890',
                      prefixIcon: Icon(Icons.phone_outlined)),
                  validator: (v) => (v == null || v.trim().length < 8)
                      ? 'Nomor telepon tidak valid'
                      : null,
                ),
                const SizedBox(height: 16),
                _label('Email (opsional)'),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      hintText: 'mis. nama@email.com',
                      prefixIcon: Icon(Icons.email_outlined)),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    return v.contains('@') ? null : 'Email tidak valid';
                  },
                ),
                const SizedBox(height: 16),
                _label('Catatan (opsional)'),
                TextFormField(
                  controller: _note,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      hintText: 'mis. Suka model fade, alergi produk tertentu...'),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            _saving ? null : () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        child: Text(isEdit ? 'Simpan' : 'Tambah'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
