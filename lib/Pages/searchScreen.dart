import 'dart:async';
import 'dart:convert';
import 'package:find_a_mechanic/DataHandler/appData.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';


import '../AllWidgets/Divider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController ulTextEditingController = TextEditingController();
  var uuid = Uuid();
  String sessionToken = '122344';
  Timer? debounce;
  List<dynamic> _placesList = [];

  // late GooglePlace googlePlace;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    onChange();
  }

  void onChange() {
    if (sessionToken == null) {
      setState(() {
        sessionToken = uuid.v4();
      });
    }

    getSuggestion(ulTextEditingController.text);
  }

  void getSuggestion(String input) async {
    String API_KEY = 'AIzaSyA06urkWllGfrZwsKHSomPfZvYKhs8z7v0';

    // https://maps.googleapis.com/maps/api/place/autocomplete/json?input=Apple&key=AIzaSyAfPaXfRiAH_f8Pzm67-KTpw2S2u7W4AlQ&sessiontoken=122344


    try {
      String baseURL =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request =
          '$baseURL?input=$input&key=$API_KEY&sessiontoken=$sessionToken&components=country:pk';
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);
      print('data');
      print(data);
      if (response.statusCode == 200) {
        setState(() {
          _placesList = json.decode(response.body)['predictions'];
        });
      } else {
        throw Exception('Failed to load predictions');
      }
    } catch (e) {
      // toastMessage('success');
    }
  }

  @override
  Widget build(BuildContext context) {
    // String placeAddress= Provider.of<AppData>(context).userLocation!.placeName.toString() ?? "Where are You";
    return Scaffold(
        body: Column(
          children: [
          Container(
          height: 265.0,
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 6.0,
              spreadRadius: 0.5,
              offset: Offset(0.7, 0.7),
            ),
          ]),
          child: Padding(
            padding: EdgeInsets.only(
                left: 25.0, top: 25.0, right: 25.0, bottom: 20.0),
            child: Column(
              children: [
                SizedBox(height: 20.0),
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.arrow_back),
                    ),
                    Center(
                      child: Text(
                        "Set Location",
                        style: TextStyle(
                            fontSize: 18.0, fontFamily: "Brand-Bold"),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Row(
                  children: [
                    Image.asset(
                      "images/location.png",
                      height: 20.0,
                      width: 30.0,
                    ),
                    SizedBox(
                      width: 5.0,
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(0.0),
                          child: TextField(
                            controller: ulTextEditingController,
                            decoration: InputDecoration(
                              hintText: "search",
                              fillColor: Colors.grey[300],
                              filled: true,
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.only(
                                  left: 11.0, top: 8.0, bottom: 8.0),

                            ),
                            onChanged: (value) {
                              if (debounce?.isActive ?? false) {
                                debounce!.cancel();
                              }
                              debounce =
                                  Timer(const Duration(milliseconds: 1000), () {
                                    if (value.isNotEmpty) {
                                      onChange();
                                    }
                                    else {

                                    }
                                  }
                                  );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Row(
                  children: [
                    Icon(
                      Icons.home,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      width: 12.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          // Provider.of<AppData>(context)
                          //             .userLocation
                          //             .toString() !=
                          //         null
                          //     ? Provider.of<AppData>(context)
                          //         .userLocation
                          //         .placeName
                          //         .toString()
                          //     :
                          "Add Home",
                        ),
                        SizedBox(
                          height: 4.0,
                        ),
                        Text(
                          "Your living home address",
                          style: TextStyle(
                              color: Colors.black54, fontSize: 12.0),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 5.0,
                ),
                DividerWidget(),
                SizedBox(
                  height: 5.0,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.work,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      width: 12.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Add Work"),
                        SizedBox(
                          height: 4.0,
                        ),
                        Text(
                          "Your office address",
                          style: TextStyle(
                              color: Colors.black54, fontSize: 12.0),
                        ),
                      ],
                    ),
                  ],
                ),

              ],
            ),

          ),
        ),
        Expanded(child: ListView.separated(

            itemCount: _placesList.length,
            padding: EdgeInsets.all(0.0),
            separatorBuilder: (BuildContext context, int index)=>DividerWidget(),

            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                  onTap: () async {
                     List<Location> Locations = await locationFromAddress(
                    _placesList[index]['description']);

                       LatLng seaLocation = LatLng(Locations.last.latitude, Locations.last.longitude);
                       Navigator.pop(context, seaLocation);


                     print(Locations.last.longitude);
                     print(Locations.last.latitude);
              },
              title: Text(
              _placesList[index]['description']
              ),


        );
    }
    ))]
    ,
    )
    ,

    );
  }
}
