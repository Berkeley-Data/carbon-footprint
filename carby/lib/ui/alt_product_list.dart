import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'product_detail.dart';
import 'package:carby/ui/product.dart';

import 'package:http/http.dart';

class ProductList extends StatelessWidget {
  final Product product;

  ProductList({Key key, this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
      ),
      itemCount: 1,
      itemBuilder: (context, index) {
        return Image.network(product.imageUrl);
      },
    );
  }
}

class AltProductList extends StatefulWidget {
  final Product product;
  AltProductList(this.product) : super();

  @override
  AltProductListState createState() => AltProductListState(product);
}

class AltProductListState extends State<AltProductList> {
  List<dynamic> altProducts;
  final Product product;

  AltProductListState(this.product) : super();

  @override
  initState() {
    super.initState();
    getAltProducts(product);
  }

  Future<String> getAltProducts(Product product) async {
    print("product id ${product.productId}");
    List<int> altProductIds = [];

    get("http://carbyapi-env.eba-wjqkprkx.us-east-1.elasticbeanstalk.com/getlowerfootprint/ids/${product.productId}")
        .then((res) {
      print(res.body);
      var altProductIdStrings =
          res.body.replaceAll("[", "").replaceAll("]", "").split(",");
      print(altProductIdStrings);
      altProductIdStrings.forEach((String altProductIdString) {
        print(altProductIdString);
        altProductIds.add(int.parse(altProductIdString));
      });
      print(altProductIds);
      print("alternative id ${altProductIds.toList()}");
      List<Product> prods = [];
      altProductIds.forEach((int productId) {
        print("finding alternative product id ${productId}");
        get("http://carbyapi-env.eba-wjqkprkx.us-east-1.elasticbeanstalk.com/metadata/${productId}")
            .then((res) {
          print("found this : ${res.body}");
          product = parseProduct(res.body);
          print("turned it into a product : ${product.productName}");
          prods.add(product);
          setState(() {
            altProducts = prods;
          });
        });
      });
    });

    return "Success";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Alternate Products')),
        // The image is stored as a file on the device. Use the `Image.file`
        // constructor with the given path to display the image.

        body: Stack(alignment: Alignment.topCenter, children: <Widget>[
          new Container(
              padding: const EdgeInsets.only(top: 32.0, left: 40.0),
              child: new Row(children: [
                new Expanded(
                  child: new ListView.builder(
                      itemCount: altProducts == null ? 0 : altProducts.length,
                      itemBuilder: (context, i) {
                        return new FlatButton(
                          child: new ProductCell(altProducts, i),
                          padding: const EdgeInsets.all(0.0),
                          onPressed: () {
                            Navigator.push(context,
                                new MaterialPageRoute(builder: (context) {
                              return new ProductDetail(altProducts[i]);
                            }));
                          },
                          color: Colors.white,
                        );
                      }),
                )
              ]))
        ]));
  }
}

/*
Future<Map> getJson() async {
  var apiKey = getApiKey();
  var url = 'http://api.themoviedb.org/3/discover/movie?api_key=${apiKey}';
  var response = await http.get(url);
  return json.decode(response.body);
}
*/

class ProductCell extends StatelessWidget {
  final List<Product> products;
  final i;
  final Color mainColor = const Color(0xff3C3261);

  ProductCell(this.products, this.i);

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Row(
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.all(0.0),
              child: new Container(
                margin: const EdgeInsets.all(16.0),
//                                child: new Image.network(image_url+movies[i]['poster_path'],width: 100.0,height: 100.0),
                child: new Container(
                  width: 70.0,
                  height: 70.0,
                ),
                decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.circular(10.0),
                  color: Colors.grey,
                  image: new DecorationImage(
                      image: new NetworkImage(products[i].imageUrl),
                      fit: BoxFit.cover),
                  boxShadow: [
                    new BoxShadow(
                        color: mainColor,
                        blurRadius: 5.0,
                        offset: new Offset(2.0, 5.0))
                  ],
                ),
              ),
            ),
            new Expanded(
                child: new Container(
              margin: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
              child: new Column(
                children: [
                  new Text(
                    products[i].productName,
                    style: new TextStyle(
                        fontSize: 20.0,
                        fontFamily: 'Arvo',
                        fontWeight: FontWeight.bold,
                        color: mainColor),
                  ),
                  new Padding(padding: const EdgeInsets.all(2.0)),
                  (products[i].carbonFootprint > 550)
                      ? new Icon(
                          Icons.sentiment_very_dissatisfied,
                          color: Colors.red[500],
                          size: 40,
                        )
                      : new Icon(
                          Icons.sentiment_very_satisfied,
                          color: Colors.green[500],
                          size: 40,
                        ),
                  new Text(
                    '${products[i].carbonFootprint}',
                    maxLines: 3,
                    style: new TextStyle(
                        color: const Color(0xff8785A4), fontFamily: 'Arvo'),
                  )
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            )),
          ],
        ),
        new Container(
          width: 300.0,
          height: 0.5,
          color: const Color(0xD2D2E1ff),
          margin: const EdgeInsets.all(16.0),
        )
      ],
    );
  }
}
