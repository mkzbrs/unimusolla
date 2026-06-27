import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/musolla.dart';
import '../../providers/musolla_provider.dart';
import '../../widgets/app_states.dart';
import '../../widgets/network_image_box.dart';
import '../../widgets/status_badge.dart';

class MusollaDetailScreen extends StatefulWidget {
  const MusollaDetailScreen({super.key, required this.id});
  final int id;

  @override
  State<MusollaDetailScreen> createState() => _MusollaDetailScreenState();
}

class _MusollaDetailScreenState extends State<MusollaDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<MusollaProvider>().loadDetail(widget.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusollaProvider>();
    final musolla = provider.selected;
    return Scaffold(
      appBar: AppBar(title: const Text('Musolla Detail')),
      body: Builder(
        builder: (_) {
          if (provider.loading && musolla == null)
            return const SkeletonList(itemCount: 3);
          if (provider.error != null && musolla == null)
            return ErrorState(
              message: provider.error!,
              onRetry: () => provider.loadDetail(widget.id),
            );
          if (musolla == null)
            return const EmptyState(
              icon: Icons.mosque_outlined,
              title: 'Not found',
              message: 'This musolla could not be loaded.',
            );
          return RefreshIndicator(
            onRefresh: () => provider.loadDetail(widget.id),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Gallery(musolla: musolla),
                const SizedBox(height: 16),
                Text(
                  musolla.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                StatusBadge(
                  status: musolla.available ? 'available' : 'unavailable',
                ),
                const SizedBox(height: 16),
                _Info(
                  icon: Icons.place_outlined,
                  label: 'Location',
                  value: musolla.location,
                ),
                _Info(
                  icon: Icons.near_me_outlined,
                  label: 'Exact Location',
                  value: musolla.exactLocation,
                ),
                const SizedBox(height: 12),
                Text(
                  'Facilities',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: musolla.facilities.labels
                      .map((label) => Chip(label: Text(label)))
                      .toList(),
                ),
                const SizedBox(height: 16),
                if (musolla.latitude != null && musolla.longitude != null) ...[
                  _MapPreview(musolla: musolla),
                  const SizedBox(height: 12),
                ],
                FilledButton.icon(
                  onPressed:
                      musolla.latitude == null || musolla.longitude == null
                      ? null
                      : () => _showMapHint(context, musolla),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Open in Google Map'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () =>
                      context.push('/reports/create', extra: musolla),
                  icon: const Icon(Icons.edit_note_outlined),
                  label: const Text('Report Update'),
                ),
                const SizedBox(height: 4),
                Text(
                  'Help keep musolla information accurate.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showMapHint(BuildContext context, Musolla musolla) {
    final uri = Uri.parse(
      'https://maps.google.com/?q=${musolla.latitude},${musolla.longitude}',
    );
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _MapPreview extends StatelessWidget {
  const _MapPreview({required this.musolla});
  final Musolla musolla;

  @override
  Widget build(BuildContext context) {
    final point = LatLng(musolla.latitude!, musolla.longitude!);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 180,
        child: FlutterMap(
          options: MapOptions(initialCenter: point, initialZoom: 17),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.unimusolla_app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: point,
                  width: 48,
                  height: 48,
                  child: Icon(
                    Icons.location_pin,
                    size: 42,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Gallery extends StatelessWidget {
  const _Gallery({required this.musolla});
  final Musolla musolla;

  @override
  Widget build(BuildContext context) {
    final images = musolla.images.isEmpty ? [musolla.imageUrl] : musolla.images;
    return SizedBox(
      height: 220,
      child: PageView(
        children: images
            .map(
              (url) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: NetworkImageBox(url: url, height: 220),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value.isEmpty ? '-' : value),
    );
  }
}
