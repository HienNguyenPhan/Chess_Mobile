import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SettingTile extends StatelessWidget {
  final String title;
  final bool? value;
  final ValueChanged<bool>? onChanged;
  final String? dropdownValue;
  final List<String>? options;
  final ValueChanged<String?>? onDropdownChanged;
  final Widget? child;

  const SettingTile.switchTile({
    super.key,
    required this.title,
    required bool this.value,
    required ValueChanged<bool> this.onChanged,
  })  : dropdownValue = null,
        options = null,
        onDropdownChanged = null,
        child = null;

  const SettingTile.dropdown({
    super.key,
    required this.title,
    required String this.dropdownValue,
    required this.options,
    required this.onDropdownChanged,
  })  : value = null,
        onChanged = null,
        child = null;

  @override
  Widget build(BuildContext context) {
    if (value != null) {
      return SwitchListTile(
        title: Text(title, style: const TextStyle(fontSize: 16)),
        value: value!,
        onChanged: onChanged,
        activeColor: Colors.blue,
        inactiveThumbColor: Colors.grey,
        inactiveTrackColor: Colors.grey.withOpacity(0.5),
        splashRadius: 24.0, // Increases the touch target size
      );
    }

    if (options != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                value: dropdownValue,
                items: options!
                    .map((e) => DropdownMenuItem<String>(
                          value: e,
                          child: Text(e.tr(), style: const TextStyle(fontSize: 14)),
                        ))
                    .toList(),
                onChanged: onDropdownChanged,
                buttonStyleData: ButtonStyleData(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  height: 40,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
                iconStyleData: const IconStyleData(
                  icon: Icon(Icons.keyboard_arrow_down_rounded),
                  iconSize: 22,
                  iconEnabledColor: Colors.black87,
                ),
                dropdownStyleData: DropdownStyleData(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return child ?? const SizedBox.shrink();
  }
}
