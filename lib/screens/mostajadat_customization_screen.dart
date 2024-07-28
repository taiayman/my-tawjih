import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:taleb_edu_platform/models/mostajadat_modal.dart';
import 'package:taleb_edu_platform/providers/mostajadat_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:taleb_edu_platform/screens/web_view_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class MostajadatCustomizationScreen extends ConsumerStatefulWidget {
  final Mostajadat? mostajadat;
  final String title;
  final String description;
  final String details;
  final DateTime date;
  final DateTime? deadlineDate;
  final String imageUrl;
  final String? cardImagePath;
  final String category;

  MostajadatCustomizationScreen({
    this.mostajadat,
    required this.title,
    required this.description,
    required this.details,
    required this.date,
    this.deadlineDate,
    required this.imageUrl,
    required String type,
    required this.category,
    this.cardImagePath,
  });

  @override
  _MostajadatCustomizationScreenState createState() =>
      _MostajadatCustomizationScreenState();
}

class _MostajadatCustomizationScreenState
    extends ConsumerState<MostajadatCustomizationScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _detailsController;
  String? _cardImagePath;
  late String _selectedCategory;

  String? _headerImageUrl;
  List<ContentBlock> _contentBlocks = [];
  List<ButtonLink> _buttonLinks = [];
  List<IconLink> _iconLinks = [];

  TextSelection _selection =
      const TextSelection(baseOffset: 0, extentOffset: 0);
  final GlobalKey _textFieldKey = GlobalKey();

  late TextAlign _titleAlignment;
  late TextAlign _dateAlignment;
  late TextAlign _descriptionAlignment;
  late TextAlign _detailsAlignment;
  Map<int, TextAlign> _textAlignments = {};

  int _currentBlockIndex = 0;

  double _imageWidth = 200.0;
  double _imageHeight = 200.0;

  List<String> _categories = ['jobs', 'guidance'];

  String _type = 'بدون';
  final List<String> _types = [
    'بدون',
    'باك',
    'باك+1',
    'باك+2',
    'باك+3',
    'باك+4',
    'باك+5',
    'أخرى',
  ];

  Color _titleColor = Colors.black;
  Color _descriptionColor = Colors.black;
  Color _detailsColor = Colors.black;
  Color _dateColor = Colors.black;
  Color _typeColor = Colors.black;
  Color _categoryColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _descriptionController = TextEditingController(text: widget.description);
    _detailsController = TextEditingController(text: widget.details);
    _headerImageUrl = widget.imageUrl;
    _titleAlignment = TextAlign.center;
    _dateAlignment = TextAlign.center;
    _descriptionAlignment = TextAlign.center;
    _detailsAlignment = TextAlign.center;
    if (widget.mostajadat != null) {
      _type = widget.mostajadat!.type;
      _buttonLinks = widget.mostajadat!.buttonLinks;
      _iconLinks = widget.mostajadat!.iconLinks;
    }
    _loadSavedData();
    _cardImagePath = widget.cardImagePath;
    _selectedCategory = widget.category;


  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
  if (widget.mostajadat != null) {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('mostajadat')
        .doc(widget.mostajadat!.id)
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      setState(() {
        _titleController.text = data['title'] ?? '';
        _descriptionController.text = data['description'] ?? '';
        _detailsController.text = data['details'] ?? '';
        _headerImageUrl = data['imageUrl'];
        _cardImagePath = data['cardImagePath'] as String?;
        _imageWidth = data['imageWidth'] ?? 200.0;
        _imageHeight = data['imageHeight'] ?? 200.0;
        _selectedCategory = data['category'] ?? 'jobs';
        _type = data['type'] ?? 'بدون';
        _contentBlocks = (data['contentBlocks'] as List? ?? [])
            .map((block) => ContentBlock.fromMap(block))
            .toList();
        _buttonLinks = (data['buttonLinks'] as List<dynamic>? ?? [])
            .map((link) => ButtonLink.fromMap(link))
            .toList();
        _iconLinks = (data['iconLinks'] as List<dynamic>? ?? [])
            .map((link) => IconLink.fromMap(link))
            .toList();
        _titleColor = Color(data['titleColor'] ?? Colors.black.value);
        _descriptionColor = Color(data['descriptionColor'] ?? Colors.black.value);
        _detailsColor = Color(data['detailsColor'] ?? Colors.black.value);
        _dateColor = Color(data['dateColor'] ?? Colors.black.value);
        _typeColor = Color(data['typeColor'] ?? Colors.black.value);
        _categoryColor = Color(data['categoryColor'] ?? Colors.black.value);
        _titleAlignment = TextAlign.values[data['titleAlignment'] ?? TextAlign.center.index];
        _dateAlignment = TextAlign.values[data['dateAlignment'] ?? TextAlign.center.index];
        _descriptionAlignment = TextAlign.values[data['descriptionAlignment'] ?? TextAlign.center.index];
        _detailsAlignment = TextAlign.values[data['detailsAlignment'] ?? TextAlign.center.index];
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('customize_mostajadat'.tr(), style: GoogleFonts.cairo()),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveData,
          ),
          IconButton(
            icon: Icon(Icons.preview),
            onPressed: _previewMostajadat,
          ),
        ],
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          textTheme: Theme.of(context).textTheme.apply(
            bodyColor: Colors.black,
            displayColor: Colors.black,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            labelStyle: TextStyle(color: Colors.black),
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildHeaderImageSection(),
                      SizedBox(height: 16),
                      _buildTitleSection(),
                      SizedBox(height: 16),
                      _buildDateSection(),
                      SizedBox(height: 16),
                      _buildContentBlocksEditor(),
                      SizedBox(height: 16),
                      _buildButtonLinksSection(),
                      SizedBox(height: 16),
                      _buildIconLinksSection(),
                    ],
                  ),
                ),
              ),
            ),
            _buildFormatToolbar(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatToolbar() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              _buildFormatButton(
                  Icons.format_bold, () => _applyTextStyle(weight: FontWeight.bold)),
              _buildFormatButton(Icons.format_italic,
                  () => _applyTextStyle(fontStyle: FontStyle.italic)),
              _buildFormatButton(Icons.format_underline,
                  () => _applyTextStyle(decoration: TextDecoration.underline)),
              _buildFormatButton(Icons.format_size, _showFontSizeDialog),
              _buildFormatButton(Icons.format_color_text, _showTextColorDialog),
              VerticalDivider(width: 16, thickness: 1, color: Colors.grey[400]),
              _buildFormatButton(
                  Icons.format_align_left, () => _applyTextAlign(TextAlign.left)),
              _buildFormatButton(Icons.format_align_center,
                  () => _applyTextAlign(TextAlign.center)),
              _buildFormatButton(
                  Icons.format_align_right, () => _applyTextAlign(TextAlign.right)),
              VerticalDivider(width: 16, thickness: 1, color: Colors.grey[400]),
              _buildFormatButton(Icons.format_list_bulleted, _insertBulletList),
              _buildFormatButton(Icons.format_list_numbered, _insertNumberedList),
              _buildFormatButton(Icons.link, _insertLink),
              VerticalDivider(width: 16, thickness: 1, color: Colors.grey[400]),
              _buildFormatButton(Icons.image, _insertImage),
              _buildFormatButton(Icons.code, _addCodeBlock),
              _buildFormatButton(Icons.format_quote, _addBlockquote),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormatButton(IconData icon, VoidCallback onPressed) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.all(8),
            child: Icon(icon, size: 20, color: Colors.grey[800]),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderImageSection() {
    return GestureDetector(
      onTap: _pickHeaderImage,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          image: _headerImageUrl != null
              ? DecorationImage(
                  image: NetworkImage(_headerImageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(41, 158, 158, 158).withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: _headerImageUrl == null
            ? Center(
                child: Icon(Icons.add_photo_alternate,
                    size: 50, color: Colors.grey[600]),
              )
            : null,
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Title', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          textAlign: _titleAlignment,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _titleColor,
          ),
          decoration: InputDecoration(
            labelText: 'عنوان'.tr(),
            alignLabelWithHint: true,
          ),
        ),

      ],
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('تاريخ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('dd/MM/yyyy').format(widget.date),
                style: TextStyle(fontSize: 16, color: _dateColor),
                textAlign: _dateAlignment,
              ),
              if (widget.deadlineDate != null) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.event, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'deadline'.tr() + ': ${DateFormat('dd/MM/yyyy').format(widget.deadlineDate!)}',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                      textAlign: _dateAlignment,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 8),
       
      ],
    );
  }


  Widget _buildContentBlocksEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('المحتوى', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        SizedBox(height: 8),
        for (int i = 0; i < _contentBlocks.length; i++)
          _buildContentBlock(_contentBlocks[i], i),
        SizedBox(height: 16),
        _buildAddContentButton(),
      ],
    );
  }

  Widget _buildContentBlock(ContentBlock block, int index) {
    if (block is TextBlock) {
      return _buildTextBlock(block, index);
    } else if (block is ImageBlock) {
      return _buildImageBlock(block, index);
    } else if (block is CodeBlock) {
      return _buildCodeBlock(block, index);
    } else if (block is BlockquoteBlock) {
      return _buildBlockquoteBlock(block, index);
    }
    return SizedBox.shrink();
  }

  Widget _buildTextBlock(TextBlock block, int index) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          setState(() {
            _currentBlockIndex = index;
          });
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        child: TextFormField(
          key: index == 0 ? _textFieldKey : null,
          controller: block.controller,
          style: block.textStyle.copyWith(color: Colors.black),
          textAlign: _textAlignments[index] ?? TextAlign.center,
          maxLines: null,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(12),
          ),
          onChanged: (text) {
            setState(() {
              block.text = text;
            });
          },
        ),
      ),
    );
  }

  Widget _buildImageBlock(ImageBlock block, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (block.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                block.imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            )
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(Icons.image, size: 50, color: Colors.grey[600]),
              ),
            ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                onPressed: () => _pickImage(index),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeContentBlock(index),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCodeBlock(CodeBlock block, int index) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: block.controller,
            maxLines: null,
            style: TextStyle(fontFamily: 'Courier', color: Colors.black),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'enter_code_here'.tr(),
              hintStyle: TextStyle(color: Colors.grey),
            ),
            onChanged: (newText) {
              setState(() {
                _contentBlocks[index] = CodeBlock(text: newText);
              });
            },
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeContentBlock(index),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBlockquoteBlock(BlockquoteBlock block, int index) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.grey, width: 4)),
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: block.controller,
            maxLines: null,
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'enter_quote_here'.tr(),
              hintStyle: TextStyle(color: Colors.grey),
            ),
            onChanged: (newText) {
              setState(() {
                _contentBlocks[index] = BlockquoteBlock(text: newText);
              });
            },
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeContentBlock(index),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddContentButton() {
    return ElevatedButton.icon(
      icon: Icon(Icons.add),
      label: Text('إضافة محتوى'.tr()),
      onPressed: _showAddContentDialog,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showAddContentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('add_content'.tr(), style: TextStyle(color: Colors.black)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.text_fields, color: Theme.of(context).primaryColor),
                title: Text('text'.tr(), style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  _addTextBlock();
                },
              ),
              ListTile(
                leading: Icon(Icons.image, color: Theme.of(context).primaryColor),
                title: Text('image'.tr(), style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  _addImage();
                },
              ),
              ListTile(
                leading: Icon(Icons.code, color: Theme.of(context).primaryColor),
                title: Text('code'.tr(), style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  _addCodeBlock();
                },
              ),
              ListTile(
                leading: Icon(Icons.format_quote, color: Theme.of(context).primaryColor),
                title: Text('quote'.tr(), style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  _addBlockquote();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _addTextBlock() {
    setState(() {
      _contentBlocks.add(TextBlock(
          text: '', textStyle: TextStyle(color: Colors.black), alignment: TextAlign.center));
      _textAlignments[_contentBlocks.length - 1] = TextAlign.center;
    });
  }

  void _addImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      String? imageUrl = await _uploadImage(File(image.path));
      if (imageUrl != null) {
        setState(() {
          _contentBlocks.add(ImageBlock(imageUrl: imageUrl));
        });
      }
    }
  }

  void _addCodeBlock() {
    setState(() {
      _contentBlocks.add(CodeBlock(text: ''));
    });
  }

  void _addBlockquote() {
    setState(() {
      _contentBlocks.add(BlockquoteBlock(text: ''));
    });
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('mostajadat_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(imageFile);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  void _removeContentBlock(int index) {
    setState(() {
      _contentBlocks.removeAt(index);
      _textAlignments.remove(index);
    });
  }

  void _pickHeaderImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      String? imageUrl = await _uploadImage(File(image.path));
      if (imageUrl != null) {
        setState(() {
          _headerImageUrl = imageUrl;
        });
      }
    }
  }

  void _pickImage(int index) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      String? imageUrl = await _uploadImage(File(image.path));
      if (imageUrl != null) {
        setState(() {
          _contentBlocks[index] = ImageBlock(imageUrl: imageUrl);
        });
      }
    }
  }

  void _applyTextStyle({
    FontWeight? weight,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? fontSize,
    Color? color
  }) {
    setState(() {
      if (_currentBlockIndex >= 0 && _currentBlockIndex < _contentBlocks.length) {
        ContentBlock block = _contentBlocks[_currentBlockIndex];
        if (block is TextBlock) {
          TextStyle newStyle = block.textStyle.copyWith(
            fontWeight: weight ?? block.textStyle.fontWeight,
            fontStyle: fontStyle ?? block.textStyle.fontStyle,
            decoration: decoration ?? block.textStyle.decoration,
            fontSize: fontSize ?? block.textStyle.fontSize,
            color: color ?? block.textStyle.color,
          );
          _contentBlocks[_currentBlockIndex] = TextBlock(
            text: block.text,
            textStyle: newStyle,
            alignment: block.alignment
          );
        }
      }
    });
  }

  void _applyTextAlign(TextAlign alignment) {
    setState(() {
      if (_currentBlockIndex >= 0 && _currentBlockIndex < _contentBlocks.length) {
        ContentBlock block = _contentBlocks[_currentBlockIndex];
        if (block is TextBlock) {
          _textAlignments[_currentBlockIndex] = alignment;
          _contentBlocks[_currentBlockIndex] = TextBlock(
            text: block.text,
            textStyle: block.textStyle,
            alignment: alignment,
          );
        }
      } else if (_currentBlockIndex == -1) {
        _titleAlignment = alignment;
      } else if (_currentBlockIndex == -2) {
        _dateAlignment = alignment;
      } else if (_currentBlockIndex == -3) {
        _descriptionAlignment = alignment;
      }
    });
  }

  void _showFontSizeDialog() {
    double currentFontSize = 16.0;
    if (_currentBlockIndex >= 0 && _currentBlockIndex < _contentBlocks.length) {
      ContentBlock block = _contentBlocks[_currentBlockIndex];
      if (block is TextBlock) {
        currentFontSize = block.textStyle.fontSize ?? 16.0;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('font_size'.tr(), style: TextStyle(color: Colors.black)),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    value: currentFontSize,
                    min: 8,
                    max: 32,
                    divisions: 12,
                    label: currentFontSize.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        currentFontSize = value;
                      });
                    },
                  ),
                  Text('${currentFontSize.round()} px', style: TextStyle(color: Colors.black)),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('cancel'.tr()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('apply'.tr()),
              onPressed: () {
                _applyTextStyle(fontSize: currentFontSize);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showTextColorDialog() {
    Color currentColor = Colors.black;
    if (_currentBlockIndex >= 0 && _currentBlockIndex < _contentBlocks.length) {
      ContentBlock block = _contentBlocks[_currentBlockIndex];
      if (block is TextBlock) {
        currentColor = block.textStyle.color ?? Colors.black;
      }
    }

    _showColorDialog(currentColor, (color) {
      _applyTextStyle(color: color);
    });
  }

  void _showColorDialog(Color initialColor, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Color', style: TextStyle(color: Colors.black)),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: initialColor,
              onColorChanged: onColorChanged,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('cancel'.tr()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('apply'.tr()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _insertBulletList() {
    _insertListItem('• ');
  }

  void _insertNumberedList() {
    _insertListItem('1. ');
  }

  void _insertListItem(String prefix) {
    setState(() {
      if (_currentBlockIndex >= 0 && _currentBlockIndex < _contentBlocks.length) {
        ContentBlock block = _contentBlocks[_currentBlockIndex];
        if (block is TextBlock) {
          String newText = block.text + '\n' + prefix;
          _contentBlocks[_currentBlockIndex] = TextBlock(
            text: newText,
            textStyle: block.textStyle,
            alignment: block.alignment,
          );
        }
      }
    });
  }

  void _insertLink() {
    String url = '';
    String linkText = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('insert_link'.tr(), style: TextStyle(color: Colors.black)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'enter_url'.tr(),
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (value) => url = value,
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: 'enter_link_text'.tr(),
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (value) => linkText = value,
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('cancel'.tr()),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('insert'.tr()),
              onPressed: () {
                _insertLinkToContent(url, linkText);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _insertLinkToContent(String url, String linkText) {
    setState(() {
      if (_currentBlockIndex >= 0 && _currentBlockIndex < _contentBlocks.length) {
        ContentBlock block = _contentBlocks[_currentBlockIndex];
        if (block is TextBlock) {
          String newText = block.text + '[$linkText]($url)';
          _contentBlocks[_currentBlockIndex] = TextBlock(
            text: newText,
            textStyle: block.textStyle,
            alignment: block.alignment,
          );
        }
      }
    });
  }

  void _insertImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      String? imageUrl = await _uploadImage(File(image.path));
      if (imageUrl != null) {
        setState(() {
          _contentBlocks.insert(
              _currentBlockIndex + 1, ImageBlock(imageUrl: imageUrl));
        });
      }
    }
  }

  Future<void> _saveData() async {
  try {
    final mostajadat = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'details': _detailsController.text,
      'category': _selectedCategory,
      'date': Timestamp.fromDate(widget.date),
      'deadlineDate': widget.deadlineDate != null
          ? Timestamp.fromDate(widget.deadlineDate!)
          : null,
      'imageUrl': _headerImageUrl,
      'cardImagePath': _cardImagePath,
      'imageWidth': _imageWidth,
      'imageHeight': _imageHeight,
      'type': _type,
      'contentBlocks': _contentBlocks.map((block) => block.toMap()).toList(),
      'buttonLinks': _buttonLinks.map((link) => link.toMap()).toList(),
      'iconLinks': _iconLinks.map((link) => link.toMap()).toList(),
      'titleColor': _titleColor.value,
      'descriptionColor': _descriptionColor.value,
      'detailsColor': _detailsColor.value,
      'dateColor': _dateColor.value,
      'typeColor': _typeColor.value,
      'categoryColor': _categoryColor.value,
      'titleAlignment': _titleAlignment.index,
      'descriptionAlignment': _descriptionAlignment.index,
      'detailsAlignment': _detailsAlignment.index,
      'dateAlignment': _dateAlignment.index,
    };

    if (widget.mostajadat == null) {
      await FirebaseFirestore.instance
          .collection('mostajadat')
          .add(mostajadat);
    } else {
      await FirebaseFirestore.instance
          .collection('mostajadat')
          .doc(widget.mostajadat!.id)
          .update(mostajadat);
    }

    // Refresh the mostajadatProvider
    ref.refresh(mostajadatProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('mostajadat_saved_successfully'.tr()),
        backgroundColor: Colors.green,
      ),
    );
    // After saving, navigate back to the dashboard
    Navigator.of(context).pop();
  } catch (e) {
    print('Error saving mostajadat: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('failed_to_save'.tr()),
        backgroundColor: Colors.red,
      ),
    );
  }
}
  void _previewMostajadat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MostajadatPreviewScreen(
          title: _titleController.text,
          date: widget.date,
          deadlineDate: widget.deadlineDate,
          imageUrl: _headerImageUrl,
          contentBlocks: _contentBlocks,
          titleAlignment: _titleAlignment,
          dateAlignment: _dateAlignment,
          type: _type,
          cardImagePath: widget.cardImagePath,
          buttonLinks: _buttonLinks,
          iconLinks: _iconLinks,
          titleColor: _titleColor,
          descriptionColor: _descriptionColor,
          detailsColor: _detailsColor,
          dateColor: _dateColor,
          typeColor: _typeColor,
          categoryColor: _categoryColor,
        ),
      ),
    );
  }

  Widget _buildButtonLinksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('روابط الأزرار', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        SizedBox(height: 8),
        ..._buttonLinks.map((link) => _buildButtonLinkItem(link)).toList(),
        SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _addButtonLink,
          icon: Icon(Icons.add),
          label: Text('إضافة روابط الأزرار'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtonLinkItem(ButtonLink link) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(link.text, style: TextStyle(color: Colors.black)),
        subtitle: Text(link.url, style: TextStyle(color: Colors.grey[600])),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
              onPressed: () => _editButtonLink(link),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeButtonLink(link),
            ),
          ],
        ),
        onTap: () => _editButtonLink(link),
      ),
    );
  }

  Widget _buildIconLinksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('روابط الأيقونات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        SizedBox(height: 8),
        ..._iconLinks.map((link) => _buildIconLinkItem(link)).toList(),
        SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _addIconLink,
          icon: Icon(Icons.add),
          label: Text('إضافة روابط الأيقونات'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconLinkItem(IconLink link) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: link.iconUrl.isNotEmpty
            ? Image.network(link.iconUrl, width: 24, height: 24)
            : Icon(Icons.broken_image),
        title: Text(link.url, style: TextStyle(color: Colors.black)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
              onPressed: () => _editIconLink(link),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeIconLink(link),
            ),
          ],
        ),
        onTap: () => _editIconLink(link),
      ),
    );
  }

  void _addButtonLink() {
    showDialog(
      context: context,
      builder: (context) => _ButtonLinkDialog(
        onSave: (text, url) {
          setState(() {
            _buttonLinks.add(ButtonLink(text: text, url: url));
          });
        },
      ),
    );
  }

  void _editButtonLink(ButtonLink link) {
    showDialog(
      context: context,
      builder: (context) => _ButtonLinkDialog(
        initialText: link.text,
        initialUrl: link.url,
        onSave: (text, url) {
          setState(() {
            int index = _buttonLinks.indexOf(link);
            _buttonLinks[index] = ButtonLink(text: text, url: url);
          });
        },
      ),
    );
  }

  void _removeButtonLink(ButtonLink link) {
    setState(() {
      _buttonLinks.remove(link);
    });
  }

  void _addIconLink() {
    showDialog(
      context: context,
      builder: (context) => _IconLinkDialog(
        onSave: (iconUrl, url) {
          setState(() {
            _iconLinks.add(IconLink(iconUrl: iconUrl, url: url));
          });
        },
      ),
    );
  }

  void _editIconLink(IconLink link) {
    showDialog(
      context: context,
      builder: (context) => _IconLinkDialog(
        initialIconUrl: link.iconUrl,
        initialUrl: link.url,
        onSave: (iconUrl, url) {
          setState(() {
            int index = _iconLinks.indexOf(link);
            _iconLinks[index] = IconLink(iconUrl: iconUrl, url: url);
          });
        },
      ),
    );
  }

  void _removeIconLink(IconLink link) {
    setState(() {
      _iconLinks.remove(link);
    });
  }
}

