import 'package:flutter/material.dart';

class TrashBin extends StatelessWidget {
  final Function(String) onAccept;
  final String type;

  const TrashBin({
    super.key,
    required this.onAccept,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: DragTarget<String>(
        onWillAcceptWithDetails: (data) => true,
        onAcceptWithDetails: (details) {
          final String data = details.data;
          onAccept(data);
        },
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
