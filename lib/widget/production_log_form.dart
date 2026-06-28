import 'package:flutter/material.dart';
import 'package:flutter_demos/ui/button.dart';

class ProductionLogForm extends StatefulWidget {
  final List<String> availableItems;
  final Function(String item, int good, int damaged, int misprint) onSubmit;

  const ProductionLogForm({
    super.key,
    required this.availableItems,
    required this.onSubmit,
  });

  @override
  State<ProductionLogForm> createState() => _ProductionLogFormState();
}

class _ProductionLogFormState extends State<ProductionLogForm> {
  String? _selectedItem;
  final _goodController = TextEditingController(text: '0');
  final _damagedController = TextEditingController(text: '0');
  final _misprintController = TextEditingController(text: '0');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start, // Left backbone of the F-pattern
      children: [
        // 1. ITEM DROPDOWN (High probability of change / replacement)
        DropdownButton<String>(
          value: _selectedItem,
          hint: const Text('SELECT ITEM'),
          isExpanded: true,
          items: widget.availableItems.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: (val) => setState(() => _selectedItem = val),
        ),

        const SizedBox(height: 24),

        // 2. MID AXIS: HIGH-FREQUENCY COUNTERS
        Row(
          children: [
            // GOOD FIELD (High probability of change / automation)
            Expanded(
              child: TextField(
                controller: _goodController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'GOOD'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _damagedController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'DAMAGED'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // 3. VERTICAL STEM: LOW-FREQUENCY EXCEPTION
        SizedBox(
          width: 150, // Short width breaks the grid for the F-Pattern look
          child: TextField(
            controller: _misprintController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'MISPRINT'),
          ),
        ),

        const SizedBox(height: 32),

        // 4. SUBMIT ACTION
        PrimaryButton(
          onTap: _selectedItem == null
              ? null
              : () {
                  widget.onSubmit(
                    _selectedItem!,
                    int.tryParse(_goodController.text) ?? 0,
                    int.tryParse(_damagedController.text) ?? 0,
                    int.tryParse(_misprintController.text) ?? 0,
                  );
                },
          title: 'SUBMIT BATCH',
        ),
      ],
    );
  }
}
