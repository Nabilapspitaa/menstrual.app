import 'package:flutter/material.dart';

class CartItemCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const CartItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title:
            Text(item["name"], style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle:
            Text("Jumlah: ${item["quantity"]} | Harga: Rp ${item["price"]}"),
        trailing: Text(
          "Rp ${(item["price"] * item["quantity"])}",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
        ),
      ),
    );
  }
}