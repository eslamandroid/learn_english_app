
DateTime toDateTime(String raw) {
  final d = DateTime.tryParse(raw);
  if (d != null) return d;
  throw ArgumentError('Invalid date: $raw');
}



double? toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  final s = v.toString().trim();
  if (s.isEmpty) return null;
  return double.tryParse(s);
}