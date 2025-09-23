import 'package:flutter/material.dart';

class CustomToggleAppBar extends StatefulWidget implements PreferredSizeWidget {
  final int initialIndex;
  final ValueChanged<int>? onTabChanged; // notify parent
  final VoidCallback? onSettingsPressed;

  const CustomToggleAppBar({
    super.key,
    this.initialIndex = 0,
    this.onTabChanged,
    this.onSettingsPressed,
  });

  @override
  State<CustomToggleAppBar> createState() => _CustomToggleAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomToggleAppBarState extends State<CustomToggleAppBar> {
  late int selectedIndex;

  final List<TabData> tabs = [
    TabData(icon: Icons.home, label: "Home"),
    TabData(icon: Icons.person, label: "Profile"),
    TabData(icon: Icons.chat, label: "Chat"),
  ];

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  void _handleSwipe(DragEndDetails details) {
    const double sensitivity = 50.0;
    if (details.primaryVelocity != null) {
      if (details.primaryVelocity! > sensitivity && selectedIndex > 0) {
        _changeTab(selectedIndex - 1);
      } else if (details.primaryVelocity! < -sensitivity && selectedIndex < tabs.length - 1) {
        _changeTab(selectedIndex + 1);
      }
    }
  }

  void _changeTab(int index) {
    setState(() => selectedIndex = index);
    if (widget.onTabChanged != null) {
      widget.onTabChanged!(index); // notify parent
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey[900],
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildToggleSwitch(),
          _buildSettingsButton(),
        ],
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return GestureDetector(
      onHorizontalDragEnd: _handleSwipe,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.all(3),
              width: 80,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              transform: Matrix4.translationValues(selectedIndex * 80.0, 0, 0),
            ),
            Row(
              children: tabs.asMap().entries.map((entry) {
                int index = entry.key;
                TabData tab = entry.value;
                return _buildTabButton(tab.icon, tab.label, index);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(IconData icon, String label, int index) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => _changeTab(index),
      child: SizedBox(
        width: 80,
        height: 46,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : Colors.white,
              size: 18,
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        onPressed: widget.onSettingsPressed,
        icon: const Icon(Icons.settings, color: Colors.black, size: 20),
      ),
    );
  }
}

class TabData {
  final IconData icon;
  final String label;

  TabData({required this.icon, required this.label});
}
