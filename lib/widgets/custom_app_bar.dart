import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends ConsumerStatefulWidget {
  final Function(int) onSectionTap;

  const CustomAppBar({Key? key, required this.onSectionTap}) : super(key: key);

  @override
  ConsumerState<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends ConsumerState<CustomAppBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;
  late Animation<Color?> _colorAnimation;
  int _selectedIndex = 0;

  final List<_SectionInfo> _sections = [
    _SectionInfo(Icons.feed, 'مستجدات', Color(0xFF3498db)),
    _SectionInfo(Icons.work, 'مباريات وظيفية', Color(0xFF2ecc71)),
    _SectionInfo(Icons.school, 'التوجيه', Color(0xFFe74c3c)),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animations = _sections.map((section) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
        ),
      );
    }).toList();

    _colorAnimation = ColorTween(
      begin: _sections[0].color,
      end: _sections[0].color,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      _colorAnimation = ColorTween(
        begin: _colorAnimation.value ?? _sections[_selectedIndex].color,
        end: _sections[index].color,
      ).animate(_controller);
      _controller.forward(from: 0.0);
      widget.onSectionTap(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      snap: false,
      expandedHeight: 120.0,
      backgroundColor: _colorAnimation.value ?? _sections[_selectedIndex].color,
      automaticallyImplyLeading: false, // This line removes the back icon
      flexibleSpace: FlexibleSpaceBar(
        background: AnimatedBuilder(
          animation: _colorAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _colorAnimation.value ?? _sections[_selectedIndex].color,
                    _colorAnimation.value?.withOpacity(0.8) ?? _sections[_selectedIndex].color.withOpacity(0.8),
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text(
                            _sections[_selectedIndex].label,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.notifications, color: Colors.white),
                          onPressed: () {
                            // Handle notifications
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          height: 64,
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_sections.length, (index) => 
              _buildSection(index, _sections[index].icon, _sections[index].label)
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onTap(index),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 3.0,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 24 + (isSelected ? _animations[index].value * 4 : 0),
                ),
                SizedBox(height: 4),
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionInfo {
  final IconData icon;
  final String label;
  final Color color;

  _SectionInfo(this.icon, this.label, this.color);
}