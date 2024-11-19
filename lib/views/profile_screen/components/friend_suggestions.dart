import 'package:flutter/material.dart';

class FriendSuggestions extends StatelessWidget {
  const FriendSuggestions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        bigTitle(),
        Container(
          margin: const EdgeInsets.only(top: 15, left: 5),
          height: 190.0,
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            children: [
              friendBox('assets/images/cyan.png', 'Cyan', 'Yellow'),
              friendBox('assets/images/impostor.png', 'Impostor', 'Heisenberg'),
              friendBox('assets/images/white.png', 'White', 'Jessie Pinkman'),
              friendBox('assets/images/green.png', 'Green', 'Red'),
              friendBox('assets/images/yellow.png', 'Yellow', 'Pink'),
            ],
          ),
        ),
      ],
    );
  }

  Widget friendBox(String image, String name, String follower) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      padding: const EdgeInsets.all(5),
      height: 170,
      width: 145,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          width: 2.5,
          color: const Color(0xFFE5E5E5),
        ),
      ),
      child: Column(
        children: [
          avatar(image),
          friendName(name),
          followedBy(follower),
          const Spacer(),
          followButton(),
        ],
      ),
    );
  }

  Widget followButton() {
    return Container(
      width: double.infinity,
      height: 30,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1CB0F6),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: const Text(
          'FOLLOW',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget followedBy(String name) {
    return Text(
      'Followed by $name',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFFAFAFAF),
        fontSize: 15,
      ),
      textAlign: TextAlign.center,
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

  Widget bigTitle() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(top: 20, left: 15),
        child: Text(
          'Friend Suggestions',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4B4B4B),
          ),
        ),
      ),
    );
  }
}
