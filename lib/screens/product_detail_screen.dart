import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/pruducts.dart';
// import '../providers/pruducts.dart';

class ProducDetailScreen extends StatelessWidget {
  static const routename = '/product-detail';
  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    final loadedProduct =
        Provider.of<Products>(context, listen: false).findById(productId);
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(loadedProduct.title),
      // ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loadedProduct.title),
              background: Hero(
                tag: loadedProduct.id,
                child: Image.network(
                  loadedProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Column(
                  children: <Widget>[
                    // Container(
                    //   height: 300,
                    //   width: double.infinity,
                    //   child: Hero(
                    //     tag: loadedProduct.id,
                    //     child: Image.network(
                    //       loadedProduct.imageUrl,
                    //       fit: BoxFit.cover,
                    //     ),
                    //   ),
                    // ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      '\$${loadedProduct.price}',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        loadedProduct.description,
                        textAlign: TextAlign.center,
                        softWrap: true,
                      ),
                    ),
                    SizedBox(
                      height: 800,
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
