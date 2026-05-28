/// Immutable resume data model. JSON round-trips losslessly so the same shape
/// can be persisted to localStorage or exported to disk.
library;

import 'dart:convert';

/// Top-level resume: identity header + optional content sections.
class Resume {
  const Resume({
    this.bio = const Bio(),
    this.summary = '',
    this.education = const [],
    this.experience = const [],
    this.projects = const [],
    this.skills = const [],
  });

  final Bio bio;
  final String summary;
  final List<EducationItem> education;
  final List<ExperienceItem> experience;
  final List<ProjectItem> projects;
  final List<SkillGroup> skills;

  Resume copyWith({
    Bio? bio,
    String? summary,
    List<EducationItem>? education,
    List<ExperienceItem>? experience,
    List<ProjectItem>? projects,
    List<SkillGroup>? skills,
  }) =>
      Resume(
        bio: bio ?? this.bio,
        summary: summary ?? this.summary,
        education: education ?? this.education,
        experience: experience ?? this.experience,
        projects: projects ?? this.projects,
        skills: skills ?? this.skills,
      );

  Map<String, dynamic> toJson() => {
        'bio': bio.toJson(),
        'summary': summary,
        'education': education.map((e) => e.toJson()).toList(),
        'experience': experience.map((e) => e.toJson()).toList(),
        'projects': projects.map((e) => e.toJson()).toList(),
        'skills': skills,
      };

  factory Resume.fromJson(Map<String, dynamic> json) => Resume(
        bio: Bio.fromJson(_asMap(json['bio'])),
        summary: (json['summary'] as String?) ?? '',
        education: _asList(json['education'])
            .map((e) => EducationItem.fromJson(_asMap(e)))
            .toList(),
        experience: _asList(json['experience'])
            .map((e) => ExperienceItem.fromJson(_asMap(e)))
            .toList(),
        projects: _asList(json['projects'])
            .map((e) => ProjectItem.fromJson(_asMap(e)))
            .toList(),
        skills: _parseSkills(json['skills']),
      );

  String encode() => jsonEncode(toJson());
  static Resume decode(String src) =>
      Resume.fromJson(jsonDecode(src) as Map<String, dynamic>);
}

/// Back-compat: previously `skills` was `List<String>` (a flat list). Detect
/// that shape and migrate it into a single un-named [SkillGroup].
List<SkillGroup> _parseSkills(Object? raw) {
  final list = _asList(raw);
  if (list.isEmpty) return const [];
  if (list.first is String) {
    return [SkillGroup(items: list.cast<String>())];
  }
  return list.map((e) => SkillGroup.fromJson(_asMap(e))).toList();
}

/// A named bucket of skills. PDF renders as `Name: item1, item2, ...`.
class SkillGroup {
  const SkillGroup({this.name = '', this.items = const []});
  final String name;
  final List<String> items;

  SkillGroup copyWith({String? name, List<String>? items}) =>
      SkillGroup(name: name ?? this.name, items: items ?? this.items);

  Map<String, dynamic> toJson() => {'name': name, 'items': items};

  factory SkillGroup.fromJson(Map<String, dynamic> json) => SkillGroup(
        name: (json['name'] as String?) ?? '',
        items: _asList(json['items']).cast<String>(),
      );
}

/// Contact header. Email/phone/links are rendered as selectable, clickable
/// text so ATS parsers extract them as fields.
class Bio {
  const Bio({
    this.name = '',
    this.headline = '',
    this.email = '',
    this.phone = '',
    this.location = '',
    this.links = const [],
  });

  final String name;
  final String headline;
  final String email;
  final String phone;
  final String location;
  final List<Link> links;

  Bio copyWith({
    String? name,
    String? headline,
    String? email,
    String? phone,
    String? location,
    List<Link>? links,
  }) =>
      Bio(
        name: name ?? this.name,
        headline: headline ?? this.headline,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        location: location ?? this.location,
        links: links ?? this.links,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'headline': headline,
        'email': email,
        'phone': phone,
        'location': location,
        'links': links.map((e) => e.toJson()).toList(),
      };

