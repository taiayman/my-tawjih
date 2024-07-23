import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:taleb_edu_platform/models/announcement_model.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Import cached_network_image

class AnnouncementCarousel extends StatelessWidget {
  final List<Announcement> announcements;

  const AnnouncementCarousel({Key? key, required this.announcements}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 300.0, // Increased height
        aspectRatio: 16 / 9,
        viewportFraction: 0.8,
        initialPage: 0,
        enableInfiniteScroll: true,
        reverse: false,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 3),
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: true,
        scrollDirection: Axis.horizontal,
      ),
      items: announcements.map((announcement) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack( // Using Stack to overlay gradient
                children: [
                  ClipRRect( // ClipRRect to apply rounded corners to image
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage( // Using CachedNetworkImage for better image loading
                      imageUrl: announcement.schoolImageUrl ?? '',
                      width: MediaQuery.of(context).size.width,
                      height: 300, // Matching Carousel height
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                      ),
                    ),
                  ),
                  Positioned.fill( // Positioned.fill to cover the entire image with padding
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(announcement.schoolImageUrl ?? ''),
                                radius: 25,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  announcement.title,
                                  style: GoogleFonts.cairo(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                DateFormat('dd/MM/yyyy').format(announcement.date),
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              SizedBox(width: 10),
                              _buildEducationLevelChip(announcement.category),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildEducationLevelChip(String category) {
    Color chipColor;
    String label;
    switch (category) {
      case 'bac':
        chipColor = Colors.green;
        label = 'باك';
        break;
      case 'bac+2':
        chipColor = Colors.blue;
        label = 'باك+2';
        break;
      default:
        chipColor = Colors.orange;
        label = category;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}