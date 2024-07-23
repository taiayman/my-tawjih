import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EducationPathway {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<Specialization> specializations;

  EducationPathway({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.specializations,
  });

  factory EducationPathway.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return EducationPathway(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      specializations: (data['specializations'] as List? ?? [])
          .map((spec) => Specialization.fromFirestore(spec))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'specializations': specializations.map((spec) => spec.toMap()).toList(),
    };
  }
}

class Specialization {
  final String id;
  final String name;
  final String description;
  final List<University> universities;

  Specialization({
    required this.id,
    required this.name,
    required this.description,
    required this.universities,
  });

  factory Specialization.fromFirestore(Map<String, dynamic> data) {
    return Specialization(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      universities: (data['universities'] as List? ?? [])
          .map((uni) => University.fromFirestore(uni))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'universities': universities.map((uni) => uni.toMap()).toList(),
    };
  }
}

class University {
  final String id;
  final String name;
  final String description;
  final String website;
  final String imageUrl;
  final double? imageHeight;
  final double? titleFontSize;
  final Color? titleColor;
  final TextAlign? titleAlignment;
  final Color? detailsColor;
  final double? detailsFontSize;
  final double? descriptionFontSize;
  final Color? descriptionColor;
  final TextAlign? descriptionAlignment;
  final List<ContentBlock> contentBlocks;
  final List<ButtonLink> buttonLinks;
  final List<IconLink> iconLinks;

  University({
    required this.id,
    required this.name,
    required this.description,
    required this.website,
    this.imageUrl = '',
    this.imageHeight,
    this.titleFontSize,
    this.titleColor,
    this.titleAlignment,
    this.detailsColor,
    this.detailsFontSize,
    this.descriptionFontSize,
    this.descriptionColor,
    this.descriptionAlignment,
    this.contentBlocks = const [],
    this.buttonLinks = const [],
    this.iconLinks = const [],
  });

  factory University.fromFirestore(Map<String, dynamic> data) {
    return University(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      website: data['website'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      imageHeight: data['imageHeight'] != null ? (data['imageHeight'] as num).toDouble() : null,
      titleFontSize: data['titleFontSize'] != null ? (data['titleFontSize'] as num).toDouble() : null,
      titleColor: data['titleColor'] != null ? Color(data['titleColor'] as int) : null,
      titleAlignment: data['titleAlignment'] != null ? TextAlign.values[data['titleAlignment']] : null,
      detailsColor: data['detailsColor'] != null ? Color(data['detailsColor'] as int) : null,
      detailsFontSize: data['detailsFontSize'] != null ? (data['detailsFontSize'] as num).toDouble() : null,
      descriptionFontSize: data['descriptionFontSize'] != null ? (data['descriptionFontSize'] as num).toDouble() : null,
      descriptionColor: data['descriptionColor'] != null ? Color(data['descriptionColor'] as int) : null,
      descriptionAlignment: data['descriptionAlignment'] != null ? TextAlign.values[data['descriptionAlignment']] : null,
      contentBlocks: _parseContentBlocks(data['contentBlocks']),
      buttonLinks: (data['buttonLinks'] as List<dynamic>? ?? [])
          .map((link) => ButtonLink.fromMap(link))
          .toList(),
      iconLinks: (data['iconLinks'] as List<dynamic>? ?? [])
          .map((link) => IconLink.fromMap(link))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'website': website,
      'imageUrl': imageUrl,
      'imageHeight': imageHeight,
      'titleFontSize': titleFontSize,
      'titleColor': titleColor?.value,
      'titleAlignment': titleAlignment?.index,
      'detailsColor': detailsColor?.value,
      'detailsFontSize': detailsFontSize,
      'descriptionFontSize': descriptionFontSize,
      'descriptionColor': descriptionColor?.value,
      'descriptionAlignment': descriptionAlignment?.index,
      'contentBlocks': contentBlocks.map((block) => block.toMap()).toList(),
      'buttonLinks': buttonLinks.map((link) => link.toMap()).toList(),
      'iconLinks': iconLinks.map((link) => link.toMap()).toList(),
    };
  }
  
  static List<ContentBlock> _parseContentBlocks(dynamic contentBlocksData) {
    if (contentBlocksData is List) {
      return contentBlocksData.map((blockData) {
        if (blockData is Map<String, dynamic>) {
          switch (blockData['type']) {
            case 'text':
              return TextBlock.fromMap(blockData);
            case 'image':
              return ImageBlock.fromMap(blockData);
            case 'code':
              return CodeBlock.fromMap(blockData);
            case 'blockquote':
              return BlockquoteBlock.fromMap(blockData);
            default:
              return TextBlock(
                text: 'Unknown Block Type',
                textStyle: TextStyle(),
                alignment: TextAlign.left,
              );
          }
        } else {
          return TextBlock(
            text: 'Invalid Block Data',
            textStyle: TextStyle(),
            alignment: TextAlign.left,
          );
        }
      }).toList();
    }
    return [];
  }
}

//Content Blocks for University

enum ContentType { text, image, code, blockquote }

abstract class ContentBlock {
  ContentType type;

