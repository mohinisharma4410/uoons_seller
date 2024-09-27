import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductPage extends StatefulWidget {
  final String username;
  ProductPage({required this.username});
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String _currentTab = 'All';
  static const double padding = 20.0;
  static const double cardElevation = 4.0;
  static const double borderRadius = 15.0;
  static const double fontSizeHeader = 10.0;
  static const double fontSizeTableHeader = 15.0;
  static const double fontSizeTableContent = 12.0;
  static const String baseUrl = 'https://uoons.com';
  List<Map<String, dynamic>> _allProducts = [];
  String? _sellerId;

  @override
  void initState() {
    super.initState();
    _fetchSellerIdAndProductList();
  }

  Future<void> _fetchSellerIdAndProductList() async {
    await _fetchSellerId();
    if (_sellerId != null) {
      await _fetchProductList();
    }
  }

  Future<void> _fetchSellerId() async {
    var url = Uri.parse('https://uoons.com/seller/get-user?username=${widget.username}');

    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        setState(() {
          _sellerId = jsonResponse['data']['s_id'].toString();
        });
      } else {
        throw Exception('Failed to fetch seller ID');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _fetchProductList() async {
    var url = Uri.parse('https://uoons.com/seller/product-lists?seller_id=$_sellerId');

    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);

        setState(() {
          _allProducts = (jsonResponse['data'] as List<dynamic>).map((item) => {
            'pid': item['pid'],
            'slug': item['product_slug'],
            'image': item['product_images'] != null && item['product_images'].isNotEmpty
                ? '$baseUrl/${item['product_images']}'
                : 'assets/Boy.png',
            'name': item['product_name']?.toString() ?? '',
            'sku': item['product_sku']?.toString() ?? '',
            'price': item['product_price']?.toString() ?? '',
            'sale_price': item['product_sale_price']?.toString() ?? '',
            // Clean the HTML tags from the description here
            'description': _removeHtmlTags(item['product_description']?.toString() ?? ''),
            'shipping_charges': item['shipping_charges']?.toString() ?? '',
            'status': item['product_status'] == "1" ? "Active" : "Inactive",
          }).toList();
        });
      } else {
        print('Failed to load products. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching product list: $e');
    }
  }

  Future<Map<String, dynamic>> _fetchProductDetails(String slug) async {
    var url = Uri.parse('https://uoons.com/seller/fetch-single-product?slug=$slug&seller_id=$_sellerId');

    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        var productData = jsonResponse['data'];

        // Clean the HTML tags from the description here
        productData['product_description'] = _removeHtmlTags(productData['product_description'] ?? '');

        return productData;
      } else {
        throw Exception('Failed to fetch product details');
      }
    } catch (e) {
      print('Error: $e');
      return {};
    }
  }

  String _getProductImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return imageUrl.startsWith('http') ? imageUrl : '$baseUrl/$imageUrl';
    } else {
      return 'assets/Boy.png';
    }
  }

  void _showProductDetailsDialog(Map<String, dynamic> productDetails) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(productDetails['product_name']),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Image.network(
                  _getProductImage(productDetails['product_images']),
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.broken_image, size: 100);
                  },
                ),
                SizedBox(height: 10),
                Text(
                  'Rs. ${productDetails['product_sale_price']} /-',
                  style: TextStyle(fontSize: fontSizeTableContent, color: Colors.red, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Rs. ${productDetails['product_price']} /-',
                  style: TextStyle(
                    fontSize: fontSizeTableContent,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                Text('Description: ${productDetails['product_description']}'),
                Text('Shipping Charges: ${productDetails['shipping_charges']}'),
                Text('Status: ${productDetails['product_status'] == "1" ? "Active" : "Inactive"}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(padding),
                child: _buildProductList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      labelColor: Colors.blue,
      unselectedLabelColor: Colors.black,
      tabs: [
        Tab(text: 'All'),
        Tab(text: 'Active'),
      ],
      onTap: (index) {
        setState(() {
          _currentTab = index == 0 ? 'All' : 'Active';
        });
      },
    );
  }

  Widget _buildProductList() {
    List<Map<String, dynamic>> activeProducts = _allProducts.where((product) => product['status'] == 'Active').toList();
    List<Map<String, dynamic>> productsToDisplay = _currentTab == 'All' ? _allProducts : activeProducts;
    return ListView.builder(
      itemCount: productsToDisplay.length,
      itemBuilder: (context, index) {
        var product = productsToDisplay[index];
        return GestureDetector(
          onTap: () async {
            var productDetails = await _fetchProductDetails(product['slug']);
            _showProductDetailsDialog(productDetails);
          },
          child: Card(
            elevation: cardElevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Column(
                        children: [
                          Image.network(
                            _getProductImage(product['image']),
                            width: 85,
                            height: 85,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.broken_image, size: 55);
                            },
                          ),
                          SizedBox(height: 5),
                          Text('SKU - ${product['sku']}', style: TextStyle(fontSize: fontSizeTableContent)),
                        ],
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _truncateWithEllipsis(50, product['name']),
                          style: TextStyle(fontSize: fontSizeTableHeader, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Rs. ${product['sale_price']} /-',
                        style: TextStyle(fontSize: fontSizeTableContent, color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Rs. ${product['price']} /-',
                        style: TextStyle(
                          fontSize: fontSizeTableContent,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                  Text('Shipping Charges: ${product['shipping_charges']}', style: TextStyle(fontSize: fontSizeTableContent)),
                  Text('Status: ${product['status']}', style: TextStyle(fontSize: fontSizeTableContent)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // String _truncateWithEllipsis(int cutoff, String myString) {
  //   return (myString.length

        String _truncateWithEllipsis(int cutoff, String myString) {
    return (myString.length <= cutoff) ? myString : '${myString.substring(0, cutoff)}...';
  }
  String _removeHtmlTags(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: false);
    return htmlString.replaceAll(exp, '');
  }

}