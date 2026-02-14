import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/invoice_item_model.dart';

class InvoiceItemCard extends StatelessWidget {
  final InvoiceItemModel item;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const InvoiceItemCard({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onChanged,
  });

  // Theme constants
  final Color primaryColor = const Color(0xFF4F46E5);
  final Color borderColor = const Color(0xFFE5E7EB);
  final Color textColor = const Color(0xFF111827);
  final Color mutedText = const Color(0xFF6B7280);
  final Color fieldBg = const Color(0xFFF9FAFB);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -------- ITEM NAME + DELETE --------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildLabelledField(
                  label: "ITEM DESCRIPTION",
                  child: TextFormField(
                    initialValue: item.name,
                    onChanged: (v) {
                      item.name = v;
                      onChanged();
                    },
                    style: _textStyle(),
                    decoration: _inputDecoration(
                      hint: "Service or Product name",
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _deleteButton(),
            ],
          ),

          const SizedBox(height: 12),

          // -------- HSN / SAC --------
          _buildLabelledField(
            label: "HSN / SAC (OPTIONAL)",
            child: TextFormField(
              initialValue: item.hsnSacCode,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (v) {
                item.hsnSacCode = v.trim();
                onChanged();
              },
              style: _textStyle(),
              decoration: _inputDecoration(
                hint: "4 / 6 / 8 digit code",
              ),
            ),
          ),

          const SizedBox(height: 16),

          // -------- QTY | UNIT PRICE | TAX --------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // QTY
              Expanded(
                flex: 2,
                child: _buildLabelledField(
                  label: "QTY",
                  child: TextFormField(
                    initialValue: item.quantity.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      item.quantity = double.tryParse(v) ?? 0.0;
                      onChanged();
                    },
                    style: _textStyle(),
                    decoration: _inputDecoration(),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // UNIT PRICE
              Expanded(
                flex: 5,
                child: _buildLabelledField(
                  label: "UNIT PRICE",
                  child: Container(
                    decoration: BoxDecoration(
                      color: fieldBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        _currencyPicker(),
                        Expanded(
                          child: TextFormField(
                            initialValue: item.unitPrice == 0
                                ? ""
                                : item.unitPrice.toString(),
                            keyboardType:
                            const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (v) {
                              item.unitPrice =
                                  double.tryParse(v) ?? 0.0;
                              onChanged();
                            },
                            style: _textStyle(),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 12,
                              ),
                              border: InputBorder.none,
                              hintText: "0.00",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // TAX
              Expanded(
                flex: 3,
                child: _buildLabelledField(
                  label: "TAX %",
                  child: DropdownButtonFormField<double>(
                    value: item.taxRate,
                    icon: const Icon(
                      Icons.expand_more_rounded,
                      size: 18,
                    ),
                    decoration: _inputDecoration(),
                    style: _textStyle(),
                    items: const [0, 5, 12, 18, 28]
                        .map(
                          (v) => DropdownMenuItem<double>(
                        value: v.toDouble(),
                        child: Text("$v%"),
                      ),
                    )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        item.taxRate = v;
                        onChanged();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------- CURRENCY PICKER --------
  Widget _currencyPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(7),
          bottomLeft: Radius.circular(7),
        ),
        border: Border(right: BorderSide(color: borderColor)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: item.currency,
          icon: const Icon(
            Icons.unfold_more_rounded,
            size: 12,
            color: Colors.grey,
          ),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: primaryColor,
            fontSize: 13,
          ),
          onChanged: (v) {
            if (v != null) {
              item.currency = v;
              onChanged();
            }
          },
          items: const [
            DropdownMenuItem(value: "₹", child: Text("₹")),
            DropdownMenuItem(value: "\$", child: Text("\$")),
          ],
        ),
      ),
    );
  }

  // -------- HELPERS --------
  Widget _buildLabelledField({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: mutedText,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _deleteButton() {
    return IconButton(
      onPressed: onRemove,
      icon: const Icon(Icons.delete_outline_rounded, size: 20),
      color: const Color(0xFFEF4444),
      style: IconButton.styleFrom(
        backgroundColor: const Color(0xFFFEF2F2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  TextStyle _textStyle() => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textColor,
  );

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      filled: true,
      fillColor: fieldBg,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
    );
  }
}
