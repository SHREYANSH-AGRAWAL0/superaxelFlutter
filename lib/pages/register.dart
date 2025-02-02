import 'dart:developer';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loginuicolors/models/statesDecode.dart';
import 'package:loginuicolors/services/garagesService.dart';
import 'package:loginuicolors/utils/Globals.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';

class MyRegister extends StatefulWidget {
  const MyRegister({Key? key}) : super(key: key);

  @override
  _MyRegisterState createState() => _MyRegisterState();
}

class _MyRegisterState extends State<MyRegister> {
  TextEditingController _garageName = TextEditingController();
  TextEditingController _mobNumber = TextEditingController();
  TextEditingController _city = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _address = TextEditingController();
  final _signUpKey = GlobalKey<FormState>();

  File _image = File('');
  // late String lat, long;
  double lat = 0;
  double long = 0;
  bool imageloaded = false;
  bool location = false;
  String? dropDownValue;
  bool isLocation = false;

  // locator
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
  bool loadLocation = false;

  String address = '';

  signUp(BuildContext context) async {
    await GaragesService.signUp(_image, _garageName.text, dropDownValue.toString(), _city.text, _address.text,
        _mobNumber.text, lat.toString(), long.toString(), _password.text, context);
  }

  addImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null) {
        setState(() {
          _image = File(result.files.single.path.toString());
          imageloaded = true;
        });
      }
    } catch (error) {
      log(error.toString());
    }
  }

  Future<void> checkGps() async {
    loadLocation = true;
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if (servicestatus) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
        } else if (permission == LocationPermission.deniedForever) {
          debugPrint("'Location permissions are permanently denied");
        } else {
          haspermission = true;
        }
      } else {
        haspermission = true;
      }

      if (haspermission) {
        setState(() {
          //refresh the UI
        });

        await getLocation();
      }
    } else {
      print("GPS Service is not enabled, turn on GPS location");
    }

    setState(() {
      //refresh the UI
    });
  }

  Future<void> getLocation() async {
    position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    debugPrint(position.longitude.toString());
    debugPrint(position.latitude.toString());

    long = position.longitude;
    lat = position.latitude;

    setState(() {
      //refresh UI
      loadLocation = false;
    });
  }

  Future<Position> _getCurrentLocation(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Turn on location\n")));
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    // Assuming the first result is accurate

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark placemark = placemarks[0]; // Assuming the first result is accurate

      String? state = placemark.administrativeArea;
      String? city = placemark.locality;

      log(state.toString());
      log(city.toString());
    } catch (error) {
      log(error.toString());
    }
    return position;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: isLocation
            ? OpenStreetMapSearchAndPick(
                center: LatLong(lat, long),
                onPicked: (pickedData) {
                  debugPrint("${pickedData.toString()}");
                  setState(() {
                    lat = pickedData.latLong.latitude;
                    long = pickedData.latLong.longitude;
                    address = pickedData.addressName;
                    log(pickedData.latLong.latitude.toString());
                    log(pickedData.latLong.longitude.toString());
                    // log(pickedData.address);
                    isLocation = false;
                  });
                },
                buttonText: "Pick Location",
              )
            : CustomPaint(
                painter: BlackRedPainter(),
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 35, top: 30),
                      child: Text(
                        'Create\nAccount',
                        style: TextStyle(color: Colors.white, fontSize: 33),
                      ),
                    ),
                    SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.28),
                        child: Form(
                          key: _signUpKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 35, right: 35),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 30,
                                    ),
                                    imageloaded
                                        ? GestureDetector(
                                            onTap: () => addImage(),
                                            child: Container(
                                                padding: const EdgeInsets.all(2),
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(125),
                                                    border: Border.all(color: Colors.red, width: 2)),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(125),
                                                  child: Image.file(
                                                    _image,
                                                    fit: BoxFit.cover,
                                                    height: 250,
                                                    width: 250,
                                                  ),
                                                )),
                                          )
                                        : DottedBorder(
                                            borderType: BorderType.Circle,
                                            radius: const Radius.circular(10),
                                            color: Colors.white,
                                            strokeCap: StrokeCap.round,
                                            dashPattern: const [10, 4],
                                            child: GestureDetector(
                                              onTap: () => addImage(),
                                              child: Container(
                                                height: 250,
                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                                                width: 250,
                                                child: Center(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: const [
                                                      Icon(
                                                        Icons.add_a_photo_outlined,
                                                        color: Colors.white,
                                                      ),
                                                      Text(
                                                        "Add Image",
                                                        style: TextStyle(color: Colors.white),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    TextFormField(
                                      controller: _garageName,
                                      style: TextStyle(color: Colors.black),
                                      decoration: InputDecoration(
                                          fillColor: Colors.grey.shade100,
                                          filled: true,
                                          hintText: "Garage Name",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          )),
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    TextFormField(
                                      controller: _mobNumber,
                                      style: TextStyle(color: Colors.black),
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                          fillColor: Colors.grey.shade100,
                                          filled: true,
                                          hintText: "Mobile Number",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          )),
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    TextFormField(
                                      controller: _password,
                                      style: TextStyle(color: Colors.black),
                                      decoration: InputDecoration(
                                          fillColor: Colors.grey.shade100,
                                          filled: true,
                                          hintText: "Password",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          )),
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    TextFormField(
                                      controller: _city,
                                      style: TextStyle(color: Colors.black),
                                      decoration: InputDecoration(
                                          fillColor: Colors.grey.shade100,
                                          filled: true,
                                          hintText: "City",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          )),
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    DropdownButtonFormField(
                                      items: [
                                        for (StateDecode state in Globals.allStates)
                                          DropdownMenuItem(value: state.state, child: Text("${state.state}"))
                                      ],
                                      decoration: InputDecoration(
                                          fillColor: Colors.grey.shade100,
                                          filled: true,
                                          hintText: "Select State",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          )),
                                      onChanged: (value) {
                                        dropDownValue = value.toString();
                                      },
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    TextFormField(
                                      controller: _address,
                                      style: TextStyle(color: Colors.black),
                                      decoration: InputDecoration(
                                          fillColor: Colors.grey.shade100,
                                          filled: true,
                                          hintText: "Address",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          )),
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    loadLocation
                                        ? Center(
                                            child: CircularProgressIndicator.adaptive(),
                                          )
                                        : GestureDetector(
                                            onTap: () async {
                                              await checkGps();
                                              setState(() {
                                                isLocation = true;
                                              });

                                              // _getCurrentLocation(context).then((value) {
                                              //     lat = '${value.latitude}';

                                              //     long = '${value.longitude}';
                                              //     log(lat);
                                              //     log(long);
                                              //     location = true;
                                              //     setState(() {});
                                              //   });
                                            },
                                            child: Container(
                                              child: Center(
                                                  child: Text(
                                                "Pick Location",
                                                style: TextStyle(fontSize: 18),
                                              )),
                                              height: 65,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all()),
                                            )),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      width: 300,
                                      child: Text(
                                        style: TextStyle(fontSize: 16, color: Colors.white),
                                        address,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      height: 40,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Sign Up',
                                          style:
                                              TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w700),
                                        ),
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Color(0xff4c505b),
                                          child: IconButton(
                                              color: Colors.white,
                                              onPressed: () => signUp(context),
                                              icon: Icon(
                                                Icons.arrow_forward,
                                              )),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 40,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextButton(
                                          onPressed: () => Navigator.pushReplacementNamed(context, 'login'),
                                          child: Text(
                                            'Sign In',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                decoration: TextDecoration.underline,
                                                color: Colors.white,
                                                fontSize: 18),
                                          ),
                                          style: ButtonStyle(),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class BlackRedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final height = size.height;
    final width = size.width;
    Paint paint = Paint();

    Path mainBackground = Path();
    mainBackground.addRect(Rect.fromLTRB(0, 0, width, height));
    paint.color = Color.fromARGB(255, 0, 0, 0);
    canvas.drawPath(mainBackground, paint);

    Path ovalPath = Path();
    ovalPath.moveTo(0, height * 0.2);
    ovalPath.quadraticBezierTo(width * 0.45, height * 0.25, width * 0.5, height * 0.5);

    ovalPath.quadraticBezierTo(width * 0.6, height * 0.8, width * 0.1, height);
    ovalPath.lineTo(0, height);
    ovalPath.close();
    paint.color = Color.fromARGB(255, 184, 0, 0);
    canvas.drawPath(ovalPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
