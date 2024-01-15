import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

import '../widgets/products_table.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import '../widgets/drawer.dart';
import '../screens/cart_screen.dart';
import '../providers/products_provider.dart';

enum FliterOptions {
  Favorites,
  All,
}

class ProductOverviewScreen extends StatefulWidget {
  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      Provider.of<ProductsProvider>(context).getProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Widget _buildAppBar() {
    return Platform.isIOS
        ? CupertinoNavigationBar(
            middle: const Text('Magazin Engross'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => PopupMenuButton(
                    icon: Icon(CupertinoIcons.ellipsis),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        child: const Text('Afiseaza doar favorite'),
                        value: FliterOptions.Favorites,
                      ),
                      PopupMenuItem(
                        child: const Text('Afiseaza toate produsele'),
                        value: FliterOptions.All,
                      )
                    ],
                    onSelected: (selectedValue) {
                      setState(() {
                        if (selectedValue == FliterOptions.Favorites) {
                          _showOnlyFavorites = true;
                        } else {
                          _showOnlyFavorites = false;
                        }
                      });
                    },
                  ),
                ),
                Consumer<Cart>(
                  builder: (_, cart, ch) => BadgeIcon(
                    child: ch!,
                    value: cart.itemCount,
                  ),
                  child: IconButton(
                    icon: Icon(CupertinoIcons.shopping_cart),
                    onPressed: () {
                      Navigator.of(context).pushNamed(CartScreen.routeName);
                    },
                  ),
                )
              ],
            ))
        : AppBar(
            title: const Text(
              'Magazin Engross',
              style: TextStyle(fontSize: 20),
            ),
            actions: [
              PopupMenuButton(
                icon: Icon(Icons.more_vert),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    child: Text('Afiseaza doar favorite'),
                    value: FliterOptions.Favorites,
                  ),
                  PopupMenuItem(
                    child: Text('Afiseaza toate produsele'),
                    value: FliterOptions.All,
                  )
                ],
                onSelected: (selectedValue) {
                  setState(() {
                    if (selectedValue == FliterOptions.Favorites) {
                      _showOnlyFavorites = true;
                    } else {
                      _showOnlyFavorites = false;
                    }
                  });
                },
              ),
              Consumer<Cart>(
                builder: (_, cart, ch) => BadgeIcon(
                  child: ch!,
                  value: cart.itemCount,
                ),
                child: IconButton(
                  icon: Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.of(context).pushNamed(CartScreen.routeName);
                  },
                ),
              )
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    final dynamic appBar = _buildAppBar();

    return Platform.isIOS
        ? CupertinoPageScaffold(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ProductsTable(_showOnlyFavorites),
            navigationBar: appBar,
          )
        : Scaffold(
            appBar: appBar,
            drawer: AppDrawer(),
            body: _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ProductsTable(_showOnlyFavorites),
          );
  }
}
