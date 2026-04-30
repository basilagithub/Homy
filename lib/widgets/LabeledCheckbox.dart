import 'package:flutter/material.dart';

class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox({
    super.key,
    required this.label,
    required this.padding,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final EdgeInsets padding;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print('------------------ontap value');
        onChanged(!value);
      },
      child: Padding(
        padding: padding,
        child: ListTile(
          title: Text(label),
          leading: CircleAvatar(backgroundColor: Colors.amber),
          trailing: Checkbox(
            activeColor: Color.fromARGB(255, 34, 156, 144),
            value: value,
            onChanged: (bool? newValue) {
              onChanged(newValue!);
            },
          ),
          tileColor: value ? Color.fromARGB(255, 65, 123, 156) : null,
        ),
      ),
    );
  }
}
