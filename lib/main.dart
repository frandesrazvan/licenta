import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/cart.dart';
import './providers/orders.dart';
import './providers/products_provider.dart';
import './providers/authentication.dart';

import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/cart_screen.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/authentication_screen.dart';
import './screens/loading_screen.dart';

void main() => runApp(MyShopApp());

class MyShopApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => Authentication(),
          ),
          ChangeNotifierProxyProvider<Authentication, ProductsProvider>(
            create: (_) => ProductsProvider('', '', []),
            update: (context, authentication, previousProducts) =>
                ProductsProvider(authentication.token, authentication.userId,
                    previousProducts == null ? [] : previousProducts.items),
          ),
          ChangeNotifierProvider(
            create: (context) => Cart(),
          ),
          ChangeNotifierProxyProvider<Authentication, Orders>(
            create: (_) => Orders('', '', []),
            update: (context, authentication, previousOrders) => Orders(
                authentication.token,
                authentication.userId,
                previousOrders == null ? [] : previousOrders.orders),
          ),
        ],
        child: Consumer<Authentication>(
          builder: (context, authenticationData, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Magazin Engross',
            theme: ThemeData(
              primarySwatch: Colors.orange,
              fontFamily: 'Lato',
              appBarTheme: const AppBarTheme(
                  titleTextStyle: TextStyle(fontFamily: 'Lato', fontSize: 25)),
            ).copyWith(
                colorScheme: ThemeData()
                    .colorScheme
                    .copyWith(primary: Colors.orange, secondary: Colors.white)),
            home: authenticationData.isAuthenticated
                ? ProductOverviewScreen()
                : FutureBuilder(
                    future: authenticationData.tryAutoLogin(),
                    builder: (context, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? LoadingScreen()
                            : AuthScreen()),
            routes: {
              ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
              CartScreen.routeName: (context) => CartScreen(),
              OrdersScreen.routeName: (context) => OrdersScreen(),
              UserProductsScreen.routeName: (context) => UserProductsScreen(),
              EditProductScreen.routeName: (context) => EditProductScreen()
            },
          ),
        ));
  }
}
