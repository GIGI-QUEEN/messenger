import 'package:flutter/material.dart';
import 'package:secure_messenger/components/my_list_tile.dart';

import '../pages/search_page.dart';
import '../pages/settings_page.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onProfileTap;
  final void Function()? onSignOut;

  const MyDrawer({
    super.key,
    required this.onProfileTap,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              // logo tile
              DrawerHeader(
                child: Center(
                  child: Icon(
                    Icons.message,
                    color: Theme.of(context).colorScheme.primary,
                    size: 40,
                  ),
                ),
              ),

              // home list tile
              MyListTile(
                icon: Icons.home,
                text: 'H O M E',
                onTap: () => Navigator.pop(context),
              ),

              // search list tile
              MyListTile(
                icon: Icons.add_box_outlined,
                text: 'S E A R C H',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchPage(),
                  ),
                ),
              ),

              // settings list tile

              MyListTile(
                icon: Icons.person,
                text: 'P R O F I L E',
                onTap: onProfileTap,
              ),

              MyListTile(
                icon: Icons.settings,
                text: 'S E T T I N G S',
                onTap: () {
                  // pop the drawer
                  Navigator.pop(context);

                  // navigate to settings page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
              ),
            ],
          ),

          // logout tile
          MyListTile(
            icon: Icons.logout,
            text: 'L O G O U T',
            onTap: onSignOut,
          ),
        ],
      ),
    );
  }
}
