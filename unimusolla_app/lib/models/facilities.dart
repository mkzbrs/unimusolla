import 'json_helpers.dart';

class Facilities {
  const Facilities({
    this.wudhu = false,
    this.toilet = false,
    this.aircond = false,
    this.prayerMats = false,
    this.telekung = false,
  });

  final bool wudhu;
  final bool toilet;
  final bool aircond;
  final bool prayerMats;
  final bool telekung;

  factory Facilities.fromJson(Map<String, dynamic> json) => Facilities(
    wudhu: boolOf(json['has_wudhu'] ?? json['wudhu']),
    toilet: boolOf(json['has_toilet'] ?? json['toilet']),
    aircond: boolOf(
      json['has_aircond'] ?? json['aircond'] ?? json['air_conditioning'],
    ),
    prayerMats: boolOf(
      json['has_mats'] ?? json['prayer_mats'] ?? json['prayerMat'],
    ),
    telekung: boolOf(json['has_telekung'] ?? json['telekung']),
  );

  Map<String, dynamic> toJson() => {
    'has_wudhu': wudhu ? 1 : 0,
    'has_toilet': toilet ? 1 : 0,
    'has_aircond': aircond ? 1 : 0,
    'has_mats': prayerMats ? 1 : 0,
    'has_telekung': telekung ? 1 : 0,
  };

  List<String> get labels => [
    if (wudhu) 'Wudhu',
    if (toilet) 'Toilet',
    if (aircond) 'Aircond',
    if (prayerMats) 'Prayer Mats',
    if (telekung) 'Telekung',
  ];
}
