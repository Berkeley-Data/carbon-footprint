import 'package:flutter/material.dart';
import 'package:carby/ui/product.dart';
import 'package:carby/ui/alt_product_list.dart';

/// Product Detail information
class ProductDetail extends StatelessWidget {
  final Product product;

  ProductDetail(this.product);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          new Image.network(product.imageUrl),
          new Container(
            padding: const EdgeInsets.all(32.0),
            child: new Row(
              children: [
                // First child in the Row for the name and the
                // Release date information.
                new Expanded(
                  // Name and Release date are in the same column
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Code to create the view for name.
                      new Container(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: new Text(
                          "Product Name: " + product.productName,
                          style: new TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Code to create the view for release date.
                      new Text(
                        "Product Category: " + product.productCategory,
                        style: new TextStyle(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                // Icon to indicate the rating.

                (product.carbonFootprint > 550)
                    ? new IconButton(
                        icon: new Icon(
                            Icons.sentiment_very_dissatisfied_rounded,
                            size: 40,
                            color: Colors.red[500]),
                        onPressed: () {
                          _onCarbonButtonPressed(context, product);
                        },
                      )
                    : new Icon(
                        Icons.sentiment_very_satisfied,
                        color: Colors.green[500],
                        size: 40,
                      ),
                new Text('${product.carbonFootprint}'),
              ],
            ),
          )
        ]));
  }

  void _onCarbonButtonPressed(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AltProductList(product),
      ),
    );
  }
}
