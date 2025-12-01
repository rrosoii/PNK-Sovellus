import 'package:flutter/material.dart';
import 'package:pnksovellus/services/ajankohtaista_service.dart';

class AjankohtaistaDetailPage extends StatelessWidget {
  final AjankohtaistaItem item;

  const AjankohtaistaDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final date =
        '${item.date.day.toString().padLeft(2, '0')}.${item.date.month.toString().padLeft(2, '0')}.${item.date.year}';

    return Scaffold(
      backgroundColor: const Color(0xFFEFF4FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF2E5AAC)),
        elevation: 0,
        title: const Text(
          'Ajankohtaista',
          style: TextStyle(color: Color(0xFF2E5AAC)),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroImage(imageUrl: item.imageUrl),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DatePill(date: date),
                    const SizedBox(height: 10),
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2E5AAC),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      item.body ?? 'Ei kuvausta',
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Color(0xFF3C4A62),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  final String? imageUrl;

  const _HeroImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E5AAC), Color(0xFF6CA7FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: hasImage
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
              )
            : const Center(
                child: Icon(
                  Icons.image,
                  color: Colors.white,
                  size: 42,
                ),
              ),
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  final String date;

  const _DatePill({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(46, 90, 172, 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.event, size: 16, color: Color(0xFF2E5AAC)),
          const SizedBox(width: 6),
          Text(
            date,
            style: const TextStyle(
              color: Color(0xFF2E5AAC),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
