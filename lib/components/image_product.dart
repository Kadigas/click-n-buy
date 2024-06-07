import 'package:flutter/material.dart';

class ImageProduct extends StatelessWidget {
  final String? imageUrl;

  const ImageProduct({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return imageUrl != null
        ? Image.network(
            imageUrl!,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
            },
            errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
              return const Icon(
                Icons.broken_image,
                size: 100.0,
              );
            },
          )
        : const Center(
            child: Icon(
              Icons.photo,
              size: 60,
            ),
          );
  }
}
