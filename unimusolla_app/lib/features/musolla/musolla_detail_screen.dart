import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/musolla.dart';
import '../../providers/auth_provider.dart';
import '../../providers/musolla_provider.dart';
import '../../widgets/app_states.dart';
import '../../widgets/network_image_box.dart';

class MusollaDetailScreen extends StatefulWidget {
  const MusollaDetailScreen({super.key, required this.id});
  final int id;

  @override
  State<MusollaDetailScreen> createState() => _MusollaDetailScreenState();
}

class _MusollaDetailScreenState extends State<MusollaDetailScreen> {
  static const _surface = Color(0xFFF8F9FF);
  static const _surfaceContainer = Color(0xFFE6EEFF);
  static const _surfaceContainerLow = Color(0xFFEFF4FF);
  static const _onSurface = Color(0xFF121C2A);
  static const _onSurfaceVariant = Color(0xFF3F4944);
  static const _outline = Color(0xFF6F7973);
  static const _outlineVariant = Color(0xFFBEC9C2);
  static const _primary = Color(0xFF004532);

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
      backgroundColor: _surface,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          tooltip: 'Go back',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
          color: _onSurfaceVariant,
        ),
        title: Text(
          'Musolla Detail',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: _primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: _surface,
        surfaceTintColor: _surface,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: .12),
      ),
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
          final isAdmin = context.watch<AuthProvider>().isAdmin;
          return RefreshIndicator(
            onRefresh: () => provider.loadDetail(widget.id),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _Gallery(musolla: musolla),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    24,
                    16,
                    32 + MediaQuery.paddingOf(context).bottom,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1024),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HeaderSection(musolla: musolla),
                          const SizedBox(height: 24),
                          _Section(
                            title: 'Exact Location',
                            child: Text(
                              musolla.exactLocation.isEmpty
                                  ? '-'
                                  : musolla.exactLocation,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: _onSurfaceVariant),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _Section(
                            title: 'Facilities',
                            child: _FacilityChips(musolla: musolla),
                          ),
                          const SizedBox(height: 24),
                          _Section(
                            title: 'Location Map',
                            child: Column(
                              children: [
                                _MapPreview(musolla: musolla),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton.icon(
                                    onPressed:
                                        musolla.latitude == null ||
                                            musolla.longitude == null
                                        ? null
                                        : () => _showMapHint(context, musolla),
                                    icon: const Icon(Icons.directions_outlined),
                                    label: const Text('Open in Google Maps'),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (!isAdmin) ...[
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () => context.push(
                                        '/reports/create',
                                        extra: musolla,
                                      ),
                                      icon: const Icon(
                                        Icons.assignment_outlined,
                                      ),
                                      label: const Text('Report Update'),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
    if (musolla.latitude == null || musolla.longitude == null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: _MusollaDetailScreenState._surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _MusollaDetailScreenState._outlineVariant),
        ),
        child: const SizedBox(
          height: 192,
          width: double.infinity,
          child: Center(
            child: Icon(
              Icons.map_outlined,
              size: 48,
              color: _MusollaDetailScreenState._outline,
            ),
          ),
        ),
      );
    }
    final point = LatLng(musolla.latitude!, musolla.longitude!);
    return Container(
      height: 192,
      decoration: BoxDecoration(
        color: _MusollaDetailScreenState._surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _MusollaDetailScreenState._outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
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
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.musolla});
  final Musolla musolla;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AvailabilityPill(available: musolla.available),
        const SizedBox(height: 8),
        Text(
          musolla.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: _MusollaDetailScreenState._onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          musolla.location.isEmpty ? '-' : musolla.location,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: _MusollaDetailScreenState._onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _AvailabilityPill extends StatelessWidget {
  const _AvailabilityPill({required this.available});
  final bool available;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: available ? const Color(0xFF1E4334) : const Color(0xFFFFDAD6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          available ? 'Available' : 'Unavailable',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: available ? Colors.white : const Color(0xFF93000A),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: _MusollaDetailScreenState._onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _FacilityChips extends StatelessWidget {
  const _FacilityChips({required this.musolla});
  final Musolla musolla;

  @override
  Widget build(BuildContext context) {
    final facilities = [
      if (musolla.facilities.wudhu) (Icons.water_drop_outlined, 'Wudu'),
      if (musolla.facilities.aircond) (Icons.air_outlined, 'AC'),
      if (musolla.facilities.prayerMats)
        (Icons.self_improvement_outlined, 'Mats'),
      if (musolla.facilities.telekung) (Icons.checkroom_outlined, 'Telekung'),
      if (musolla.facilities.toilet) (Icons.wc_outlined, 'Toilet'),
    ];

    if (facilities.isEmpty) {
      return Text(
        'Facilities not listed',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: _MusollaDetailScreenState._onSurfaceVariant,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final facility in facilities)
          Chip(
            avatar: Icon(
              facility.$1,
              size: 18,
              color: _MusollaDetailScreenState._onSurfaceVariant,
            ),
            label: Text(facility.$2),
            labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: _MusollaDetailScreenState._onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
            backgroundColor: _MusollaDetailScreenState._surfaceContainer,
            side: const BorderSide(
              color: _MusollaDetailScreenState._outlineVariant,
            ),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
      ],
    );
  }
}

class _Gallery extends StatefulWidget {
  const _Gallery({required this.musolla});
  final Musolla musolla;

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.musolla.images.isEmpty
        ? [widget.musolla.imageUrl]
        : widget.musolla.images;

    return SizedBox(
      height: MediaQuery.sizeOf(context).width >= 768 ? 384 : 256,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            itemCount: images.length,
            onPageChanged: (value) => setState(() => _index = value),
            itemBuilder: (context, index) => NetworkImageBox(
              url: images[index],
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          if (images.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < images.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _index
                            ? _MusollaDetailScreenState._primary
                            : Colors.white.withValues(alpha: .65),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
