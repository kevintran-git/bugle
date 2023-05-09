import 'package:flutter/material.dart';

class ResponsiveNavigationLayout extends StatelessWidget {
  final int selectedIndex;
  final List<ResponsiveNavigationDestination> destinations;
  final ValueChanged<int> onItemSelected;

  const ResponsiveNavigationLayout({
    Key? key,
    required this.selectedIndex,
    required this.destinations,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final useNavigationBar = MediaQuery.of(context).size.width > 450;
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    var mainArea = destinations[selectedIndex].screen;

    return Scaffold(
        bottomNavigationBar: useNavigationBar
            ? null
            : NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: onItemSelected,
                destinations: List.generate(
                  destinations.length,
                  (index) => NavigationDestination(
                    icon: destinations[index].icon,
                    selectedIcon: destinations[index].selectedIcon,
                    label: destinations[index].title,
                  ),
                ),
              ),
        body: SafeArea(
            child: useNavigationBar
                ? Row(
                    children: [
                      NavigationRail(
                        extended: isLargeScreen,
                        destinations: List.generate(
                          destinations.length,
                          (index) => NavigationRailDestination(
                            icon: destinations[index].icon,
                            selectedIcon: destinations[index].selectedIcon,
                            label: Text(destinations[index].title),
                          ),
                        ),
                        selectedIndex: selectedIndex,
                        onDestinationSelected: (value) {
                          onItemSelected(value);
                        },
                      ),
                      Expanded(
                        child: mainArea,
                      ),
                    ],
                  )
                : mainArea));
  }
}

class ResponsiveNavigationDestination {
  final String title;
  final Icon icon;
  final Icon selectedIcon;
  final Widget screen;

  const ResponsiveNavigationDestination ({
    required this.title,
    required this.icon,
    required this.selectedIcon,
    required this.screen,
  });
}
