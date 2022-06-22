import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth_service.dart';
import 'package:mynotes/view/notes/new_note_view.dart';
import 'package:mynotes/view/registerView.dart';
import 'package:mynotes/view/loginView.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mynotes/view/verify_email_view.dart';
import 'dart:developer' as devtools show log;
import 'package:mynotes/view/notesView.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(myApp());
}

class myApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Flutter Demo',
      home: HomePage(),
      routes: {
        loginRoute : (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyRoute : (context) => const verifyEmailView(),
        newNotesRoute : (context) => const newNoteView(),
      },
    );
  }
}

// class HomePage extends StatelessWidget{
//   const HomePage({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context){
//     return FutureBuilder(
//         future: AuthService.firebase().initialise(),
//         builder: (context, snapshot){
//           switch(snapshot.connectionState){
//                 case ConnectionState.done:
//                     final user = AuthService.firebase().currentUser;
//                     final userVerified = user?.isEmailVerified ?? false;
//                     if(userVerified){
//                       devtools.log("User verified");
//                       return const NotesView();
//                     }
//                     else if(user!=null){
//                       devtools.log("Verify your email id");
//                       return const verifyEmailView();
//                     }
//                     else{
//                       return const LoginView();
//                     }
//                   default:
//                       return Container(
//                         decoration: const BoxDecoration(
//                           color: Colors.white,
//                         ),
//                          child: Center(
//                             child: SpinKitFoldingCube(
//                                 color: Colors.blue[800],
//                                 size: 80.0,
//                               ),
//                         ),
//                       );
//                   }
//                 },
//         );
//     }
// }

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _controller;

  @override
  void initState(){
    _controller = TextEditingController();
    super.initState();
  }

  void dispose(){
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context)=>CounterBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Testing Bloc'),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: BlocConsumer<CounterBloc, CounterState>(
          listener: (context, state){
            _controller.clear();
          },
          builder: (context, state){
            final invalidValue = (state is CounterStateInvalid) ? state.invalidValue : '';
            return Column(
              children: <Widget>[
                const SizedBox(height: 20.0),
                Text('Current value is equal to ${state.value}'),
                Visibility(
                  visible: state is CounterStateInvalid,
                  child: Text('Invalid input => $invalidValue'),
                ),
                const SizedBox(height: 20.0),
                Container(
                  margin: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Please input number",
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 2.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.pink,
                          width: 2.0,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                        onPressed: (){
                          context.read<CounterBloc>().add(IncrementEvent(_controller.text));
                        },
                        child: const Text('+'),
                    ),
                    const SizedBox(width: 280.0),
                    TextButton(
                        onPressed: (){
                          context.read<CounterBloc>().add(DecrementEvent(_controller.text));
                        },
                        child: const Text('-')
                    ),
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

@immutable
abstract class CounterState{
  final int value;
  const CounterState({required this.value});
}

class CounterStateValid extends CounterState{
  const CounterStateValid(int value) : super(value: value);
}

class CounterStateInvalid extends CounterState{
  final String invalidValue;
  const CounterStateInvalid({
    required this.invalidValue,
    required int previousValue,
  }) : super(value: previousValue);
}

abstract class CounterEvent{
  final String value;
  const CounterEvent({required this.value});
}

class IncrementEvent extends CounterEvent{
  const IncrementEvent(String value) : super(value: value);
}

class DecrementEvent extends CounterEvent{
  const DecrementEvent(String value) : super(value: value);
}

class CounterBloc extends Bloc<CounterEvent, CounterState>{
  CounterBloc() : super(const CounterStateValid(0)){
    on<IncrementEvent>((event, emit){
      final integer = int.tryParse(event.value);
      if(integer==null){
        emit(CounterStateInvalid(invalidValue: event.value, previousValue: state.value));
      }
      else{
        emit(CounterStateValid(state.value+integer));
      }
    });
    on<DecrementEvent>((event, emit){
      final integer = int.tryParse(event.value);
      if(integer==null){
        emit(CounterStateInvalid(invalidValue: event.value, previousValue: state.value));
      }
      else{
        emit(CounterStateValid(state.value-integer));
      }
    });
  }
}