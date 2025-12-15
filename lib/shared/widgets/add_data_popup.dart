import 'package:flutter/material.dart';

class AddDataPopup extends StatefulWidget {
  final String title;
  final List<Widget> formFields;
  final VoidCallback onSave;
  final VoidCallback onReset;
  final String saveButtonText;
  final String resetButtonText;
  final bool isLoading;
  final double? maxHeight;
  final EdgeInsets? contentPadding;

  const AddDataPopup({
    super.key,
    required this.title,
    required this.formFields,
    required this.onSave,
    required this.onReset,
    this.saveButtonText = 'Simpan',
    this.resetButtonText = 'Reset',
    this.isLoading = false,
    this.maxHeight,
    this.contentPadding,
  });

  @override
  State<AddDataPopup> createState() => _AddDataPopupState();
}

class _AddDataPopupState extends State<AddDataPopup> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxHeight = widget.maxHeight ?? screenHeight * 0.85;
    final contentPadding =
        widget.contentPadding ?? const EdgeInsets.fromLTRB(20, 16, 20, 16);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
          minWidth: screenWidth > 600 ? 400 : screenWidth * 0.9,
          maxWidth: screenWidth > 600 ? 500 : screenWidth * 0.95,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with title and close button
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 20,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Form content
              Flexible(
                child: SingleChildScrollView(
                  padding: contentPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: widget.formFields,
                  ),
                ),
              ),

              // Action buttons
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.isLoading ? null : widget.onReset,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(
                            color: Color(0xFF6938EF),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.refresh_rounded,
                              size: 18,
                              color: Color(0xFF6938EF),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.resetButtonText,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6938EF),
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.isLoading ? null : widget.onSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6938EF),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: widget.isLoading
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Menyimpan...',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.save_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.saveButtonText,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper function to show the popup
Future<T?> showAddDataPopup<T>({
  required BuildContext context,
  required String title,
  required List<Widget> formFields,
  required VoidCallback onSave,
  required VoidCallback onReset,
  String saveButtonText = 'Simpan',
  String resetButtonText = 'Reset',
  bool isLoading = false,
  double? maxHeight,
  EdgeInsets? contentPadding,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AddDataPopup(
      title: title,
      formFields: formFields,
      onSave: onSave,
      onReset: onReset,
      saveButtonText: saveButtonText,
      resetButtonText: resetButtonText,
      isLoading: isLoading,
      maxHeight: maxHeight,
      contentPadding: contentPadding,
    ),
  );
}