class _ButtonLinkDialog extends StatefulWidget {
  final String? initialText;
  final String? initialUrl;
  final Function(String, String) onSave;

  const _ButtonLinkDialog({
    Key? key,
    this.initialText,
    this.initialUrl,
    required this.onSave,
  }) : super(key: key);

  @override
  __ButtonLinkDialogState createState() => __ButtonLinkDialogState();
}

class __ButtonLinkDialogState extends State<_ButtonLinkDialog> {
  late TextEditingController _textController;
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
    _urlController = TextEditingController(text: widget.initialUrl);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add/Edit Button Link', style: TextStyle(color: Colors.black)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _textController,
            decoration: InputDecoration(labelText: 'Button Text'),
            style: TextStyle(color: Colors.black),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _urlController,
            decoration: InputDecoration(labelText: 'URL'),
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_textController.text, _urlController.text);
            Navigator.of(context).pop();
          },
          child: Text('Save'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }
}

class _IconLinkDialog extends StatefulWidget {
  final String? initialIconUrl;
  final String? initialUrl;
  final Function(String, String) onSave;

  const _IconLinkDialog({
    Key? key,
    this.initialIconUrl,
    this.initialUrl,
    required this.onSave,
  }) : super(key: key);

  @override
  __IconLinkDialogState createState() => __IconLinkDialogState();
}

