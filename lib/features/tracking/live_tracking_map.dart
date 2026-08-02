import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../home/models/available_booking_response_model.dart';
import 'tracking_repository.dart';

/// Shows on the customer's side: customer pin (fixed) + technician pin (live, polls 5s)
class CustomerTrackingMap extends StatefulWidget {
  final String bookingId;
  final double customerLat;
  final double customerLng;

  const CustomerTrackingMap({
    super.key,
    required this.bookingId,
    required this.customerLat,
    required this.customerLng,
  });

  @override
  State<CustomerTrackingMap> createState() => _CustomerTrackingMapState();
}

class _CustomerTrackingMapState extends State<CustomerTrackingMap> {
  final _repo = TrackingRepository();
  final _mapController = MapController();
  TechnicianLocationModel? _techLoc;
  Timer? _timer;
  bool _following = true;

  @override
  void initState() {
    super.initState();
    _poll();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _poll());
  }

  Future<void> _poll() async {
    final loc = await _repo.getTechnicianLocation(widget.bookingId);
    if (!mounted) return;
    setState(() => _techLoc = loc);
    if (loc != null && _following) {
      _mapController.move(LatLng(loc.lat, loc.lng), _mapController.camera.zoom);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final customerPin = LatLng(widget.customerLat, widget.customerLng);

    return Scaffold(
      appBar: AppBar(title: const Text('Track Technician')),
      body: Stack(children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _techLoc != null
                ? LatLng(_techLoc!.lat, _techLoc!.lng)
                : customerPin,
            initialZoom: 14,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
            onPositionChanged: (_, hasGesture) {
              if (hasGesture) setState(() => _following = false);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
              userAgentPackageName: 'com.kajache.app',
            ),
            MarkerLayer(markers: [
              // Customer location (blue)
              Marker(
                point: customerPin,
                width: 44, height: 44,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(Icons.home_outlined, color: Colors.white, size: 22),
                ),
              ),
              // Technician location (green, live)
              if (_techLoc != null)
                Marker(
                  point: LatLng(_techLoc!.lat, _techLoc!.lng),
                  width: 52, height: 52,
                  child: Column(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.engineering_outlined, color: Colors.white, size: 22),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                        child: const Text('Tech', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
            ]),
          ],
        ),

        // Legend
        Positioned(
          top: 12, right: 12,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _LegendRow(color: colors.primary, icon: Icons.home_outlined, label: 'Your Location'),
                const SizedBox(height: 6),
                _LegendRow(color: Colors.green, icon: Icons.engineering_outlined, label: 'Technician'),
              ],
            ),
          ),
        ),

        if (_techLoc == null)
          Positioned(
            bottom: 24, left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 8),
                    Text('Waiting for technician location…', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),

        if (!_following && _techLoc != null)
          Positioned(
            bottom: 24, right: 16,
            child: FloatingActionButton.small(
              heroTag: 'refollow',
              onPressed: () {
                setState(() => _following = true);
                _mapController.move(LatLng(_techLoc!.lat, _techLoc!.lng), 15);
              },
              child: const Icon(Icons.my_location_rounded),
            ),
          ),
      ]),
    );
  }
}

/// Shows on the technician's side: customer pin (fixed) + broadcasts own position every 5s
class TechnicianTrackingMap extends StatefulWidget {
  final String bookingId;
  final double customerLat;
  final double customerLng;

  const TechnicianTrackingMap({
    super.key,
    required this.bookingId,
    required this.customerLat,
    required this.customerLng,
  });

  @override
  State<TechnicianTrackingMap> createState() => _TechnicianTrackingMapState();
}

