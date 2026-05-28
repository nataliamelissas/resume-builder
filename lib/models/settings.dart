/// User-facing rendering settings: which sections to include, font, size,
/// and page margins. Kept separate from [Resume] so the data and the
/// presentation can be persisted (and reset) independently.
library;

/// Optional sections that can be toggled on/off. Bio is always shown.
enum Section { summary, education, experience, projects, skills }

/// Standard PDF-14 fonts. Picked from this fixed set so ATS parsers never
/// have to deal with an embedded font subset.
enum ResumeFont { helvetica, times, courier }

/// Page margin in inches. ATS-safe values only.
enum Margin {
  half(0.5),
  quarter(0.25),
  eighth(0.125);

  const Margin(this.inches);
  final double inches;
}

/// Default section order used when nothing is persisted yet.
const List<Section> kDefaultSectionOrder = [
  Section.summary,
  Section.experience,
  Section.education,
  Section.projects,
  Section.skills,
];

class Settings {
  const Settings({
    this.enabled = const {
      Section.summary,
      Section.education,
      Section.experience,
      Section.projects,
      Section.skills,
    },
    this.order = kDefaultSectionOrder,
    this.font = ResumeFont.helvetica,
    this.fontSize = 10,
    this.margin = Margin.quarter,
  });

  final Set<Section> enabled;
  /// Persisted display order. Always contains every [Section] exactly once so
  /// re-enabling a previously-disabled section keeps its position.
  final List<Section> order;
  final ResumeFont font;
  final int fontSize;
  final Margin margin;

  bool isOn(Section s) => enabled.contains(s);

  Settings copyWith({
    Set<Section>? enabled,
    List<Section>? order,
    ResumeFont? font,
    int? fontSize,
    Margin? margin,
  }) =>
      Settings(
        enabled: enabled ?? this.enabled,
        order: order ?? this.order,
        font: font ?? this.font,
        fontSize: fontSize ?? this.fontSize,
        margin: margin ?? this.margin,
      );

  Settings toggle(Section s) {
    final next = Set<Section>.from(enabled);
    next.contains(s) ? next.remove(s) : next.add(s);
    return copyWith(enabled: next);
  }

  /// Move section [s] to index [newIndex] in [order], shifting the rest.
  Settings reorder(Section s, int newIndex) {
    final next = [...order]..remove(s);
    next.insert(newIndex.clamp(0, next.length), s);
    return copyWith(order: next);
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled.map((e) => e.name).toList(),
        'order': order.map((e) => e.name).toList(),
        'font': font.name,
        'fontSize': fontSize,
        'margin': margin.name,
      };

  factory Settings.fromJson(Map<String, dynamic> json) {
    final rawEnabled = json['enabled'];
    final enabledNames =
        rawEnabled is List ? rawEnabled.cast<String>() : const <String>[];

    final rawOrder = json['order'];
    final orderNames =
        rawOrder is List ? rawOrder.cast<String>() : const <String>[];
    final parsedOrder = orderNames
        .map((n) => Section.values.where((s) => s.name == n).firstOrNull)
        .whereType<Section>()
        .toList();
    // Append any missing sections (e.g. after a model upgrade) at the end.
    for (final s in Section.values) {
      if (!parsedOrder.contains(s)) parsedOrder.add(s);
    }

    return Settings(
      enabled: enabledNames
          .map((n) => Section.values.where((s) => s.name == n).firstOrNull)
          .whereType<Section>()
          .toSet(),
      order: parsedOrder,
      font: ResumeFont.values.firstWhere(
        (e) => e.name == json['font'],
        orElse: () => ResumeFont.helvetica,
      ),
      fontSize: (json['fontSize'] as int?) ?? 10,
      margin: Margin.values.firstWhere(
        (e) => e.name == json['margin'],
        orElse: () => Margin.quarter,
      ),
    );
  }
}
