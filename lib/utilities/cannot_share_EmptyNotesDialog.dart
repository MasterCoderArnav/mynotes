import 'package:flutter/material.dart';
import 'generic_dialog.dart';

Future<void> cannotShareEmptyNotesDialog(BuildContext context){
  return showGenericDialog<void>(
      context: context,
      title: 'An error occurred',
      content: 'Cannot share empty notes',
      optionBuilder: ()=>{
        'Ok': null,
      }
  );
}