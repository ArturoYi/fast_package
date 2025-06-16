import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:xml/xml.dart';

void main() {
  final file = File('resources/fast_phone_number_resources/PhoneNumberMetadata.xml');
  final document = XmlDocument.parse(file.readAsStringSync());
  document.findAllElements("territory").forEach((country) {
    debugPrint("case '${country.localName}':");
  });
}
