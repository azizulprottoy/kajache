import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/translation_keys.dart';

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
class SystemFeePaymentDialog extends StatefulWidget {
  final num systemFee;

  const SystemFeePaymentDialog({super.key, required this.systemFee});

  @override
  State<SystemFeePaymentDialog> createState() => _SystemFeePaymentDialogState();
}

class _SystemFeePaymentDialogState extends State<SystemFeePaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _transactionIdController = TextEditingController();
  String _method = 'wallet';

  static const _methods = <String, String>{
    'wallet': 'Wallet',
    'bkash': TKeys.bkash,
    'nagad': TKeys.nagad,
  };

  @override
  void dispose() {
    _transactionIdController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      SystemFeePaymentResult(
        paymentMethod: _method,
        transactionId:
            _method == 'wallet' ? '' : _transactionIdController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                groupValue: _method,
                onChanged: (value) {
                  if (value != null) setState(() => _method = value);
                },
                child: Column(
                  children: _methods.entries
                      .map(
                        (entry) => RadioListTile<String>(
                          value: entry.key,
                          title: Text(entry.value.tr),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      )
                      .toList(),
                ),
              ),
              if (_method != 'wallet') ...[
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
