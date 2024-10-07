import 'package:example/routes/routes.dart';
import 'package:flutter/material.dart';

class ExampleIndex extends StatelessWidget {
  ExampleIndex({super.key});

  final List<ListType> exampleList = [
    ListType(name: "double example", path: ExampleRoute.debounce),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView.separated(
        itemBuilder: (context, index) {
          ListType data = exampleList[index];
          return ListTile(
            onTap: () {
              Navigator.of(context).pushNamed(data.path);
            },
            title: Text(data.name),
          );
        },
        itemCount: exampleList.length,
        separatorBuilder: (BuildContext context, int index) {
          return Container(
            width: double.infinity,
            height: 1,
            color: Colors.black,
          );
        },
      ),
    );
  }
}

class ListType {
  String name;
  String path;
  ListType({required this.name, required this.path});
}
