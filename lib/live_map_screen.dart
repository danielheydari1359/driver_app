import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart'; // For kIsWeb

class LiveMapScreen extends StatelessWidget {
  const LiveMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return Scaffold(
        body: Center(
          child: Text("This view only works on Web right now."),
        ),
      );
    }

    // ✅ Register an HTML view type
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'google-map-embed',
      (int viewId) => IFrameElement()
        ..width = '100%'
        ..height = '100%'
        ..src = 'https://maps.google.com/maps?q=San+Diego&t=&z=13&ie=UTF8&iwloc=&output=embed'
        ..style.border = '0',
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Live Location")),
      body: const HtmlElementView(viewType: 'google-map-embed'),
    );
  }
}
