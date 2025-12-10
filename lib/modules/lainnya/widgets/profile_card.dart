import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final String? imageUrl;

  const ProfileCard({
    super.key,
    required this.name,
    required this.email,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[200],
              child: (imageUrl != null && imageUrl!.isNotEmpty)
                  ? ClipOval(
                      child: Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        width: 60,
                        height: 60,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) {
                            return child;
                          }
                          return const CircularProgressIndicator();
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            CupertinoIcons.person_alt_circle,
                            size: 40,
                            color: Colors.grey[600],
                          );
                        },
                      ),
                    )
                  : Icon(
                      CupertinoIcons.person_alt_circle,
                      size: 40,
                      color: Colors.grey[600],
                    ),
            ),
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, 
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}