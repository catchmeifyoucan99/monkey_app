import 'package:flutter/material.dart';

class TrashBin extends StatelessWidget {
  final Function(String) onAccept;

  const TrashBin({super.key, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: DragTarget<String>(
        onWillAccept: (data) => true,
        onAccept: onAccept,
        builder: (context, candidateData, rejectedData) {
          return Container(
            width: 60,
            height:60,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.delete,
              color: Colors.white,
              size: 40,
            ),
          );
        },
      ),
    );
  }
}
