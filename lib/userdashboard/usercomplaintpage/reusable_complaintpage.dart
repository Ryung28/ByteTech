import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobileapplication/userdashboard/usercomplaintpage/complaint_provider.dart';
import 'package:mobileapplication/userdashboard/usercomplaintpage/complaint_page.dart';
import 'package:mobileapplication/reusable_widget/reusable_widget.dart';
import 'package:mobileapplication/reusable_widget/bottom_nav_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobileapplication/services/cloudinary_service.dart';
import 'package:mobileapplication/userdashboard/usercomplaintpage/complaint_form_builders.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ReusableComplaintPage extends StatelessWidget {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  const ReusableComplaintPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Consumer<ComplaintFormProvider>(
        builder: (context, state, _) {
          return WillPopScope(
            onWillPop: () async {
              Navigator.of(context).pop();
              return false;
            },
            child: Scaffold(
              backgroundColor: isDark
                  ? const Color(0xFF1A1A1A)
                  : const Color.fromARGB(255, 197, 212, 223),
              appBar: AppBar(
                backgroundColor: isDark
                    ? const Color(0xFF1A1A1A)
                    : const Color.fromARGB(255, 197, 212, 223),
                automaticallyImplyLeading: false,
                title: const Text(
                  'Submit Complaint',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            const Color(0xFF1A1A1A),
                            const Color(0xFF2C2C2C),
                          ]
                        : [
                            const Color.fromARGB(255, 197, 212, 223),
                            const Color.fromARGB(255, 180, 200, 215),
                          ],
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    left: 12.0,
                    right: 12.0,
                    top: 12.0,
                    bottom: 100.0,
                  ),
                  child: Form(
                    key: state
                        .formKey!, // Added null check operator since formKey can be null
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey[850]
                                : Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withOpacity(0.3)
                                    : Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Title Section
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'File a Complaint',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1A237E),
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Please fill out the form below to report a seen illegal activity.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[700],
                                        fontSize: 14,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Divider(
                                      color: isDark
                                          ? Colors.grey[700]
                                          : Colors.grey[300],
                                      thickness: 1,
                                    ),
                                  ],
                                ),
                              ),
                              ComplaintFormBuilders.buildNameField(
                                  context, state),
                              const SizedBox(height: 8),
                              ComplaintFormBuilders.buildDateOfBirthField(
                                  context, state),
                              const SizedBox(height: 8),
                              ComplaintFormBuilders.buildPhoneField(
                                  context, state),
                              const SizedBox(height: 8),
                              ComplaintFormBuilders.buildEmailField(
                                  context, state),
                              const SizedBox(height: 8),
                              ComplaintFormBuilders.buildAddressField(
                                  context, state),
                              const SizedBox(height: 12),
                              FileUploadWidget(
                                  state: state as ComplaintFormProvider),
                              const SizedBox(height: 12),
                              ComplaintFormBuilders.buildComplaintField(
                                  context, state),
                              const SizedBox(height: 16),
                              _buildSubmitButton(context, state),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, ComplaintFormProvider state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color.fromARGB(255, 25, 135, 231),
                  const Color.fromARGB(255, 18, 102, 177),
                ]
              : [
                  const Color(0xFF0277BD),
                  const Color.fromARGB(255, 25, 135, 231),
                ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : const Color(0xFF0277BD).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed:
            state.isSubmitting ? null : () => state.submitComplaint(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: state.isSubmitting
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Form Submitting...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : const Text(
                'Submit Complaint',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

class FileUploadWidget extends StatefulWidget {
  final ComplaintFormProvider state;

  const FileUploadWidget({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void showToastMessage(bool isSuccess) {
    Fluttertoast.showToast(
      msg: isSuccess
          ? 'File Added Successfully'
          : 'Invalid file type. Please select an image, video, or document.',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 2,
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _handleFileSelection(BuildContext context, File file) {
    if (!mounted) return;

    if (CloudinaryService.isValidFileType(file.path)) {
      widget.state.addFile(file);
      if (mounted) {
        showToastMessage(true);
      }
    } else {
      if (mounted) {
        showToastMessage(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          _buildUploadArea(context),
          _buildAttachedFilesList(),
        ],
      ),
    );
  }

  Widget _buildUploadArea(BuildContext context) {
    return InkWell(
      onTap: () => _showUploadOptions(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFE0F7FA),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFF003366),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_upload_outlined,
              size: 48,
              color: Color(0xFF003366),
            ),
            const SizedBox(height: 12),
            const Text(
              'Upload Supporting Documents',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF003366),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to upload images, videos',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachedFilesList() {
    if (widget.state.attachedFiles.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attached Files:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF003366),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.state.attachedFiles.length,
              itemBuilder: (context, index) => _AttachedFileItem(
                file: widget.state.attachedFiles[index],
                onRemove: () => widget.state.removeFile(index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _UploadOptionsSheet(
        onFileSelected: (file) => _handleFileSelection(context, file),
      ),
    );
  }
}

class _AttachedFileItem extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;

  const _AttachedFileItem({
    required this.file,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isImage = ['.jpg', '.jpeg', '.png', '.gif'].any(
      (ext) => file.path.toLowerCase().endsWith(ext),
    );

    return Container(
      margin: const EdgeInsets.only(right: 8),
      width: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFE0F7FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF003366)),
      ),
      child: Stack(
        children: [
          if (isImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                file,
                fit: BoxFit.cover,
                width: 100,
                height: 100,
              ),
            )
          else
            Center(
              child: Icon(
                file.path.toLowerCase().endsWith('.mp4')
                    ? Icons.video_file
                    : Icons.insert_drive_file,
                size: 40,
                color: const Color(0xFF003366),
              ),
            ),
          Positioned(
            top: 4,
            right: 4,
            child: _RemoveButton(onTap: onRemove),
          ),
        ],
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RemoveButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.close,
          size: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _UploadOptionsSheet extends StatelessWidget {
  final Function(File) onFileSelected;

  const _UploadOptionsSheet({required this.onFileSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Upload File',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF003366),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _UploadOption(
                icon: Icons.photo_library,
                label: 'Gallery',
                onTap: () => _pickImage(context, ImageSource.gallery),
              ),
              _UploadOption(
                icon: Icons.videocam,
                label: 'Video',
                onTap: () => _pickVideo(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    Navigator.pop(context);
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      onFileSelected(File(pickedFile.path));
    }
  }

  Future<void> _pickVideo(BuildContext context) async {
    Navigator.pop(context);
    final pickedFile =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      onFileSelected(File(pickedFile.path));
    }
  }
}

class _UploadOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _UploadOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 32,
            color: const Color(0xFF003366),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF003366),
            ),
          ),
        ],
      ),
    );
  }
}
