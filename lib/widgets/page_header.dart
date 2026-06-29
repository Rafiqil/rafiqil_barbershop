import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Header halaman dengan judul, subjudul, dan aksi (mis. tombol tambah).
class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? action;

  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final compact = c.maxWidth < 520;
      final titleBlock = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(subtitle,
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 13.5)),
        ],
      );
      if (compact && action != null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            titleBlock,
            const SizedBox(height: 14),
            Align(alignment: Alignment.centerLeft, child: action!),
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: titleBlock),
          if (action != null) action!,
        ],
      );
    });
  }
}

/// Kolom pencarian standar.
class SearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  const SearchField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
        fillColor: AppColors.surface,
      ),
    );
  }
}
