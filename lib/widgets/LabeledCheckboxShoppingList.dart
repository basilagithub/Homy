import 'package:flutter/material.dart';

class LabeledCheckboxShopping extends StatelessWidget {
  const LabeledCheckboxShopping(
      {super.key,
      required this.label,
      required this.padding,
      required this.value,
      required this.onChanged,
      required this.deletefromOurList});

  final String label;
  final EdgeInsets padding;
  final bool value;
  final ValueChanged<bool> onChanged;
  //final VoidCallback deletefromOurList;
  final Function deletefromOurList;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Dismissible(
        key: UniqueKey(),
        onDismissed: (DismissDirection direction) {
          deletefromOurList(direction);
        },
        background: slideLeftBackground(),
        secondaryBackground: slideLeftBackground(),
        child: Padding(
          padding: padding,
          child: ListTile(
            title: Text(
              label,
              style: TextStyle(
                  decoration:
                      value ? TextDecoration.lineThrough : TextDecoration.none),
            ),
            leading: CircleAvatar(backgroundColor: Colors.amber),
            trailing: Checkbox(
              activeColor: Color.fromARGB(255, 34, 156, 144),
              value: value,
              onChanged: (bool? newValue) {
                onChanged(newValue!);
              },
            ),
          ),
        ),
      ),
    );
  }
}

Widget slideLeftBackground() {
  return Container(
    color: Colors.red,
    child: Align(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Icon(
            Icons.delete,
            color: Colors.white,
          ),
          Text(
            " Delete",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.right,
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
      alignment: Alignment.centerRight,
    ),
  );
}
