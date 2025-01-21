import 'package:flutter/material.dart';
import 'package:summerschool_tutorial/agent.dart';
import 'package:summerschool_tutorial/thingylib.dart';

class ThingyDataView extends StatelessWidget {
  ThingyDataView({super.key});

  final ThingyManager thingyManager = ThingyManager();
  final thingyAgent = ThingyAgent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () => thingyManager.scanAndSelectDevice(context),
                  child: const Text('Connect'),
                ),
                TextButton(
                  onPressed: () {
                    thingyManager.startCharacteristics(thingyAgent.applyQuaternion);
                  },
                  child: const Text('Start'),
                ),
                TextButton(
                  onPressed: () => thingyManager.stopCharacteristics(),
                  child: const Text('Stop'),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}