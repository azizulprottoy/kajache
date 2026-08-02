import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class PickedLocation {
  final double lat;
  final double lng;
  final String address;
  final String district;
  final String area;

  PickedLocation({
    required this.lat,
    required this.lng,
    required this.address,
    required this.district,
    required this.area,
  });
}

class MapLocationPicker extends StatefulWidget {
  final LatLng? initialPosition;
  const MapLocationPicker({super.key, this.initialPosition});

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  late final MapController _mapController;
  LatLng _pin = const LatLng(23.8103, 90.4125); // Dhaka default
  bool _loading = false;
  String _address = '';
  String _district = '';
  String _area = '';

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    if (widget.initialPosition != null) _pin = widget.initialPosition!;
    _reverseGeocode(_pin);
  }

  Future<void> _locateMe() async {
    setState(() => _loading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) return;
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final loc = LatLng(pos.latitude, pos.longitude);
      setState(() => _pin = loc);
      _mapController.move(loc, 16);
      await _reverseGeocode(loc);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reverseGeocode(LatLng loc) async {
    try {
      final dio = Dio();
      final res = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': loc.latitude,
          'lon': loc.longitude,
          'format': 'json',
          'accept-language': 'en',
        },
        options: Options(headers: {'User-Agent': 'KajAche/1.0'}),
      );
      final data = res.data is String ? jsonDecode(res.data) : res.data;
      final addr = data['address'] as Map? ?? {};
      setState(() {
        _address = data['display_name']?.toString().split(',').take(3).join(', ') ?? '';
        _district = addr['city_district']?.toString() ??
            addr['suburb']?.toString() ??
            addr['county']?.toString() ?? '';
        _area = addr['neighbourhood']?.toString() ??
            addr['road']?.toString() ?? '';
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Location'),
        actions: [
          TextButton(
            onPressed: _address.isEmpty
                ? null
                : () => Navigator.pop(
                      context,
                      PickedLocation(
                        lat: _pin.latitude,
                        lng: _pin.longitude,
                        address: _address,
                        district: _district,
                        area: _area,
                      ),
                    ),
            child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _pin,
              initialZoom: 14,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
              onTap: (_, loc) {
                setState(() => _pin = loc);
                _reverseGeocode(loc);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                userAgentPackageName: 'com.kajache.app',
              ),
              MarkerLayer(markers: [
                Marker(
                  point: _pin,
                  width: 48,
                  height: 48,
                  child: Icon(Icons.location_pin,
                      color: colorScheme.primary, size: 48),
                ),
              ]),
            ],
          ),

          // Bottom info card
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 12)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.location_on_outlined, color: colorScheme.primary, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _address.isEmpty ? 'Tap map to set location' : _address,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                  if (_district.isNotEmpty || _area.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      [_area, _district].where((s) => s.isNotEmpty).join(', '),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Locate me button
          Positioned(
            right: 16, bottom: 160,
            child: FloatingActionButton.small(
              heroTag: 'locate',
              onPressed: _loading ? null : _locateMe,
              child: _loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location_rounded),
            ),
          ),
        ],
      ),
    );
  }
}
