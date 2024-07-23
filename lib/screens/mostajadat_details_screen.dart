import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:taleb_edu_platform/models/mostajadat_modal.dart';
import 'package:taleb_edu_platform/screens/web_view_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class MostajadatDetailsScreen extends StatelessWidget {
  final Mostajadat mostajadat;

  const MostajadatDetailsScreen({Key? key, required this.mostajadat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: AnimationLimiter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 375),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: widget,
                    ),
                  ),
                  children: [
                    _buildTitleAndCategoryCard(),
                    _buildDatesCard(),
                    _buildContentSection(),
                    _buildButtonLinksCard(context),
                    _buildIconLinksCard(context),
                    _buildDownloadCard(context),
                    _buildShareCard(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
  return SliverAppBar(
    expandedHeight: 200.0,
    floating: false,
    pinned: true,
    backgroundColor: Colors.transparent,
    flexibleSpace: LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final top = constraints.biggest.height;
        final expandRatio = (top - kToolbarHeight) / (200.0 - kToolbarHeight);
        final isCollapsed = expandRatio <= 0.5;
        return Stack(
          fit: StackFit.expand,
          children: [
            AnimatedOpacity(
              opacity: isCollapsed ? 0.0 : 1.0,
              duration: Duration(milliseconds: 300),
              child: Hero(
                tag: 'mostajadat-image-${mostajadat.id}',
                child: mostajadat.imageUrl.isNotEmpty
                    ? Image.network(
                        mostajadat.imageUrl,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.event_note, size: 80, color: Colors.white),
                      ),
              ),
            ),
            Positioned(
              left: 16,
              top: MediaQuery.of(context).padding.top + 8,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCollapsed ? Color(0xFFFFFFFF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    // You can add additional widgets here if needed
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ),
    leading: Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ),
  );
}
  

  Widget _buildTitleAndCategoryCard() {
    return Card(
      color: Color(0xFFFFFFFF),
      margin: EdgeInsets.all(16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mostajadat.title,
              style: GoogleFonts.cairo(
                fontSize: mostajadat.titleFontSize,
                fontWeight: FontWeight.bold,
                color: mostajadat.titleColor,
              ),
              textAlign: mostajadat.titleAlignment,
            ),
            SizedBox(height: 8),
            
          ],
        ),
      ),
    );
  }

  Widget _buildDatesCard() {
    return Card(
      color: Color(0xFFFFFFFF),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateRow(Icons.calendar_today, 'تاريخ النشر:', mostajadat.date),
            if (mostajadat.deadlineDate != null)
              _buildDateRow(Icons.event, 'تاريخ الانتهاء:', mostajadat.deadlineDate!, isDeadline: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRow(IconData icon, String label, DateTime date, {bool isDeadline = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: isDeadline ? Colors.red : mostajadat.dateColor),
          SizedBox(width: 8),
          Text(
            '$label ${DateFormat('dd/MM/yyyy').format(date)}',
            style: GoogleFonts.cairo(
              fontSize: mostajadat.dateFontSize,
              color: isDeadline ? Colors.red : mostajadat.dateColor,
              fontWeight: isDeadline ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

Widget _buildContentSection() {
  return Card(
    color: Color(0xFFFFFFFF),
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: mostajadat.contentBlocks.map((block) {
          if (block is TextBlock) {
            if (block.text.trim().startsWith('-')) {
              List<String> lines = block.text.trim().split('\n');
              return Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: lines.map((line) {
                    line = line.trim().startsWith('-') ? line.trim().substring(1).trim() : line.trim();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '•',
                            style: TextStyle(
                              fontSize: block.textStyle.fontSize,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              line,
                              style: block.textStyle,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            } else {
              return Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(block.text, style: block.textStyle, textAlign: block.alignment),
              );
            }
          } else if (block is ImageBlock) {
            return block.imageUrl != null
                ? Image.network(block.imageUrl!, width: double.infinity, fit: BoxFit.cover)
                : SizedBox.shrink();
          } else if (block is CodeBlock) {
            return Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                block.text,
                style: TextStyle(fontFamily: 'Courier'),
              ),
            );
          } else if (block is BlockquoteBlock) {
            return Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: Colors.grey, width: 4)),
              ),
              child: Text(
                block.text,
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            );
          } else {
            return SizedBox.shrink();
          }
        }).toList(),
      ),
    ),
  );
}
  List<String> _processText(String text) {
    // Remove any leading dash and trim
    text = text.trim().startsWith('-') ? text.substring(1).trim() : text.trim();
    
    // Split the text into sentences
    List<String> sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
    
    // Process each sentence
    return sentences.map((sentence) {
      // If the sentence doesn't end with a period, exclamation mark, or question mark, add a period
      if (!sentence.endsWith('.') && !sentence.endsWith('!') && !sentence.endsWith('?')) {
        sentence += '.';
      }
      // Capitalize the first letter of each sentence
      return sentence.length > 0 ? sentence[0].toUpperCase() + sentence.substring(1) : sentence;
    }).toList();
  }





  Widget _buildButtonLinksCard(BuildContext context) {
    if (mostajadat.buttonLinks.isEmpty) return SizedBox.shrink();

    return Card(
      color: Color(0xFFFFFFFF),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: mostajadat.buttonLinks.map((buttonLink) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ElevatedButton(
                onPressed: () => _launchURL(context, buttonLink.url),
                child: Text(
                  buttonLink.text,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
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


   void _showModernImageView(BuildContext context, String imageUrl, String linkUrl) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return ModernImageView(imageUrl: imageUrl, linkUrl: linkUrl);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Widget _buildIconLinksCard(BuildContext context) {
    if (mostajadat.iconLinks.isEmpty) return SizedBox.shrink();

    return Card(
      color: Color(0xFFFFFFFF),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'روابط إضافية',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: mostajadat.iconLinks.length,
              itemBuilder: (context, index) {
                final iconLink = mostajadat.iconLinks[index];
                return Hero(
                  tag: 'icon-${iconLink.iconUrl}',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showModernImageView(context, iconLink.iconUrl, iconLink.url),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                                child: iconLink.iconUrl.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                        child: Image.network(
                                          iconLink.iconUrl,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                      )
                                    : Icon(Icons.broken_image, size: 80, color: Theme.of(context).primaryColor),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: Offset(0, -2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.link,
                                    color: Theme.of(context).primaryColor.withOpacity(0.7),
                                    size: 16,
                                  ),
                                  SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      _formatUrl(iconLink.url),
                                      style: GoogleFonts.cairo(
                                        fontSize: 13,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatUrl(String url) {
    Uri uri = Uri.parse(url);
    String host = uri.host;
    if (host.startsWith('www.')) {
      host = host.substring(4);
    }
    return host;
  }



  Widget _buildDownloadCard(BuildContext context) {
    return Card(
      color: Color(0xFFFFFFFF),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _downloadPdf(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.download, color: Theme.of(context).primaryColor),
              SizedBox(width: 8),
              Text(
                'تحميل كملف PDF',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareCard(BuildContext context) {
    return Card(
      color: Color(0xFFFFFFFF),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _shareContent(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.share, color: Theme.of(context).primaryColor),
              SizedBox(width: 8),
              Text(
                'مشاركة المحتوى',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _downloadPdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(mostajadat.title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('الفئة: ${mostajadat.category}'),
              pw.Text('تاريخ النشر: ${DateFormat('dd/MM/yyyy').format(mostajadat.date)}'),
              if (mostajadat.deadlineDate != null)
                pw.Text('تاريخ الانتهاء: ${DateFormat('dd/MM/yyyy').format(mostajadat.deadlineDate!)}'),
              pw.SizedBox(height: 20),
              ...mostajadat.contentBlocks.map((block) {
                if (block is TextBlock) {
                  return pw.Text(block.text);
                } else if (block is ImageBlock) {
                  if (block.imageUrl != null) {
                    return pw.Text('[Image: ${block.imageUrl}]');
                  } else {
                    return pw.SizedBox.shrink();
                  }
                } else if (block is CodeBlock) {
                  return pw.Container(
                    margin: pw.EdgeInsets.symmetric(vertical: 8),
                    padding: pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey200,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(block.text),
                  );
                } else if (block is BlockquoteBlock) {
                  return pw.Container(
                    margin: pw.EdgeInsets.symmetric(vertical: 8),
                    padding: pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border(left: pw.BorderSide(color: PdfColors.grey, width: 4)),
                    ),
                    child: pw.Text(
                      block.text,
                      style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
                    ),
                  );
                } else {
                  return pw.SizedBox.shrink();
                }
              }).toList(),
              pw.SizedBox(height: 20),
              if (mostajadat.buttonLinks.isNotEmpty) ...[
                pw.Text('روابط إضافية:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                ...mostajadat.buttonLinks.map((buttonLink) => pw.Text('${buttonLink.text}: ${buttonLink.url}')),
              ],
              if (mostajadat.iconLinks.isNotEmpty) ...[
                pw.SizedBox(height: 10),
                pw.Text('روابط الأيقونات:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                ...mostajadat.iconLinks.map((iconLink) => pw.Text('${iconLink.iconUrl}: ${iconLink.url}')),
              ],
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/mostajadat_${mostajadat.id}.pdf');
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم تحميل الملف بنجاح')),
    );

    if (await canLaunch(file.path)) {
      await launch(file.path);
    } else {
      print('Could not launch ${file.path}');
    }
  }

  void _shareContent(BuildContext context) {
    final String content = '''
${mostajadat.title}

الفئة: ${mostajadat.category}
تاريخ النشر: ${DateFormat('dd/MM/yyyy').format(mostajadat.date)}
${mostajadat.deadlineDate != null ? 'تاريخ الانتهاء: ${DateFormat('dd/MM/yyyy').format(mostajadat.deadlineDate!)}' : ''}

${mostajadat.contentBlocks.map((block) {
      if (block is TextBlock) {
        return block.text;
      } else if (block is ImageBlock) {
        return '[Image: ${block.imageUrl}]';
      } else if (block is CodeBlock) {
        return '```\n${block.text}\n```';
      } else if (block is BlockquoteBlock) {
        return '> ${block.text}';
      } else {
        return '';
      }
    }).join('\n\n')}

${mostajadat.buttonLinks.isNotEmpty ? 'روابط إضافية:\n' + mostajadat.buttonLinks.map((link) => '${link.text}: ${link.url}').join('\n') : ''}

${mostajadat.iconLinks.isNotEmpty ? 'روابط الأيقونات:\n' + mostajadat.iconLinks.map((link) => '${link.iconUrl}: ${link.url}').join('\n') : ''}
''';

    Share.share(content, subject: mostajadat.title);
  }
}

class ModernImageView extends StatefulWidget {
  final String imageUrl;
  final String linkUrl;

  const ModernImageView({Key? key, required this.imageUrl, required this.linkUrl}) : super(key: key);

  @override
  _ModernImageViewState createState() => _ModernImageViewState();
}

class _ModernImageViewState extends State<ModernImageView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'icon-${widget.imageUrl}',
              child: Center(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator(color: Colors.white));
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.broken_image, size: 100, color: Colors.white);
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              left: 16,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _launchURL(context, widget.linkUrl),
                    icon: Icon(Icons.link),
                    label: Text('زيارة الرابط', style: GoogleFonts.cairo()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'انقر في أي مكان للإغلاق',
                    style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchURL(BuildContext context, String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }
}

