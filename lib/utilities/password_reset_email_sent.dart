import 'package:flutter/material.dart';
import 'package:mynotes/utilities/generic_dialog.dart';

Future<void> showPasswordEmailSentDialog(BuildContext context){
  return showGenericDialog(
      context: context,
      title: 'Reset Password',
      content: 'We have now sent the reset password mail',
      optionBuilder: ()=>{
        'Ok' : null,
      }
  );
}