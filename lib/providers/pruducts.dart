import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import './product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items = [];
  var showFavouritesOnly = false;

  final String authToken;
  final String userId;

  Products(this.authToken, this._items, this.userId);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favouriteItems {
    return _items.where((prodItem) => prodItem.isFavourite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    final url = Uri.parse(
        'https://flutter-update-757ac-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final Url = Uri.parse(
          "https://flutter-update-757ac-default-rtdb.firebaseio.com/userFavourites/$userId.json?auth=$authToken");

      final favouriteResponse = await http.get(Url);
      final favouriteData = json.decode(favouriteResponse.body);
      // print(json.decode(response.body));
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, ProdData) {
        loadedProducts.add(Product(
          id: prodId,
          title: ProdData['title'],
          description: ProdData['description'],
          price: ProdData['price'],
          imageUrl: ProdData['imageUrl'],
          isFavourite:
              favouriteData == null ? false : favouriteData[prodId] ?? false,
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProducts(Product product) async {
    final url = Uri.parse(
        'https://flutter-update-757ac-default-rtdb.firebaseio.com/products.json?auth=$authToken');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'isFavourite': product.isFavourite,
          'creatorId': userId,
        }),
      );
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere(
      (prod) => prod.id == id,
    );
    if (prodIndex >= 0) {
      final url = Uri.parse(
          'https://flutter-update-757ac-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    // _items.removeWhere((prod) => prod.id == id);
    final url = Uri.parse(
        'https://flutter-update-757ac-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      throw HttpException('could not delete it');
    }
    existingProduct = null;
  }
}
