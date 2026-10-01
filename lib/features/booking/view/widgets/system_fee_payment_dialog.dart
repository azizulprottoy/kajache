import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kaj_ache/shared/widgets/app_network_image.dart';

import '../../../../core/utils/translation_keys.dart';
import '../../../payments/models/payment_method_model.dart';
import '../../../payments/repository/payment_repository.dart';

/// Result of the system fee dialog: the chosen method and, for mobile
/// banking, the transaction ID the customer entered.
class SystemFeePaymentResult {
  final String paymentMethod;
  final String transactionId;

  const SystemFeePaymentResult({
    required this.paymentMethod,
    this.transactionId = '',
  });
}

/// Asks the customer to pay the bid placement (system) fee that publishes a
/// booking for bidding. Pops with a [SystemFeePaymentResult], or null when
/// the customer closes it.
///
/// Options: the built-in wallet (debited by the server) plus the admin-managed
/// payment methods from `/paymentMethod`, same as the website.
class SystemFeePaymentDialog extends StatefulWidget {
  final num systemFee;

  const SystemFeePaymentDialog({super.key, required this.systemFee});

  @override
  State<SystemFeePaymentDialog> createState() => _SystemFeePaymentDialogState();
}

class _SystemFeePaymentDialogState extends State<SystemFeePaymentDialog> {
  static const _wallet = 'wallet';

  final _formKey = GlobalKey<FormState>();
  final _transactionIdController = TextEditingController();
  String _selectedId = _wallet;
  List<PaymentMethodModel>? _methods;

  bool get _isBangla => Get.locale?.languageCode == 'bn';

  PaymentMethodModel? get _selectedMethod =>
      _methods?.firstWhereOrNull((m) => m.id == _selectedId);

  @override
  void initState() {
    super.initState();
    _loadMethods();
  }

  /// The fee is paid before bidding, so cash doesn't apply, and the wallet is
  /// already the built-in option.
  static bool _isFeeMethod(PaymentMethodModel method) {
    final name = method.name.trim().toLowerCase();
    return name != 'cash' && !name.contains('wallet');
  }

  Future<void> _loadMethods() async {
    List<PaymentMethodModel> methods = const [];
    try {
      methods = (await PaymentRepository().getPaymentMethods())
          .where(_isFeeMethod)
          .toList();
    } catch (_) {
      // Falls back to the wallet only
    }
    if (mounted) setState(() => _methods = methods);
  }

  @override
  void dispose() {
    _transactionIdController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final method = _selectedMethod;
    Navigator.of(context).pop(
      SystemFeePaymentResult(
        paymentMethod: method?.name ?? _wallet,
        transactionId: method == null ? '' : _transactionIdController.text.trim(),
      ),
    );
  }

  Widget _methodIcon(PaymentMethodModel method, ColorScheme colors) {
    if (method.image.isEmpty) {
      return Icon(Icons.account_balance_outlined, color: colors.primary);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AppNetworkImage(
        method.image,
        width: 32,
        height: 32,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.account_balance_outlined, color: colors.primary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final methods = _methods;
    final selectedMethod = _selectedMethod;

    return AlertDialog(
      title: const Text('Publish your request'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pay the ৳${widget.systemFee} system fee so technicians can '
                'see your request and start bidding.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(TKeys.paymentMethod.tr, style: theme.textTheme.titleSmall),
              RadioGroup<String>(
                groupValue: _selectedId,
                onChanged: (value) {
                  if (value != null) setState(() => _selectedId = value);
                },
                child: Column(
                  children: [
                    RadioListTile<String>(
                      value: _wallet,
                      title: const Text('Wallet'),
                      secondary: Icon(
                        Icons.account_balance_wallet_outlined,
                        color: colors.primary,
                      ),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                    if (methods == null)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else
                      for (final method in methods)
                        RadioListTile<String>(
                          value: method.id,
                          title: Text(method.localizedName(_isBangla)),
                          subtitle: method.description.isEmpty
                              ? null
                              : Text(method.localizedDescription(_isBangla)),
                          secondary: _methodIcon(method, colors),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                  ],
                ),
              ),
              if (selectedMethod != null) ...[
                if (selectedMethod.account.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Send ৳${widget.systemFee} to ${selectedMethod.account}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          tooltip: 'Copy',
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: selectedMethod.account),
                            );
                            ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                              const SnackBar(content: Text('Copied')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                TextFormField(
                  controller: _transactionIdController,
                  decoration: InputDecoration(
                    labelText: TKeys.transactionId.tr,
                    hintText: TKeys.transactionIdHint.tr,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? TKeys.transactionIdRequired.tr
                      : null,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(TKeys.cancel.tr),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(TKeys.payNow.tr),
        ),
      ],
    );
  }
}
