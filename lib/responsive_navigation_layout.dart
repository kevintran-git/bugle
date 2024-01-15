import 'package:flutter/material.dart';

class ResponsiveNavigationController extends StatefulWidget {
  final List<ResponsiveNavigationDestination> allDestinations;

  const ResponsiveNavigationController(
      {super.key, required this.allDestinations});

  @override
  ResponsiveNavigationControllerState createState() =>
      ResponsiveNavigationControllerState();
}

class ResponsiveNavigationControllerState
    extends State<ResponsiveNavigationController>
    with TickerProviderStateMixin {
  late List<Key> _destinationKeys;
  late List<AnimationController> _faders;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _faders = widget.allDestinations
        .map<AnimationController>(
            (ResponsiveNavigationDestination destination) =>
                AnimationController(
                    vsync: this, duration: const Duration(milliseconds: 500)))
        .toList();
    _faders[_currentIndex].value = 1.0;
    _destinationKeys = List<Key>.generate(
        widget.allDestinations.length, (int index) => GlobalKey());
  }

  @override
  void dispose() {
    for (AnimationController controller in _faders) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: _currentIndex != index,
      child: FadeTransition(
        opacity: _faders[index].drive(CurveTween(curve: Curves.fastOutSlowIn)),
        child: KeyedSubtree(
          key: _destinationKeys[index],
          child: widget.allDestinations[index].screen,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final useNavigationBar = MediaQuery.of(context).size.width > 450;
    final isLargeScreen = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: useNavigationBar
            ? Row(
                children: [
                  NavigationRail(
                    extended: isLargeScreen,
                    destinations: widget.allDestinations.map((destination) {
                      return NavigationRailDestination(
                        icon: destination.icon,
                        selectedIcon: destination.selectedIcon,
                        label: Text(destination.title),
                      );
                    }).toList(),
                    selectedIndex: _currentIndex,
                    onDestinationSelected: (index) {
                      setState(() {
                        _faders[_currentIndex].reverse();
                        _currentIndex = index;
                        _faders[_currentIndex].forward();
                      });
                    },
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        for (var i = 0; i < widget.allDestinations.length; i++)
                          _buildOffstageNavigator(i),
                      ],
                    ),
                  ),
                ],
              )
            : Stack(
                children: [
                  for (var i = 0; i < widget.allDestinations.length; i++)
                    _buildOffstageNavigator(i),
                ],
              ),
      ),
      bottomNavigationBar: useNavigationBar
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _faders[_currentIndex].reverse();
                  _currentIndex = index;
                  _faders[_currentIndex].forward();
                });
              },
              destinations: widget.allDestinations.map((destination) {
                return NavigationDestination(
                  icon: destination.icon,
                  selectedIcon: destination.selectedIcon,
                  label: destination.title,
                );
              }).toList(),
            ),
    );
  }
}

class ResponsiveNavigationDestination {
  final String title;
  final Icon icon;
  final Icon selectedIcon;
  final Widget screen;

  const ResponsiveNavigationDestination({
    required this.title,
    required this.icon,
    required this.selectedIcon,
    required this.screen,
  });
}
