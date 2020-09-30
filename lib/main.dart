import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sms/sms.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(UrlLauncher());
}

/// SMS [https://pub.dev/packages/sms]
void _getAllSmsMessages(BuildContext context) async {
  SmsQuery query = new SmsQuery();
  List<SmsMessage> messages = await query.getAllSms;
  _showAlertDialog(context, messages.length);
}

void _showAlertDialog(BuildContext context, int count) {
  // set up the button
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.of(context, rootNavigator: true).pop();
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("How many SMS messages?"),
    content: Text('Retrieved $count messages!'),
    actions: [
      okButton,
    ],
  );
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

/// URL_LAUNCHER [https://pub.dev/packages/url_launcher]
class UrlLauncher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'URL Launcher',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UrlLauncherPage(title: 'URL Launcher'),
    );
  }
}

class UrlLauncherPage extends StatefulWidget {
  UrlLauncherPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _UrlLauncherPageState createState() => _UrlLauncherPageState();
}

class _UrlLauncherPageState extends State<UrlLauncherPage> {
  Future<void> _launched;
  String _phone = '';

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchInWebViewOrVC(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: true,
        forceWebView: true,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchInWebViewWithJavaScript(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: true,
        forceWebView: true,
        enableJavaScript: true,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchInWebViewWithDomStorage(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: true,
        forceWebView: true,
        enableDomStorage: true,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchUniversalLinkIos(String url) async {
    if (await canLaunch(url)) {
      final bool nativeAppLaunchSucceeded = await launch(
        url,
        forceSafariVC: false,
        universalLinksOnly: true,
      );
      if (!nativeAppLaunchSucceeded) {
        await launch(
          url,
          forceSafariVC: true,
        );
      }
    }
  }

  Widget _launchStatus(BuildContext context, AsyncSnapshot<void> snapshot) {
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else {
      return const Text('');
    }
  }

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _makeSms(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    const String toLaunch = 'https://www.cylog.org/headers/';
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                    onChanged: (String text) => _phone = text,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                        hintText: 'Input the phone number to launch')),
              ),
              RaisedButton(
                onPressed: () => setState(() {
                  _launched = _makePhoneCall('tel:$_phone');
                }),
                child: const Text('Launch phone call'),
              ),
              RaisedButton(
                onPressed: () => setState(() {
                  _launched = _makeSms('sms:$_phone');
                }),
                child: const Text('Launch SMS'),
              ),
              RaisedButton(
                onPressed: () => setState(() {
                  _getAllSmsMessages(context);
                }),
                child: const Text('Make SMS'),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(toLaunch),
              ),
              RaisedButton(
                onPressed: () => setState(() {
                  _launched = _launchInBrowser(toLaunch);
                }),
                child: const Text('Launch in browser'),
              ),
              //const Padding(padding: EdgeInsets.all(16.0)),
              RaisedButton(
                onPressed: () => setState(() {
                  _launched = _launchInWebViewOrVC(toLaunch);
                }),
                child: const Text('Launch in app'),
              ),
              RaisedButton(
                onPressed: () => setState(() {
                  _launched = _launchInWebViewWithJavaScript(toLaunch);
                }),
                child: const Text('Launch in app (JavaScript ON)'),
              ),
              RaisedButton(
                onPressed: () => setState(() {
                  _launched = _launchInWebViewWithDomStorage(toLaunch);
                }),
                child: const Text('Launch in app (DOM storage ON)'),
              ),
              const Padding(padding: EdgeInsets.all(16.0)),
              RaisedButton(
                onPressed: () => setState(() {
                  _launched = _launchUniversalLinkIos(toLaunch);
                }),
                child: const Text(
                    'Launch a universal link in a native app, fallback to Safari. (Youtube)'),
              ),
              const Padding(padding: EdgeInsets.all(16.0)),
              RaisedButton(
                onPressed: () => setState(() {
                  _launched = _launchInWebViewOrVC(toLaunch);
                  Timer(const Duration(seconds: 5), () {
                    print('Closing WebView after 5 seconds...');
                    closeWebView();
                  });
                }),
                child: const Text('Launch in app & close after 5 seconds'),
              ),
              const Padding(padding: EdgeInsets.all(16.0)),
              FutureBuilder<void>(future: _launched, builder: _launchStatus),
            ],
          ),
        ],
      ),
    );
  }
}
