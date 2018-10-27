// Copyright (c) 2017, Spencer. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

typedef Widget AppBarCallback(BuildContext context);
typedef void TextFieldSubmitCallback(String value);
typedef void TextFieldChangeCallback(String value);
typedef void SetStateCallback(void fn());

class SearchBar {

    SearchBar({
    @required this.setState,
    @required this.buildDefaultAppBar,
    this.onSubmitted,
    this.controller,
    this.hintText = 'Search',
    this.inBar = true,
    this.colorBackButton = true,
    this.closeOnSubmit = true,
    this.clearOnSubmit = true,
    this.showClearButton = true,
    this.onChanged,
    this.onClosed
  }) {
      controller ??= new TextEditingController();
    

    // Don't waste resources on listeners for the text controller if the dev
    // doesn't want a clear button anyways in the search bar
    if (!showClearButton) {
      return;
    }

     controller.addListener(() {
      if (controller.text.isEmpty) {
        // If clear is already disabled, don't disable it
        if (_clearActive) {
          setState(() {
            _clearActive = false;
          });
        }

        return;
      }

      // If clear is already enabled, don't enable it
      if (!_clearActive) {
        setState(() {
          _clearActive = true;
        });
      }
    });
  }
  
  /// Whether the search should take place "in the existing search bar", meaning whether it has the same background or a flipped one. Defaults to true.
  final bool inBar;

  /// Whether the back button should be colored, if this is false the back button will be Colors.grey.shade400
  final bool colorBackButton;

  /// Whether or not the search bar should close on submit. Defaults to true.
  final bool closeOnSubmit;

  /// Whether the text field should be cleared when it is submitted
  final bool clearOnSubmit;

  /// A callback which should return an AppBar that is displayed until search is started. One of the actions in this AppBar should be a search button which you obtain from SearchBar.getSearchAction(). This will be called every time search is ended, etc. (like a build method on a widget)
  final AppBarCallback buildDefaultAppBar;

  /// A void callback which takes a string as an argument, this is fired every time the search is submitted. Do what you want with the result.
  final TextFieldSubmitCallback onSubmitted;

  /// Since this should be inside of a State class, just pass setState to this.
  final SetStateCallback setState;

  /// Whether or not the search bar should add a clear input button, defaults to true.
  final bool showClearButton;

  /// What the hintText on the search bar should be. Defaults to 'Search'.
  final String hintText;

  ///Event triggered when the user close the search bar
  final VoidCallback onClosed;

  /// Whether search is currently active.
  final ValueNotifier<bool> isSearching = new ValueNotifier<bool>(false);

  /// A callback which is invoked each time the text field's value changes
  final TextFieldChangeCallback onChanged;

  /// The controller to be used in the textField.
  TextEditingController controller;

  /// Whether the clear button should be active (fully colored) or inactive (greyed out)
  bool _clearActive = false;

  /// The last built default AppBar used for colors and such.
  AppBar _defaultAppBar;



  /// Initializes the search bar.
  ///
  /// This adds a new route that listens for onRemove (and stops the search when that happens), and then calls [setState] to rebuild and start the search.
  Future<dynamic> beginSearch(dynamic context) {
    ModalRoute.of(context).addLocalHistoryEntry(
        new LocalHistoryEntry(
            onRemove: () {
              setState(() {
                isSearching.value = false;
              });
            }
        ));

    setState(() {
      isSearching.value = true;
    });
    return Future<dynamic>.value();
  }

  /// Builds, saves and returns the default app bar.
  ///
  /// This calls the [buildDefaultAppBar] provided in the constructor, and saves it to [_defaultAppBar].
  AppBar buildAppBar(BuildContext context) {
    _defaultAppBar = buildDefaultAppBar(context);

    return _defaultAppBar;
  }

  /// Builds the search bar!
  ///
  /// The leading will always be a back button.
  /// backgroundColor is determined by the value of inBar
  /// title is always a [TextField] with the key 'SearchBarTextField', and various text stylings based on [inBar]. This is also where [onSubmitted] has its listener registered.
  ///
  AppBar buildSearchBar(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Color barColor = inBar ? _defaultAppBar.backgroundColor : theme.canvasColor;

    // Don't provide a color (make it white) if it's in the bar, otherwise color it or set it to grey.
    final Color buttonColor = inBar ? null : (colorBackButton ? _defaultAppBar.backgroundColor ?? theme.primaryColor ?? Colors.grey.shade400 : Colors.grey.shade400);
    final Color buttonDisabledColor = inBar ? const Color.fromRGBO(255, 255, 255, 0.25) : Colors.grey.shade300;

    final Color textColor = inBar ? Colors.white70 : Colors.black54;

    return new AppBar(
      leading: WillPopScope(
        onWillPop: () {
              if (onClosed != null) {
                onClosed();
              }
              return Future<bool>.value(true);
            },
       child: new IconButton(
        icon: const BackButton(),
        color: buttonColor,
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: () {
          print('called');
          if (onClosed != null) {
            onClosed();
          }
          controller.clear();
          Navigator.maybePop(context);
        },
      ),
      ),
      backgroundColor: barColor,
      title: new Directionality(
          textDirection: Directionality.of(context),
          child: new TextField(
            key: const Key('SearchBarTextField'),
            keyboardType: TextInputType.text,
            style: new TextStyle(
                color: textColor,
                fontSize: 16.0
            ),
            decoration: new InputDecoration(
                hintText: hintText,
                hintStyle: new TextStyle(
                    color: textColor,
                    fontSize: 16.0
                ),
                border: null
            ),
            onChanged: onChanged,
            onSubmitted: (String val) async {
              if (closeOnSubmit) {
                await Navigator.maybePop(context);
              }

              if (clearOnSubmit) {
                controller.clear();
              }

              onSubmitted(val);
            },
            autofocus: true,
            controller: controller,
          )
      ),
      actions: !showClearButton ? null : <Widget>[
        // Show an icon if clear is not active, so there's no ripple on tap
        new IconButton(
            icon: new Icon(Icons.clear, color: _clearActive ? buttonColor : buttonDisabledColor),
            disabledColor: buttonDisabledColor,
            onPressed: !_clearActive ? null : () { controller.clear(); })
      ],
    );
  }

  /// Returns an [IconButton] suitable for an Action
  ///
  /// Put this inside your [buildDefaultAppBar] method!
  IconButton getSearchAction(BuildContext context) {
    return new IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          beginSearch(context);
        }
    );
  }

  /// Returns an AppBar based on the value of [isSearching]
  AppBar build(BuildContext context) {
    return isSearching.value ? buildSearchBar(context) : buildAppBar(context);
  }
}