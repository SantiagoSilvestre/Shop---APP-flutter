import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/exceptions/http_exception.dart';
import 'package:shop/models/product.dart';
import 'package:shop/utils/constants.dart';

class ProductList with ChangeNotifier {
  List<Product> itemsGlobal = [];
  final String token;
  final String userId;

  ProductList({this.token = '', this.itemsGlobal = const [], this.userId = ''});

  List<Product> get items => [...itemsGlobal];

  int get itemsCount => itemsGlobal.length;

  Future<void> loadProducts() async {
    itemsGlobal.clear();
    final response = await http
        .get(Uri.parse("${Constants.PRODUCT_BASE_URL}.json?auth=$token"));
    if (response.body == 'null') return;

    final favResponse = await http.get(
      Uri.parse("${Constants.USER_FAVORITES_URL}/$userId.json?auth=$token"),
    );

    Map<String, dynamic> favData =
        favResponse.body == 'null' ? {} : jsonDecode(favResponse.body);

    Map<String, dynamic> data = jsonDecode(response.body);
    data.forEach((productId, productData) {
      itemsGlobal.add(Product(
        id: productId,
        name: productData['name'],
        description: productData['description'],
        price: productData['price'],
        imageUrl: productData['imageUrl'],
        isFavorite: favData[productId] ?? false,
      ));
    });
    notifyListeners();
  }

  List<Product> get favoreItems =>
      itemsGlobal.where((prod) => prod.isFavorite).toList();

  Future<void> addProduct(Product product) async {
    final response = await http.post(
        Uri.parse("${Constants.PRODUCT_BASE_URL}.json?auth=$token"),
        body: jsonEncode({
          "name": product.name,
          "price": product.price,
          "description": product.description,
          "imageUrl": product.imageUrl,
        }));

    final id = jsonDecode(response.body)['name'];
    itemsGlobal.add(Product(
      id: id,
      name: product.name,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
    ));
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    final productIndex =
        itemsGlobal.indexWhere((prod) => prod.id == product.id);
    if (productIndex >= 0) {
      await http.patch(
        Uri.parse(
            "${Constants.PRODUCT_BASE_URL}/${product.id}.json?auth=$token"),
        body: jsonEncode(
          {
            "name": product.name,
            "price": product.price,
            "description": product.description,
            "imageUrl": product.imageUrl,
          },
        ),
      );

      itemsGlobal[productIndex] = product;
      notifyListeners();
    }
  }

  Future<void> removeProduct(Product product) async {
    final productIndex =
        itemsGlobal.indexWhere((prod) => prod.id == product.id);
    if (productIndex >= 0) {
      final product = itemsGlobal[productIndex];
      itemsGlobal.remove(product);
      notifyListeners();

      final response = await http.delete(
        Uri.parse(
            "${Constants.PRODUCT_BASE_URL}/${product.id}.json?auth=$token"),
      );

      if (response.statusCode >= 400) {
        itemsGlobal.insert(productIndex, product);
        notifyListeners();
        throw HttpException(
          msg: "Não foi possível excluir o produto",
          statusCode: response.statusCode,
        );
      }
    }
  }

  Future<void> saveProduct(Map<String, Object> data) {
    bool hasId = data['id'] != null;

    final product = Product(
      id: hasId
          ? data['id'] as String
          : Random().nextInt(max(1, 1000)).toString(),
      name: data['name'] as String,
      description: data['description'] as String,
      price: data['price'] as double,
      imageUrl: data['imageUrl'] as String,
    );

    if (hasId) {
      return updateProduct(product);
    } else {
      return addProduct(product);
    }
  }
}