class __IconLinkDialogState extends State<_IconLinkDialog> {
  late TextEditingController _iconUrlController;
  late TextEditingController _urlController;
  String? _selectedIconUrl;

  @override
  void initState() {
    super.initState();
    _iconUrlController = TextEditingController(text: widget.initialIconUrl);
    _urlController = TextEditingController(text: widget.initialUrl);
    _selectedIconUrl = widget.initialIconUrl;
  }

  Future<void> _pickIcon() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      String? iconUrl = await _uploadImage(File(image.path));
      if (iconUrl != null) {
        setState(() {
          _selectedIconUrl = iconUrl;
          _iconUrlController.text = iconUrl;
        });
      }
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('icon_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(imageFile);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add/Edit Icon Link', style: TextStyle(color: Colors.black)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _pickIcon,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _selectedIconUrl != null
                  ? Image.network(_selectedIconUrl!, fit: BoxFit.cover)
                  : Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey[600]),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _urlController,
            decoration: InputDecoration(labelText: 'URL'),
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_selectedIconUrl ?? '', _urlController.text);
            Navigator.of(context).pop();
          },
          child: Text('Save'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }
}

class MostajadatPreviewScreen extends StatelessWidget {
  final String title;
  final DateTime date;
  final DateTime? deadlineDate;
  final String? imageUrl;
  final List<ContentBlock> contentBlocks;
  final TextAlign titleAlignment;
  final TextAlign dateAlignment;
  final String type;
  final String? cardImagePath;
  final List<ButtonLink> buttonLinks;
  final List<IconLink> iconLinks;
  final Color titleColor;
  final Color descriptionColor;
  final Color detailsColor;
  final Color dateColor;
  final Color typeColor;
  final Color categoryColor;

