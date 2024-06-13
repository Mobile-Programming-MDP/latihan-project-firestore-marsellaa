import 'dart:html';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes/models/note.dart';
import 'package:notes/services/location_service.dart';
import 'package:notes/services/note_service.dart';
import 'package:path/path.dart';
import 'package:camera/camera.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';


class NoteDialog extends StatefulWidget {
  final Note? note;

  NoteDialog({super.key, this.note});

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  XFile? _imageFile;
  Position? _position;
  Uint8List? _imageBytes;
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _descriptionController.text = widget.note!.description;
    }
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _cameraController.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageFile = pickedFile;
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _getLocation() async {
    final location = await LocationService().getCurrentLocation();
    setState(() {
      _position = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.note == null ? 'Add Notes' : 'Update Notes'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Title: ',
            textAlign: TextAlign.start,
          ),
          TextField(
            controller: _titleController,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              'Description: ',
            ),
          ),
          TextField(
            controller: _descriptionController,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text('Image: '),
          ),
          if (_imageBytes != null)
              SizedBox(
                height: 200, // Set a fixed height for the image container
                child: Image.memory(
                  _imageBytes!,
                  fit: BoxFit.cover,
                ),
              )
            else if (widget.note?.imageUrl != null &&
                Uri.parse(widget.note!.imageUrl!).isAbsolute)
              SizedBox(
                height: 200, // Set a fixed height for the image container
                child: Image.network(
                  widget.note!.imageUrl!,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(),
            Row(
              children: [
                TextButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  child: const Text("Gallery"),
                ),
                TextButton(
                  onPressed: () async {
                    final XFile? image = await _cameraController.takePicture();
                    if (image != null) {
                      final directory =
                          await getApplicationDocumentsDirectory();
                      final path = '${directory.path}/${DateTime.now()}.png';
                      await image.saveTo(path);
                      setState(() {
                        _imageFile = XFile(path);
                      });
                    }
                  },
                  child: const Text("Camera"),
                ),
              ],
            ),
          TextButton(
            onPressed: _getLocation,
            child: const Text("Get Location"),
          ),
          Text(
            _position?.latitude != null && _position?.longitude != null
                ? 'Current Position : ${_position!.longitude.toString()}, ${_position!.latitude.toString()}'
                :'',
            textAlign: TextAlign.start,
          )
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            String? imageUrl;
            if (_imageFile != null) {
              imageUrl = await NoteService.uploadImage(_imageFile!);
            } else {
              imageUrl = widget.note?.imageUrl;
            }

            Note note = Note(
              id: widget.note?.id,
              title: _titleController.text,
              description: _descriptionController.text,
              imageUrl: imageUrl,
              lat: widget.note?.lat.toString() != _position!.latitude.toString()
                  ? _position!.latitude.toString()
                  : widget.note?.lat.toString(),
              lng:
                  widget.note?.lng.toString() != _position!.longitude.toString()
                      ? _position!.longitude.toString()
                      : widget.note?.lng.toString(),
              createdAt: widget.note?.createdAt,
            );

            if (widget.note == null) {
              NoteService.addNote(note).whenComplete(() {
                Navigator.of(context).pop();
              });
            } else {
              NoteService.updateNote(note)
                  .whenComplete(() => Navigator.of(context).pop());
            }
          },
          child: Text(widget.note == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}
