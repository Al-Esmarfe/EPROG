import 'package:flutter/material.dart';

class Friends extends StatelessWidget {
  const Friends({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      // Adicione este widget
      length: 2, // Número de abas
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        height: 344,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            width: 2.5,
            color: const Color(0xFFE5E5E5),
          ),
        ),
        child: Column(
          children: [
            TabBar(
              indicatorColor: const Color(0xFF1CB0F6),
              indicatorWeight: 3,
              tabs: [
                tabBarText('FOLLOWING'),
                tabBarText('FOLLOWERS'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  following(),
                  followers(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget following() {
    return ListView(
      shrinkWrap: true,
      children: [
        friend('assets/images/white.png', 'Batman', '10234'),
        friend('assets/images/cyan.png', 'Vinod', '893'),
        friend('assets/images/profile.png', 'Wanda', '314'),
      ],
    );
  }

  Widget followers() {
    return ListView(
      shrinkWrap: true,
      children: [
        friend('assets/images/profile.png', 'Wanda', '314'),
        friend('assets/images/profile.jpg', 'Marc', '2012'),
      ],
    );
  }

  Widget friend(String image, String name, String xp) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Row(
        children: [
          avatar(image),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              friendName(name),
              xpAmount(xp),
            ],
          ),
        ],
      ),
    );
  }

  Widget xpAmount(String xp) {
    return Text(
      '$xp XP',
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Color(0xFFAFAFAF),
      ),
    );
  }

  Widget friendName(String name) {
    return Text(
      name,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF4B4B4B),
        fontSize: 17,
      ),
    );
  }

  Widget avatar(String image) {
    return CircleAvatar(
      backgroundImage: AssetImage(image),
      radius: 22,
    );
  }

  Widget tabBarText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget bigTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 20, left: 15, bottom: 10),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4B4B4B),
          ),
        ),
      ),
    );
  }
}
