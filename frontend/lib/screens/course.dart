import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart'; // For opening external links

class Course extends StatefulWidget {
  final Map<String, dynamic> courseData;

  const Course({super.key, required this.courseData});

  @override
  State<Course> createState() => _CourseState();
}

class _CourseState extends State<Course> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _reviewTextController = TextEditingController();
  int _selectedRating = 0; // User's selected star rating (0-5)
  bool _isSubmittingRating = false;

  @override
  void dispose() {
    _reviewTextController.dispose();
    super.dispose();
  }

  // Function to submit a new rating
  Future<void> _submitRating() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      _showSnackBar('Please log in to submit a rating.', Colors.red);
      return;
    }
    if (_selectedRating == 0) {
      _showSnackBar('Please select a star rating.', Colors.orange);
      return;
    }

    setState(() {
      _isSubmittingRating = true;
    });

    try {
      final String courseId =
          widget.courseData['id']
              as String; // Assuming 'id' is present in courseData
      await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('ratings')
          .add({
            'userId': currentUser.uid,
            'rating': _selectedRating,
            'reviewText': _reviewTextController.text.trim(),
            'timestamp': FieldValue.serverTimestamp(),
          });

      _showSnackBar('Rating submitted successfully!', Colors.green);
      _reviewTextController.clear();
      setState(() {
        _selectedRating = 0; // Reset stars
      });
    } catch (e) {
      _showSnackBar('Failed to submit rating: $e', Colors.red);
      print('Error submitting rating: $e');
    } finally {
      setState(() {
        _isSubmittingRating = false;
      });
    }
  }

  // Helper to show a SnackBar message
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Function to launch URL
  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      _showSnackBar('Could not launch $url', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.courseData['title'] ?? 'N/A';
    final String description =
        widget.courseData['description'] ?? 'No description available.';
    final String provider = widget.courseData['provider'] ?? 'N/A';
    final String imageUrl = 'assets/app-watermark.jpg'; // Placeholder
    final List<dynamic> associatedProfessionIds =
        widget.courseData['associatedProfessionIds'] ?? [];
    final double averageRating =
        (widget.courseData['averageRating'] as num?)?.toDouble() ?? 0.0;
    final String? courseLink = widget.courseData['link'];
    final String courseId =
        widget.courseData['id']
            as String; // Get course ID for ratings sub-collection
    double width = MediaQuery.of(context).size.width;

    double imageWidth = width * 0.7;
    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                imageUrl,
                width: imageWidth,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title and Provider
            Text(
              title,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Provider: $provider',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),

            // Average Rating Display
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 24),
                const SizedBox(width: 4),
                Text(
                  averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${widget.courseData['ratingCount'] ?? 0} ratings)', // Assuming a 'ratingCount' field
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            Text(description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),

            // Associated Profession IDs
            if (associatedProfessionIds.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [const SizedBox(height: 16)],
              ),

            // Course Link Button
            if (courseLink != null && courseLink.isNotEmpty)
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _launchUrl(courseLink),
                  icon: const Icon(Icons.launch),
                  label: const Text('Go to Course'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            const Divider(height: 32, thickness: 1),

            // --- Rating Section ---
            const Text(
              'Add Your Rating',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _selectedRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 36,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedRating = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reviewTextController,
              decoration: InputDecoration(
                labelText: 'Write a review (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Center(
              child: _isSubmittingRating
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitRating,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Submit Rating'),
                    ),
            ),
            const Divider(height: 32, thickness: 1),

            // --- Existing Ratings Section ---
            const Text(
              'User Reviews',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('courses')
                  .doc(courseId)
                  .collection('ratings')
                  .orderBy(
                    'timestamp',
                    descending: true,
                  ) // Order by latest reviews
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading reviews: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No reviews yet. Be the first!'),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true, // Important for nested ListView
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable scrolling for this nested list
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final ratingDoc = snapshot.data!.docs[index];
                    final ratingData = ratingDoc.data() as Map<String, dynamic>;
                    final int rating = ratingData['rating'] ?? 0;
                    final String reviewText = ratingData['reviewText'] ?? '';
                    final String userId = ratingData['userId'] ?? '';
                    final Timestamp? timestamp =
                        ratingData['timestamp'] as Timestamp?;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display username
                            FutureBuilder<DocumentSnapshot>(
                              future: _firestore
                                  .collection('users')
                                  .doc(userId)
                                  .get(),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text(
                                    'Loading user...',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                    ),
                                  );
                                }
                                if (userSnapshot.hasError) {
                                  return const Text(
                                    'Error loading user',
                                    style: TextStyle(color: Colors.red),
                                  );
                                }
                                if (userSnapshot.hasData &&
                                    userSnapshot.data!.exists) {
                                  final userData =
                                      userSnapshot.data!.data()
                                          as Map<String, dynamic>;
                                  return Text(
                                    userData['username'] ?? 'Anonymous User',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  );
                                }
                                return const Text(
                                  'Unknown User',
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                );
                              },
                            ),
                            const SizedBox(height: 4),
                            // Stars
                            Row(
                              children: List.generate(5, (starIndex) {
                                return Icon(
                                  starIndex < rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 18,
                                );
                              }),
                            ),
                            const SizedBox(height: 8),
                            // Review Text
                            if (reviewText.isNotEmpty)
                              Text(
                                reviewText,
                                style: const TextStyle(fontSize: 14),
                              ),
                            if (reviewText.isNotEmpty)
                              const SizedBox(height: 8),
                            // Timestamp
                            if (timestamp != null)
                              Text(
                                '${timestamp.toDate().toLocal().toString().split(' ')[0]}', // Display date only
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
