import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_api/models/weather_model.dart';
import 'package:weather_api/services/client_service.dart';
import 'package:weather_api/widgets/blur_container.dart';

import '../constants/address.dart';
import '../constants/geocode.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// properties
  bool isLoading = false;
  late WeatherModel weather;
  late double lat;
  late double lon;
  Address address = Address();

  /// methods

  @override
  void initState() {
    super.initState();
    checkPermission().then((value) async {
      await fetchWeather();
    });
  }

  // check permission
  Future<void> checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
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
    Position userPosition = await Geolocator.getCurrentPosition();
    lat = userPosition.latitude;
    lon = userPosition.longitude;
  }

  // fetch data

  Future<void> fetchWeather() async {
    isLoading = false;
    setState(() {});
    String? str = await ClientService.get(api: ClientService.apiGetWeather, param: {
      "lat": lat.toString(),
      "lon": lon.toString(),
    });
    if (str != null) {
      weather = weatherModelFromJson(str);
      await reverse();
      setState(() {
        isLoading = true;
      });
    }
  }

  TextStyle textStyle = const TextStyle(
    fontSize: 20,
    color: Colors.white,
    fontWeight: FontWeight.w300,
  );

  Future<void> reverse()async{
    address = await GeoCode().reverseGeocoding(latitude: lat, longitude: lon);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration:
            const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/bcg.png"), fit: BoxFit.cover)),
        child: Center(
          child: isLoading
              ? BlurContainer(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.45,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0x9963c9c9),
                      borderRadius: BorderRadius.circular(39),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40,),
                        Text("${address.countryName.toString()}, ${address.city.toString()}, ${address.streetAddress.toString()}",
                          style: textStyle,),
                        const SizedBox(height: 20,),
                        Text("Harorat: ${weather.temp.toString()}",
                          style: textStyle,),
                        const Spacer(),
                        // Text(
                        //   "Harorat: ${weather.temp}",
                        //   style: textStyle,
                        // ),
                        // Text(
                        //   "Namlik: ${weather.humidity}",
                        //   style: textStyle,
                        // ),
                        // Text(
                        //   "Sezilmoqda: ${weather.feelsLike}",
                        //   style: textStyle,
                        // ),
                        // Text(
                        //   "Shamol tezligi: ${weather.windSpeed}",
                        //   style: textStyle,
                        // ),
                        // Text(
                        //   "Bulutlik darajasi: ${weather.cloudPct}%",
                        //   style: textStyle,
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            sameContainer(
                              name: "Highest",
                              degree: weather.maxTemp.toString(),
                            ),
                            const Spacer(),
                            sameContainer(
                              name: "Lowest",
                              degree: weather.minTemp.toString(),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}


Widget sameContainer({required String name, required String degree}){
  return Container(
    alignment: Alignment.center,
    height: 74,
    width: 132,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      color: const Color(0xa316c9c9),
    ),
    child: Text("$name\n   $degree C", style: const TextStyle(
      fontSize: 22,
      color: Colors.white,
      fontWeight: FontWeight.w700
    ),),
  );
}