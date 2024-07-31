import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:khata_app/data/database_helper_add_customers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khata_app/views/screens/user_khata_details.dart';
import 'package:khata_app/views/widgets/add_users_dialog_box.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<Map<String, dynamic>> _customers = [];

  Future<void> _fetchCustomers() async {
    List<Map<String, dynamic>> customers =
        await DatabaseHelper().getAllCustomers();
    setState(() {
      _customers = customers;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  // File? _selectedImage;
  bool isLoading = false;
  // Future<void> _selectImage() async {
  //   final pickedImage =
  //       await ImagePicker().pickImage(source: ImageSource.gallery);
  //   if (pickedImage != null) {
  //     setState(() {
  //       _selectedImage = File(pickedImage.path);
  //     });
  //   }
  // }

  Future<void> deleteAllCartItems() async {
    await DatabaseHelper().deleteAllUsers();
    _fetchCustomers();
    if (kDebugMode) {
      print("All Cart list after updating $_customers");
    }
  }

  // Future<Uint8List?> compressImage(File imageFile) async {
  //   try {
  //     final result = await FlutterImageCompress.compressWithFile(
  //       imageFile.path,
  //       quality: 50,
  //     );
  //     return result;
  //   } catch (e) {
  //     print("Error compressing image: $e");
  //     return null;
  //   }
  // }

 void _showAddDoctorDialog() {
  TextEditingController nameController = TextEditingController();
  TextEditingController cnicController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              "Add Customers",
              style: GoogleFonts.rubik(color: Color(0xff5B40A7)),
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 16),
                  TextField(
                      controller: nameController,
                      style: GoogleFonts.rubik(color: Colors.black),
                      decoration: InputDecoration(labelText: "Name")),
                  SizedBox(height: 8),
                  TextField(
                      controller: cnicController,
                      style: GoogleFonts.rubik(color: Colors.black),
                      decoration: InputDecoration(labelText: "CNIC")),
                  if (isLoading) SizedBox(height: 16),
                  if (isLoading) CircularProgressIndicator(),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
              InkWell(
                onTap: () async {
                  if (nameController.text.isEmpty || cnicController.text.isEmpty) {
                    // Show the toast message if any of the fields are empty
                    ScaffoldMessenger.of(context).showSnackBar(
                      
                      SnackBar(
                        backgroundColor: Color(0xff5B40A7),
                        content: Text('Both fields should be filled!'),
                      ),
                    );
                  } else {
                    setState(() {
                      isLoading = true;
                    });

                    var user = {
                      'name': nameController.text,
                      'cnic': cnicController.text,
                    };
                    await DatabaseHelper().saveCustomer(user);
                    _fetchCustomers();
                    setState(() {
                      isLoading = false;
                    });

                    Navigator.pop(context);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Color(0xff5B40A7),
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        "Add Customer",
                        style: GoogleFonts.rubik(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              )
            ],
          );
        },
      );
    },
  );
}


  // Uint8List? registrationImage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff5B40A7),
        title: Text(
          "Khata Entery",
          style: GoogleFonts.rubik(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
            onPressed: () async {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AddUsersDialogBox(
                      content2: "All Customers are deleted Successfully",
                      content: "Are you sure want to delete all Customers?",
                      title: "Delete Customers",
                      function: deleteAllCartItems,
                    );
                  });
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
            bottom: 16.0), // Adjust the bottom padding as needed
        child: FloatingActionButton(
          backgroundColor: Color(0xff5B40A7),
          onPressed: () {
            _showAddDoctorDialog();
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: _customers.isEmpty
            ? Center(
                child: Text(
                "No customers available.",
                style: GoogleFonts.rubik(color: Colors.black),
              ))
            : GridView.builder(
                padding: EdgeInsets.all(16.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                ),
                itemCount: _customers.length,
                itemBuilder: (context, index) {
                  final customer = _customers[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserKhataDetails(
                            customerId: customer["id"],
                            customerName: customer["name"],
                          ),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            // backgroundImage: FileImage(File(customer['image'])),
                            backgroundImage:
                                AssetImage("assets/images/users_logo.jpeg"),
                          ),
                          SizedBox(height: 8),
                          Flexible(
                            child: Text(
                              customer['name'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 4),
                          Flexible(
                            child: Text(
                              customer['cnic'],
                              style: GoogleFonts.rubik(color: Colors.black),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
