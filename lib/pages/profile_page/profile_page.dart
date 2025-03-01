import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:provider/provider.dart';
import 'package:secure_messenger/components/avatar.dart';
import 'package:secure_messenger/pages/contacts_page/contacts_page.dart';
import 'package:secure_messenger/pages/profile_page/editing_view.dart';
import 'package:secure_messenger/pages/profile_page/profile_provider.dart';
import 'package:secure_messenger/pages/qr_page/qr_code_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.userId,
  });
  final String userId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfileProvider(userId: userId),
      child: Consumer<ProfileProvider>(
        builder: (context, model, child) {
          return Scaffold(
            appBar: ProfilePageAppBar(),
            body: model.isEditing
                ? EditingView()
                : UserProfile(
                    user: model.user,
                    addToContacts: model.addToContacts,
                    removeFromContacts: model.removeFromContacts,
                    isCurrentUser: model.isCurrentUserProfile,
                    isContact: model.isContact,
                  ),
          );
        },
      ),
    );
  }
}

class ProfilePageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ProfilePageAppBar({
    super.key,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    final profileModel = Provider.of<ProfileProvider>(context);
    return AppBar(
      backgroundColor: Colors.transparent,
      leadingWidth: profileModel.isEditing ? 80 : null,
      leading: profileModel.isEditing
          ? TextButton(
              onPressed: () => profileModel.cancelEditing(),
              child: const Text('Cancel'))
          : null,
      actions: profileModel.isCurrentUserProfile
          ? profileModel.isEditing
              ? [
                  TextButton(
                      onPressed: () => profileModel.saveChanges(),
                      child: const Text('Done'))
                ]
              : [
                  TextButton(
                      onPressed: () => profileModel.startEditing(),
                      child: const Text('Edit'))
                ]
          : null,
    );
  }
}

class UserProfile extends StatelessWidget {
  const UserProfile({
    super.key,
    required this.user,
    required this.addToContacts,
    required this.isCurrentUser,
    required this.isContact,
    required this.removeFromContacts,
  });
  final User user;
  final bool isCurrentUser;
  final bool isContact;
  final Function(String contactId) addToContacts;
  final Function(String contactId) removeFromContacts;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          UserAvatar(
            imageUrl: user.imageUrl,
            radius: 100,
            iconColor: Colors.white,
            iconSize: 150,
            iconBorderColor: Colors.white,
          ),
          const SizedBox(
            height: 20,
          ),
          ProfileInfo(
            user: user,
          ),
          const SizedBox(
            height: 20,
          ),
          // const Bio(bio: 'bio ()'),
          _addOrRemoveContactButton(),
          const SizedBox(
            height: 20,
          ),
          OutlinedButton(
              onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QRCodePage(),
                    ),
                  ),
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              child: const Text('QR Code')),
        ],
      ),
    );
  }

  Widget _addOrRemoveContactButton() {
    if (!isCurrentUser) {
      switch (isContact) {
        case true:
          return OutlinedButton(
            onPressed: () => removeFromContacts(user.id),
            child: const Text('remove from contacts'),
          );
        case false:
          return OutlinedButton(
            onPressed: () => addToContacts(user.id),
            child: const Text('add to contacts'),
          );
      }
    } else {
      return Container();
    }
  }
}

class ProfileInfo extends StatelessWidget {
  const ProfileInfo({super.key, required this.user});
  final User user;
  @override
  Widget build(BuildContext context) {
    return ProfileInfoSectionContainer(
      child: user.metadata != null
          ? ListView(
              children: [
                Text(user.metadata!['username']),
                divider,
                Text(user.metadata!['email']),
              ],
            )
          : null,
    );
  }
}

class ProfileInfoSectionContainer extends StatelessWidget {
  const ProfileInfoSectionContainer({super.key, this.child, this.height});
  final Widget? child;
  final double? height;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20, top: 15, right: 20),
      height: height ?? 85,
      width: 300,
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 32, 32, 32),
          borderRadius: BorderRadius.circular(10)),
      child: child,
    );
  }
}

class Bio extends StatelessWidget {
  const Bio({super.key, required this.bio});
  final String bio;
  @override
  Widget build(BuildContext context) {
    return ProfileInfoSectionContainer(
      height: 105,
      child: Text(bio),
    );
  }
}

const divider = Divider(
  thickness: 0.2,
  color: Color.fromARGB(94, 255, 255, 255),
);

class TextBox extends StatelessWidget {
  const TextBox({
    super.key,
    required this.sectionName,
    required this.sectionValue,
  });
  final String sectionName;
  final String sectionValue;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(sectionName),
          Text(sectionValue),
        ],
      ),
    );
  }
}
