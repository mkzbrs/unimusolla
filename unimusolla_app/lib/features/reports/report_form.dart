import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../models/facilities.dart';
import '../../models/musolla.dart';
import '../../models/report.dart';
import '../../providers/report_provider.dart';
import '../../widgets/app_states.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key, this.report, this.sourceMusolla});
  final Report? report;
  final Musolla? sourceMusolla;

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  static const _surface = Color(0xFFF8F9FF);
  static const _surfaceContainerLow = Color(0xFFEFF4FF);
  static const _surfaceContainerHigh = Color(0xFFDEE9FC);
  static const _onSurface = Color(0xFF121C2A);
  static const _onSurfaceVariant = Color(0xFF3F4944);
  static const _outline = Color(0xFF6F7973);
  static const _outlineVariant = Color(0xFFBEC9C2);
  static const _primary = Color(0xFF004532);
  static const _primaryContainer = Color(0xFF065F46);

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _location = TextEditingController();
  final _exactLocation = TextEditingController();
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();
  final _picker = ImagePicker();
  final List<XFile> _images = [];
  bool _available = true;
  bool _wudhu = false;
  bool _toilet = false;
  bool _aircond = false;
  bool _prayerMats = false;
  bool _telekung = false;

  bool get _isEdit => widget.report != null;
  bool get _isMusollaUpdate => widget.sourceMusolla != null;

  @override
  void initState() {
    super.initState();
    final report = widget.report;
    if (report != null) {
      _name.text = report.name;
      _location.text = report.location;
      _exactLocation.text = report.exactLocation;
      _latitude.text = report.latitude?.toString() ?? '';
      _longitude.text = report.longitude?.toString() ?? '';
      _available = report.available;
      _wudhu = report.facilities.wudhu;
      _toilet = report.facilities.toilet;
      _aircond = report.facilities.aircond;
      _prayerMats = report.facilities.prayerMats;
      _telekung = report.facilities.telekung;
      return;
    }
    final musolla = widget.sourceMusolla;
    if (musolla != null) {
      _name.text = musolla.name;
      _location.text = musolla.location;
      _exactLocation.text = musolla.exactLocation;
      _latitude.text = musolla.latitude?.toString() ?? '';
      _longitude.text = musolla.longitude?.toString() ?? '';
      _available = musolla.available;
      _wudhu = musolla.facilities.wudhu;
      _toilet = musolla.facilities.toilet;
      _aircond = musolla.facilities.aircond;
      _prayerMats = musolla.facilities.prayerMats;
      _telekung = musolla.facilities.telekung;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _exactLocation.dispose();
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportProvider>();
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Go back',
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
          icon: const Icon(Icons.arrow_back),
          color: _primary,
        ),
        title: Text(
          'UniMusolla',
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 768),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formTitle,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: _onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!_isEdit) ...[
                              _SectionHeader(
                                title: 'Upload Image',
                                trailing: 'Optional',
                              ),
                              const SizedBox(height: 16),
                              _UploadArea(
                                images: _images,
                                onTap: provider.loading ? null : _pickImages,
                                onRemove: provider.loading
                                    ? null
                                    : (image) =>
                                          setState(() => _images.remove(image)),
                              ),
                              const SizedBox(height: 24),
                              const Divider(color: _outlineVariant),
                              const SizedBox(height: 24),
                            ],
                            const _SectionHeader(title: 'Basic Information'),
                            const SizedBox(height: 16),
                            _TextInput(
                              key: const Key('report_name'),
                              controller: _name,
                              label: 'Musolla Name',
                              hint: 'e.g., Block B Musolla',
                              validator: _required,
                            ),
                            const SizedBox(height: 12),
                            _TextInput(
                              controller: _location,
                              label: 'Location',
                              hint: 'e.g., DKG 1, Block A',
                              validator: _required,
                            ),
                            const SizedBox(height: 12),
                            _TextInput(
                              controller: _exactLocation,
                              label: 'Exact Location',
                              hint: 'e.g., Level 2, near IBS Faculty',
                              validator: _required,
                            ),
                            const SizedBox(height: 16),
                            _MapPickerPanel(
                              latitude: _latitude.text,
                              longitude: _longitude.text,
                              onUseLocation: provider.loading
                                  ? null
                                  : _useCurrentLocation,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<bool>(
                              initialValue: _available,
                              decoration: _inputDecoration('Current Status'),
                              items: const [
                                DropdownMenuItem(
                                  value: true,
                                  child: Text('Available'),
                                ),
                                DropdownMenuItem(
                                  value: false,
                                  child: Text('Unavailable'),
                                ),
                              ],
                              onChanged: (value) => setState(
                                () => _available = value ?? _available,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Divider(color: _outlineVariant),
                            const SizedBox(height: 24),
                            const _SectionHeader(title: 'Facilities Available'),
                            const SizedBox(height: 16),
                            _FacilityGrid(
                              wudhu: _wudhu,
                              toilet: _toilet,
                              aircond: _aircond,
                              prayerMats: _prayerMats,
                              telekung: _telekung,
                              onWudhu: (value) =>
                                  setState(() => _wudhu = value),
                              onToilet: (value) =>
                                  setState(() => _toilet = value),
                              onAircond: (value) =>
                                  setState(() => _aircond = value),
                              onPrayerMats: (value) =>
                                  setState(() => _prayerMats = value),
                              onTelekung: (value) =>
                                  setState(() => _telekung = value),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: provider.loading ? null : _submit,
                                icon: provider.loading
                                    ? const SizedBox.square(
                                        dimension: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.send_outlined),
                                label: Text(_submitLabel),
                                style: FilledButton.styleFrom(
                                  backgroundColor: _primaryContainer,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 24,
                                  ),
                                  shape: const StadiumBorder(),
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            if (provider.error != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  provider.error!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _formTitle => _isEdit
      ? 'Edit Report'
      : _isMusollaUpdate
      ? 'Report Musolla Update'
      : 'Add New Musolla';

  String get _formSubtitle => _isEdit
      ? 'Update your submitted report before admin review.'
      : _isMusollaUpdate
      ? 'Help keep this musolla information accurate for everyone.'
      : 'Contribute to the community by adding a new musolla.';

  String get _submitLabel => _isEdit
      ? 'Save Changes'
      : _isMusollaUpdate
      ? 'Submit Update'
      : 'Submit Musolla';

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _onSurfaceVariant),
      filled: true,
      fillColor: _surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: _outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: _outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: _primaryContainer, width: 2),
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage();
    final availableSlots = 5 - _images.length;
    if (availableSlots <= 0) {
      if (mounted) showAppMessage(context, 'Maximum 5 images allowed');
      return;
    }
    if (picked.length > availableSlots) {
      if (mounted) showAppMessage(context, 'Maximum 5 images allowed');
    }
    setState(() {
      _images.addAll(picked.take(availableSlots));
    });
  }

  Future<void> _useCurrentLocation() async {
    final permission = await Permission.locationWhenInUse.request();
    if (!permission.isGranted) {
      if (mounted) showAppMessage(context, 'Location permission is required');
      return;
    }
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) showAppMessage(context, 'Please enable location services');
      return;
    }
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    if (!mounted) return;
    setState(() {
      _latitude.text = position.latitude.toStringAsFixed(6);
      _longitude.text = position.longitude.toStringAsFixed(6);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final facilities = Facilities(
      wudhu: _wudhu,
      toilet: _toilet,
      aircond: _aircond,
      prayerMats: _prayerMats,
      telekung: _telekung,
    );
    final payload = <String, dynamic>{
      if (_isEdit) 'report_id': widget.report!.id,
      if (_isEdit) 'id': widget.report!.id,
      'musolla_id': _isMusollaUpdate
          ? widget.sourceMusolla!.id
          : widget.report?.musollaId,
      'name': _name.text.trim(),
      'location': _location.text.trim(),
      'exact_location': _exactLocation.text.trim(),
      'latitude': _latitude.text.trim(),
      'longitude': _longitude.text.trim(),
      'status': _available ? 'available' : 'unavailable',
      ...facilities.toJson(),
    };
    final provider = context.read<ReportProvider>();
    final ok = _isEdit
        ? await provider.update(payload)
        : await provider.create(payload, _images);
    if (!mounted) return;
    if (ok) {
      showAppMessage(
        context,
        _isMusollaUpdate
            ? 'Report submitted successfully. An admin will review your changes.'
            : _isEdit
            ? 'Report updated'
            : 'Report submitted',
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/home');
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: _ReportFormScreenState._primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: _ReportFormScreenState._onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

class _UploadArea extends StatelessWidget {
  const _UploadArea({
    required this.images,
    required this.onTap,
    required this.onRemove,
  });
  final List<XFile> images;
  final VoidCallback? onTap;
  final ValueChanged<XFile>? onRemove;

  @override
  Widget build(BuildContext context) {
    final hasImages = images.isNotEmpty;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: hasImages
            ? _ReportFormScreenState._surfaceContainerLow
            : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasImages
              ? _ReportFormScreenState._primary
              : _ReportFormScreenState._outlineVariant,
          width: 2,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: hasImages ? _previewList(context) : _emptyPicker(context),
    );
  }

  Widget _emptyPicker(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 192,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _UploadPrompt(hasImages: false, imageCount: images.length),
          ),
        ),
      ),
    );
  }

  Widget _previewList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _UploadPrompt(hasImages: true, imageCount: images.length),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                if (index == images.length) {
                  return _AddImageTile(onTap: onTap);
                }
                final image = images[index];
                return _SelectedImageTile(
                  image: image,
                  onRemove: onRemove == null ? null : () => onRemove!(image),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadPrompt extends StatelessWidget {
  const _UploadPrompt({required this.hasImages, required this.imageCount});

  final bool hasImages;
  final int imageCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: _ReportFormScreenState._surfaceContainerHigh,
          foregroundColor: _ReportFormScreenState._primaryContainer,
          child: const Icon(Icons.cloud_upload_outlined),
        ),
        const SizedBox(height: 12),
        Text(
          hasImages
              ? 'Selected $imageCount image${imageCount == 1 ? '' : 's'}'
              : 'Tap to upload images',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: hasImages
                ? _ReportFormScreenState._primaryContainer
                : _ReportFormScreenState._onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          hasImages
              ? 'Preview and remove before submit'
              : 'JPEG, PNG up to 5MB',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: _ReportFormScreenState._onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SelectedImageTile extends StatelessWidget {
  const _SelectedImageTile({required this.image, required this.onRemove});

  final XFile image;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(image.path),
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: IconButton.filled(
            tooltip: 'Remove image',
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 18),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: .62),
              foregroundColor: Colors.white,
              minimumSize: const Size(32, 32),
              fixedSize: const Size(32, 32),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}

class _AddImageTile extends StatelessWidget {
  const _AddImageTile({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _ReportFormScreenState._outlineVariant),
        ),
        child: const Icon(
          Icons.add_photo_alternate_outlined,
          color: _ReportFormScreenState._primary,
        ),
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  const _TextInput({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.validator,
  });
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          color: _ReportFormScreenState._onSurfaceVariant,
        ),
        filled: true,
        fillColor: _ReportFormScreenState._surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(
            color: _ReportFormScreenState._outlineVariant,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(
            color: _ReportFormScreenState._outlineVariant,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(
            color: _ReportFormScreenState._primaryContainer,
            width: 2,
          ),
        ),
      ),
    );
  }
}