  factory Bio.fromJson(Map<String, dynamic> json) => Bio(
        name: (json['name'] as String?) ?? '',
        headline: (json['headline'] as String?) ?? '',
        email: (json['email'] as String?) ?? '',
        phone: (json['phone'] as String?) ?? '',
        location: (json['location'] as String?) ?? '',
        links: _asList(json['links'])
            .map((e) => Link.fromJson(_asMap(e)))
            .toList(),
      );
}

class Link {
  const Link({this.label = '', this.url = ''});
  final String label;
  final String url;

  Link copyWith({String? label, String? url}) =>
      Link(label: label ?? this.label, url: url ?? this.url);

  Map<String, dynamic> toJson() => {'label': label, 'url': url};
  factory Link.fromJson(Map<String, dynamic> json) => Link(
        label: (json['label'] as String?) ?? '',
        url: (json['url'] as String?) ?? '',
      );
}

class EducationItem {
  const EducationItem({
    this.school = '',
    this.degree = '',
    this.location = '',
    this.start = '',
    this.end = '',
    this.details = '',
  });

  final String school;
  final String degree;
  final String location;
  final String start;
  final String end;
  final String details;

  EducationItem copyWith({
    String? school,
    String? degree,
    String? location,
    String? start,
    String? end,
    String? details,
  }) =>
      EducationItem(
        school: school ?? this.school,
        degree: degree ?? this.degree,
        location: location ?? this.location,
        start: start ?? this.start,
        end: end ?? this.end,
        details: details ?? this.details,
      );

  Map<String, dynamic> toJson() => {
        'school': school,
        'degree': degree,
        'location': location,
        'start': start,
        'end': end,
        'details': details,
      };

  factory EducationItem.fromJson(Map<String, dynamic> json) => EducationItem(
        school: (json['school'] as String?) ?? '',
        degree: (json['degree'] as String?) ?? '',
        location: (json['location'] as String?) ?? '',
        start: (json['start'] as String?) ?? '',
        end: (json['end'] as String?) ?? '',
        details: (json['details'] as String?) ?? '',
      );
}

class ExperienceItem {
  const ExperienceItem({
    this.title = '',
    this.company = '',
    this.location = '',
    this.start = '',
    this.end = '',
    this.bullets = const [],
  });

  final String title;
  final String company;
  final String location;
  final String start;
  final String end;
  final List<String> bullets;

  ExperienceItem copyWith({
    String? title,
    String? company,
    String? location,
    String? start,
    String? end,
    List<String>? bullets,
  }) =>
      ExperienceItem(
        title: title ?? this.title,
        company: company ?? this.company,
        location: location ?? this.location,
        start: start ?? this.start,
        end: end ?? this.end,
        bullets: bullets ?? this.bullets,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'company': company,
        'location': location,
        'start': start,
        'end': end,
        'bullets': bullets,
      };

  factory ExperienceItem.fromJson(Map<String, dynamic> json) => ExperienceItem(
        title: (json['title'] as String?) ?? '',
        company: (json['company'] as String?) ?? '',
        location: (json['location'] as String?) ?? '',
        start: (json['start'] as String?) ?? '',
        end: (json['end'] as String?) ?? '',
        bullets: _asList(json['bullets']).cast<String>(),
      );
}

class ProjectItem {
  const ProjectItem({
    this.name = '',
    this.url = '',
    this.bullets = const [],
  });

  final String name;
  final String url;
  final List<String> bullets;

  ProjectItem copyWith({String? name, String? url, List<String>? bullets}) =>
      ProjectItem(
        name: name ?? this.name,
        url: url ?? this.url,
        bullets: bullets ?? this.bullets,
      );

  Map<String, dynamic> toJson() =>
      {'name': name, 'url': url, 'bullets': bullets};

  factory ProjectItem.fromJson(Map<String, dynamic> json) => ProjectItem(
        name: (json['name'] as String?) ?? '',
        url: (json['url'] as String?) ?? '',
        bullets: _asList(json['bullets']).cast<String>(),
      );
}

Map<String, dynamic> _asMap(Object? v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

List<dynamic> _asList(Object? v) => v is List ? v : const [];
