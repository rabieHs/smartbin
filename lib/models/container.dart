// ignore_for_file: public_member_api_docs, sort_constructors_first

class Trash {
  final String id;
  final double longitude;
  final double latitude;
  final int volume;
  double? distace;
  double? timeTaken;
  Trash(
      {required this.id,
      required this.longitude,
      required this.latitude,
      required this.volume,
      this.distace,
      this.timeTaken});

  factory Trash.fromMap(Map<String, dynamic> map) {
    return Trash(
      id: map['id'],
      longitude: map['longitude'],
      latitude: map['latitude'],
      volume: map['volume'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'longitude': longitude,
      'latitude': latitude,
      'volume': volume,
    };
  }
}
