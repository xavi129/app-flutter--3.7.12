import 'package:flutter/material.dart';
import 'colors.dart';
import 'package:google_fonts/google_fonts.dart';

class TitleTextWidget extends StatelessWidget {
  const TitleTextWidget({
    Key key,
    this.size,
    this.index,
    this.name,
  }) : super(key: key);

  final Size size;
  final int index;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: GoogleFonts.inter(
        color: kTitleColor,
        fontWeight: FontWeight.bold,
        fontSize: size.width * 0.055,
      ),
    );
  }
}
