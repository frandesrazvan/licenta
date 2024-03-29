import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/product.dart';
import '../providers/authentication.dart';
import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context);
    final cart = Provider.of<Cart>(context, listen: false);
    final authenticationData =
        Provider.of<Authentication>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          child: Hero(
            tag: product.id as Object,
            child: FadeInImage(
              placeholder: AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(product.image),
              fit: BoxFit.cover,
            ),
          ),
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                arguments: product.id);
          },
        ),
        header: Text(
          product.title,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 25,
              backgroundColor: Colors.black38),
        ),
        footer: MediaQuery.of(context).size.width < 390
            ? Container(
                height: 70,
                child: GridTileBar(
                  backgroundColor: Colors.black87,
                  leading: IconButton(
                    icon: Icon(product.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border),
                    onPressed: () {
                      product.toggleFavoriteStatus(
                          authenticationData.token as String,
                          authenticationData.userId as String);
                    },
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    '${product.price} Lei',
                    //textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 8),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.shopping_cart),
                    onPressed: () {
                      cart.addItem(
                          product.id as String, product.price, product.title);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Produs adaugat in cos!'),
                        duration: Duration(seconds: 2),
                        action: SnackBarAction(
                          label: 'ANULARE',
                          textColor: Theme.of(context).colorScheme.primary,
                          onPressed: () {
                            cart.removeOneItem(product.id as String);
                          },
                        ),
                      ));
                    },
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              )
            : GridTileBar(
                backgroundColor: Colors.black87,
                leading: IconButton(
                  icon: Icon(product.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border),
                  onPressed: () {
                    product.toggleFavoriteStatus(
                        authenticationData.token as String,
                        authenticationData.userId as String);
                  },
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  '${product.price} Lei',
                  //textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 8),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.shopping_cart),
                  onPressed: () {
                    cart.addItem(
                        product.id as String, product.price, product.title);
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Produs adaugat in cos!'),
                      duration: Duration(seconds: 2),
                      action: SnackBarAction(
                        label: 'ANULARE',
                        textColor: Theme.of(context).colorScheme.primary,
                        onPressed: () {
                          cart.removeOneItem(product.id as String);
                        },
                      ),
                    ));
                  },
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
      ),
    );
  }
}
