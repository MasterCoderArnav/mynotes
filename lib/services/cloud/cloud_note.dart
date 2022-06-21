import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'cloud_storage_constants.dart';

@immutable
class CloudNote{
  final String documentID;
  final String ownerUserID;
  final String text;
  const CloudNote({required this.documentID, required this.ownerUserID, required this.text});
  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot):
        documentID = snapshot.id,
        ownerUserID = snapshot.data()[ownerUserIdFieldName],
        text = snapshot.data()[textFieldName] as String;
}