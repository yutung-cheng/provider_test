import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Represenst a Cart Item. Has <int>`id`, <String>`name`, <int>`quantity`
class CartItem {
  int id;
  String name;
  int qty;

  //constructor
  CartItem({required this.id, required this.name, required this.qty});
}

/// Manages a cart. Implements ChangeNotifier
class CartState with ChangeNotifier {
  List<CartItem> _products = [];

  CartState();

  /// The number of individual items in the cart. That is, all cart items' quantities.
  // TODO: return actual cart volume.
  int get totalCartItems =>
      _products.fold(0, (current, product) => current + product.qty);

  /// The list of CartItems in the cart
  List<CartItem> get products => _products;

  /// Clears the cart. Notifies any consumers.
  void clearCart() {
    print('=====Clear=====');
    _products.clear(); //clear all objects from the list
    notifyListeners();
  }

  /// Adds a new CartItem to the cart. Notifies any consumers.
  void addToCart({required CartItem item}) {
    print('======Add======');
    _products.add(item);
    notifyListeners();
  }

  /// Updates the quantity of the Cart item with this id. Notifies any consumers.
  void updateQuantity({required int id, required int newQty}) {
    //find if the product is already exist
    CartItem found = _products.firstWhere((element) => element.id == id);

    //if the qty adds the newQty will equals to 0 (or even less than 0)
    if (found.qty + newQty <= 0) {
      //remove the product from _products list
      _products.remove(found);
    } else {
      //add the newQty
      found.qty = found.qty + newQty;
    }

    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartState(),
      child: MyCartApp(),
    ),
  );
}

class MyCartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //remove debug banner
      home: Scaffold(
        body: Container(
          child: Column(
            children: [
              ListOfCartItems(),
              CartSummary(),
              CartControls(),
            ],
          ),
        ),
      ),
    );
  }
}

class CartControls extends StatelessWidget {
  /// Handler for Add Item pressed
  void _addItemPressed(BuildContext context) {
    /// mostly unique cartItemId.
    /// don't change this; not important for this test
    int nextCartItemId = Random().nextInt(10000);
    String nextCartItemName = 'A cart item';
    int nextCartItemQuantity = 1;

    // Actually use the CartItem constructor to assign id, name and quantity
    CartItem item = new CartItem(
        id: nextCartItemId, name: nextCartItemName, qty: nextCartItemQuantity);

    // TODO: Get the cart current state through Provider. Add this cart item to cart.
    Provider.of<CartState>(context, listen: false).addToCart(item: item);
  }

  /// Handle clear cart pressed. Should clear the cart
  void _clearCartPressed(BuildContext context) {
    Provider.of<CartState>(context, listen: false).clearCart();
  }

  @override
  Widget build(BuildContext context) {
    final Widget addCartItemWidget = TextButton(
      child: Text('Add Item'),
      onPressed: () {
        _addItemPressed(context);
      },
    );

    final Widget clearCartWidget = TextButton(
      child: Text('Clear Cart'),
      onPressed: () {
        _clearCartPressed(context);
      },
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        addCartItemWidget,
        SizedBox(width: 20), // seperated two buttons
        clearCartWidget,
      ],
    );
  }
}

class ListOfCartItems extends StatelessWidget {
  /// Handles adding 1 to the current cart item quantity.
  void _incrementQuantity(context, int id, int delta) {
    print('===Increment===');
    Provider.of<CartState>(context, listen: false)
        .updateQuantity(id: id, newQty: delta);
  }

  /// Handles removing 1 to the current cart item quantity.
  /// Don't forget: we can't have negative numbers of an item in the cart
  void _decrementQuantity(context, int id, int delta) {
    print('===Decrement===');
    Provider.of<CartState>(context, listen: false)
        .updateQuantity(id: id, newQty: delta);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartState>(
        builder: (BuildContext context, CartState cart, Widget? child) {
      if (cart.totalCartItems == 0) {
        // TODO: return a Widget that tells us there are no items in the cart
        return Text('\nThere are no items in the cart\n');
      }

      return Column(children: [
        ...cart.products.map(
          (c) => Padding(
            padding: const EdgeInsets.all(2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // TODO: Widget for the line item name AND current quantity, eg "Item name x 4".
                //  Current quantity should update whenever a change occurs.
                // TODO: Button to handle incrementing cart quantity. Handler is above.
                // TODO: Button to handle decrementing cart quantity. Handler is above.
                Container(
                  width: 350,
                  decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                      leading: Text(c.id.toString()),
                      title: Text(c.name),
                      trailing: Container(
                        width: 130,
                        child: Row(
                          children: [
                            TextButton(
                                onPressed: () =>
                                    _incrementQuantity(context, c.id, 1),
                                child: Icon(
                                  Icons.add,
                                )),
                            Text(c.qty.toString()),
                            TextButton(
                                onPressed: () =>
                                    _decrementQuantity(context, c.id, -1),
                                child: Icon(
                                  Icons.remove,
                                )),
                          ],
                        ),
                      )),
                ),
              ],
            ),
          ),
        ),
      ]);
    });
  }
}

class CartSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CartState>(
      builder: (BuildContext context, CartState cart, Widget? child) {
        return Text("Total items: ${cart.totalCartItems}");
      },
    );
  }
}
