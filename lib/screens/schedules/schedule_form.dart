import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/seed_data.dart';
import '../../models/customer.dart';
import '../../models/service.dart';
import '../../models/schedule.dart';
import '../../providers/data_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';

Future<void> showScheduleForm(BuildContext context, {Schedule? existing}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ScheduleForm(existing: existing),
  );
}

class _ScheduleForm extends StatefulWidget {
  final Schedule? existing;
  const _ScheduleForm({this.existing});

  @override
  State<_ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<_ScheduleForm> {
  Customer? _customer;
  BarberService? _service;
  String _barber = SeedData.barbers.first;
  late DateTime _date;
  late TimeOfDay _time;
  ScheduleStatus _status = ScheduleStatus.upcoming;
  final _note = TextEditingController();
  bool _saving = false;
  bool _custErr = false;
  bool _svcErr = false;

  bool get isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final data = context.read<DataProvider>();
    final e = widget.existing;
    if (e != null) {
      _customer = data.customerById(e.customerId);
      try {
        _service = data.services.firstWhere((s) => s.id == e.serviceId);
      } catch (_) {}
      _barber = e.barberName;
      _date = DateTime(e.startTime.year, e.startTime.month, e.startTime.day);
      _time = TimeOfDay(hour: e.startTime.hour, minute: e.startTime.minute);
      _status = e.status;
      _note.text = e.note ?? '';
    } else {
      final now = DateTime.now();
      _date = DateTime(now.year, now.month, now.day);
      _time = TimeOfDay(hour: now.hour + 1, minute: 0);
    }
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  DateTime get _start => DateTime(
      _date.year, _date.month, _date.day, _time.hour, _time.minute);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    setState(() {
      _custErr = _customer == null;
      _svcErr = _service == null;
    });
    if (_customer == null || _service == null) return;

    setState(() => _saving = true);
    final data = context.read<DataProvider>();

    if (isEdit) {
      final updated = widget.existing!.copyWith(
        customerId: _customer!.id,
        customerName: _customer!.name,
        serviceId: _service!.id,
        serviceName: _service!.name,
        barberName: _barber,
        startTime: _start,
        durationMinutes: _service!.durationMinutes,
        status: _status,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      Navigator.pop(context);
      await data.updateSchedule(updated);
      _toast('Jadwal diperbarui.');
    } else {
      final s = Schedule(
        id: data.genId('sch'),
        customerId: _customer!.id,
        customerName: _customer!.name,
        serviceId: _service!.id,
        serviceName: _service!.name,
        barberName: _barber,
        startTime: _start,
        durationMinutes: _service!.durationMinutes,
        status: _status,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      Navigator.pop(context);
      await data.addSchedule(s);
      _toast('Jadwal untuk ${s.customerName} dibuat.');
    }
  }

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
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
              Text(isEdit ? 'Edit Jadwal' : 'Buat Jadwal',
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
                  errorText: _custErr ? 'Pilih pelanggan' : null,
                ),
                items: data.customers
                    .map((c) => DropdownMenuItem(
                        value: c,
                        child:
                            Text(c.name, overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (c) => setState(() {
                  _customer = c;
                  _custErr = false;
                }),
              ),
              const SizedBox(height: 16),

              _label('Layanan'),
              DropdownButtonFormField<BarberService>(
                value: _service,
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: 'Pilih layanan',
                  prefixIcon: const Icon(Icons.content_cut),
                  errorText: _svcErr ? 'Pilih layanan' : null,
                ),
                items: data.activeServices
                    .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text('${s.name} • ${s.durationMinutes} mnt',
                            overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (s) => setState(() {
                  _service = s;
                  _svcErr = false;
                }),
              ),
              const SizedBox(height: 16),

              _label('Barber'),
              DropdownButtonFormField<String>(
                value: _barber,
                isExpanded: true,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.badge_outlined)),
                items: SeedData.barbers
                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                onChanged: (b) => setState(() => _barber = b!),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Tanggal'),
                        _pickerTile(Icons.calendar_today_outlined,
                            Formatters.tanggal(_date), _pickDate),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Jam'),
                        _pickerTile(Icons.schedule, _time.format(context),
                            _pickTime),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _label('Status'),
              DropdownButtonFormField<ScheduleStatus>(
                value: _status,
                isExpanded: true,
                items: ScheduleStatus.values
                    .map((s) =>
                        DropdownMenuItem(value: s, child: Text(s.label)))
                    .toList(),
                onChanged: (s) => setState(() => _status = s!),
              ),
              const SizedBox(height: 16),

              _label('Catatan (opsional)'),
              TextFormField(
                controller: _note,
                maxLines: 2,
                decoration: const InputDecoration(
                    hintText: 'mis. Minta barber tertentu...'),
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
                      child: Text(isEdit ? 'Simpan' : 'Buat Jadwal'),
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

  Widget _pickerTile(IconData icon, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Expanded(
                child: Text(value,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14))),
          ],
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
