import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddUsersDialogBox extends StatefulWidget {
  final String title;
  final String content;
  final String content2;
  final Future<void> Function() function;
  AddUsersDialogBox({super.key, required this.function,required this.content,required this.title,required this.content2});

  @override
  State<AddUsersDialogBox> createState() =>
      _AddUsersDialogBoxState();
}

class _AddUsersDialogBoxState extends State<AddUsersDialogBox> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.title,
        style: GoogleFonts.montserrat(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
      ),
      content: Text(
       widget.content,
        style: GoogleFonts.montserrat(
            color: Colors.black, fontSize: 12, fontWeight: FontWeight.w300),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                    color: const Color(0xff5B40A7),
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          fontSize: 10),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            GestureDetector(
              onTap: () async {
                await widget.function().then((value) {
                  Navigator.pop(context);

                  return showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Done(content: widget.content2,);
                      });
                });
              },
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                    color: const Color(0xff5B40A7),
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: Text(
                      "Ok",
                      style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          fontSize: 10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}

class Done extends StatefulWidget {
  final String content;
  const Done({super.key,required this.content});

  @override
  State<Done> createState() => _DoneState();
}

class _DoneState extends State<Done> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
         
            Text(
              "You have successfully deleted all items from wishList",
              style: GoogleFonts.montserrat(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            )
          ],
        ),
      ),
      actions: [
        Align(
          alignment: Alignment.bottomRight,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                  color: const Color(0xff5B40A7),
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Center(
                  child: Text(
                    "OK",
                    style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 10),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}