class _MapPickerPanel extends StatelessWidget {
  const _MapPickerPanel({
    required this.latitude,
    required this.longitude,
    required this.onUseLocation,
  });
  final String latitude;
  final String longitude;
  final VoidCallback? onUseLocation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pin Location on Map',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: _ReportFormScreenState._onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 192,
          width: double.infinity,
          decoration: BoxDecoration(
            color: _ReportFormScreenState._surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _ReportFormScreenState._outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _MapGridPainter())),
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 28),
                  child: Icon(
                    Icons.location_on,
                    size: 44,
                    color: _ReportFormScreenState._primary,
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 48,
                child: Column(
                  children: [
                    _MapControl(icon: Icons.add, onPressed: () {}),
                    const SizedBox(height: 8),
                    _MapControl(icon: Icons.remove, onPressed: () {}),
                    const SizedBox(height: 12),
                    _MapControl(
                      icon: Icons.my_location,
                      color: _ReportFormScreenState._primary,
                      onPressed: onUseLocation,
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ColoredBox(
                  color: Colors.white.withValues(alpha: .82),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'Use current location to pin the musolla on map',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _ReportFormScreenState._onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _CoordinateBox(label: 'Latitude', value: latitude),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _CoordinateBox(label: 'Longitude', value: longitude),
            ),
          ],
        ),
      ],
    );
  }
}

