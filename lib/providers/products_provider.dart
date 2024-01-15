import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import './product.dart';
import '../models/http_exception.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _items = [];

  final String? authToken;
  String? userId;

  ProductsProvider(this.authToken, this.userId, this._items);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> getProducts([bool filterByUser = false]) async {
    final filterString = filterByUser ? 'equalTo="$userId"' : '';
    var url =
        'https://first-flutter-project-5ba85-default-rtdb.firebaseio.com/' +
            'products.json?auth=$authToken&orderBy="creatorId"&$filterString';
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      // ignore: unnecessary_null_comparison
      if (extractedData == null) {
        return;
      }

      url = 'https://first-flutter-project-5ba85-default-rtdb.firebaseio.com/' +
          'userFavorites/$userId.json?auth=$authToken';
      final favoriteResponse = await http.get(Uri.parse(url));
      final favoriteData = json.decode(favoriteResponse.body);

      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            image: prodData['image'],
            isFavorite:
                favoriteData == null ? false : favoriteData[prodId] ?? false));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://first-flutter-project-5ba85-default-rtdb.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'image': product.image,
            'price': product.price,
            'creatorId': userId,
          }));
      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          image: product.image);

      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);

    if (prodIndex >= 0) {
      final url =
          'https://first-flutter-project-5ba85-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';

      await http.patch(Uri.parse(url),
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'image': newProduct.image,
            'price': newProduct.price
          }));
      _items[prodIndex] = newProduct;
    }

    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://first-flutter-project-5ba85-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    dynamic existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(Uri.parse(url));

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();

      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}
