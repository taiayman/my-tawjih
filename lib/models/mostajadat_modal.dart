import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Mostajadat {
  final String id;
  final String title;
  final String description;
  final String details;
  final String category;
  final DateTime date;
  final DateTime? deadlineDate;
  final String imageUrl;
  final double titleFontSize;
  final Color titleColor;
  final TextAlign titleAlignment;
  final double descriptionFontSize;
  final Color descriptionColor;
  final TextAlign descriptionAlignment;
  final double detailsFontSize;
  final Color detailsColor;
  final TextAlign detailsAlignment;
  final double categoryFontSize;
  final Color categoryColor;
  final TextAlign categoryAlignment;
  final double dateFontSize;
  final Color dateColor;
  final TextAlign dateAlignment;
  final double imageWidth;
  final double imageHeight;
  final String type;
  final String? cardImagePath;
  final List<ContentBlock> contentBlocks;
  final List<ButtonLink> buttonLinks;
  final List<IconLink> iconLinks;

  Mostajadat({
    required this.id,
    required this.title,
    required this.description,
    required this.details,
    required this.category,
    required this.date,
    this.deadlineDate,
    required this.imageUrl,
    this.titleFontSize = 24.0,
    this.titleColor = Colors.black,
    this.titleAlignment = TextAlign.center,
    this.descriptionFontSize = 18.0,
    this.descriptionColor = Colors.black,
    this.descriptionAlignment = TextAlign.left,
    this.detailsFontSize = 16.0,
    this.detailsColor = Colors.black,
    this.detailsAlignment = TextAlign.left,
    this.categoryFontSize = 16.0,
    this.categoryColor = Colors.black,
    this.categoryAlignment = TextAlign.left,
    this.dateFontSize = 16.0,
    this.dateColor = Colors.black,
    this.dateAlignment = TextAlign.left,
    this.imageWidth = 200.0,
    this.imageHeight = 200.0,
    required this.type,
    this.cardImagePath,
    required this.contentBlocks,
    this.buttonLinks = const [],
    this.iconLinks = const [],
  });

  factory Mostajadat.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Mostajadat(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      details: data['details'] ?? '',
      category: data['category'] ?? 'general',
      date: (data['date'] is Timestamp)
          ? (data['date'] as Timestamp).toDate()
          : DateTime.now(),
      deadlineDate: (data['deadlineDate'] is Timestamp)
          ? (data['deadlineDate'] as Timestamp).toDate()
          : null,
      imageUrl: data['imageUrl'] ?? '',
      titleFontSize: data['titleFontSize'] as double? ?? 24.0,
      titleColor: Color(data['titleColor'] as int? ?? 0xFF000000),
      titleAlignment: TextAlign.values[data['titleAlignment'] as int? ?? 1],
      descriptionFontSize: data['descriptionFontSize'] as double? ?? 18.0,
      descriptionColor: Color(data['descriptionColor'] as int? ?? 0xFF000000),
      descriptionAlignment:
          TextAlign.values[data['descriptionAlignment'] as int? ?? 0],
      detailsFontSize: data['detailsFontSize'] as double? ?? 16.0,
      detailsColor: Color(data['detailsColor'] as int? ?? 0xFF000000),
      detailsAlignment: TextAlign.values[data['detailsAlignment'] as int? ?? 0],
      categoryFontSize: data['categoryFontSize'] as double? ?? 16.0,
      categoryColor: Color(data['categoryColor'] as int? ?? 0xFF000000),
      categoryAlignment:
          TextAlign.values[data['categoryAlignment'] as int? ?? 0],
      dateFontSize: data['dateFontSize'] as double? ?? 16.0,
      dateColor: Color(data['dateColor'] as int? ?? 0xFF000000),
      dateAlignment: TextAlign.values[data['dateAlignment'] as int? ?? 0],
      imageWidth: data['imageWidth'] as double? ?? 200.0,
      imageHeight: data['imageHeight'] as double? ?? 200.0,
      type: data['type'] ?? 'general',
      cardImagePath: data['cardImagePath'],
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
      'title': title,
      'description': description,
      'details': details,
      'category': category,
      'date': Timestamp.fromDate(date),
      'deadlineDate':
          deadlineDate != null ? Timestamp.fromDate(deadlineDate!) : null,
      'imageUrl': imageUrl,
      'titleFontSize': titleFontSize,
      'titleColor': titleColor.value,
      'titleAlignment': titleAlignment.index,
      'descriptionFontSize': descriptionFontSize,
      'descriptionColor': descriptionColor.value,
      'descriptionAlignment': descriptionAlignment.index,
      'detailsFontSize': detailsFontSize,
      'detailsColor': detailsColor.value,
      'detailsAlignment': detailsAlignment.index,
      'categoryFontSize': categoryFontSize,
      'categoryColor': categoryColor.value,
      'categoryAlignment': categoryAlignment.index,
      'dateFontSize': dateFontSize,
      'dateColor': dateColor.value,
      'dateAlignment': dateAlignment.index,
      'imageWidth': imageWidth,
      'imageHeight': imageHeight,
      'type': type,
      'cardImagePath': cardImagePath,
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
                  alignment: TextAlign.left);
          }
        } else {
          return TextBlock(
              text: 'Invalid Block Data',
              textStyle: TextStyle(),
              alignment: TextAlign.left);
        }
      }).toList();
    }
    return [];
  }
}

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
            alignment: TextAlign.left);
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
  final String iconUrl;  // Changed from iconName to iconUrl
  final String url;

  IconLink({required this.iconUrl, required this.url});

  factory IconLink.fromMap(Map<String, dynamic> map) {
    return IconLink(
      iconUrl: map['iconUrl'] ?? '',  // Changed from iconName to iconUrl
      url: map['url'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'iconUrl': iconUrl,  // Changed from iconName to iconUrl
      'url': url,
    };
  }
}