import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:smart_bin/controllers/container/container_bloc.dart';
import 'package:smart_bin/widgets/custom_button.dart';

import '../models/container.dart';

class Trashes extends StatelessWidget {
  const Trashes({super.key});

  void showDetailDialog(Trash container, BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Center(child: Text("Container ${container.id}")),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularPercentIndicator(
                    radius: 50,
                    lineWidth: 7.0,
                    percent: container.volume / 100,
                    center: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/bin.png",
                          width: 30,
                        ),
                        new Text(
                          "${container.volume}%",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    progressColor: Colors.blueAccent,
                  ),
                  SizedBox(height: 10),
                  CustomButton(text: "Add", onPressed: () {}),
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<ContainerBloc>(context).add(GetNearbyContainersEvent());
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("ID"),
            Text("Volume"),
          ],
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey.shade200,
      body:
          BlocBuilder<ContainerBloc, ContainerState>(builder: (context, state) {
        print(state.runtimeType);
        if (state is LoadingGetNearbyContainersState) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is LoadedGetNearbyContainersState) {
          final containers = state.containers;
          return ListView.builder(
            itemCount: containers.length,
            itemBuilder: (context, index) {
              final container = containers[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Center(
                    child: ListTile(
                      onTap: () => showDetailDialog(container, context),
                      leading: Image.asset(
                        "assets/images/bin.png",
                        width: 30,
                      ),
                      title: Text(
                        container.id,
                        style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold),
                      ),
                      trailing: CircularPercentIndicator(
                        radius: 20,
                        lineWidth: 4.0,
                        percent: container.volume / 100,
                        center: new Text("${container.volume}%"),
                        progressColor: Colors.blueAccent,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        } else if (state is ErrorGetNearbyContainersState) {
          return Center(
            child: Text(state.message),
          );
        } else {
          return Center(
            child: Text("No containers found"),
          );
        }
      }),
    );
  }
}
