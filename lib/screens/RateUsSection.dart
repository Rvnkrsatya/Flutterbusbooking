import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RateUsSection extends StatefulWidget {
  const RateUsSection({super.key});

  @override
  State<RateUsSection> createState() => _RateUsSectionState();
}

class _RateUsSectionState extends State<RateUsSection> {
  void _showRateDialog() {
    showDialog(
      context: context,
      builder: (context) => const RateDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/images/rating.png', // replace with your asset
              height: 70.h,
              width: 80.h,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Happy with YesGoBus?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Share your thoughts and help others choose YesGoBus!',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  ElevatedButton(
                    onPressed: _showRateDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF033564),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 10.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                    child: Text(
                      "Rate Now",
                      style: TextStyle(color: Colors.white, fontSize: 14.sp),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RateDialog extends StatefulWidget {
  const RateDialog({super.key});

  @override
  State<RateDialog> createState() => _RateDialogState();
}

class _RateDialogState extends State<RateDialog> {
  double _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();

  void _submitRating() {
    final feedback = _feedbackController.text.trim();
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Thanks for rating ${_rating.toInt()} star(s)! "
            "${feedback.isNotEmpty ? '\nFeedback: $feedback' : ''}"),
        duration: const Duration(seconds: 3),
      ),
    );

    // TODO: Send _rating and feedback to server
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: 20.h,
              bottom: MediaQuery
                  .of(context)
                  .viewInsets
                  .bottom + 20.h,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 0,
                maxHeight: MediaQuery
                    .of(context)
                    .size
                    .height * 0.8,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 35.r,
                      backgroundColor: Colors.yellow[700],
                      child: Icon(Icons.star, size: 40.sp, color: Colors.white),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "How would you rate our app experience?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    RatingBar.builder(
                      initialRating: 0,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemSize: 32.sp,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.w),
                      itemBuilder: (context, _) =>
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 30.sp,
                          ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          _rating = rating;
                        });
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      controller: _feedbackController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Write your feedback here...',
                        hintStyle: TextStyle(fontSize: 13.sp),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF14bde3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        minimumSize: Size(double.infinity, 44.h),
                      ),
                      onPressed: () {
                        if (_rating > 0) {
                          _submitRating();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please select a rating.')),
                          );
                        }
                      },
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "No, Thanks",
                        style: TextStyle(fontSize: 13.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// class RateDialog extends StatefulWidget {
//   const RateDialog({super.key});
//
//   @override
//   State<RateDialog> createState() => _RateDialogState();
// }
//
// class _RateDialogState extends State<RateDialog> {
//   int _rating = 0;
//   final TextEditingController _feedbackController = TextEditingController();
//
//   void _submitRating() {
//     final feedback = _feedbackController.text;
//     Navigator.of(context).pop();
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text("Thanks for rating $_rating star(s)!"),
//       ),
//     );
//
//     // TODO: send feedback and rating to backend
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Rate Us'),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Star Rating
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: List.generate(5, (index) {
//               return IconButton(
//                 icon: Icon(
//                   index < _rating ? Icons.star : Icons.star_border,
//                   color: Colors.amber,
//                   size: 40.sp,
//                 ),
//                 onPressed: () {
//                   setState(() {
//                     _rating = index + 1;
//                   });
//                 },
//               );
//             }),
//           ),
//           // Feedback TextField
//           TextField(
//             controller: _feedbackController,
//             maxLines: 3,
//             decoration: InputDecoration(
//               hintText: "Share your feedback...",
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10.r),
//               ),
//             ),
//           ),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: _submitRating,
//           child: const Text("Submit"),
//         ),
//       ],
//     );
//   }
// }
