import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const BrowserApp());
}

class BrowserApp extends StatelessWidget {
  const BrowserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Browser App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BrowserHomePage(),
    );
  }
}

class BrowserHomePage extends StatefulWidget {
  const BrowserHomePage({super.key});

  @override
  State<BrowserHomePage> createState() => _BrowserHomePageState();
}

class _BrowserHomePageState extends State<BrowserHomePage> {
  late final WebViewController controller;
  final TextEditingController urlController = TextEditingController(text: 'https://www.google.com');
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
              urlController.text = url;
            });
          },
          onWebResourceError: (WebResourceError error) {
            // Handle errors
          },
        ),
      )
      ..loadRequest(Uri.parse(urlController.text));
  }

  void _goToUrl() {
    final url = urlController.text;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      controller.loadRequest(Uri.parse('https://$url'));
    } else {
      controller.loadRequest(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                if (await controller.canGoBack()) {
                  await controller.goBack();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () async {
                if (await controller.canGoForward()) {
                  await controller.goForward();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                controller.reload();
              },
            ),
            Expanded(
              child: TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  hintText: 'Enter URL',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _goToUrl(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _goToUrl,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}