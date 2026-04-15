import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/models/invoice_model.dart';
import '../../data/models/user_model.dart';

class PdfInvoiceService {
  static Future<void> printOrDownloadInvoice({
    required BuildContext context,
    required InvoiceModel invoice,
    required UserModel? businessOwner,
  }) async {
    final pdf = pw.Document();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    String formatDate(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';

    String formatAmount(double amt) =>
        '₹ ${amt.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (m) => '${m[1]},')}';

    final statusColor = invoice.status == 'PAID'
        ? PdfColors.green700
        : invoice.status == 'OVERDUE'
            ? PdfColors.red700
            : PdfColors.orange700;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        businessOwner?.businessName?.isNotEmpty == true
                            ? businessOwner!.businessName!
                            : businessOwner?.fullName ?? 'Business Name',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                      if (businessOwner?.gstin?.isNotEmpty == true)
                        pw.Text(
                          'GSTIN: ${businessOwner!.gstin}',
                          style: const pw.TextStyle(
                              fontSize: 9, color: PdfColors.grey700),
                        ),
                      if (businessOwner?.phone?.isNotEmpty == true)
                        pw.Text(
                          'Tel: +91 ${businessOwner!.phone}',
                          style: const pw.TextStyle(
                              fontSize: 9, color: PdfColors.grey700),
                        ),
                      pw.Text(
                        businessOwner?.email ?? '',
                        style: const pw.TextStyle(
                            fontSize: 9, color: PdfColors.grey700),
                      ),
                      if (businessOwner?.address?.isNotEmpty == true)
                        pw.Container(
                          constraints: const pw.BoxConstraints(maxWidth: 200),
                          child: pw.Text(
                            businessOwner!.address!,
                            style: const pw.TextStyle(
                                fontSize: 9, color: PdfColors.grey700),
                          ),
                        ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'TAX INVOICE',
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey800,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: statusColor,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(
                          invoice.status,
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Divider(color: PdfColors.blue800, thickness: 2),
              pw.SizedBox(height: 12),

              // ── Invoice Meta ─────────────────────────────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _metaBlock('Invoice Number', invoice.invoiceNumber),
                  _metaBlock('Issue Date', formatDate(invoice.issueDate)),
                  _metaBlock('Due Date', formatDate(invoice.dueDate)),
                ],
              ),

              pw.SizedBox(height: 20),

              // ── Bill To ──────────────────────────────────
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'BILL TO',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                        letterSpacing: 1,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      invoice.clientName,
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey900,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // ── Line Items Table ───────────────────────────
              pw.Table(
                border:
                    pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(4),
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  // Header row
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.blue800),
                    children: [
                      _tableHeader('Description'),
                      _tableHeader('Qty'),
                      _tableHeader('Unit Price'),
                      _tableHeader('Amount'),
                    ],
                  ),
                  // Data rows
                  if (invoice.items.isNotEmpty)
                    ...invoice.items.map((item) => pw.TableRow(children: [
                          _tableCell(item.description),
                          _tableCell(item.quantity.toString()),
                          _tableCell(formatAmount(item.unitPrice)),
                          _tableCell(formatAmount(item.total)),
                        ]))
                  else
                    pw.TableRow(children: [
                      _tableCell('Professional Services', bold: true),
                      _tableCell('1'),
                      _tableCell(formatAmount(invoice.amount)),
                      _tableCell(formatAmount(invoice.amount)),
                    ]),
                ],
              ),

              pw.SizedBox(height: 16),

              // ── Totals ────────────────────────────────────
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 220,
                  child: pw.Column(
                    children: [
                      _totalRow('Subtotal', formatAmount(invoice.amount)),
                      if (invoice.gstRate > 0) ...[
                        pw.Divider(color: PdfColors.grey300, height: 8),
                        _totalRow(
                          'GST @ ${invoice.gstRate.toInt()}%',
                          formatAmount(invoice.gstAmount),
                        ),
                      ],
                      pw.Divider(color: PdfColors.blue800, thickness: 1.5),
                      _totalRow(
                        'Total Amount',
                        formatAmount(invoice.totalWithGst),
                        bold: true,
                        large: true,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Notes ─────────────────────────────────────
              if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                pw.Text(
                  'Notes:',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                    color: PdfColors.grey800,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  invoice.notes!,
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.grey700),
                ),
              ],

              pw.Spacer(),

              // ── Footer ────────────────────────────────────
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Text(
                  'Thank you for your business! | Generated by Invoice Pro India',
                  style:
                      const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Show print/share/download dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${invoice.invoiceNumber}.pdf',
    );
  }

  // Helper widgets for PDF
  static pw.Widget _metaBlock(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label.toUpperCase(),
          style: const pw.TextStyle(
              fontSize: 8, color: PdfColors.grey600, letterSpacing: 0.5),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey900,
          ),
        ),
      ],
    );
  }

  static pw.Widget _tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _tableCell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          color: PdfColors.grey800,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _totalRow(String label, String value,
      {bool bold = false, bool large = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: large ? 12 : 10,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: bold ? PdfColors.blue800 : PdfColors.grey700,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: large ? 13 : 10,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: bold ? PdfColors.blue800 : PdfColors.grey800,
            ),
          ),
        ],
      ),
    );
  }
}
