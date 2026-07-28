import 'package:flutter/material.dart';
import '../../../app/theme/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final String? initialValue;
  final bool showCounter;
  final EdgeInsetsGeometry? contentPadding;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.focusNode,
    this.obscureText      = false,
    this.enabled          = true,
    this.readOnly         = false,
    this.keyboardType     = TextInputType.text,
    this.textInputAction  = TextInputAction.next,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines         = 1,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.validator,
    this.initialValue,
    this.showCounter      = false,
    this.contentPadding,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscure;
  late FocusNode _focus;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
    _focus   = widget.focusNode ?? FocusNode();
    _focus.addListener(() => setState(() => _isFocused = _focus.hasFocus));
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    final borderColor = widget.errorText != null
        ? cs.error
        : _isFocused
        ? cs.primary
        : cs.outlineVariant;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide:   BorderSide(color: borderColor, width: _isFocused ? 2 : 1.5),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: _isFocused
            ? [
          BoxShadow(
            color:      cs.primary.withOpacity(0.12),
            blurRadius: 8,
            spreadRadius: 1,
          )
        ]
            : [],
      ),
      child: TextFormField(
        controller:      widget.controller,
        focusNode:       _focus,
        initialValue:    widget.initialValue,
        obscureText:     _obscure,
        enabled:         widget.enabled,
        readOnly:        widget.readOnly,
        keyboardType:    widget.keyboardType,
        textInputAction: widget.textInputAction,
        maxLines:        _obscure ? 1 : widget.maxLines,
        maxLength:       widget.maxLength,
        inputFormatters: widget.inputFormatters,
        onChanged:       widget.onChanged,
        onTap:           widget.onTap,
        onFieldSubmitted: widget.onSubmitted,
        validator:       widget.validator,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: widget.enabled ? cs.onSurface : cs.onSurface.withOpacity(0.5),
        ),
        decoration: InputDecoration(
          labelText:  widget.label?.tr,
          hintText:   widget.hint?.tr,
          errorText:  widget.errorText,
          filled:     true,
          fillColor:  widget.enabled
              ? cs.surface
              : cs.onSurface.withOpacity(0.04),
          contentPadding: widget.contentPadding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          counterText: widget.showCounter ? null : '',
          prefixIcon: widget.prefixIcon != null
              ? IconTheme(
            data: IconThemeData(
              color: _isFocused ? cs.primary : cs.onSurfaceVariant,
              size: 20,
            ),
            child: widget.prefixIcon!,
          )
              : null,
          suffixIcon: widget.obscureText
              ? IconButton(
            icon: Icon(
              _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 20,
              color: cs.onSurfaceVariant,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
          )
              : widget.suffixIcon,
          enabledBorder:  border,
          focusedBorder:  border,
          errorBorder:    border,
          focusedErrorBorder: border,
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:   BorderSide(color: cs.borderColor),
          ),
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            color: _isFocused ? cs.primary : cs.onSurfaceVariant,
          ),
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant.withOpacity(0.6),
          ),
          errorStyle: theme.textTheme.labelSmall?.copyWith(color: cs.error),
        ),
      ),
    );
  }
}


class ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final int maxLines;

  const ProfileField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}