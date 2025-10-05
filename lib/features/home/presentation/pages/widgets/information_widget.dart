import 'package:flutter/material.dart';
class InformationWidget extends StatefulWidget {
  const InformationWidget({super.key});

  @override
  State<InformationWidget> createState() => _InformationWidgetState();
}

class _InformationWidgetState extends State<InformationWidget> {
   String? information;
   Icon? _icon;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(10),
      ),
        child: Column(
          children: [
            Row(
              children: [
                Text("information"),
                Spacer(),
                //Icon(Icons.i,color: Colors.black,),
              ],
            )
          ],
        ),
    );
  }
}
