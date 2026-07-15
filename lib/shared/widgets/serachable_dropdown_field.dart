import 'package:flutter/material.dart';

class SearchableDropdownField extends StatefulWidget {
  final String label;
  final IconData icon;
  final String? value;
  final List<String> items;
  final String hint;
  final bool enabled;
  final ValueChanged<String> onSelected;

  const SearchableDropdownField({
    super.key,
    required this.label,
    required this.icon,
    required this.items,
    required this.onSelected,
    this.value,
    this.hint = 'Select',
    this.enabled = true,
  });

  @override
  State<SearchableDropdownField> createState() =>
      _SearchableDropdownFieldState();
}

class _SearchableDropdownFieldState extends State<SearchableDropdownField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
  }

  @override
  void didUpdateWidget(covariant SearchableDropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync external changes — e.g. area gets reset to null when district changes.
    if (widget.value != oldWidget.value) {
      _controller.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      controller: _controller,
      enabled: widget.enabled,
      enableFilter: true,
      requestFocusOnTap: true,
      expandedInsets: EdgeInsets.zero,
      menuHeight: 320,
      label: Text(widget.label),
      hintText: widget.hint,
      leadingIcon: Icon(widget.icon),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dropdownMenuEntries: widget.items
          .map((e) => DropdownMenuEntry<String>(value: e, label: e))
          .toList(),
      onSelected: (val) {
        if (val != null) widget.onSelected(val);
      },
    );
  }
}