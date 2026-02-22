class Gym {
  final int? id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final double rating;
  final String? crowdStatus;
  final bool hasParking;
  final bool hasShower;
  final bool hasEnduranceWall;
  final String? imageUrl;

  Gym({
    this.id,
    required this.name,
    this.address = '',
    this.lat = 0.0,
    this.lng = 0.0,
    this.rating = 0.0,
    this.crowdStatus,
    this.hasParking = false,
    this.hasShower = false,
    this.hasEnduranceWall = false,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'address': address,
        'lat': lat,
        'lng': lng,
        'rating': rating,
        'crowd_status': crowdStatus,
        'has_parking': hasParking ? 1 : 0,
        'has_shower': hasShower ? 1 : 0,
        'has_endurance_wall': hasEnduranceWall ? 1 : 0,
        'image_url': imageUrl,
      };

  factory Gym.fromMap(Map<String, dynamic> map) => Gym(
        id: map['id'] as int?,
        name: map['name'] as String,
        address: map['address'] as String? ?? '',
        lat: (map['lat'] as num?)?.toDouble() ?? 0.0,
        lng: (map['lng'] as num?)?.toDouble() ?? 0.0,
        rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
        crowdStatus: map['crowd_status'] as String?,
        hasParking: (map['has_parking'] as int?) == 1,
        hasShower: (map['has_shower'] as int?) == 1,
        hasEnduranceWall: (map['has_endurance_wall'] as int?) == 1,
        imageUrl: map['image_url'] as String?,
      );
}
