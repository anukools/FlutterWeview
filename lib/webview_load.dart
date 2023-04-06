import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewApp extends StatefulWidget {
  const WebViewApp({Key? key}) : super(key: key);

  @override
  State<WebViewApp> createState() => _WebViewStackState();
}

class _WebViewStackState extends State<WebViewApp>
    with AutomaticKeepAliveClientMixin {
  var loadingPercentage = 0;
  late final WebViewController controller;
  var url = 'https://asthatrade.com/product/flow';
  var isWebViewVisible = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          setState(() {
            loadingPercentage = 0;
          });
        },
        onProgress: (progress) {
          print('loadingPercentage  $loadingPercentage');
          setState(() {
            loadingPercentage = progress;
          });
        },
        onPageFinished: (url) {
          setState(() {
            loadingPercentage = 100;
          });
        },
      ));
  }

  void updateState(var value) {
    setState(() {
      isWebViewVisible = value;
      if (value && loadingPercentage < 100) {
        controller.loadRequest(
          Uri.parse(url),
        );
      }
    });
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to go back?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                //<-- SEE HERE
                child: new Text('No'),
              ),
              TextButton(
                onPressed: () => {
                  isWebViewVisible
                      ?  {updateState(false), Navigator.of(context).pop(false)}
                      : Navigator.of(context).pop(true)
                },
                // <-- SEE HERE
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: isWebViewVisible
            ? AppBar(
                leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      updateState(false);
                    }),
                title: Text('Second Screen'),
              )
            : AppBar(
                title: const Text('First Screen'),
              ),
        body: isWebViewVisible
            ? Stack(
                children: [
                  WebViewWidget(
                    controller: controller,
                  ),
                  if (loadingPercentage < 100)
                    LinearProgressIndicator(
                      value: loadingPercentage / 100.0,
                    ),
                ],
              )
            : Center(
                child: OutlinedButton(
                  child: const Text('Open WebView'),
                  onPressed: () {
                    updateState(true);
                  },
                ),
              ),
      ),
    );
  }
}
