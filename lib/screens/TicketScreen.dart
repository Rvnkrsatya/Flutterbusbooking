import 'dart:developer';
import 'dart:io';

import 'dart:ui';
import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';

import 'dart:convert';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../Service/appservice/api_urls.dart';
import '../Service/appservice/apibase.dart';

class TicketScreen extends StatefulWidget {
  // final String userId;
  final String bookingId;

  const TicketScreen({super.key, required this.bookingId});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}




class _TicketScreenState extends State<TicketScreen> {
  Map<String, dynamic>? bookingDetails;
  bool isLoading = true;
  bool isFetching = false;
  String travellers = "";
  String travellersAge = "";
  String travellerssex = "";

  @override
  void initState() {
    super.initState();
    log("📥 TicketScreen received bookingId: ${widget.bookingId}");
    fetchBookingDetails();
  }

  Future<void> fetchBookingDetails() async {
    if (isFetching) return;
    isFetching = true;

    try {
      var response = await ApiBase.getRequest(extendedURL: "${ApiUrls.getbookingbyid}/${widget.bookingId}", withToken: false);
      log("API Link: ${ApiUrls.getbookingbyid}/${widget.bookingId}");
      log("Response Body2: ${response.body}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        log("Decoded Data: $data");

        setState(() {
          bookingDetails = data['data'] ?? {};
          isLoading = false;
        });

        if (bookingDetails != null) {
          log("Booking Details: ${jsonEncode(bookingDetails)}");

          // Check for SRS booking
          if (bookingDetails?['srsBlockSeatDetails'] != null) {
            var seatDetails = (bookingDetails?['srsBlockSeatDetails']['book_ticket']['seat_details']['seat_detail'] as List?) ?? [];

            travellers = seatDetails.map((seat) => seat['name']?.toString() ?? "N/A").join(", ");
            travellersAge = seatDetails.map((seat) => seat['age']?.toString() ?? "N/A").join(", ");
            travellerssex = seatDetails.map((seat) => seat['sex']?.toString() ?? "N/A").join(", ");
          }
          // Check for VRL booking
          else if ((bookingDetails?['reservationSchema'] as List?)?.isNotEmpty ?? false) {
            List paxList = bookingDetails!['reservationSchema'][0]['paxDetails'] ?? [];

            travellers = paxList.map((pax) => pax['paxName']?.toString() ?? "N/A").join(", ");
            travellersAge = paxList.map((pax) => pax['paxAge']?.toString() ?? "N/A").join(", ");

            // Extract gender from seatNames
            String seatNames = bookingDetails!['reservationSchema'][0]['seatNames'] ?? "";
            List<String> parts = seatNames.split(",");
            // Assuming the format is like "L17,F"
            travellerssex = parts.length > 1 ? (parts[1].trim().toUpperCase() == "F" ? "Female" : "Male") : "N/A";
          }
        } else {
          log("No Booking Details Found");
        }
      } else {
        log("Error: Status Code ${response.statusCode}");
      }
    } catch (e) {
      log("Error fetching booking details: $e");
    } finally {
      isFetching = false;
    }
  }



