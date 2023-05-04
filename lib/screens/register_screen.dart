import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  Map<String, String> regions = {};
  Map<String, String> provinces = {};
  bool isRegionsLoaded = false;
  bool isProvincesLoaded = false;
  TextEditingController _provinceController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();

  Future<void> callAPI() async {
    //https://psgc.gitlab.io/api/island-groups/
    var url = Uri.https('psgc.gitlab.io', 'api/island-groups/');
    var response = await http.get(url);
    print(response.body);
    // print(response.statusCode);
    //json -> decode -> map
    List decodedResponse = jsonDecode(response.body);
    decodedResponse.forEach((element) {
      Map item = element;
      print(item['name']);
    });
  }

  Future<void> loadRegions() async {
    var url = Uri.https('psgc.gitlab.io', 'api/regions/');
    var response = await http.get(url);
    List decodedResponse = jsonDecode(response.body);
    print(decodedResponse);
    decodedResponse.forEach((element) {
      // print(element['regionName']);
      //map key: value -> code : regionName
      regions.addAll({element['code']: element['regionName']});
    });
    print(regions);
    setState(() {
      isRegionsLoaded = true;
    });
  }

  Future<void> loadProvinces(String regionCode) async {
    //https://psgc.gitlab.io/api/regions/010000000/provinces/
    var url = Uri.https('psgc.gitlab.io', 'api/regions/$regionCode/provinces/');
    var response = await http.get(url);
    // print(response.body);
    List decodedResponse = jsonDecode(response.body);
    provinces.clear();
    decodedResponse.forEach((element) {
      provinces.addAll({element['code']: element['name']});
    });
    print(provinces);
    setState(() {
      isProvincesLoaded = true;
    });
  }

  Future<void> register() async {
    var url = Uri.parse('http://132.168.13.238/flutter_3a_php/register.php');
    var response = await http.post(url, body: {
      'username': _usernameController.text,
      'province': _provinceController.text
    });
    Map decodedResponse = jsonDecode(response.body);
    print(decodedResponse['message']);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadRegions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 12,
          ),
          if (isRegionsLoaded)
            DropdownMenu(
              label: const Text('Region'),
              width: MediaQuery.of(context).size.width,
              // enableFilter: true,
              enableSearch: true,
              dropdownMenuEntries: regions.entries.map((item) {
                //convert into DropdownMenuEntry
                return DropdownMenuEntry(value: item.key, label: item.value);
              }).toList(),
              onSelected: (value) {
                print(value);
                setState(() {
                  isProvincesLoaded = false;
                });
                loadProvinces(value!);
              },
            )
          else
            Center(child: CircularProgressIndicator()),
          const SizedBox(
            height: 12,
          ),
          if (isProvincesLoaded)
            DropdownMenu(
              controller: _provinceController,
              label: const Text('Provinces'),
              width: MediaQuery.of(context).size.width,
              // enableFilter: true,
              enableSearch: true,
              dropdownMenuEntries: provinces.entries.map((item) {
                //convert into DropdownMenuEntry
                return DropdownMenuEntry(value: item.key, label: item.value);
              }).toList(),
              onSelected: (value) {
                print(value);
                // loadProvinces(value!);
              },
            ),
          TextField(
            controller: _usernameController,
          ),
          ElevatedButton(
            onPressed: register,
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }
}
