import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminMenuPage extends StatefulWidget {
  const AdminMenuPage({super.key});

  @override
  State<AdminMenuPage> createState() => _AdminMenuPageState();
}

class _AdminMenuPageState extends State<AdminMenuPage> {
  final List<Map<String, dynamic>> _editedItems = [];
  String _selectedCategory = 'Menu_Breakfast'; // Moved to a state variable

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Canteen Menu',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.lightGreen.shade700,
        elevation: 4.0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildMenuSection('Breakfast', 'Menu_Breakfast'),
            _buildMenuSection('Lunch', 'Menu_Lunch'),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: _addMenuItem,
            backgroundColor: Colors.blue.shade700,
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: _saveChanges,
            backgroundColor: Colors.green.shade700,
            child: const Icon(Icons.save),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, String collectionName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection(collectionName).snapshots(),
          builder: (context, snapshots) {
            if (snapshots.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshots.hasError) {
              return Center(child: Text('Error: ${snapshots.error}'));
            }

            if (!snapshots.hasData || snapshots.data!.docs.isEmpty) {
              return const Center(child: Text('No menu items available.'));
            }

            var menuItems = snapshots.data!.docs;

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                var document = menuItems[index];
                var data = document.data() as Map<String, dynamic>? ?? {};
                String itemId = document.id;

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      data['Item_Name'] ?? 'Unnamed Item',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Stock: ${data['Stock']}, Price: Rs ${data['Price']}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    onTap: () => _editMenuItem(itemId, collectionName, data),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteMenuItem(itemId, collectionName),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _addMenuItem() {
    String itemName = '';
    int stock = 0;
    double price = 0.0;
    String category = 'Menu_Breakfast';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Menu Item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: 'Item Name'),
                    onChanged: (value) => itemName = value,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Stock'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => stock = int.tryParse(value) ?? 0,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => price = double.tryParse(value) ?? 0.0,
                  ),
                  DropdownButton<String>(
                    value: category,
                    items: const [
                      DropdownMenuItem(
                          value: 'Menu_Breakfast', child: Text('Breakfast')),
                      DropdownMenuItem(
                          value: 'Menu_Lunch', child: Text('Lunch')),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        // Use setDialogState to update only the dropdown
                        category = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (itemName.isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection(category)
                          .add({
                        'Item_Name': itemName,
                        'Stock': stock,
                        'Price': price,
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editMenuItem(
      String itemId, String collectionName, Map<String, dynamic> data) {
    TextEditingController stockController =
        TextEditingController(text: data['Stock'].toString());
    TextEditingController priceController =
        TextEditingController(text: data['Price'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Menu Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: stockController,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                int newStock = int.tryParse(stockController.text) ?? 0;
                double newPrice = double.tryParse(priceController.text) ?? 0.0;

                await FirebaseFirestore.instance
                    .collection(collectionName)
                    .doc(itemId)
                    .update({
                  'Stock': newStock,
                  'Price': newPrice,
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

  void _deleteMenuItem(String itemId, String collectionName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection(collectionName)
                    .doc(itemId)
                    .delete();
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _saveChanges() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changes saved successfully.')),
    );
  }
}
