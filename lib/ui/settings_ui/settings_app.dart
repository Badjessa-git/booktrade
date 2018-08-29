import 'package:booktrade/models/user.dart';
import 'package:booktrade/services/TradeApi.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:booktrade/models/constants.dart';
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
  BannerAd bannerAd;
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: const Text('Settings'),
        leading: new IconButton(  
          icon: const BackButton(),
          onPressed: () {
            if (banner != null) {
              banner.show();
              isAdShown = true;
            }
            Navigator.pop(context);
          },
        ),
      ),
      body: new Flex(
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
                  if (isAdShown && !calledDisposed) {
                      bannerAd = banner;
                      await bannerAd?.dispose();
                      isAdShown = false;
                      calledDisposed = true; 
                  }
                await TradeApi.signOutWithGoogle();
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/home', (Route<dynamic> route) => false);
              },
            ),
          ),
        ], direction: Axis.vertical,
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

class EULAPolicy extends StatelessWidget {
  
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

  final Divider divider = const Divider(height: 30.0);
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: const Color(0xFFD4B484),
      appBar: new AppBar(
        title: const Text('End User License Agreement')
      ),
      body: new Column(
        children: <Widget> [
          paragraph('Copyright (c) 2018 BBB Development'),
          titleOrSousTitle('*** END USER LICENSE AGREEMENT ***', true),
          titleOrSousTitle('IMPORTANT: PLEASE READ THIS LICENSE CAREFULLY BEFORE USING THIS SOFTWARE.', false),
          titleOrSousTitle('1. LICENSE', false),
          paragraph('By receiving, opening the file package, and/or using BookTrade("Software"), you agree that this End User User License Agreement(EULA) is a legally binding and valid contract and agree to be bound by it. You agree to abide by the intellectual property laws and all of the terms and conditions of this Agreement.'),
          paragraph('Unless you have a different license agreement signed by BBB Development, your use of BookTrade indicates your acceptance of this license agreement and warranty.'),
          paragraph('Subject to the terms of this Agreement, BBB Development grants to you a limited, non-exclusive, non-transferable license, without right to sub-license, to use BookTrade in accordance with this Agreement and any other written agreement with BBB Development. BBB Development does not transfer the title of BookTrade to you; the license granted to you is not a sale. This agreement is a binding legal agreement between BBB Development and the purchasers or users of BookTrade.'),
          paragraph('If you do not agree to be bound by this agreement, remove BookTrade from your mobile device now and, if applicable, promptly return to BBB Development by mail any copies of BookTrade and related documentation and packaging in your possession.'),
          divider,
          titleOrSousTitle('2. DISTRIBUTION', false),
          paragraph('BookTrade and the license herein granted shall not be copied, shared, distributed, re-sold, offered for re-sale, transferred or sub-licensed in whole or in part except that you may make one copy for archive purposes only. For information about redistribution of BookTrade contact BBB Development.'),
          divider,
          titleOrSousTitle('3. USER AGREEMENT', false),
          paragraph('3.1 Use'),
          paragraph('Your license to use BookTrade is limited to the number of licenses purchased by you. You shall not allow others to use, copy or evaluate copies of BookTrade.'),
          paragraph('3.2 Use Restrictions'),
          paragraph('You shall use BookTrade in compliance with all applicable laws and not for any unlawful purpose. Without limiting the foregoing, use, display or distribution of BookTrade together with material that is pornographic, racist, vulgar, obscene, defamatory, libelous, abusive, promoting hatred, discriminating or displaying prejudice based on religion, ethnic heritage, race, gender, sexual orientation or age is strictly prohibited.'),
          paragraph('Each licensed copy of BookTrade may be used on one single mobile device location by one user. Use of BookTrade means that you have loaded, installed, or run BookTrade on a mobile device. If you install BookTrade onto a multi-user platform, server or network, each and every individual user of BookTrade must be licensed separately.'),
          paragraph('You may make one copy of BookTrade for backup purposes, providing you only have one copy installed on one mobile device being used by one person. Other users may not use your copy of BookTrade . The assignment, sub-license, networking, sale, or distribution of copies of BookTrade are strictly forbidden without the prior written consent of BBB Development. It is a violation of this agreement to assign, sell, share, loan, rent, lease, borrow, network or transfer the use of BookTrade. If any person other than yourself uses BookTrade registered in your name, regardless of whether it is at the same time or different times, then this agreement is being violated and you are responsible for that violation!'),
          paragraph('3.3 Copyright Restriction'),
          paragraph('This Software contains copyrighted material, trade secrets and other proprietary material. You shall not, and shall not attempt to, modify, reverse engineer, disassemble or decompile BookTrade. Nor can you create any derivative works or other works that are based upon or derived from BookTrade in whole or in part.'),
          paragraph('BBB Development\'s name, logo and graphics file that represents BookTrade shall not be used in any way to promote products developed with BookTrade. BBB Development retains sole and exclusive ownership of all right, title and interest in and to BookTrade and all Intellectual Property rights relating thereto.'),
          paragraph('Copyright law and international copyright treaty provisions protect all parts of BookTrade, products and services. No program, code, part, image, audio sample, or text may be copied or used in any way by the user except as intended within the bounds of the single user program. All rights not expressly granted hereunder are reserved for BBB Development.'),
          paragraph('3.4 Limitation of Responsibility'),
          paragraph('You will indemnify, hold harmless, and defend BBB Development , its employees, agents and distributors against any and all claims, proceedings, demand and costs resulting from or in any way connected with your use of BBB Development\'s Software.'),
          paragraph('In no event (including, without limitation, in the event of negligence) will BBB Development , its employees, agents or distributors be liable for any consequential, incidental, indirect, special or punitive damages whatsoever (including, without limitation, damages for loss of profits, loss of use, business interruption, loss of information or data, or pecuniary loss), in connection with or arising out of or related to this Agreement, BookTrade or the use or inability to use BookTrade or the furnishing, performance or use of any other matters hereunder whether based upon contract, tort or any other theory including negligence.'),
          paragraph('BBB Development\'s entire liability, without exception, is limited to the customers\' reimbursement of the purchase price of the Software (maximum being the lesser of the amount paid by you and the suggested retail price as listed by BBB Development ) in exchange for the return of the product, all copies, registration papers and manuals, and all materials that constitute a transfer of license from the customer back to BBB Development.'),
          paragraph('3.5 Warranties'),
          paragraph('Except as expressly stated in writing, BBB Development makes no representation or warranties in respect of this Software and expressly excludes all other warranties, expressed or implied, oral or written, including, without limitation, any implied warranties of merchantable quality or fitness for a particular purpose.'),
          paragraph('3.6 Governing Law'),
          paragraph('This Agreement shall be governed by the law of the United States applicable therein. You hereby irrevocably attorn and submit to the non-exclusive jurisdiction of the courts of United States therefrom. If any provision shall be considered unlawful, void or otherwise unenforceable, then that provision shall be deemed severable from this License and not affect the validity and enforceability of any other provisions.'),
          paragraph('3.7 Termination'),
          paragraph('Any failure to comply with the terms and conditions of this Agreement will result in automatic and immediate termination of this license. Upon termination of this license granted herein for any reason, you agree to immediately cease use of BookTrade and destroy all copies of BookTrade supplied under this Agreement. The financial obligations incurred by you shall survive the expiration or termination of this license.'),
          divider,
          titleOrSousTitle('4. DISCLAIMER OF WARRANTY', false),
          paragraph('THIS SOFTWARE AND THE ACCOMPANYING FILES ARE SOLD "AS IS" AND WITHOUT WARRANTIES AS TO PERFORMANCE OR MERCHANTIBILITY OR ANY OTHER WARRANTIES WHETHER EXPRESSED OR IMPLIED. THIS DISCLAIMER CONCERNS ALL FILES GENERATED AND EDITED BY BookTrade AS WELL.'),
          divider,
          titleOrSousTitle('5. CONSENT OF USE OF DATA', false),
          paragraph('You agree that BBB Development may collect and use information gathered in any manner as part of the product support services provided to you, if any, related to BookTrade .BBB Development may also use this information to provide notices to you which may be of use or interest to you.'),
        ],
      ),
    );
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
