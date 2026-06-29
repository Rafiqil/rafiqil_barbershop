import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/service.dart';
import '../../providers/data_provider.dart';
import '../../theme/app_theme.dart';

const _iconChoices = <IconData>[
  Icons.content_cut,
  Icons.spa,
  Icons.face_retouching_natural,
  Icons.brush,
  Icons.child_care,
  Icons.water_drop,
  Icons.auto_awesome,
  Icons.cut,
];

Future<void> showServiceForm(BuildContext context, {BarberService? existing}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ServiceForm(existing: existing),
  );
}

class _ServiceForm extends StatefulWidget {
  final BarberService? existing;
  const _ServiceForm({this.existing});

  @override
  State<_ServiceForm> createState() => _ServiceFormState();
}

class _ServiceFormState extends State<_ServiceForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _desc;
  late final TextEditingController _price;
  late final TextEditingController _dur;
  late IconData _icon;
  late bool _active;
  bool _saving = false;

  bool get isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _desc = TextEditingController(text: e?.description ?? '');
    _price = TextEditingController(text: e?.price.toString() ?? '');
    _dur = TextEditingController(text: e?.durationMinutes.toString() ?? '30');
    _icon = e?.icon ?? Icons.content_cut;
    _active = e?.active ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _price.dispose();
    _dur.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final data = context.read<DataProvider>();
    final price = int.tryParse(_price.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final dur = int.tryParse(_dur.text) ?? 30;

    if (isEdit) {
      final updated = widget.existing!.copyWith(
        name: _name.text.trim(),
        description: _desc.text.trim(),
        price: price,
        durationMinutes: dur,
        icon: _icon,
        active: _active,
      );
      Navigator.pop(context);
      await data.updateService(updated);
      _toast('Layanan diperbarui.');
    } else {
      final s = BarberService(
        id: data.genId('svc'),
        name: _name.text.trim(),
        description: _desc.text.trim(),
        price: price,
        durationMinutes: dur,
        icon: _icon,
        active: _active,
      );
      Navigator.pop(context);
      await data.addService(s);
      _toast('Layanan "${s.name}" ditambahkan.');
    }
  }

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
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
          maxHeight: MediaQuery.of(context).size.height * 0.92,
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
                Text(isEdit ? 'Edit Layanan' : 'Tambah Layanan',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                _label('Ikon Layanan'),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final ic in _iconChoices)
                      GestureDetector(
                        onTap: () => setState(() => _icon = ic),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _icon == ic
                                ? AppColors.accentSoft.withOpacity(.6)
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: _icon == ic
                                    ? AppColors.accent
                                    : AppColors.border,
                                width: _icon == ic ? 1.6 : 1),
                          ),
                          child: Icon(ic,
                              color: _icon == ic
                                  ? AppColors.accent
                                  : AppColors.textSecondary),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                _label('Nama Layanan'),
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                      hintText: 'mis. Potong Rambut Pria'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                _label('Deskripsi'),
                TextFormField(
                  controller: _desc,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      hintText: 'Deskripsi singkat layanan...'),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Harga (Rp)'),
                          TextFormField(
                            controller: _price,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(hintText: 'mis. 35000'),
                            validator: (v) {
                              final n = int.tryParse(
                                  (v ?? '').replaceAll(RegExp(r'[^0-9]'), ''));
                              return (n == null || n <= 0)
                                  ? 'Harga tidak valid'
                                  : null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Durasi (menit)'),
                          TextFormField(
                            controller: _dur,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(hintText: 'mis. 30'),
                            validator: (v) {
                              final n = int.tryParse(v ?? '');
                              return (n == null || n <= 0)
                                  ? 'Durasi tidak valid'
                                  : null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _active,
                  activeColor: AppColors.success,
                  onChanged: (v) => setState(() => _active = v),
                  title: const Text('Layanan Aktif',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Layanan nonaktif tidak muncul di transaksi/jadwal baru.',
                      style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(height: 16),
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
