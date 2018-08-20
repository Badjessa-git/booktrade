import 'package:booktrade/models/user.dart';
import 'package:booktrade/services/TradeApi.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  final User _user;
  final TradeApi _api;

  const Settings(this._user, this._api);

  @override
  _SettingsState createState() => new _SettingsState();
}

class _SettingsState extends State<Settings> {
  User user;
  bool _isTurnedOn;
  @override
  void initState() {
    super.initState();
    if (mounted) {
      setState(() {
        user = widget._user;
        _isTurnedOn = user.notify;
      });
    }
  }

  bool _isTerms;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: const Text('Settings'),
      ),
      body: new Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          new ListTile(
            title: const Text('Push Notifications'),
            trailing: new Switch(
              onChanged: (bool value) {
                _isTurnedOn = value;
                _turnOn(_isTurnedOn);
              },
              value: _isTurnedOn,
              activeColor: Theme.of(context).primaryColor,
              inactiveTrackColor: Colors.grey,
            ),
          ),
          new ListTile(
            title: const Text('About'),
            onTap: () {
              Navigator.of(context).push<MaterialPageRoute<dynamic>>(
                      new MaterialPageRoute<MaterialPageRoute<dynamic>>(
                    builder: (BuildContext context) {
                      return new AppInfo();
                    },
                    fullscreenDialog: true,
                  ));
            },
          ),
          new ListTile(
              title: const Text('Privacy Policy'),
              onTap: () {
                setState(() {
                  _isTerms = false;
                });
                Navigator.of(context).push<MaterialPageRoute<dynamic>>(
                        new MaterialPageRoute<MaterialPageRoute<dynamic>>(
                      builder: (BuildContext context) {
                        return const ShowPolicy(false);
                      },
                      fullscreenDialog: true,
                    ));
              }),
          new ListTile(
            title: const Text('Terms & Conditions'),
            onTap: () {
              setState(() {
                _isTerms = true;
              });
              Navigator.of(context).push<MaterialPageRoute<dynamic>>(
                      new MaterialPageRoute<MaterialPageRoute<dynamic>>(
                    builder: (BuildContext context) {
                      return const ShowPolicy(true);
                    },
                    fullscreenDialog: true,
                  ));
            },
          ),
          new Align(
            alignment: FractionalOffset.bottomCenter,
            child: new RaisedButton(
              color: Colors.red,
              child: const Text('Sign out of BookTrade'),
              onPressed: () async {
                await TradeApi.signOutWithGoogle();
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/home', (Route<dynamic> route) => false);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _turnOn(bool isTurnedon) async {
    user.notify = isTurnedon;
    await widget._api.addorUpdateUser(otherUser: user).then((_) {
      setState(() {
        _isTurnedOn = isTurnedon;
      });
    }).catchError((dynamic _) {
      _scaffoldKey.currentState.showSnackBar(
        const SnackBar(
            content: const Text('Error communicating with our server')),
      );
      setState(() {
        _isTurnedOn = !isTurnedon;
      });
    });
  }
}

class ShowPolicy extends StatelessWidget {
  final bool _isTerms;
  const ShowPolicy(this._isTerms);

  Text titleOrSousTitle(String title, bool isTitle) {
    return isTitle
        ? new Text('$title',
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 40.0))
        : new Text(
            '$title',
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20.0),
          );
  }

  Column paragraph(String paragraph) {
    return new Column(children: <Widget>[
      const Divider(height: 15.0),
      new Text(
        '$paragraph',
        style: const TextStyle(
            color: Colors.black, fontWeight: FontWeight.normal, fontSize: 20.0),
        textAlign: TextAlign.start,
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final Column terms = new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Divider(height: 40.0),
        titleOrSousTitle('Terms & Conditions', true),
        paragraph(
            'By downloading or using the app, these terms will automatically apply to you – you should make sure therefore that you read them carefully before using the app. You’re not allowed to copy, or modify the app, any part of the app, or our trademarks in any way. You’re not allowed to attempt to extract the source code of the app, and you also shouldn’t try to translate the app into other languages, or make derivative versions. The app itself, and all the trade marks, copyright, database rights and other intellectual property rights related to it, still belong to Badjessa B. Bahoumda.'),
        paragraph(
            'Badjessa B. Bahoumda is committed to ensuring that the app is as useful and efficient as possible. For that reason, we reserve the right to make changes to the app or to charge for its services, at any time and for any reason. We will never charge you for the app or its services without making it very clear to you exactly what you’re paying for.'),
        paragraph(
            'The BookTrade app stores and processes personal data that you have provided to us, in order to provide my Service. It’s your responsibility to keep your phone and access to the app secure. We therefore recommend that you do not jailbreak or root your phone, which is the process of removing software restrictions and limitations imposed by the official operating system of your device. It could make your phone vulnerable to malware/viruses/malicious programs, compromise your phone’s security features and it could mean that the BookTrade app won’t work properly or at all.'),
        paragraph(
            'You should be aware that there are certain things that Badjessa B. Bahoumda will not take responsibility for. Certain functions of the app will require the app to have an active internet connection. The connection can be Wi-Fi, or provided by your mobile network provider, but Badjessa B. Bahoumda cannot take responsibility for the app not working at full functionality if you don’t have access to Wi-Fi, and you don’t have any of your data allowance left.'),
        paragraph(
            'If you’re using the app outside of an area with Wi-Fi, you should remember that your terms of the agreement with your mobile network provider will still apply. As a result, you may be charged by your mobile provider for the cost of data for the duration of the connection while accessing the app, or other third party charges. In using the app, you’re accepting responsibility for any such charges, including roaming data charges if you use the app outside of your home territory (i.e. region or country) without turning off data roaming. If you are not the bill payer for the device on which you’re using the app, please be aware that we assume that you have received permission from the bill payer for using the app.'),
        paragraph(
            'Along the same lines, Badjessa B. Bahoumda cannot always take responsibility for the way you use the app i.e. You need to make sure that your device stays charged – if it runs out of battery and you can’t turn it on to avail the Service, Badjessa B. Bahoumda cannot accept responsibility'),
        paragraph(
            'With respect to Badjessa B. Bahoumda’s responsibility for your use of the app, when you’re using the app, it’s important to bear in mind that although we endeavour to ensure that it is updated and correct at all times, we do rely on third parties to provide information to us so that we can make it available to you. Badjessa B. Bahoumda accepts no liability for any loss, direct or indirect, you experience as a result of relying wholly on this functionality of the app.'),
        paragraph(
            'At some point, we may wish to update the app. The app is currently available on Android and iOS – the requirements for both systems (and for any additional systems we decide to extend the availability of the app to) may change, and you’ll need to download the updates if you want to keep using the app. Badjessa B. Bahoumda does not promise that it will always update the app so that it is relevant to you and/or works with the iOS/Android version that you have installed on your device. However, you promise to always accept updates to the application when offered to you, We may also wish to stop providing the app, and may terminate use of it at any time without giving notice of termination to you. Unless we tell you otherwise, upon any termination, (a) the rights and licenses granted to you in these terms will end; (b) you must stop using the app, and (if needed) delete it from your device.'),
        const Divider(height: 30.0),
        titleOrSousTitle('Changes to This Terms and Conditions', false),
        paragraph(
            'I may update our Terms and Conditions from time to time. Thus, you are advised to review this page periodically for any changes. I will notify you of any changes by posting the new Terms and Conditions on this page. These changes are effective immediately after they are posted on this page.'),
        const Divider(height: 30.0),
        titleOrSousTitle('Contact Us', false),
        paragraph(
            'If you have any questions or suggestions about my Terms and Conditions, do not hesitate to contact me.'),
        paragraph(
            'This Terms and Conditions page was generated by App Privacy Policy Generator'),
      ],
    );

    final Column privacy = new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      verticalDirection: VerticalDirection.down,
      children: <Widget>[
        const Divider(height: 40.0),
        titleOrSousTitle('Privacy Policy', true),
        paragraph(
            'Badjessa B. Bahoumda built the BookTrade app as an Ad Supported app. This SERVICE is provided by Badjessa B. Bahoumda at no cost and is intended for use as is.'),
        paragraph(
            'This page is used to inform website visitors regarding my policies with the collection, use, and disclosure of Personal Information if anyone decided to use my Service'),
        paragraph(
            'If you choose to use my Service, then you agree to the collection and use of information in relation to this policy. The Personal Information that I collect is used for providing and improving the Service. I will not use or share your information with anyone except as described in this Privacy Policy.'),
        paragraph(
            'The terms used in this Privacy Policy have the same meanings as in our Terms and Conditions, which is accessible at BookTrade unless otherwise defined in this Privacy Policy.'),
        const Divider(height: 30.0),
        titleOrSousTitle('Information Collection and Use', false),
        paragraph(
            'For a better experience, while using our Service, I may require you to provide us with certain personally identifiable information, including but not limited to Name, Email, Images, User Device Information. The information that I request is retained on your device and is not collected by me in any way'),
        paragraph(
            'The app does use third party services that may collect information used to identify you.'),
        paragraph(
            'Look up privacy policy of third party service providers used by the app'),
        const Divider(height: 30.0),
        new GestureDetector(
          child: const Text(
            '-   Google Play Services',
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              decorationStyle: TextDecorationStyle.solid,
              color: const Color(0xFF0000FF),
            ),
          ),
          onTap: () => _launchWebPage(1),
        ),
        const Divider(height: 10.0),
        new GestureDetector(
          child: const Text(
            '-   AdMob',
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              decorationStyle: TextDecorationStyle.solid,
              color: const Color(0xFF0000FF),
            ),
          ),
          onTap: () => _launchWebPage(2),
        ),
        const Divider(height: 10.0),
        new GestureDetector(
          child: const Text(
            '-   Firebase Analytics',
            style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                decorationStyle: TextDecorationStyle.solid,
                color: const Color(0xFF0000FF)),
          ),
          onTap: () => _launchWebPage(3),
        ),
        const Divider(height: 30.0),
        titleOrSousTitle('Log Data', false),
        paragraph(
            'I want to inform you that whenever you use my Service, in a case of an error in the app I collect data and information (through third party products) on your phone called Log Data. This Log Data may include information such as your device Internet Protocol (“IP”) address, device name, operating system version, the configuration of the app when utilizing my Service, the time and date of your use of the Service, and other statistics.'),
        const Divider(height: 30.0),
        titleOrSousTitle('Cookies', false),
        paragraph(
            'Cookies are files with a small amount of data that are commonly used as anonymous unique identifiers. These are sent to your browser from the websites that you visit and are stored on your device\'s internal memory.'),
        paragraph(
            'This Service does not use these “cookies” explicitly. However, the app may use third party code and libraries that use “cookies” to collect information and improve their services. You have the option to either accept or refuse these cookies and know when a cookie is being sent to your device. If you choose to refuse our cookies, you may not be able to use some portions of this Service.'),
        const Divider(height: 30.0),
        paragraph(
            'I may employ third-party companies and individuals due to the following reasons:'),
        const Divider(height: 30.0),        
        const Text(
          '  • To facilitate our Service;',
          style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 20.0),
          textAlign: TextAlign.start,
          textDirection: TextDirection.ltr,
        ),
        const Text(
          '  • To provide the Service on our behalf;',
          style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 20.0),
          textAlign: TextAlign.start,
          textDirection: TextDirection.ltr,
        ),
        const Text(
          '  • To perform Service-related services; or',
          style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 20.0),
          textAlign: TextAlign.start,
          textDirection: TextDirection.ltr,
        ),
        const Text(
          '  • To assist us in analyzing how our Service is used.',
          style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 20.0),
          textAlign: TextAlign.start,
          textDirection: TextDirection.ltr,
        ),
        paragraph(
            'I want to inform users of this Service that these third parties have access to your Personal Information. The reason is to perform the tasks assigned to them on our behalf. However, they are obligated not to disclose or use the information for any other purpose'),
        const Divider(height: 30.0),
        titleOrSousTitle('Security', false),
        paragraph(
            'I value your trust in providing us your Personal Information, thus we are striving to use commercially acceptable means of protecting it. But remember that no method of transmission over the internet, or method of electronic storage is 100% secure and reliable, and I cannot guarantee its absolute security.'),
        const Divider(height: 30.0),
        titleOrSousTitle('Links to Other Sites', false),
        paragraph(
            'This Service may contain links to other sites. If you click on a third-party link, you will be directed to that site. Note that these external sites are not operated by me. Therefore, I strongly advise you to'
            'review the Privacy Policy of these websites. I have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services.'),
        const Divider(height: 30.0),
        titleOrSousTitle('Changes to This Privacy Policy', false),
        paragraph(
            'I may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. I will notify you of any changes by posting the new Privacy Policy on this page. These changes are effective immediately after they are posted on this page.'),
        const Divider(height: 30.0),
        titleOrSousTitle('Contact Us', false),
        paragraph(
            'If you have any questions or suggestions about my Privacy Policy, do not hesitate to contact me.')
      ],
    );

    return new Scaffold(
        backgroundColor: const Color(0xFFD4B484),
        appBar: AppBar(
          title: _isTerms
              ? const Text('Terms & Conditions')
              : const Text('Privacy Policy'),
        ),
        body: new Flex(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new Flexible(
              child: new ListView(
                children: <Widget>[
                  _isTerms ? terms : privacy,
                ],
              ),
            )
          ],
          direction: Axis.vertical,
        ));
  }

  void _launchWebPage(int val) async {
    const String urlGoogle = 'https://policies.google.com/privacy';
    const String urlAdMob =
        'https://support.google.com/admob/answer/6128543?hl=en';
    const String urlFireAnalytics =
        'https://firebase.google.com/policies/analytics/';
    String launchURl = '';
    switch (val) {
      case 1:
        launchURl = urlGoogle;
        break;
      case 2:
        launchURl = urlAdMob;
        break;
      case 3:
        launchURl = urlFireAnalytics;
        break;
    }

    if (await canLaunch(launchURl)) {
      await launch(launchURl).catchError(() => throw 'Error with url');
    } else {
      throw 'Could not launch url';
    }
  }
}

class AppInfo extends StatefulWidget {
  @override
  _AppInfoState createState() => new _AppInfoState();
}

class _AppInfoState extends State<AppInfo> {
  PackageInfo _packageInfo = new PackageInfo(
      appName: 'Retrieving...',
      packageName: 'Retrieving...',
      version: 'Retrieving...',
      buildNumber: 'Retrieving...');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getPackageInfo();
  }

  dynamic _getPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('About'),
      ),
      body: new Column(
        children: <Widget>[
          new ListTile(
            title: const Text('App Name'),
            trailing: new Text(_packageInfo.appName),
          ),
          new ListTile(
            title: const Text('Package name'),
            trailing: new Text(_packageInfo.packageName),
          ),
          new ListTile(
              title: const Text('App Version'),
              trailing: new Text(_packageInfo.version)),
          new ListTile(
            title: const Text('Build Version'),
            trailing: new Text(_packageInfo.buildNumber),
          ),
        ],
      ),
    );
  }
}