  Future<void> generatePDF() async {
    final pdf = pw.Document();
// your pdf building code...
    final pdfBytes = await pdf.save();
    // Load logo image
    final ByteData data = await rootBundle.load('assets/images/yesgobuswhite.png');
    final Uint8List logoBytes = data.buffer.asUint8List();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black),
                borderRadius: pw.BorderRadius.circular(12),
                //color: PdfColor.fromInt(0xFF0564B1),
                color: PdfColors.white
            ),
            padding: pw.EdgeInsets.all(0),
            child: pw.Column(
              children: [
                // Header Section (Logo & Contact)

                //  pw.SizedBox(height: 10),

                // Booking details
                pw.Container(
                  padding: pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(12),
                    color: PdfColors.white,
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        padding: pw.EdgeInsets.all(0),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blue,
                          borderRadius: pw.BorderRadius.only(
                            topLeft: pw.Radius.circular(12),
                            topRight: pw.Radius.circular(12),
                          ),
                        ), // Add padding if needed
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Image(pw.MemoryImage(logoBytes), height: 50),
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                pw.Text(
                                  "support@yesgobus.com",
                                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                                ),
                                pw.Text(
                                  "9888417555",
                                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.SizedBox(height: 5),

                              pw.Text("From", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                              pw.SizedBox(height: 3),
                              pw.Text(bookingDetails?['sourceCity'] ?? ''),
                              pw.SizedBox(height: 4),
                              pw.Text("Date: ${formatDate(bookingDetails?['doj'])}"),
                            ],
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.SizedBox(height: 5), // space before the "To" section

                              pw.Text(
                                "To",
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                              ),
                              pw.SizedBox(height: 3), // space between lines

                              pw.Text(
                                bookingDetails?['destinationCity'] ?? '',
                              ),
                              pw.SizedBox(height: 4), // space between lines

                              pw.Text(
                                "PNR: ${bookingDetails?['buspnr'] ?? ''}",
                              ),
                              pw.SizedBox(height: 10), // space below this section
                            ],
                          ),

                        ],
                      ),
                      pw.Divider(color: PdfColors.black, thickness: 1),
                      pw.SizedBox(height: 6),

                      // Bus Type
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "Bus Type: ",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                              color: PdfColors.black,
                            ),
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                bookingDetails?['busOperator'] ?? '',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.Text(
                                bookingDetails?['busType'] ?? '',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  color: PdfColors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),


                      pw.SizedBox(height: 6),
                      pw.Divider(color: PdfColors.black, thickness: 1),
                      pw.SizedBox(height: 6),


                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // Pickup (left-aligned)
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text("Pickup Point:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                pw.Text(
                                  bookingDetails?['boardingPoint'] ?? '',
                                  style: pw.TextStyle(fontSize: 11),
                                  textAlign: pw.TextAlign.left,
                                  softWrap: true,
                                ),
                                pw.Text(
                                  formatTime(bookingDetails?['pickUpTime']),
                                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                                ),
                              ],
                            ),
                          ),

                          pw.Container(width: 1, height: 40, color: PdfColors.black),

                          // Dropping (right-aligned)
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                pw.Text("Dropping Point:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                pw.Text(
                                  bookingDetails?['droppingPoint'] ?? '',
                                  style: pw.TextStyle(fontSize: 11),
                                  textAlign: pw.TextAlign.right,
                                  softWrap: true,
                                ),
                                pw.Text(
                                  formatTime(bookingDetails?['reachTime']),
                                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      pw.SizedBox(height: 6),
                      pw.Divider(color: PdfColors.black, thickness: 1),
                      pw.SizedBox(height: 6),

                      // Contact Details
                      pw.Row(
                        children: [
                          pw.Text("Email Id: ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          // pw.Text("customer@example.com"),
                          pw.Text(bookingDetails?['customerEmail'] ?? ''),

                        ],
                      ),
                      pw.Row(
                        children: [
                          pw.Text("Mobile No: ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text(bookingDetails?['customerPhone'] ?? ''),
                        ],
                      ),
                      pw.SizedBox(height: 6),
                      pw.Divider(color: PdfColors.black, thickness: 1),
                      pw.SizedBox(height: 6),

                      // Passenger Details Table
                      pw.Table(
                        border: pw.TableBorder.all(color: PdfColors.black),
                        columnWidths: {
                          0: pw.FlexColumnWidth(2),
                          1: pw.FlexColumnWidth(1),
                          2: pw.FlexColumnWidth(1),
                          3: pw.FlexColumnWidth(1),
                        },
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.all(4),
                                child: pw.Text("Traveller Name", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),


                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(4),
                                child: pw.Text("Gender", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(4),
                                child: pw.Text("Age", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(4),
                                child: pw.Text("Seat No.", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                              ),
                            ],
                          ),
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(travellers), // ✅ traveller name(s)
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(travellerssex ?? ''), // ✅ sex
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(travellersAge ?? ''), // ✅ age
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(bookingDetails?['selectedSeats'] ?? ''), // ✅ seat no
                              ),
                            ],
                          ),

                        ],
                      ),

                      pw.SizedBox(height: 20),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Text(
                            "Total amount: ${bookingDetails?['totalAmount'] ?? ''}",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      pw.Text(
                        "Terms and Conditions",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF0564B1),
                        ),
                      ),
                      pw.SizedBox(height: 8),

                      pw.Bullet(
                        text: "YesGoBus Travellers can book bus tickets online at the lowest ticket fares. Travellers prefer to choose their favorite bus to reserve online bus booking.",
                      ),
                      pw.SizedBox(height: 6),

                      pw.Bullet(
                        text: "Youre at the right place to find a wide range of Private buses and SRTC (State Road Transport Corporation) buses are available for bus booking online on bus..",
                      ),
                      pw.SizedBox(height: 6),

                      pw.Bullet(
                        text: "Passengers should arrive at least 15 min before the scheduled time of departure.",
                      ),
                      pw.SizedBox(height: 10),

                      pw.SizedBox(height: 20),
                      pw.Text(
                          'Cancelation',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFF0564B1))),
                      pw.SizedBox(height: 6),

                      pw.Bullet(
                        text: "YesGoBus is not responsible for any accident or any passenger losses.",
                      ),

                      pw.SizedBox(height: 6),

                      pw.Bullet(
                        text: "Cancellation charges are applicable on the original fare but not available on discount.",
                      ),
                      // Adds some space between title and content



                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Save & Print
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }



  Future<void> sharePDF() async {
    final pdf = pw.Document();
    final ByteData data = await rootBundle.load('assets/images/yesgobuswhite.png');
    final Uint8List logoBytes = data.buffer.asUint8List();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black),
                borderRadius: pw.BorderRadius.circular(12),
                //color: PdfColor.fromInt(0xFF0564B1),
                color: PdfColors.white
            ),
            padding: pw.EdgeInsets.all(0),
            child: pw.Column(
              children: [
                // Header Section (Logo & Contact)

                //  pw.SizedBox(height: 10),

                // Booking details
                pw.Container(
                  padding: pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(12),
                    color: PdfColors.white,
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        padding: pw.EdgeInsets.all(0),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blue,
                          borderRadius: pw.BorderRadius.only(
                            topLeft: pw.Radius.circular(12),
                            topRight: pw.Radius.circular(12),
                          ),
                        ), // Add padding if needed
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Image(pw.MemoryImage(logoBytes), height: 60),
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                pw.Text(
                                  "support@gmail.com",
                                  style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                                ),
                                pw.Text(
                                  "9986638183",
                                  style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.SizedBox(height: 5),
                              pw.Text("From", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                              pw.SizedBox(height: 3),
                              pw.Text(bookingDetails?['sourceCity'] ?? ''),
                              pw.SizedBox(height: 4),

                              pw.Text("Date: ${formatDate(bookingDetails?['doj'])}"),
                            ],
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.SizedBox(height: 5),

                              pw.Text("To", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                              pw.SizedBox(height: 3),

                              pw.Text(bookingDetails?['destinationCity'] ?? ''),
                              pw.SizedBox(height: 4),
// Replace with actual data
                              pw.Text("PNR: ${bookingDetails?['buspnr'] ?? ''}"),
                            ],
                          ),
                        ],
                      ),
                      pw.Divider(color: PdfColors.black, thickness: 1),
                      pw.SizedBox(height: 6),

                      // Bus Type
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "Bus Type: ",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                              color: PdfColors.black,
                            ),
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                bookingDetails?['busOperator'] ?? '',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  color: PdfColors.black,
                                ),
                              ),
                              pw.Text(
                                bookingDetails?['busType'] ?? '',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  color: PdfColors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),


                      pw.SizedBox(height: 6),
                      pw.Divider(color: PdfColors.black, thickness: 1),
                      pw.SizedBox(height: 6),




                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // Pickup (left-aligned)
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text("Pickup Point:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                pw.Text(
                                  bookingDetails?['boardingPoint'] ?? '',
                                  style: pw.TextStyle(fontSize: 11),
                                  textAlign: pw.TextAlign.left,
                                  softWrap: true,
                                ),
                                pw.Text(
                                  formatTime(bookingDetails?['pickUpTime']),
                                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                                ),
                              ],
                            ),
                          ),

                          pw.Container(width: 1, height: 40, color: PdfColors.black),

                          // Dropping (right-aligned)
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                pw.Text("Dropping Point:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                pw.Text(
                                  bookingDetails?['droppingPoint'] ?? '',
                                  style: pw.TextStyle(fontSize: 11),
                                  textAlign: pw.TextAlign.right,
                                  softWrap: true,
                                ),
                                pw.Text(
                                  formatTime(bookingDetails?['reachTime']),
                                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      pw.SizedBox(height: 6),
                      pw.Divider(color: PdfColors.black, thickness: 1),
                      pw.SizedBox(height: 6),

                      // Contact Details
                      pw.Row(
                        children: [
                          pw.Text("Email Id: ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          // pw.Text("customer@example.com"),
                          pw.Text(bookingDetails?['customerEmail'] ?? ''),

                        ],
                      ),
                      pw.Row(
                        children: [
                          pw.Text("Mobile No: ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text(bookingDetails?['customerPhone'] ?? ''),
                        ],
                      ),
                      pw.SizedBox(height: 6),
                      pw.Divider(color: PdfColors.black, thickness: 1),
                      pw.SizedBox(height: 6),

                      // Passenger Details Table
                      pw.Table(
                        border: pw.TableBorder.all(color: PdfColors.black),
                        columnWidths: {
                          0: pw.FlexColumnWidth(2),
                          1: pw.FlexColumnWidth(1),
                          2: pw.FlexColumnWidth(1),
                          3: pw.FlexColumnWidth(1),
                        },
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.all(4),
                                child: pw.Text("Traveller Name", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),


                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(4),
                                child: pw.Text("Gender", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(4),
                                child: pw.Text("Age", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(4),
                                child: pw.Text("Seat No.", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                              ),
                            ],
                          ),
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(travellers), // ✅ traveller name(s)
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(travellerssex ?? ''), // ✅ sex
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(travellersAge ?? ''), // ✅ age
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(4),
                                child: pw.Text(bookingDetails?['selectedSeats'] ?? ''), // ✅ seat no
                              ),
                            ],
                          ),

                        ],
                      ),

                      pw.SizedBox(height: 20),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Text(
                            "Total amount: ${bookingDetails?['totalAmount'] ?? ''}",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      pw.Text(
                        "Terms and Conditions",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromInt(0xFF0564B1),
                        ),
                      ),
                      pw.SizedBox(height: 8),

                      pw.Bullet(
                        text: "YesGoBus Travellers can book bus tickets online at the lowest ticket fares. Travellers prefer to choose their favorite bus to reserve online bus booking.",
                      ),
                      pw.SizedBox(height: 6),

                      pw.Bullet(
                        text: "Youre at the right place to find a wide range of Private buses and SRTC (State Road Transport Corporation) buses are available for bus booking online on bus..",
                      ),
                      pw.SizedBox(height: 6),

                      pw.Bullet(
                        text: "Passengers should arrive at least 15 min before the scheduled time of departure.",
                      ),
                      pw.SizedBox(height: 10),

                      pw.SizedBox(height: 20),
                      pw.Text(
                          'Cancelation',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFF0564B1))),
                      pw.SizedBox(height: 6),

                      pw.Bullet(
                        text: "YesGoBus is not responsible for any accident or any passenger losses.",
                      ),

                      pw.SizedBox(height: 6),

                      pw.Bullet(
                        text: "Cancellation charges are applicable on the original fare but not available on discount.",
                      ),
                      // Adds some space between title and content



                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    final Uint8List pdfBytes = await pdf.save();
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/ticket.pdf");
    await file.writeAsBytes(pdfBytes);

    await Share.shareXFiles([XFile(file.path)], text: 'Here is your ticket');
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ticket Details')),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(), // Smooth scrolling effect
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height, // Ensures full height
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                //SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(0.0),
                  decoration: BoxDecoration(
                    color: Color(0xFF0564B1),  // Outer white background
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                    border: Border.all(color: Colors.black), // Border
                  ),
                  child: Column(
                    children: [
                      /// **Top Section: Logo & Help Info**
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                                'assets/images/yesgobuswhite.png', height: 80),// Logo
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Padding(
                                //   padding: EdgeInsets.only(right: 12), // Add left margin of 10
                                //   child: Text(
                                //     "Help me",
                                //     style: TextStyle(fontSize: 12, color: Colors.white),
                                //   ),
                                // ),
                                Padding(
                                  padding: EdgeInsets.only(right: 5), // Add left margin of 10
                                  child: Text(
                                    "support@gmail.com",
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,color:Colors.white),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 10), // Add left margin of 10
                                  child: Text(
                                    "9986638183",
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      //SizedBox(height: 4), // Spacing

                      /// **Blue Box for From & To Details**
                      //SizedBox(height: 4), // Spacing
                      Container(
                        padding: EdgeInsets.all(0.0),
                        decoration: BoxDecoration(
                          color: Colors.white,  // Outer white background
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
// Rounded corners
                          border: Border.all(color: Colors.white), // Border
                        ),
                        child: Column(
                          children: [
                            /// **From & To Details (without table border)**
                            Container(
                              color: Colors.white, // White background
                              padding: EdgeInsets.all(3.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// "From" and "To" Labels
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("From", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                                      Text("To", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                                    ],
                                  ),

                                  /// Dotted Line Between "From" and "To"
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: Colors.black,
                                          thickness: 1,
                                          height: 10,
                                        ),
                                      ),
                                      Icon(Icons.directions_bus, size: 16, color: Colors.black), // Bus Icon
                                      Expanded(
                                        child: Divider(
                                          color: Colors.black,
                                          thickness: 1,
                                          height: 10,
                                        ),
                                      ),
                                    ],
                                  ),

                                  /// "From" and "To" Values
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            bookingDetails?['sourceCity'] ?? '',
                                            style: TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            "Date: ${formatDate(bookingDetails?['doj'])}",
                                            style: TextStyle(color: Colors.black,fontSize: 13),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            bookingDetails?['destinationCity'] ?? '',
                                            style: TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            "PNR: ${bookingDetails?['buspnr']?.toString() ?? ''}",
                                            style: TextStyle(color: Colors.black,fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            //SizedBox(height: 4),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 0.0), // Adds space around the line
                              child: Divider(
                                color: Colors.black,
                                thickness: 1, // Line thickness
                              ),
                            ),
                            Container(
                              color: Colors.white, // White background
                              padding: EdgeInsets.all(3.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// "From" and "To" Labels
                                  Row(
                                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Bus Type :  ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12, color: Colors.black)),
                                      Text(
                                        bookingDetails?['busOperator'] ?? '',
                                        style: TextStyle(fontSize: 12, color: Colors.black),
                                      ),
                                    ],

                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 65), // Add left margin of 10
                                    child: Text(
                                      bookingDetails?['busType'] ?? '',
                                      style: TextStyle(fontSize: 12, color: Colors.black),
                                    ),
                                  ),
                                  /// Dotted Line Between "From" and "To"


                                  /// "From" and "To" Values

                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 0.0), // Adds space around the line
                              child: Divider(
                                color: Colors.black,
                                thickness: 1, // Line thickness
                              ),
                            ),
                            Container(
                              color: Colors.white, // White background
                              padding: EdgeInsets.all(3.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  /// **Pickup & Dropping Section**
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      /// **Pickup Point**
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Pickup Point:",
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              bookingDetails?['boardingPoint'] ?? '',
                                              style: TextStyle(fontSize: 12, color: Colors.black),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              " ${formatTime(bookingDetails?['pickUpTime'])}",
                                              style: TextStyle(fontSize: 12, color: Colors.black,fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),

                                      /// **Vertical Divider**
                                      Container(
                                        height: 40, // Adjust height as needed
                                        width: 1, // Thin vertical line
                                        color: Colors.black,
                                      ),

                                      /// **Dropping Point**
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              "Dropping Point:",
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              bookingDetails?['droppingPoint'] ?? '',
                                              style: TextStyle(fontSize: 12, color: Colors.black),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              "${formatTime(bookingDetails?['reachTime']??'')}",
                                              style: TextStyle(fontSize: 12, color: Colors.black,fontWeight: FontWeight.bold, ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                ],

                              ),
                            ),


                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 0.0), // Adds space around the line
                              child: Divider(
                                color: Colors.black,
                                thickness: 1, // Line thickness
                              ),
                            ),



                            Container(
                              color: Colors.white, // White background
                              padding: EdgeInsets.all(3.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// "From" and "To" Labels
                                  Row(
                                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Email Id :  ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12, color: Colors.black)),
                                      Text(
                                        bookingDetails?['customerEmail'] ?? '',
                                        style: TextStyle(fontSize: 12, color: Colors.black),
                                      ),
                                    ],

                                  ),
                                  Row(
                                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Mobile No :  ", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12, color: Colors.black)),
                                      Text(
                                        bookingDetails?['customerPhone'] ?? '',
                                        style: TextStyle(fontSize: 12, color: Colors.black),
                                      ),
                                    ],

                                  ),
                                  /// Dotted Line Between "From" and "To"


                                  /// "From" and "To" Values

                                ],
                              ),
                            ),


                            Container(
                              color: Colors.white, // White background
                              padding: EdgeInsets.all(0.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Table(
                                    border: TableBorder.all(color: Colors.black),
                                    columnWidths: {
                                      0: FlexColumnWidth(2.0), // Traveller Name (wider)
                                      1: FlexColumnWidth(1.0), // Gender (narrower)
                                      2: FlexColumnWidth(1.0), // Age (narrower)
                                      3: FlexColumnWidth(1.0), // Seat No. (narrower)
                                    },
                                    children: [
                                      buildTableRow(['Traveller Name', 'Gender', 'Age', 'Seat No.'], isHeader: true),
                                      buildTableRow([
                                        // "${bookingDetails?['customerName'] ?? ''} ${bookingDetails?['customerLastName'] ?? ''}",
                                        "$travellers",
                                        "$travellerssex",
                                        "$travellersAge",
                                        bookingDetails?['selectedSeats'] ?? '',
                                      ]),
                                    ],
                                  ),

                                ],

                              ),
                            ),


                            SizedBox(height: 6),
                            Padding(
                              padding: EdgeInsets.only(left: 6.0), // Adds left margin of 3 pixels
                              child: Align(
                                alignment: Alignment.centerRight, // Aligns text to the start
                                child: Text(
                                  'Amount : Rs. ${bookingDetails?['totalAmount']?.toString() ?? ''}',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                              ),
                            ),


                            SizedBox(height: 6),
                            Padding(
                              padding: EdgeInsets.only(left: 6.0), // Adds left margin of 6 pixels
                              child: Align(
                                alignment: Alignment.centerLeft, // Aligns text to the start
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Terms and Conditions',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0564B1),
                                      ),
                                    ),
                                    SizedBox(height: 6),

                                    // Bullet Point 1
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("• ", style: TextStyle(fontSize: 12)),
                                        Expanded(
                                          child: Text(
                                            "YesGoBus Travellers can book bus tickets online at the lowest ticket fares. Travellers prefer to choose their favorite bus to reserve online bus booking.",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 6),

                                    // Bullet Point 2
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("• ", style: TextStyle(fontSize: 12)),
                                        Expanded(
                                          child: Text(
                                            "You’re at the right place to find a wide range of Private buses and SRTC (State Road Transport Corporation) buses are available for bus booking online.",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 6),

                                    // Bullet Point 3
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("• ", style: TextStyle(fontSize: 12)),
                                        Expanded(
                                          child: Text(
                                            "Passengers should arrive at least 15 min before the scheduled time of departure.",
                                            style: TextStyle(fontSize: 12),
                                          ),

                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Cancellation',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0564B1)),
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("• ", style: TextStyle(fontSize: 12)),
                                        Expanded(
                                          child: Text(
                                            "YesGoBus is not responsible for any accident or any passenger losses.",
                                            style: TextStyle(fontSize: 12),
                                          ),

                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("• ", style: TextStyle(fontSize: 12)),
                                        Expanded(
                                          child: Text(
                                            "Cancellation charges are applicable on the original fare but not available on discount.",
                                            style: TextStyle(fontSize: 12),
                                          ),

                                        ),
                                      ],
                                    ),

                                  ],
                                ),

                              ),
                            ),

                            SizedBox(height: 8),

                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: generatePDF,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue, // Blue button
                                      foregroundColor: Colors.white, // White text
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                    child: Text("Download PDF"),
                                  ),
                                  SizedBox(width: 16), // spacing between buttons
                                  ElevatedButton(
                                    onPressed: sharePDF,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                    child: Text("Share PDF"),
                                  ),
                                ],
                              ),
                            ),


                            SizedBox(height: 12),

                          ],
                        ),
                      ),

                      //final
                    ],
                  ),
                ),




              ],
            ),
          ),
        ),
      ),
    );
  }

  TableRow buildTableRow(List<String> cells, {bool isHeader = false}) {
    return TableRow(
      children: cells
          .map((cell) => Padding(
        padding: EdgeInsets.all(8),
        child: Text(
          cell,
          style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,fontSize: 12
          ),
        ),
      ))
          .toList(),
    );
  }

  Widget tableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.bold,fontSize: 6,
          color: isHeader ? Colors.white : Colors.white, // White for header, black for normal
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String formatTime(String? time) {
    if (time == null || time.isEmpty) return '';

    try {
      DateTime parsedTime = DateFormat("HH:mm").parse(time); // Parse 24-hour format
      return DateFormat("hh:mm a").format(parsedTime); // Convert to 12-hour format with AM/PM
    } catch (e) {
      return time; // Return original if parsing fails
    }
  }
}


