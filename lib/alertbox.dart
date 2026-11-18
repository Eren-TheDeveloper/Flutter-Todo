import 'package:flutter/material.dart';
import 'package:to_do_app/buton.dart';

class DialogBox extends StatefulWidget {
  const DialogBox({super.key, this.initialTitle});
  final String? initialTitle;
  @override
  State<DialogBox> createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    title: Text(widget.initialTitle == null ? 'Yeni görev' : 'Görevi düzenle'),
    content: Form(
      key: _formKey,
      child: TextFormField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.done,
        minLines: 1,
        maxLines: 4,
        maxLength: 200,
        decoration: const InputDecoration(
          labelText: 'Görev',
          hintText: 'Ne yapmak istiyorsun?',
          border: OutlineInputBorder(),
        ),
        validator: (value) => value == null || value.trim().isEmpty
            ? 'Lütfen bir görev yazın.'
            : null,
        onFieldSubmitted: (_) => _submit(),
      ),
    ),
    actions: [
      MyButton(text: 'Vazgeç', onPressed: () => Navigator.of(context).pop()),
      FilledButton(onPressed: _submit, child: const Text('Kaydet')),
    ],
  );
}
