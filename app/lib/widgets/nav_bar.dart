import 'package:material_ui/material_ui.dart';

import '../theme.dart';

class NavItem {
  const NavItem(this.icon, this.label);
  final IconData icon;
  final String label;
}

const navItems = [
  NavItem(Icons.home_rounded, 'Accueil'),
  NavItem(Icons.live_tv_rounded, 'CaviTV'),
  NavItem(Icons.radio_rounded, 'Cavi FM'),
  NavItem(Icons.article_rounded, 'Siam Info'),
  NavItem(Icons.person_rounded, 'Plus'),
];

/// Barre d'onglets flottante du design Studio.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({super.key, required this.index, required this.onSelect});
  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: CaviColors.nav,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 24, offset: Offset(0, 8))],
      ),
      child: Row(children: [
        for (var i = 0; i < navItems.length; i++)
          Expanded(
            child: Semantics(
              selected: i == index,
              button: true,
              label: navItems[i].label,
              child: Tooltip(
                message: navItems[i].label,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => onSelect(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    height: 48,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: i == index ? CaviColors.blue : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(navItems[i].icon,
                        size: 24, color: i == index ? Colors.white : CaviColors.sub),
                  ),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}
