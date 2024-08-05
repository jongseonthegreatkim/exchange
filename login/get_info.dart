import 'package:exchange/login/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // To save username, university in firestore.

import '../main.dart';
import '../statics.dart';
import 'nation_select.dart';

class GetInfo extends StatefulWidget {
  final User user; // Pass the Firebase user to this screen

  GetInfo({super.key, required this.user});

  @override
  State<GetInfo> createState() => _GetInfoState();
}

class _GetInfoState extends State<GetInfo> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _universityController = TextEditingController();

  Future<void> _saveUserInfoToFirestore(String username, String university) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    await users.doc(widget.user.uid).set({
      'uid' : widget.user.uid,
      'email' : widget.user.email,
      'university' : university,
      'username' : username,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: _body(context),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      scrolledUnderElevation: 0,
      leading: IconButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Login(),
            ),
          );
        },
        icon: Icon(Icons.arrow_back),
      ),
    );
  }

  Widget _body(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.all(15),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                // username 적는 필드
                TextFormField(
                  controller: _usernameController,
                  onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                  decoration: InputDecoration(
                    hintText: "아이디를 입력해주세요",
                    isDense: true,
                    border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.keyColor)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "아이디는 입력 해주셔야 해요ㅜ";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                UniversityDropdown(controller: _universityController), // university 선택하는 필드
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final username = _usernameController.text;
                  final university = _universityController.text;

                  // Save the user information to Firestore
                  await _saveUserInfoToFirestore(username, university);

                  // 교환희망 국가 선택하는 페이지로 보내기
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                      NationSelect(
                        username: username,
                        university: university,
                        from: 'get_info',
                      ),
                    ),
                  );
                }
              },
              child: Text("가입하기"),
              style: ButtonStyle(
                padding: WidgetStateProperty.resolveWith((states) {
                  return EdgeInsets.symmetric(horizontal: 15);
                }),
                // foregroundColor = TextStyle(color), overlayColor = color when overlayed
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  return Colors.black.withOpacity(0.8);
                }),
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  return AppColors.white;
                }),
                overlayColor: WidgetStateProperty.resolveWith((states) {
                  return Colors.grey.withOpacity(0.1);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<List<String>> fetchUniversityKeys() async {

  final DocumentSnapshot doc = await FirebaseFirestore.instance.collection('universities').doc('names of universities').get();
  final data = doc.data() as Map<String, dynamic>; // String: field name, dynamic: field value (all type possible)

  return data.keys.cast<String>().toList();
}

class UniversityDropdown extends StatefulWidget {
  final TextEditingController controller;

  UniversityDropdown({super.key, required this.controller});

  @override
  State<UniversityDropdown> createState() => _UniversityDropdownState();
}

class _UniversityDropdownState extends State<UniversityDropdown> {
  List<String> universityNames = [];
  List<String> filteredUniversityNames = [];
  bool isLoading = true;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchUniversities();
    _focusNode.addListener(() {
      setState(() {}); // trigget to rebuild when the focus state changes
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchUniversities() async {
    try {
      List<String> names = await fetchUniversityKeys();
      setState(() {
        universityNames = names;
        filteredUniversityNames = names; // Initially, all names are shown
        isLoading = false;
      });
    } catch (e) {
      print('Error" $e');
      // Handle any errors here
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterUniversities(String query) {
    setState(() {
      filteredUniversityNames = universityNames
          .where((university) => university.contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: widget.controller, // _universityController
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: "재학 중인 대학교를 선택해주세요",
            isDense: true,
            border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.keyColor)),
          ),
          onChanged: _filterUniversities, // Filter as the user types (=something changes in TextFormField)
          onTap: () {
            // When the field is tapped -> Give focus -> Show the drop-down menu
            setState(() {
              _focusNode.requestFocus(); // Ensure the drop-down shows up
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "재학 중인 대학교는 입력 해주셔야 해요ㅜ";
            }
            if(!universityNames.contains(value)) {
              return "재학 중인 대학교는 입력 해주셔야 해요ㅜ";
            }
            return null;
          },
        ),
        if (_focusNode.hasFocus && !isLoading && filteredUniversityNames.isNotEmpty)...[
          Container(
            margin: EdgeInsets.only(top: 10),
            constraints: BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredUniversityNames.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredUniversityNames[index]),
                  visualDensity: VisualDensity(vertical: -3),
                  contentPadding: EdgeInsets.only(left: 10),
                  onTap: () {
                    widget.controller.text = filteredUniversityNames[index];
                    _focusNode.unfocus(); // Dismiss the drop-down
                  },
                );
              },
            ),
          ),
        ],
        if (isLoading)...[
          Center(child: CircularProgressIndicator(
            color: AppColors.keyColor,
            backgroundColor: AppColors.white,
          )),
        ]
      ],
    );
  }
}