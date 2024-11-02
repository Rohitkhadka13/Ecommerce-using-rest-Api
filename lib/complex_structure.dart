import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http_test1/products_details.dart';
import 'package:http_test1/products_model.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:http/http.dart' as http;

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

Future<List<ProductsModel>> fetchApi() async {
  final response = await http.get(Uri.parse("https://fakestoreapi.com/products"));

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body) as List;
    return data.map((json) => ProductsModel.fromJson(json)).toList();
  } else {
    throw Exception("Fetch failed");
  }
}

class _TestScreenState extends State<TestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: "Product Showcase".text.bold.xl.make(),
        centerTitle: true,
      ),
      body: FutureBuilder<List<ProductsModel>>(
        future: fetchApi(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: "Error: ${snapshot.error}".text.red500.bold.make(),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: "No products available".text.gray500.make(),
            );
          } else {
            var products = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.6,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                var product = products[index];
                return GestureDetector(
                  onTap: (){
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context)=> ProductsDetails(product: product)));
                  },
                  
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                  
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              product.category ?? "Unknown",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.image ?? "",
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            product.title ?? "No title",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          "\$${product.price?.toStringAsFixed(2) ?? "0.00"}"
                              .text
                              .color(Colors.green)
                              .bold
                              .xl
                              .make(),
                          const SizedBox(height: 6),
                          Flexible(
                            child: Text(
                              product.description ?? "No description",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              "${product.rating?.rate ?? 0.0}"
                                  .text
                                  .bold
                                  .make(),
                              " (${product.rating?.count ?? 0} ratings)"
                                  .text
                                  .sm
                                  .gray500
                                  .make(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );

              },
            );
          }
        },
      ),
    );
  }
}
