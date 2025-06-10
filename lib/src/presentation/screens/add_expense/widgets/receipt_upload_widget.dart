import 'package:flutter/material.dart';
import 'dart:io';

class ReceiptUploadWidget extends StatelessWidget {
  final File? receiptFile;
  final VoidCallback onPickReceipt;
  final VoidCallback onRemoveReceipt;

  const ReceiptUploadWidget({
    Key? key,
    required this.receiptFile,
    required this.onPickReceipt,
    required this.onRemoveReceipt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (receiptFile != null) {
      return _buildReceiptPreview();
    } else {
      return _buildUploadArea();
    }
  }

  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: onPickReceipt,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6C5CE7).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.upload_file,
                color: Color(0xFF6C5CE7),
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload Image',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap to select from camera or gallery',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF718096),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptPreview() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          // Image Preview
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              width: double.infinity,
              height: 150,
              color: const Color(0xFFF8FAFC),
              child: Image.file(
                receiptFile!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 48,
                          color: Color(0xFFCBD5E0),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Failed to load image',
                          style: TextStyle(
                            color: Color(0xFF718096),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Receipt Info and Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Receipt Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.receipt,
                    color: Color(0xFF10B981),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                
                // File Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getFileName(receiptFile!.path),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2D3748),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getFileSize(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Action Buttons
                Row(
                  children: [
                    // View Full Size
                    GestureDetector(
                      onTap: () => _showFullSizeImage(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C5CE7).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.fullscreen,
                          color: Color(0xFF6C5CE7),
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Remove Receipt
                    GestureDetector(
                      onTap: onRemoveReceipt,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF56565).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFFF56565),
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getFileName(String path) {
    return path.split('/').last;
  }

  String _getFileSize() {
    try {
      final bytes = receiptFile!.lengthSync();
      if (bytes < 1024) {
        return '$bytes B';
      } else if (bytes < 1048576) {
        return '${(bytes / 1024).toStringAsFixed(1)} KB';
      } else {
        return '${(bytes / 1048576).toStringAsFixed(1)} MB';
      }
    } catch (e) {
      return 'Unknown size';
    }
  }

  void _showFullSizeImage() {
    // This would typically show a full-screen image viewer
    // For now, we'll just show a simple dialog
    // You can implement a proper image viewer here
  }
}
