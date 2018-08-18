import 'package:booktrade/models/user.dart';
import 'package:booktrade/services/TradeApi.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class Settings extends StatefulWidget {
  final User _user;
  final TradeApi _api;

  const Settings(this._user, this._api);

  @override
  _SettingsState createState() => new _SettingsState();
}

class _SettingsState extends State<Settings> {
  User user;

  @override
  void initState() { 
    super.initState();
    setState(() {
      user = widget._user;
    });
  }

  bool _isTurnedOn = true;
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
                Navigator.of(context).push<MaterialPageRoute<dynamic>>(new MaterialPageRoute<MaterialPageRoute<dynamic>>(
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
              final String value = getAsset();
              Navigator.of(context).push<MaterialPageRoute<dynamic>>(new MaterialPageRoute<MaterialPageRoute<dynamic>>(
                  builder: (BuildContext context) {
                    return new ShowPolicy(value, false);
                },
                fullscreenDialog: true,
              ));
            }
          ),
          new ListTile(
            title: const Text('Terms & Conditions'),
            onTap: () {
              setState(() {
                _isTerms = true;                
              });
              final String value = getAsset();
              Navigator.of(context).push<MaterialPageRoute<dynamic>>(new MaterialPageRoute<MaterialPageRoute<dynamic>>(
                  builder: (BuildContext context) {
                    return new ShowPolicy(value, true);
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
              onPressed:  () async {
                await TradeApi.signOutWithGoogle();
                Navigator.of(context).pushReplacementNamed('/');
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
    })
    .catchError((dynamic _) {
      _scaffoldKey.currentState.showSnackBar(
        const SnackBar(content: const Text('Error communicating with our server')),
        );
        setState(() {
            _isTurnedOn = !isTurnedon;
        });
      });
  }

  String getAsset() {
    return _isTerms
    ? 'https://drive.google.com/open?id=1lBAJ0PEEy072j4I7bi_Re_LQoGaVVro2'
    : 'https://drive.google.com/open?id=1-OywQkvncynBcXHi9A6uEAxjSNb9Cxss';
  }
}

class ShowPolicy extends StatelessWidget {

  final bool _isTerms;
  final String value;
  const ShowPolicy(this.value, this._isTerms);

  @override
  Widget build(BuildContext context) {
    return new WebviewScaffold(
      appBar: AppBar(
        title: _isTerms
        ? const Text('Terms & Conditions')
        : const Text('Privacy Policy'),
      ),
      url: value,
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
    buildNumber: 'Retrieving...'
  );

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
            trailing: new Text(_packageInfo.version)
          ),
          new ListTile(
            title: const Text('Build Version'),
            trailing: new Text(_packageInfo.buildNumber),
          )
        ],
      ),
    );
  }
}