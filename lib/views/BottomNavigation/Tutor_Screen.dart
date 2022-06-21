import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mytutor2/model/subject.dart';
import 'package:mytutor2/model/tutor.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../constant.dart';

class TutorScreen extends StatefulWidget {
  const TutorScreen({Key? key}) : super(key: key);

  @override
  State<TutorScreen> createState() => TutorScreenState();
}

class TutorScreenState extends State<TutorScreen> {
  List<Subject> subjectlist = <Subject>[];
  List<Tutor> tutorlist = <Tutor>[];
  String titlecenter = "Loading...";
  var numofpage, curpage = 1;
  final df = DateFormat('dd/MM/yyyy hh:mm a');
  late double screenHeight, screenWidth, resWidth;
  String search = "";
  var color;

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTutors(1, search);
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 600) {
      resWidth = screenWidth;
      //rowcount = 2;
    } else {
      resWidth = screenWidth * 0.75;
      //rowcount = 3;
    }
    return Scaffold(
      body: tutorlist.isEmpty
          ? Center(
              child: Text(titlecenter,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)))
          : Column(children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text("Tutor Available",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                  child: GridView.count(
                      crossAxisCount: 2,
                      children: List.generate(tutorlist.length, (index) {
                        return InkWell(
                            splashColor: Colors.black,
                            onTap: () => {loadTutorDetials(index)},
                            onLongPress: () => {},
                            child: Card(
                              child: Column(children: [
                                Flexible(
                                  flex: 6,
                                  child: CachedNetworkImage(
                                    imageUrl: CONSTANTS.server +
                                        "/Mobile/assets/tutors/" +
                                        tutorlist[index].tutorId.toString() +
                                        '.jpg',
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error_outline),
                                  ),
                                ),
                                Flexible(
                                    flex: 4,
                                    child: Column(
                                      children: [
                                        Text(tutorlist[index]
                                            .tutorName
                                            .toString())
                                      ],
                                    ))
                              ]),
                            ));
                      }))),
              SizedBox(
                height: 30,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: numofpage,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    if ((curpage - 1) == index) {
                      color = Colors.blueGrey;
                    } else {
                      color = Colors.black;
                    }
                    return SizedBox(
                      width: 40,
                      child: TextButton(
                          onPressed: () => {_loadTutors(index + 1, search)},
                          child: Text(
                            (index + 1).toString(),
                            style: TextStyle(color: color),
                          )),
                    );
                  },
                ),
              ),
            ]),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search),
        tooltip: 'Search',
        onPressed: () {
          _loadSearchDialog();
        },
      ),
    );
  }

  void _loadTutors(int pageno, String search) {
    curpage = pageno;
    numofpage ?? 1;
    http.post(Uri.parse(CONSTANTS.server + "/Mobile/php/load_tutor.php/"),
        body: {
          'pageno': pageno.toString(),
          'search': search,
        }).timeout(const Duration(seconds: 5), onTimeout: () {
      return http.Response('Error', 408);
    }).then((response) {
      var jsondata = jsonDecode(response.body);

      print(jsondata);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        var extractdata = jsondata['data'];
        numofpage = int.parse(jsondata['numofpage']);

        if (extractdata['tutor'] != null) {
          tutorlist = <Tutor>[];
          extractdata['tutor'].forEach((v) {
            tutorlist.add(Tutor.fromJson(v));
          });
          titlecenter = tutorlist.length.toString() + " Tutor Available";
        } else {
          titlecenter = "No Tutor Available";
          tutorlist.clear();
        }
        setState(() {});
      }
    });
  }

  void _loadSearchDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, StateSetter setState) {
              return AlertDialog(
                title: const Text(
                  "Search ",
                ),
                content: SizedBox(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                            labelText: 'Search',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      search = searchController.text;
                      Navigator.of(context).pop();
                      _loadTutors(1, search);
                    },
                    child: const Text("Search"),
                  )
                ],
              );
            },
          );
        });
  }

  void loadTutorDetials(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            title: const Text("Tutor Details",
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
                child: Column(
              children: [
                CachedNetworkImage(
                  imageUrl: CONSTANTS.server +
                      "/Mobile/assets/tutors/" +
                      tutorlist[index].tutorId.toString() +
                      '.jpg',
                  fit: BoxFit.cover,
                  width: resWidth,
                  placeholder: (context, url) =>
                      const LinearProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                Text(
                  tutorlist[index].tutorName.toString(),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                      "Tutor Email: " + tutorlist[index].tutorEmail.toString()),
                  Text("Tutor Phone:  " +
                      (tutorlist[index].tutorPhone.toString())),
                  Text("Date Register: " +
                      df.format(DateTime.parse(
                          tutorlist[index].tutorDatereg.toString()))),
                  Text("Subject Taken: "),
                  //subjectlist[index].tutorId.toString()),
                ])
              ],
            )),
            actions: [
              TextButton(
                child: const Text(
                  "Close",
                  style: TextStyle(),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