Widget tableCell1(String text, {bool isHeader = false}) {
  return Padding(
    padding: EdgeInsets.all(8),
    child: Text(
      text,
      style: TextStyle(
        fontWeight: isHeader ? FontWeight.bold : FontWeight.bold,fontSize: 12,
        color: isHeader ? Colors.white : Colors.white, // White for header, black for normal
      ),
      textAlign: TextAlign.center,
    ),
  );
}

String formatDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return "N/A";

  try {
    DateTime date = DateTime.parse(dateStr); // Ensure it follows ISO 8601 format
    return DateFormat("dd MMM yyyy").format(date);
  } catch (e) {
    return "Invalid Date"; // Handle incorrect formats safely
  }
}


pw.Widget cell(String text) {
  return pw.Padding(
    padding: pw.EdgeInsets.all(8),
    child: pw.Text(text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 20,color: PdfColors.white)),
  );
}

pw.Widget cell1(String text) {
  return pw.Padding(
    padding: pw.EdgeInsets.all(8),
    child: pw.Text(text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 12,color: PdfColors.black)),
  );
}
pw.Widget cell2(String text) {
  return pw.Padding(
    padding: pw.EdgeInsets.all(8),
    child: pw.Text(text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 14,color: PdfColors.white)),
  );
}

pw.Widget cell3(String text) {
  return pw.Padding(
    padding: pw.EdgeInsets.all(8),
    child: pw.Text(text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 14,color: PdfColors.blue)),
  );
}

pw.Widget cell1Column(String title, String subtitle) {
  return pw.Container(
    padding: pw.EdgeInsets.all(5),
    alignment: pw.Alignment.centerLeft, // Ensures content aligns to the left
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start, // Aligns text to the left
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          subtitle,
          style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.normal),
        ),
      ],
    ),
  );
}







