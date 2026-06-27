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
      appBar: AppBar(
        title: Text(
          _isEdit
              ? 'Edit Report'
              : _isMusollaUpdate
              ? 'Report Update'
              : 'Submit Report',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              key: const Key('report_name'),
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _location,
              decoration: const InputDecoration(labelText: 'Location'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _exactLocation,
              decoration: const InputDecoration(labelText: 'Exact Location'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latitude,
                    decoration: const InputDecoration(labelText: 'Latitude'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _longitude,
                    decoration: const InputDecoration(labelText: 'Longitude'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: provider.loading ? null : _useCurrentLocation,
                icon: const Icon(Icons.my_location_outlined),
                label: const Text('Use Current Location'),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _available,
              onChanged: (value) => setState(() => _available = value),
              title: const Text('Available'),
            ),
            const SizedBox(height: 8),
            Text('Facilities', style: Theme.of(context).textTheme.titleMedium),
            CheckboxListTile(
              value: _wudhu,
              onChanged: (value) => setState(() => _wudhu = value ?? false),
              title: const Text('Wudhu'),
            ),
            CheckboxListTile(
              value: _toilet,
              onChanged: (value) => setState(() => _toilet = value ?? false),
              title: const Text('Toilet'),
            ),
            CheckboxListTile(
              value: _aircond,
              onChanged: (value) => setState(() => _aircond = value ?? false),
              title: const Text('Aircond'),
            ),
            CheckboxListTile(
              value: _prayerMats,
              onChanged: (value) =>
                  setState(() => _prayerMats = value ?? false),
              title: const Text('Prayer Mats'),
            ),
            CheckboxListTile(
              value: _telekung,
              onChanged: (value) => setState(() => _telekung = value ?? false),
              title: const Text('Telekung'),
            ),
            if (!_isEdit) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text('Upload Images (${_images.length}/5)'),
              ),
              if (_images.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_images.map((file) => file.name).join(', ')),
                ),
            ],
            const SizedBox(height: 18),
            FilledButton(
              onPressed: provider.loading ? null : _submit,
              child: provider.loading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      _isEdit
                          ? 'Save Changes'
                          : _isMusollaUpdate
                          ? 'Report Update'
                          : 'Submit Report',
                    ),
            ),
            if (provider.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  provider.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.length > 5) {
      if (mounted) showAppMessage(context, 'Maximum 5 images allowed');
    }
    setState(() {
      _images
        ..clear()
        ..addAll(picked.take(5));
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
