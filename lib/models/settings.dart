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

class Settings {
  const Settings({
    this.enabled = const {
      Section.summary,
      Section.education,
      Section.experience,
      Section.projects,
      Section.skills,
    },
    this.font = ResumeFont.helvetica,
    this.fontSize = 10,
    this.margin = Margin.quarter,
  });

  final Set<Section> enabled;
  final ResumeFont font;
  final int fontSize;
  final Margin margin;

  bool isOn(Section s) => enabled.contains(s);

  Settings copyWith({
    Set<Section>? enabled,
    ResumeFont? font,
    int? fontSize,
    Margin? margin,
  }) =>
      Settings(
        enabled: enabled ?? this.enabled,
        font: font ?? this.font,
        fontSize: fontSize ?? this.fontSize,
        margin: margin ?? this.margin,
      );

  Settings toggle(Section s) {
    final next = Set<Section>.from(enabled);
    next.contains(s) ? next.remove(s) : next.add(s);
    return copyWith(enabled: next);
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled.map((e) => e.name).toList(),
        'font': font.name,
        'fontSize': fontSize,
        'margin': margin.name,
      };

  factory Settings.fromJson(Map<String, dynamic> json) {
    final raw = json['enabled'];
    final names = raw is List ? raw.cast<String>() : const <String>[];
    return Settings(
      enabled: names
          .map((n) => Section.values.where((s) => s.name == n).firstOrNull)
          .whereType<Section>()
          .toSet(),
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
