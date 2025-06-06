import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart';

import 'app_colors.dart';

class ServiceCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final String description;

  const ServiceCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 600;

    return GestureDetector(
      onTap: () {
        if (kIsWeb) {
          {
            html.window.alert(description);
          }
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(title),
                content: Text(description),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      },
      child: Container(
        width: isMobile ? 100 : 130,
        height: isMobile ? 140 : 180,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(40),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(155, 114, 87, 0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: isMobile ? 40 : 60,
              height: isMobile ? 40 : 60,
            ),
            SizedBox(height: isMobile ? 30 : 50),
            Text(
              title,
              style: TextStyle(
                  fontSize: isMobile ? 10 : 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
