import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'orderschangenotifier.dart';


class OrdersPage extends StatefulWidget {
  final String username;

  OrdersPage({required this.username});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String? sellerId;
  String currentTag = "ALL";
  int offset = 0;
  List<Order> orders = [];

  @override
  void initState() {
    super.initState();
    _fetchSellerId();
  }

  Future<void> _fetchSellerId() async {
    try {
      final response = await http.get(
        Uri.parse('https://uoons.com/seller/get-user?username=${widget.username}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          sellerId = data['data']['s_id'].toString();
        });
        _fetchOrders();
      } else {
        throw Exception('Failed to fetch seller ID');
      }
    } catch (e) {
      print('Error fetching seller ID: $e');
    }
  }

  Future<void> _fetchOrders({bool append = false}) async {
    if (sellerId == null) return;

    try {
      final response = await http.get(
        Uri.parse('https://uoons.com/seller/orders/all?seller_id=$sellerId&offset=$offset&tag=$currentTag'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['bundles'] != null) {
          final List<Order> fetchedOrders = (data['bundles'] as List)
              .expand((bundle) => (bundle['orders'] as List)
              .map((order) => Order.fromJson(order)))
              .toList();

          setState(() {
            if (append) {
              orders.addAll(fetchedOrders);
            } else {
              orders = fetchedOrders;
            }
          });
        } else {
          print('No bundles found in the response.');
        }
      } else {
        throw Exception('Failed to fetch orders');
      }
    } catch (e) {
      print('Error fetching orders: $e');
    }
  }

  void _onTagSelected(String tag) {
    setState(() {
      currentTag = tag;
      offset = 0;
    });
    _fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    final ordersProvider = Provider.of<OrdersProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                'Order Categories',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            _buildDrawerItem('ALL', Icons.list),
            _buildDrawerItem('PENDING', Icons.pending),
            _buildDrawerItem('CONFIRM', Icons.check_circle),
            _buildDrawerItem('READY', Icons.local_shipping),
            _buildDrawerItem('SHIPPED', Icons.local_shipping_outlined),
            _buildDrawerItem('CANCELLED', Icons.cancel),
            _buildDrawerItem('DELIVERED', Icons.delivery_dining),
          ],
        ),
      ),
      body: _buildOrderList(),
    );
  }

  Widget _buildDrawerItem(String tag, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(tag),
      onTap: () {
        Navigator.pop(context); // close the drawer
        _onTagSelected(tag);
      },
    );
  }

  Widget _buildOrderList() {
    if (orders.isEmpty) {
      return Center(child: Text('No orders found.'));
    }

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(orders[index], context);
      },
    );
  }

  Widget _buildOrderCard(Order order, BuildContext context) {
    final baseUrl = "https://uoons.com/";

    return InkWell(
      onTap: () => _showOrderDetailsDialog(context, order),
      child: Card(
        elevation: 5,
        margin: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Image.network(
                    '$baseUrl${order.product.productImages}',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 5),
                  Text(
                    'SKU: ${order.product.productSku}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Price: ₹${order.amount}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
                  ),
                ],
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.product.productName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Order ID: ${order.bundleId}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Status: ${_getStatusText(order.status)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetailsDialog(BuildContext context, Order order) {
    final baseUrl = "https://uoons.com/";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
            Container(
              padding: EdgeInsets.only(top: 16),
              margin: EdgeInsets.only(top: 30), // Adjust margin to push the dialog down
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Image.network(
                          '$baseUrl${order.product.productImages}',
                          width: double.infinity,
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 10),
                        Text(
                          order.product.productName,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Total: ₹${order.amount}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'SKU: ${order.product.productSku}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case "0":
        return "PENDING";
      case "1":
        return "CONFIRM";
      case "2":
        return "READY";
      case "3":
        return "SHIPPED";
      case "4":
        return "DELIVERED";
      case "5":
        return "CANCELLED";
      default:
        return "UNKNOWN";
    }
  }
}

class Order {
  final String bundleId;
  final String createdAt;
  final String amount;
  final String status;
  final Product product;

  Order({
    required this.bundleId,
    required this.createdAt,
    required this.amount,
    required this.status,
    required this.product,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      bundleId: json['bundleid'],
      createdAt: json['created_at'],
      amount: json['amount'],
      status: json['status'],
      product: Product.fromJson(json['product']),
    );
  }
}

class Product {
  final String productName;
  final String productSku;
  final String productImages;

  Product({
    required this.productName,
    required this.productSku,
    required this.productImages,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productName: json['product_name'],
      productSku: json['product_sku'],
      productImages: json['product_images'],
    );
  }
}
