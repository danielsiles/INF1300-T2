import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

class MapsView extends StatefulWidget {
    String latitude;
    String longitude;
    MapsView(String latitude, String longitude) {
        this.latitude = latitude;
        this.longitude = latitude;
    }
    @override
    _MapsViewState createState() => _MapsViewState();
}

class _MapsViewState extends State<MapsView> {


    GoogleMapController _mapController;
    Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
    var uuid = new Uuid();
    mapLoaded(GoogleMapController controller) {
        _mapController = controller;
        var markerIdVal = uuid.v4();
        final MarkerId markerId = MarkerId(markerIdVal);
        // creating a new MARKER
        final Marker marker = Marker(
            markerId: markerId,
            position: LatLng(double.parse(widget.latitude), double.parse(widget.longitude)),
        );

            // adding a new marker to map
        this.setState(() {
            markers[markerId] = marker;
        });

    }

    @override
    Widget build(BuildContext context) {

        return Scaffold (
            body: Container(
                child: GoogleMap(
                    onMapCreated: mapLoaded,
                    initialCameraPosition: CameraPosition(
                        target: LatLng(double.parse(widget.latitude), double.parse(widget.longitude)),
                        zoom: 15.0,
                    ),
                    markers: Set<Marker>.of(markers.values),
                    scrollGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    rotateGesturesEnabled: false,
                    myLocationEnabled: true,
                    mapType: MapType.normal,
                    zoomGesturesEnabled: true,
                )
            )
        );
    }
}
