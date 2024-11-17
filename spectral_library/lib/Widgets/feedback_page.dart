import 'package:flutter/material.dart';
import 'package:spectral_library/Controllers/feedback_controller.dart';
import 'package:spectral_library/Models/response.dart';
import 'package:spectral_library/Models/user.dart';
import 'package:spectral_library/util.dart';

class Feedback extends StatefulWidget {
  final User user;
  const Feedback(this.user, {super.key});
  @override
  State<Feedback> createState() => _FeedbackState();
}

class _FeedbackState extends State<Feedback> {
  var contentController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void sendMessage() async {
    Response response = await FeedbackController.sendFeedback(
      widget.user,
      contentController.text,
    );
    if (response.isSuccess) {
      Util.showInfoDialog(context: context, content: response.body);
      Navigator.pop(context);
    } else {
      Util.showErrorDialog(context: context, content: response.message!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Geri bildirim",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Alan boş bırakılamaz.';
                              }
                              return null;
                            },
                            controller: contentController,
                            decoration: const InputDecoration(
                                hintText:
                                    "Geri bildiriminizi bu alana yazabilirsiniz."),
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    sendMessage();
                  }
                },
                child: const Text("Gönder"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
