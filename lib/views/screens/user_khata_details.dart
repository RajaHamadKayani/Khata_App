import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
              style: GoogleFonts.rubik(color: Color(0xff5B40A7))),
          content: Text("Are you sure you want to delete this product?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await DatabaseHelperAddProducts().deleteProduct(productId);
                _fetchProductsInfo();
                Navigator.pop(context);
              },
              child: Text("Delete",
                  style: GoogleFonts.rubik(color: Color(0xff5B40A7))),
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
                  style: GoogleFonts.rubik(color: Color(0xff5B40A7))),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 16),
                    TextField(
                      controller: productName,
                      style: GoogleFonts.rubik(color: Colors.black),
                      decoration: InputDecoration(labelText: "Product Name"),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: productQuantity,
                      style: GoogleFonts.rubik(color: Colors.black),
                      decoration:
                          InputDecoration(labelText: "Product Quantity"),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: productPrice,
                      style: GoogleFonts.rubik(color: Colors.black),
                      decoration: InputDecoration(labelText: "Product Price"),
                    ),
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
                TextButton(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });

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
                  },
                  child: Text("Update",
                      style: GoogleFonts.rubik(color: Color(0xff5B40A7))),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> products = [];

  Future<void> _fetchProductsInfo() async {
    List<Map<String, dynamic>> productsInfo = await DatabaseHelperAddProducts()
        .getProductsByCustomer(widget.customerId);
    setState(() {
      products = productsInfo;
            _calculateTotalAmount(); // Calculate total amount whenever products are fetched

    });
  }

  @override
  void initState() {
    super.initState();
    _fetchProductsInfo();
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
                style: GoogleFonts.rubik(color: Color(0xff5B40A7)),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 16),
                    TextField(
                        controller: productName,
                        style: GoogleFonts.rubik(color: Colors.black),
                        decoration: InputDecoration(labelText: "Product Name")),
                    SizedBox(height: 8),
                    TextField(
                        controller: productQuantity,
                        style: GoogleFonts.rubik(color: Colors.black),
                        decoration:
                            InputDecoration(labelText: "Product Quantity")),
                    SizedBox(height: 8),
                    TextField(
                        controller: productPrice,
                        style: GoogleFonts.rubik(color: Colors.black),
                        decoration:
                            InputDecoration(labelText: "Product Price")),
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
                    setState(() {
                      isLoading = true;
                    });

                    var product = {
                      'name': productName.text,
                      'quantity': productQuantity.text,
                      'price': productPrice.text,
                      'customer_id':
                          widget.customerId, // Associate product with customer
                    };
                    await DatabaseHelperAddProducts().saveProduct(product);
                    _fetchProductsInfo();
                    Navigator.pop(context);

                    setState(() {
                      isLoading = false;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Color(0xff5B40A7),
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: EdgeInsets.all(20),
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
          backgroundColor: Color(0xff5B40A7),
          onPressed: () {
            _showAddProductDialog();
          },
          child: Icon(
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
            icon: Icon(
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
        backgroundColor: Color(0xff5B40A7),
        title: Text(
          widget.customerName,
          style: GoogleFonts.rubik(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Color(0xff5FE2FF),
                        borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text("S No"),
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
                        color: Color(0xff5FE2FF),
                        borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text("P-Name"),
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
                        color: Color(0xff5FE2FF),
                        borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text("Quantity"),
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
                        color: Color(0xff5FE2FF),
                        borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text("Price"),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            products.isEmpty
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
                        itemCount: products.length,
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black),
                                          color: Colors.grey[300],
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(2),
                                          child: Center(
                                            child: Text(
                                              product["id"].toString(),
                                              style: GoogleFonts.rubik(
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black),
                                          color: Colors.grey[300],
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(2),
                                          child: Center(
                                            child: Text(
                                              product["name"],
                                              style: GoogleFonts.rubik(
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black),
                                          color: Colors.grey[300],
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(2),
                                          child: Center(
                                            child: Text(
                                              product["quantity"],
                                              style: GoogleFonts.rubik(
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black),
                                          color: Colors.grey[300],
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(2),
                                          child: Center(
                                            child: Text(
                                              product["price"],
                                              style: GoogleFonts.rubik(
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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
                                          decoration: BoxDecoration(
                                            color: Color(0xff5B40A7),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(4),
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
                                          decoration: BoxDecoration(
                                            color: Color(0xff5B40A7),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(4),
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
                           SizedBox(height: 10),
            Text(
              "Total Amount: ${totalAmount.toStringAsFixed(2)}pkr", // Display total amount
              style: GoogleFonts.rubik(
                color: Colors.black,
                fontWeight: FontWeight.w300,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