class _MapControl extends StatelessWidget {
  const _MapControl({required this.icon, required this.onPressed, this.color});
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
      elevation: 1,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            icon,
            size: 18,
            color: color ?? _ReportFormScreenState._onSurface,
          ),
        ),
      ),
    );
  }
}

class _CoordinateBox extends StatelessWidget {
  const _CoordinateBox({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: _ReportFormScreenState._outline,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: _ReportFormScreenState._surfaceContainerLow,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: _ReportFormScreenState._outlineVariant),
          ),
          child: Text(
            value.trim().isEmpty ? '-' : value.trim(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _ReportFormScreenState._onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _FacilityGrid extends StatelessWidget {
  const _FacilityGrid({
    required this.wudhu,
    required this.toilet,
    required this.aircond,
    required this.prayerMats,
    required this.telekung,
    required this.onWudhu,
    required this.onToilet,
    required this.onAircond,
    required this.onPrayerMats,
    required this.onTelekung,
  });
  final bool wudhu;
  final bool toilet;
  final bool aircond;
  final bool prayerMats;
  final bool telekung;
  final ValueChanged<bool> onWudhu;
  final ValueChanged<bool> onToilet;
  final ValueChanged<bool> onAircond;
  final ValueChanged<bool> onPrayerMats;
  final ValueChanged<bool> onTelekung;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _FacilityTileData(
        label: 'Wudu Area',
        icon: Icons.water_drop_outlined,
        value: wudhu,
        onChanged: onWudhu,
      ),
      _FacilityTileData(
        label: 'Air Conditioning',
        icon: Icons.ac_unit_outlined,
        value: aircond,
        onChanged: onAircond,
      ),
      _FacilityTileData(
        label: 'Prayer Mats',
        icon: Icons.layers_outlined,
        value: prayerMats,
        onChanged: onPrayerMats,
      ),
      _FacilityTileData(
        label: 'Toilet',
        icon: Icons.wc_outlined,
        value: toilet,
        onChanged: onToilet,
      ),
      _FacilityTileData(
        label: 'Telekung',
        icon: Icons.checkroom_outlined,
        value: telekung,
        onChanged: onTelekung,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 560;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tile in tiles)
              SizedBox(
                width: twoColumns
                    ? (constraints.maxWidth - 8) / 2
                    : constraints.maxWidth,
                child: _FacilityTile(data: tile),
              ),
          ],
        );
      },
    );
  }
}

class _FacilityTileData {
  const _FacilityTileData({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
}

class _FacilityTile extends StatelessWidget {
  const _FacilityTile({required this.data});
  final _FacilityTileData data;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => data.onChanged(!data.value),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: data.value
                ? _ReportFormScreenState._primaryContainer
                : _ReportFormScreenState._outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              value: data.value,
              onChanged: (value) => data.onChanged(value ?? false),
              activeColor: _ReportFormScreenState._primaryContainer,
            ),
            Icon(data.icon, color: _ReportFormScreenState._outline),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                data.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _ReportFormScreenState._onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _ReportFormScreenState._outlineVariant.withValues(alpha: .45)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
