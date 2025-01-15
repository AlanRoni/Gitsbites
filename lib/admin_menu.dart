import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminMenuPage extends StatefulWidget {
  const AdminMenuPage({super.key});

  @override
  State<AdminMenuPage> createState() => _AdminMenuPageState();
}

class _AdminMenuPageState extends State<AdminMenuPage> {
  final List<Map<String, dynamic>> _editedItems = []; // List to store edited items

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Canteen Menu'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Menu').snapshots(),
        builder: (context, snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshots.hasError) {
            return const Center(child: Text('Error loading menu data.'));
          }

          if (!snapshots.hasData || snapshots.data!.docs.isEmpty) {
            return const Center(child: Text('No menu items available.'));
          }

          var menuItems = snapshots.data!.docs;

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  var document = menuItems[index];
                  var itemName = document.get('Item Name') ?? 'Unnamed Item';
                  var stock = document.get('Stock') ?? 0;
                  var price = document.get('Price') ?? 0.0;

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            itemName,
                            style: const TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Stock: $stock',
                            style: const TextStyle(fontSize: 16.0),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Price: Rs $price',
                            style: const TextStyle(fontSize: 16.0),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16.0),
                          ElevatedButton(
                            onPressed: () => _editItem(context, document.id, stock, price),
                            child: const Text('Edit'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 16.0,
                left: 16.0,
                right: 16.0,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Function to show edit dialog
  void _editItem(BuildContext context, String docId, int stock, double price) {
    final stockController = TextEditingController(text: stock.toString());
    final priceController = TextEditingController(text: price.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stock'),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _editedItems.removeWhere((item) => item['id'] == docId);
                  _editedItems.add({
                    'id': docId,
                    'Stock': int.tryParse(stockController.text) ?? stock,
                    'Price': double.tryParse(priceController.text) ?? price,
                  });
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Function to save changes
  void _saveChanges() async {
    if (_editedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No changes to save.')),
      );
      return;
    }

    bool confirm = await _showConfirmDialog();
    if (!confirm) return;

    try {
      for (var item in _editedItems) {
        await FirebaseFirestore.instance
            .collection('Menu')
            .doc(item['id'])
            .update({'Stock': item['Stock'], 'Price': item['Price']});
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved successfully.')),
      );
      setState(() {
        _editedItems.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save changes.')),
      );
    }
  }

  // Function to show confirmation dialog
  Future<bool> _showConfirmDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Confirm Save'),
              content: const Text('Are you sure you want to save these changes?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}