  MostajadatPreviewScreen({
    required this.title,
    required this.date,
    this.deadlineDate,
    this.imageUrl,
    required this.contentBlocks,
    required this.titleAlignment,
    required this.dateAlignment,
    required this.type,
    this.cardImagePath,
    required this.buttonLinks,
    required this.iconLinks,
    required this.titleColor,
    required this.descriptionColor,
    required this.detailsColor,
    required this.dateColor,
    required this.typeColor,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('معاينة المستجد', style: GoogleFonts.cairo()),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                    textAlign: titleAlignment,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'التاريخ: ${DateFormat('dd/MM/yyyy').format(date)}',
                    textAlign: dateAlignment,
                    style: TextStyle(color: dateColor),
                  ),
                  if (deadlineDate != null)
                    Text(
                      'الموعد النهائي: ${DateFormat('dd/MM/yyyy').format(deadlineDate!)}',
                      style: TextStyle(color: Colors.red),
                      textAlign: dateAlignment,
                    ),
                  SizedBox(height: 16),
                  Text('النوع: $type',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: typeColor)),
                  SizedBox(height: 16),
                  ...contentBlocks.map((block) => _buildContentBlockPreview(block)).toList(),
                  SizedBox(height: 16),
                  _buildButtonLinks(context),
                  SizedBox(height: 16),
                  _buildIconLinks(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentBlockPreview(ContentBlock block) {
    if (block is TextBlock) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Text(
          block.text,
          style: block.textStyle.copyWith(color: detailsColor),
          textAlign: block.alignment ?? TextAlign.start,
        ),
      );
    } else if (block is ImageBlock) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: block.imageUrl != null
            ? Image.network(
                block.imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
              )
            : SizedBox.shrink(),
      );
    } else if (block is CodeBlock) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            block.text,
            style: TextStyle(fontFamily: 'Courier', color: detailsColor),
          ),
        ),
      );
    } else if (block is BlockquoteBlock) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: Colors.grey, width: 4)),
          ),
          child: Text(
            block.text,
            style: TextStyle(fontStyle: FontStyle.italic, color: detailsColor),
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }

  Widget _buildButtonLinks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'روابط الأزرار',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: titleColor),
        ),
        SizedBox(height: 8),
        ...buttonLinks.map((link) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ElevatedButton(
              onPressed: () => _launchURL(context, link.url),
              child: Text(link.text),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Theme.of(context).primaryColor,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildIconLinks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'روابط الأيقونات',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: titleColor),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: iconLinks.map((link) {
            return InkWell(
              onTap: () => _launchURL(context, link.url),
              child: Column(
                children: [
                  Image.network(
                    link.iconUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 4),
                  Text(
                    link.url,
                    style: TextStyle(fontSize: 12, color: detailsColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  void _launchURL(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewScreen(url: url),
      ),
    );
  }
}