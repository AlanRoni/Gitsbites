import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminMenuPage extends StatelessWidget {
  const AdminMenuPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Canteen Menu'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Menu').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var document = snapshot.data!.docs[index];
              var itemName = document['Item Name'];
              var stock = document['Stock'];
              var price = document['Price'];

              return ListTile(
                title: Text(itemName),
                subtitle: Text('Stock: $stock\nPrice: \$${price.toStringAsFixed(2)}'),
              );
            },
          );
        },
      ),
    );
  }
}