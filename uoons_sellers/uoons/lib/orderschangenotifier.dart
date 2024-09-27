import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'orderspage.dart';

class OrdersProvider with ChangeNotifier {
  String? sellerId;
  List<Order> orders = [];
  String currentTag = "ALL";
  int offset = 0;

  Future<void> fetchSellerId(String username) async {
    try {
      final response = await http.get(
        Uri.parse('https://uoons.com/seller/get-user?username=$username'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        sellerId = data['data']['s_id'].toString();
        fetchOrders();
        notifyListeners();
      } else {
        throw Exception('Failed to fetch seller ID');
      }
    } catch (e) {
      print('Error fetching seller ID: $e');
    }
  }

  Future<void> fetchOrders({bool append = false}) async {
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

          if (append) {
            orders.addAll(fetchedOrders);
          } else {
            orders = fetchedOrders;
          }
          notifyListeners();
        } else {
          print('No bundles found in the response.');
        }
      } else {
        print('Failed to fetch orders, status code: ${response.statusCode}');
        throw Exception('Failed to fetch orders');
      }
    } catch (e) {
      print('Error fetching orders: $e');
    }
  }

  void updateTag(String tag) {
    currentTag = tag;
    offset = 0;
    fetchOrders();
  }
}
