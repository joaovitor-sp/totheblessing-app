import 'package:flutter/material.dart';

class PostCardWidget extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final String description;

  const PostCardWidget({
    super.key,
    required this.title,
    this.imageUrl,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // título
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // imagem ou descrição
            if (imageUrl != null && imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Text(
                description.length > 100
                    ? "${description.substring(0, 100)}..."
                    : description,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
          ],
        ),
      ),
    );
  }
}
