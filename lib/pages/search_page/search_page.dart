import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:provider/provider.dart';
import 'package:secure_messenger/components/avatar.dart';
import 'package:secure_messenger/components/custom_textfield.dart';
import 'package:secure_messenger/pages/profile_page/profile_page.dart';
import 'package:secure_messenger/pages/search_page/search_provider.dart';
import 'package:secure_messenger/utils/navigation.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  void navigateToUserProfile(BuildContext context, String userId) {
    navigateTo(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage(
                  userId: userId,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: ChangeNotifierProvider(
        create: (context) => SearchProvider(),
        child: Consumer<SearchProvider>(
          builder: (context, model, child) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  CustomTextField(
                    hintText: 'search',
                    obscureText: false,
                    controller: model.textEditingController,
                    suffixIcon: IconButton(
                        onPressed: () => model.findUser(),
                        icon: const Icon(
                          Icons.search,
                          color: Colors.black,
                        )),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  model.foundUser != null
                      ? FoundUserTile(
                          user: model.foundUser!,
                          onTap: () => navigateToUserProfile(
                              context, model.foundUser!.id),
                        )
                      : model.isNotFound
                          ? const Text('Not found')
                          : Container()
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class FoundUserTile extends StatelessWidget {
  const FoundUserTile({
    super.key,
    required this.user,
    this.onTap,
  });
  final User user;
  final Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(245, 245, 245, 0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: onTap,
        leading: UserAvatar(
          imageUrl: user.imageUrl,
        ),
        title: Text(
          user.metadata!['email'],
          style: const TextStyle(color: Colors.black),
        ),
        subtitle: Text(
          '@${user.metadata!['username']}',
          style: const TextStyle(color: Color.fromARGB(255, 82, 82, 82)),
        ),
      ),
    );
  }
}
