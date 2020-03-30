import 'package:flutter/material.dart';


class RootView {
  final BuildContext context;

  RootView(this.context);

  Widget build({ Widget body, Color backgroundColor: Colors.white }) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: body == null ? Container() : body,
    );
  }
}