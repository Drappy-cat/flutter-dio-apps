import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/manga_model.dart';

class DetailScreen extends StatelessWidget {
  final Manga manga;

  const DetailScreen({super.key, required this.manga});

  Future<void> _launchURL(String mangaId) async {
    final Uri uri = Uri.parse('https://mangadex.org/title/$mangaId');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $uri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(manga.title),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (manga.coverUrl.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Image.network(
                          manga.coverUrl,
                          height: 300,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 300,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        manga.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColorDark,
                            ),
                      ),
                      const SizedBox(height: 16),
                      
                      Text(
                        'Deskripsi',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Divider(),
                      Text(
                        manga.description.replaceAll(RegExp(r'\[.*?\]'), '').trim(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[800],
                              height: 1.5,
                            ),
                      ),
                      const SizedBox(height: 24),
                      
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () => _launchURL(manga.id),
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Lihat di MangaDex'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
