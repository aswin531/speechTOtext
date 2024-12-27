// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechRecgScreen extends StatefulWidget {
  const SpeechRecgScreen({super.key});

  @override
  State<SpeechRecgScreen> createState() => _SpeechRecgScreenState();
}

class _SpeechRecgScreenState extends State<SpeechRecgScreen> {
  late stt.SpeechToText speech;
  //= stt.SpeechToText();
  bool isListening = false;
  String text = "Start Talking";
  double confidence = 1.0;

  @override
  void initState() {
    super.initState();
    initSpeech();
    speech = stt.SpeechToText();
  }

  void initSpeech() async {
    await Permission.microphone.request();
    speech.initialize(
      onError: (errorNotification) => print('Error - ${errorNotification}'),
      onStatus: (status) => print("Status - $status"),
    );
  }

  void listen() async {
    if (!isListening) {
      bool available = await speech.initialize(
        onError: (errorNotification) => print('error'),
        onStatus: (status) {
          print('Speech engine status: $status');
          if (status == "done" || status == "notListening") {
            setState(() {
              isListening = false;
            });
          }
        },
      );

      if (available) {
        setState(() {
          isListening = true;
        });

        speech.listen(
            onResult: (result) => setState(() {
                  text = result.recognizedWords;
                  if (result.hasConfidenceRating && result.confidence > 0) {
                    confidence = result.confidence;
                  }
                }),
            pauseFor: const Duration(seconds: 5),
            listenOptions:
                stt.SpeechListenOptions(listenMode: stt.ListenMode.dictation)
            //listenMode: stt.ListenMode.dictation,
            );
      } else {
        setState(() {
          isListening = false;
        });
        speech.stop();
      }
    }
  }

  Future<void> startNewSession() async {
    await speech.stop(); // stoping existing session
    setState(() {
      text = "Press the Button and start speaking";
      isListening = false;
    });
    listen(); //start new one
  }

  void stopAndReset() {
    speech.stop();
    setState(() {
      text = "Recording stopped";
      isListening = false;
    });
  }

  void handleError(String error) {
    setState(() {
      text = "Error occurred: $error. Please try again.";
      isListening = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech to Text'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: listen,
        child: Icon(isListening ? Icons.mic : Icons.mic_none),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30, 30, 30, 150),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
