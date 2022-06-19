import 'package:flutter/material.dart';
import 'generic_dialog.dart';

Future<void> ErrorDialog(BuildContext context, String text){
  return showGenericDialog<void>(
      context: context,
      title: 'An error occured',
      content: text,
      optionBuilder: ()=>{
        'Ok' : null,
      }
  );
}