class _TechnicianTrackingMapState extends State<TechnicianTrackingMap> {
  final _repo = TrackingRepository();
  final _mapController = MapController();
  LatLng? _myPos;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _broadcastAndUpdate();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _broadcastAndUpdate());
  }

  Future<void> _broadcastAndUpdate() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) return;
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (!mounted) return;
      setState(() => _myPos = LatLng(pos.latitude, pos.longitude));
      await _repo.updateTechnicianLocation(
          widget.bookingId, pos.latitude, pos.longitude);
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final customerPin = LatLng(widget.customerLat, widget.customerLng);

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Location')),
      body: Stack(children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(initialCenter: customerPin, initialZoom: 14, interactionOptions: const InteractionOptions(flags: InteractiveFlag.all)),
          children: [
            TileLayer(
              urlTemplate: 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
              userAgentPackageName: 'com.kajache.app',
            ),
            MarkerLayer(markers: [
              // Customer pin (blue)
              Marker(
                point: customerPin,
                width: 44, height: 44,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(Icons.person_outline, color: Colors.white, size: 22),
                ),
              ),
              // My position (green)
              if (_myPos != null)
                Marker(
                  point: _myPos!,
                  width: 44, height: 44,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(Icons.engineering_outlined, color: Colors.white, size: 22),
                  ),
                ),
            ]),
          ],
        ),

        Positioned(
          top: 12, right: 12,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _LegendRow(color: colors.primary, icon: Icons.person_outline, label: 'Customer'),
                const SizedBox(height: 6),
                _LegendRow(color: Colors.green, icon: Icons.engineering_outlined, label: 'You'),
              ],
            ),
          ),
        ),

        Positioned(
          bottom: 24, left: 0, right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  const Text('Broadcasting location every 5s', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  const _LegendRow({required this.color, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 13),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      );
}

// ── Map showing all bidders' locations ───────────────────────────────────────
class BiddersMapPage extends StatelessWidget {
  final List<BookingBidModel> bids;
  final double? customerLat;
  final double? customerLng;

  const BiddersMapPage({
    super.key,
    required this.bids,
    this.customerLat,
    this.customerLng,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final biddersWithLocation = bids
        .where((b) => b.providerLat != null && b.providerLng != null)
        .toList();

    final hasCustomer = customerLat != null && customerLng != null;

    final center = hasCustomer
        ? LatLng(customerLat!, customerLng!)
        : biddersWithLocation.isNotEmpty
            ? LatLng(biddersWithLocation.first.providerLat!, biddersWithLocation.first.providerLng!)
            : const LatLng(23.8103, 90.4125);

    final markers = <Marker>[
      if (hasCustomer)
        Marker(
          point: LatLng(customerLat!, customerLng!),
          width: 44, height: 44,
          child: Container(
            decoration: BoxDecoration(
              color: colors.primary, shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(Icons.home_outlined, color: Colors.white, size: 22),
          ),
        ),
      ...biddersWithLocation.map((bid) => Marker(
        point: LatLng(bid.providerLat!, bid.providerLng!),
        width: 56, height: 64,
        child: Column(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: bid.status == 'selected' ? Colors.green : Colors.orange,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(Icons.engineering_outlined, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: bid.status == 'selected' ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '৳${bid.price}',
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      )),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Bidders Map (${biddersWithLocation.length} located)')),
      body: biddersWithLocation.isEmpty && !hasCustomer
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_off_outlined, size: 48, color: colors.onSurfaceVariant),
                  const SizedBox(height: 12),
                  const Text('No bidder locations available yet.\nBidders share location when placing a bid.', textAlign: TextAlign.center),
                ],
              ),
            )
          : Stack(children: [
              FlutterMap(
                options: MapOptions(initialCenter: center, initialZoom: 13, interactionOptions: const InteractionOptions(flags: InteractiveFlag.all)),
                children: [
                  TileLayer(
                    urlTemplate: 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                    userAgentPackageName: 'com.kajache.app',
                  ),
                  MarkerLayer(markers: markers),
                ],
              ),
              Positioned(
                top: 12, right: 12,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.surface, borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasCustomer) _LegendRow(color: colors.primary, icon: Icons.home_outlined, label: 'Your Location'),
                      if (hasCustomer) const SizedBox(height: 6),
                      _LegendRow(color: Colors.green, icon: Icons.engineering_outlined, label: 'Selected Bidder'),
                      const SizedBox(height: 6),
                      _LegendRow(color: Colors.orange, icon: Icons.engineering_outlined, label: 'Bidder'),
                    ],
                  ),
                ),
              ),
            ]),
    );
  }
}
