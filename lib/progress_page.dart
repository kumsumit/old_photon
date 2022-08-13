import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:photon/controllers/controllers.dart';
import 'package:photon/services/photon_receiver.dart';

import 'models/sender_model.dart';

class ProgressPage extends StatefulWidget {
  final SenderModel senderModel;
  const ProgressPage({
    Key? key,
    required this.senderModel,
  }) : super(key: key);

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  @override
  void initState() {
    super.initState();
    PhotonReceiver.receive(widget.senderModel);
  }

  final percentageController = PercentageController();
  double percentage = 0.0;
  List percentageList = [];

  @override
  Widget build(BuildContext context) {
    print(widget.senderModel.filesCount);

    var getInstance = GetIt.I<PercentageController>();
    getInstance.percentage =
        RxList.generate(widget.senderModel.filesCount!, (i) {
      return RxDouble(0.0);
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text(' Receving'),
      ),
      body: ListView.builder(
          itemCount: widget.senderModel.filesCount,
          itemBuilder: (context, item) {
            percentageList.add(0.0);
            return ListTile(
              onTap: () {},
              title: SizedBox(
                width: 180,
                height: 100,
                child: Obx(
                  () {
                    percentageList[item] =
                        (getInstance.percentage[item] as RxDouble).value;

                    return Text('${percentageList[item]}');
                  },
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(onPressed: () {
        percentageList[0]++;
      }),
    );
  }
}