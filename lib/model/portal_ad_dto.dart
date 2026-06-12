class PortalAdDto {
  final int id;
  final String title;
  final String? subtitle;
  final String? tag;
  final String cta;
  final String gradient;
  final String accent;
  final String? imageUrl;
  final String? linkType;
  final String? linkValue;

  const PortalAdDto({
    required this.id,
    required this.title,
    this.subtitle,
    this.tag,
    this.cta = 'Shop Now',
    this.gradient = 'linear-gradient(135deg,#07101e 0%,#0d2b5e 100%)',
    this.accent = '#f0560f',
    this.imageUrl,
    this.linkType,
    this.linkValue,
  });

  factory PortalAdDto.fromJson(Map<String, dynamic> j) => PortalAdDto(
    id:        j['id'] as int,
    title:     j['title'] as String,
    subtitle:  j['subtitle'] as String?,
    tag:       j['tag'] as String?,
    cta:       (j['cta'] as String?) ?? 'Shop Now',
    gradient:  (j['gradient'] as String?) ?? 'linear-gradient(135deg,#07101e 0%,#0d2b5e 100%)',
    accent:    (j['accent'] as String?) ?? '#f0560f',
    imageUrl:  j['imageUrl'] as String?,
    linkType:  j['linkType'] as String?,
    linkValue: j['linkValue'] as String?,
  );
}
