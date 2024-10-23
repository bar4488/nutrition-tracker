import 'package:flutter/material.dart';

class DualButton extends StatelessWidget {
  final void Function()? onPressed1;
  final Widget child1;
  final void Function()? onPressed2;
  final Widget child2;

  const DualButton({
    super.key,
    required this.onPressed1,
    required this.child1,
    required this.onPressed2,
    required this.child2,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            style: ButtonStyle(
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadiusDirectional.only(
                    topStart: Radius.circular(10),
                    bottomStart: Radius.circular(10),
                  ),
                ),
              ),
            ),
            onPressed: onPressed1,
            child: child1,
          ),
        ),
        Expanded(
          child: TextButton(
            style: ButtonStyle(
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadiusDirectional.only(
                    topEnd: Radius.circular(10),
                    bottomEnd: Radius.circular(10),
                  ),
                ),
              ),
            ),
            onPressed: onPressed2,
            child: child2,
          ),
        ),
      ],
    );
  }
}
