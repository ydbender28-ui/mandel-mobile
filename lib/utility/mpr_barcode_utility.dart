int? parseMprProductId(String code) {
  if (!code.trim().toUpperCase().startsWith('MPR:')) return null;
  final digits = code.trim().substring(4).replaceAll(RegExp(r'^0+'), '');
  return int.tryParse(digits.isEmpty ? '0' : digits);
}
