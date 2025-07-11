import 'package:flutter/material.dart';

class Courses extends StatelessWidget {
  final List<Map<String, dynamic>> coursesData;
  const Courses({required this.coursesData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: coursesData.length,
                itemBuilder: (context, index) {
                  final course = coursesData[index];
                  return Card(
                    child: ListTile(
                      title: Text(course['title'] ?? 'No Title'),
                      subtitle: Text(course['provider'] ?? ''),
                      trailing: course['average_rating'] != null
                          ? Text('⭐ ${course['average_rating']}')
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
