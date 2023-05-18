import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.url, this.size = 50});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(url,
            width: size,
            height: size,
            errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.person,
                  size: size,
                )));
  }
}
