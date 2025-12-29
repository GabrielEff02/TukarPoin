import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MyButton extends StatelessWidget {
  var icon;
  bool shadow;

  MyButton({
    Key? key,
    this.icon,
    this.shadow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Icon(
        icon,
        size: 27,
        color: const Color(0xFFF0830F),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[300],
        boxShadow: shadow
            ? [
                BoxShadow(
                    color: Colors.grey[600]!,
                    offset: Offset(4.0, 4.0),
                    blurRadius: 15.0,
                    spreadRadius: 1.0),
                BoxShadow(
                    color: Colors.white,
                    offset: Offset(-4.0, -4.0),
                    blurRadius: 15.0,
                    spreadRadius: 1.0),
              ]
            : null,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[200]!,
            Colors.grey[300]!,
            Colors.grey[400]!,
            Colors.grey[500]!,
          ],
          stops: [0.1, 0.3, 0.8, 1],
        ),
      ),
    );
  }
}

class ButtonTapped extends StatelessWidget {
  var icon;

  ButtonTapped({
    Key? key,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Icon(
        icon,
        size: 25,
        color: const Color.fromARGB(221, 255, 255, 255),
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[300],
          boxShadow: [
            BoxShadow(
                color: Colors.white,
                offset: Offset(4.0, 4.0),
                blurRadius: 15.0,
                spreadRadius: 1.0),
            BoxShadow(
                color: Colors.grey[600]!,
                offset: Offset(-4.0, -4.0),
                blurRadius: 15.0,
                spreadRadius: 1.0),
          ],
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange[700]!,
                Colors.orange[600]!,
                Colors.orange[500]!,
                Colors.orange[200]!,
              ],
              stops: [
                0,
                0.1,
                0.3,
                1
              ])),
    );
  }
}