  ContentBlock({required this.type});

  Map<String, dynamic> toMap();

  factory ContentBlock.fromMap(Map<String, dynamic> map) {
    switch (map['type']) {
      case 'text':
        return TextBlock.fromMap(map);
      case 'image':
        return ImageBlock.fromMap(map);
      case 'code':
        return CodeBlock.fromMap(map);
      case 'blockquote':
        return BlockquoteBlock.fromMap(map);
      default:
        return TextBlock(
          text: 'Unknown Block Type',
          textStyle: TextStyle(),
          alignment: TextAlign.left,
        );
    }
  }
}

class TextBlock extends ContentBlock {
  String text;
  TextStyle textStyle;
  TextEditingController controller = TextEditingController();
  TextAlign alignment;

  TextBlock({
    required this.text,
    this.textStyle = const TextStyle(),
    this.alignment = TextAlign.left,
  }) : super(type: ContentType.text) {
    controller.text = text;
  }

  factory TextBlock.fromMap(Map<String, dynamic> map) {
    return TextBlock(
      text: map['text'] ?? '',
      textStyle: TextStyle(
        fontSize: (map['textStyle']['fontSize'] as num?)?.toDouble(),
        fontWeight: _parseFontWeight(map['textStyle']['fontWeight']),
        fontStyle: _parseFontStyle(map['textStyle']['fontStyle']),
        color: Color(map['textStyle']['color'] as int? ?? 0xFF000000),
        decoration: _parseTextDecoration(map['textStyle']['decoration']),
      ),
      alignment: TextAlign.values[map['alignment'] as int? ?? 0],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'text',
      'text': text,
      'textStyle': {
        'fontSize': textStyle.fontSize,
        'fontWeight': textStyle.fontWeight?.index,
        'fontStyle': textStyle.fontStyle?.index,
        'color': textStyle.color?.value,
        'decoration': textStyle.decoration?.toString(),
      },
      'alignment': alignment.index,
    };
  }

  static FontWeight? _parseFontWeight(dynamic value) {
    if (value is int) {
      return FontWeight.values[value];
    }
    return null;
  }

  static FontStyle? _parseFontStyle(dynamic value) {
    if (value is int) {
      return FontStyle.values[value];
    }
    return null;
  }

  static TextDecoration? _parseTextDecoration(dynamic value) {
    if (value is String) {
      switch (value) {
        case 'TextDecoration.none':
          return TextDecoration.none;
        case 'TextDecoration.underline':
          return TextDecoration.underline;
        case 'TextDecoration.overline':
          return TextDecoration.overline;
        case 'TextDecoration.lineThrough':
          return TextDecoration.lineThrough;
        default:
          return TextDecoration.none;
      }
    }
    return null;
  }
}

class ImageBlock extends ContentBlock {
  String? imageUrl;

  ImageBlock({this.imageUrl}) : super(type: ContentType.image);

  factory ImageBlock.fromMap(Map<String, dynamic> map) {
    return ImageBlock(
      imageUrl: map['imageUrl'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'image',
      'imageUrl': imageUrl,
    };
  }
}

class CodeBlock extends ContentBlock {
  String text;
  TextEditingController controller = TextEditingController();

  CodeBlock({required this.text}) : super(type: ContentType.code) {
    controller.text = text;
  }

  factory CodeBlock.fromMap(Map<String, dynamic> map) {
    return CodeBlock(
      text: map['text'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'code',
      'text': text,
    };
  }
}

class BlockquoteBlock extends ContentBlock {
  String text;
  TextEditingController controller = TextEditingController();

  BlockquoteBlock({required this.text}) : super(type: ContentType.blockquote) {
    controller.text = text;
  }

  factory BlockquoteBlock.fromMap(Map<String, dynamic> map) {
    return BlockquoteBlock(
      text: map['text'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'blockquote',
      'text': text,
    };
  }
}

// ButtonLink and IconLink for University

class ButtonLink {
  final String text;
  final String url;

  ButtonLink({required this.text, required this.url});

  factory ButtonLink.fromMap(Map<String, dynamic> map) {
    return ButtonLink(
      text: map['text'] ?? '',
      url: map['url'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'url': url,
    };
  }
}

class IconLink {
  final String iconUrl; // Changed from iconName to iconUrl
  final String url;

  IconLink({required this.iconUrl, required this.url});

  factory IconLink.fromMap(Map<String, dynamic> map) {
    return IconLink(
      iconUrl: map['iconUrl'] ?? '', // Changed from iconName to iconUrl
      url: map['url'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'iconUrl': iconUrl, // Changed from iconName to iconUrl
      'url': url,
    };
  }
}