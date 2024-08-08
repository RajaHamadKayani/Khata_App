
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khata_app/data/database_helper_add_products.dart';
import 'package:khata_app/views/widgets/add_users_dialog_box.dart';

class UserKhataDetails extends StatefulWidget {
  final String customerName;
  final int customerId;

  const UserKhataDetails({
    Key? key,
    required this.customerName,
    required this.customerId,
  }) : super(key: key);

  @override
  State<UserKhataDetails> createState() => _UserKhataDetailsState();
}

class _UserKhataDetailsState extends State<UserKhataDetails> {
  double paidAmount = 0.0;

  TextEditingController amountController = TextEditingController();
  void _showEditTotalAmountDialog() {
    double updatedAmount = totalAmount;
    final TextEditingController amountController =
        TextEditingController(text: updatedAmount.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Edit Total Amount",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8, // Responsive width
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.stretch, // Make the column stretch
                children: [
                  Text(
                    "Current Total Amount: \$${totalAmount.toStringAsFixed(2)} PKR",
                    style: GoogleFonts.rubik(color: Colors.black54),
                  ),
                  SizedBox(height: 16), // Added spacing
                  TextField(
                    controller: amountController,
                    style: GoogleFonts.rubik(color: Colors.black),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: "Total Amount",
                      border: OutlineInputBorder(), // Added border
                    ),
                  ),
                  SizedBox(height: 16), // Added spacing
                  Wrap(
                    spacing: 8, // Spacing between buttons
                    runSpacing: 8, // Spacing between rows
                    alignment: WrapAlignment.center,
                    children: [
                      _buildArithmeticButton(
                          "+", amountController, (a, b) => a + b),
                      _buildArithmeticButton("-", amountController, (a, b) {
                        if (a - b < 0) {
                          // Handle negative values or show an error
                          return a; // Prevent negative amounts
                        }
                        paidAmount += b;
                        return a - b;
                      }),
                      _buildArithmeticButton(
                          "*", amountController, (a, b) => a * b),
                      _buildArithmeticButton(
                          "/", amountController, (a, b) => b != 0 ? a / b : a),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                setState(() {
                  totalAmount =
                      double.tryParse(amountController.text) ?? totalAmount;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildArithmeticButtonn(
      String operator,
      TextEditingController amountController,
      double Function(double a, double b) operation) {
    return ElevatedButton(
      onPressed: () {
        double currentAmount = double.tryParse(amountController.text) ?? 0.0;
        double adjustmentAmount = 10.0; // Example adjustment amount
        amountController.text =
            operation(currentAmount, adjustmentAmount).toStringAsFixed(2);
      },
      child: Text(operator),
    );
  }

  Widget _buildArithmeticButton(String symbol, TextEditingController controller,
      double Function(double, double) operation) {
    return ElevatedButton(
      onPressed: () {
        double currentValue = double.tryParse(controller.text) ?? 0.0;
        // Allow user to input the second value for arithmetic operation
        showDialog(
          context: context,
          builder: (BuildContext context) {
            TextEditingController inputController = TextEditingController();
            return AlertDialog(
              title: Text("Enter value for $symbol operation"),
              content: TextField(
                style: GoogleFonts.rubik(color: Colors.black),
                controller: inputController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: "Value"),
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    double inputValue =
                        double.tryParse(inputController.text) ?? 0.0;
                    if (inputValue != 0.0) {
                      double result = operation(currentValue, inputValue);
                      controller.text = result.toStringAsFixed(2);
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
      child: Text(symbol),
    );
  }

  List<Map<String, dynamic>> filteredProducts = [];
  TextEditingController searchController = TextEditingController();
  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterProducts();
  }

  void _filterProducts() {
    setState(() {
      filteredProducts = products.where((product) {
        return product['name']
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
      }).toList();
    });
  }

  double totalAmount = 0.0; // Variable to store total amount
  void _calculateTotalAmount() {
    totalAmount = products.fold(0.0, (sum, item) {
      double price = double.tryParse(item['price']) ?? 0.0;
      double quantity = double.tryParse(item['quantity']) ?? 1.0;
      return sum + (price * quantity);
    });
  }

  void _showDeleteProductDialog(int productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Product",
              style: GoogleFonts.rubik(color: const Color(0xff5B40A7))),
          content: const Text("Are you sure you want to delete this product?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await DatabaseHelperAddProducts().deleteProduct(productId);
                _fetchProductsInfo();
                Navigator.pop(context);
              },
              child: Text("Delete",
                  style: GoogleFonts.rubik(color: const Color(0xff5B40A7))),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateProductDialog(Map<String, dynamic> product) {
    TextEditingController productName =
        TextEditingController(text: product["name"]);
    TextEditingController productQuantity =
        TextEditingController(text: product["quantity"]);
    TextEditingController productPrice =
        TextEditingController(text: product["price"]);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Update Product",
                  style: GoogleFonts.rubik(color: const Color(0xff5B40A7))),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    TextField(
                      controller: productName,
                      style: GoogleFonts.rubik(color: Colors.black),
                      decoration:
                          const InputDecoration(labelText: "Product Name"),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: productQuantity,
                      style: GoogleFonts.rubik(color: Colors.black),
                      decoration:
                          const InputDecoration(labelText: "Product Quantity"),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: productPrice,
                      style: GoogleFonts.rubik(color: Colors.black),
                      decoration:
                          const InputDecoration(labelText: "Product Price"),
                    ),
                    if (isLoading) const SizedBox(height: 16),
                    if (isLoading) const CircularProgressIndicator(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    double? quantity = double.tryParse(productQuantity.text);
                    double? price = double.tryParse(productPrice.text);
                    if (quantity == null || price == null) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              "Invalid Input",
                              style: GoogleFonts.rubik(
                                  color: const Color(0xff5B40A7)),
                            ),
                            content: Text(
                              "Quantity and Price should be numeric values.",
                              style: GoogleFonts.rubik(color: Colors.black),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                      setState(() {
                        isLoading = false;
                      });
                    } else {
                      var updatedProduct = {
                        'name': productName.text,
                        'quantity': productQuantity.text,
                        'price': productPrice.text,
                        'customer_id': widget.customerId,
                      };

                      await DatabaseHelperAddProducts()
                          .updateProduct(product["id"], updatedProduct);
                      _fetchProductsInfo();
                      Navigator.pop(context);

                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  child: Text("Update",
                      style: GoogleFonts.rubik(color: const Color(0xff5B40A7))),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> products = [];

  void _fetchProductsInfo() async {
    List<Map<String, dynamic>> productsInfo = await DatabaseHelperAddProducts()
        .getProductsByCustomer(widget.customerId);
    setState(() {
      products = productsInfo;
      filteredProducts = products; // Initially display all products
      _calculateTotalAmount(); // Calculate total amount
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchProductsInfo();
    searchController.addListener(_onSearchChanged);
  }

  Future<void> deleteAllProducts() async {
    await DatabaseHelperAddProducts().deleteAllProducts();
    _fetchProductsInfo();
    if (kDebugMode) {
      print("All Cart list after updating $products");
    }
  }

  bool isLoading = false;

  void _showAddProductDialog() {
    TextEditingController productName = TextEditingController();
    TextEditingController productQuantity = TextEditingController();
    TextEditingController productPrice = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                "Add Product",
                style: GoogleFonts.rubik(color: const Color(0xff5B40A7)),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    TextField(
                        controller: productName,
                        style: GoogleFonts.rubik(color: Colors.black),
                        decoration:
                            const InputDecoration(labelText: "Product Name")),
                    const SizedBox(height: 8),
                    TextField(
                        controller: productQuantity,
                        style: GoogleFonts.rubik(color: Colors.black),
                        decoration: const InputDecoration(
                            labelText: "Product Quantity")),
                    const SizedBox(height: 8),
                    TextField(
                        controller: productPrice,
                        style: GoogleFonts.rubik(color: Colors.black),
                        decoration:
                            const InputDecoration(labelText: "Product Price")),
                    if (isLoading) const SizedBox(height: 16),
                    if (isLoading) const CircularProgressIndicator(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                InkWell(
                  onTap: () async {
                    setState(() {
                      isLoading = true;
                    });

                    String quantityText = productQuantity.text;
                    String priceText = productPrice.text;

                    // Validate if quantity and price are numeric
                    double? quantity = double.tryParse(quantityText);
                    double? price = double.tryParse(priceText);

                    if (quantity == null || price == null) {
                      // Show error dialog if the input is not valid
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              "Invalid Input",
                              style: GoogleFonts.rubik(
                                  color: const Color(0xff5B40A7)),
                            ),
                            content: Text(
                              "Quantity and Price should be numeric values.",
                              style: GoogleFonts.rubik(color: Colors.black),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                      setState(() {
                        isLoading = false;
                      });
                    } else {
                      var product = {
                        'name': productName.text,
                        'quantity': quantityText,
                        'price': priceText,
                        'customer_id': widget
                            .customerId, // Associate product with customer
                      };
                      await DatabaseHelperAddProducts().saveProduct(product);
                      _fetchProductsInfo();
                      Navigator.pop(context);

                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: const Color(0xff5B40A7),
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          "Add Product",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FloatingActionButton(
          backgroundColor: const Color(0xff5B40A7),
          onPressed: () {
            _showAddProductDialog();
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
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
                      content2: "All Products are deleted Successfully",
                      content: "Are you sure want to delete all Products?",
                      title: "Delete All Products",
                      function: deleteAllProducts,
                    );
                  });
            },
          ),
        ],
        backgroundColor: const Color(0xff5B40A7),
        title: Text(
          widget.customerName,
          style: GoogleFonts.rubik(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Color.fromARGB(246, 242, 243, 245),
              child: Container(
                  height: 80.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(17),
                    gradient: LinearGradient(colors: [
                      Color.fromARGB(76, 204, 217, 240),
                      Color.fromARGB(125, 201, 213, 233)
                    ]),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color.fromARGB(255, 250, 252, 253),
                        child: Icon(
                          Icons.wallet_membership_outlined,
                          color: Color.fromARGB(129, 24, 53, 0),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _showEditTotalAmountDialog,
                            child: Text(
                              "\$${totalAmount.toStringAsFixed(2)}", // Added dollar sign
                              style: GoogleFonts.rubik(
                                color: Colors.black,
                                fontWeight: FontWeight
                                    .w500, // Adjusted font weight for emphasis
                                fontSize:
                                    16, // Increased font size for better readability
                              ),
                            ),
                          ),
                          const SizedBox(
                              height:
                                  4), // Added spacing between amount and label
                          const Text(
                            "Total Amount",
                            style: TextStyle(
                              color: Color.fromARGB(255, 94, 109, 141),
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  14, // Adjusted font size for consistency
                            ),
                          ),
                        ],
                      ),
                      const CircleAvatar(
                        backgroundColor: Color.fromARGB(255, 250, 252, 253),
                        child: Icon(
                          Icons.monetization_on,
                          color: Color.fromARGB(129, 24, 53, 0),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "\$${paidAmount.toStringAsFixed(2)}", // Added dollar sign
                            style: TextStyle(
                              color: Color.fromARGB(255, 1, 109, 5),
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  16, // Increased font size for better readability
                            ),
                          ),
                          const SizedBox(
                              height:
                                  4), // Added spacing between amount and label
                          const Text(
                            "Paid Amount",
                            style: TextStyle(
                              color: Color.fromARGB(255, 94, 109, 141),
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  14, // Adjusted font size for consistency
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
            ),
            SizedBox(
              height: 10.h,
            ),
            TextField(
              controller: searchController,
              style: GoogleFonts.rubik(color: Colors.black),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(6),
                labelText: "Search Product",
                hintStyle: GoogleFonts.rubik(color: Colors.black),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                          131, 95, 226, 255), // Very low opacity
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          "S No",
                          style: TextStyle(color: Color.fromARGB(129, 0, 0, 0)),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 3,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                          131, 95, 226, 255), // Very low opacity
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Text("P-Name",
                            style:
                                TextStyle(color: Color.fromARGB(129, 0, 0, 0))),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 3,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                          131, 95, 226, 255), // Very low opacity
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Text("Quantity",
                            style:
                                TextStyle(color: Color.fromARGB(129, 0, 0, 0))),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 3,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                          131, 95, 226, 255), // Very low opacity
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Text("Price",
                            style:
                                TextStyle(color: Color.fromARGB(129, 0, 0, 0))),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: 3,
            ),
            filteredProducts.isEmpty
                ? Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "No products available for this customer.",
                        style: GoogleFonts.rubik(color: Colors.black),
                      ),
                    ],
                  ))
                : Expanded(
                    child: ListView.builder(
                        itemCount: filteredProducts.length,
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          double price =
                              double.tryParse(product["price"]) ?? 0.0;
                          double quantity =
                              double.tryParse(product["quantity"]) ?? 0.0;
                          double itemTotal = price * quantity;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _buildDetailBox(
                                          product["id"].toString(), 50),
                                      _buildDetailBox(product["name"], 100),
                                      _buildDetailBox(product["quantity"], 50),
                                      _buildDetailBox(product["price"], 100),
                                      _buildDetailBox(
                                          itemTotal.toStringAsFixed(2), 100),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () =>
                                            _showUpdateProductDialog(product),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Color(0xff5B40A7),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Center(
                                              child: Text("Update",
                                                  style: GoogleFonts.rubik(
                                                      color: Colors.white)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      GestureDetector(
                                        onTap: () => _showDeleteProductDialog(
                                            product["id"]),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Color(0xff5B40A7),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Center(
                                              child: Text("Delete",
                                                  style: GoogleFonts.rubik(
                                                      color: Colors.white)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        })),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

Widget _buildDetailBox(String content, double width) {
  return Container(
    width: width, // Set a fixed width for each box
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black),
      color: Colors.grey[300],
    ),
    child: Padding(
      padding: const EdgeInsets.all(2),
      child: Center(
        child: Text(
          content,
          style: GoogleFonts.rubik(color: Colors.black),
          overflow: TextOverflow.ellipsis, // Ensure text doesn't overflow
        ),
      ),
    ),
  );
}




//  GestureDetector(
//               onTap: _showEditTotalAmountDialog,
//               child: Text(
//                 "Total Amount: ${totalAmount.toStringAsFixed(2)} PKR",
//                 style: GoogleFonts.rubik(
//                   color: Colors.black,
//                   fontWeight: FontWeight.w300,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//             Text(
//               "Paid Amount: ${paidAmount.toStringAsFixed(2)} PKR",
//               style: GoogleFonts.rubik(
//                 color: Colors.black,
//                 fontWeight: FontWeight.w300,
//                 fontSize: 16,
//               ),
//             ),