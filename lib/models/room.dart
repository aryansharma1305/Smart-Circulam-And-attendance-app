class Room {
  final String id;
  final String name;
  final String building;
  final int floor;
  final int capacity;
  final String? bleUuid;
  final String? wifiSsid;
  final String? wifiBssid;
  final List<String> equipment;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Room({
    required this.id,
    required this.name,
    required this.building,
    required this.floor,
    required this.capacity,
    this.bleUuid,
    this.wifiSsid,
    this.wifiBssid,
    required this.equipment,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      building: map['building'] ?? '',
      floor: map['floor'] ?? 0,
      capacity: map['capacity'] ?? 0,
      bleUuid: map['ble_uuid'],
      wifiSsid: map['wifi_ssid'],
      wifiBssid: map['wifi_bssid'],
      equipment: List<String>.from(map['equipment'] ?? []),
      isActive: map['is_active'] ?? true,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'building': building,
      'floor': floor,
      'capacity': capacity,
      'ble_uuid': bleUuid,
      'wifi_ssid': wifiSsid,
      'wifi_bssid': wifiBssid,
      'equipment': equipment,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Room copyWith({
    String? id,
    String? name,
    String? building,
    int? floor,
    int? capacity,
    String? bleUuid,
    String? wifiSsid,
    String? wifiBssid,
    List<String>? equipment,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      building: building ?? this.building,
      floor: floor ?? this.floor,
      capacity: capacity ?? this.capacity,
      bleUuid: bleUuid ?? this.bleUuid,
      wifiSsid: wifiSsid ?? this.wifiSsid,
      wifiBssid: wifiBssid ?? this.wifiBssid,
      equipment: equipment ?? this.equipment,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
