class Store {
  final String id;
  final String name;
  final String openingHours;
  final String closingHours;
  final bool available;
  final List<String> catalogs;

  Store({
    required this.id,
    required this.name,
    required this.openingHours,
    required this.closingHours,
    required this.available,
    required this.catalogs,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    List<String> catalogs = [];
    if (json['catalog'] != null) {
      catalogs = json['catalog']
          .map<String>((catalog) => catalog['_ref'] as String)
          .toList();
    }
    return Store(
      id: json['_id'],
      name: json['name']['es_es'],
      openingHours: json['openingHours'],
      closingHours: json['closingHours'],
      available: json['available'],
      catalogs: catalogs,
    );
  }
}
