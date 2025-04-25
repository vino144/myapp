import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/blocs/sms_bloc.dart';
import 'presentation/screens/expanse_list_screen.dart'; // Import the correct file


import 'package:provider/provider.dart'; 
import 'core/usecases/get_all_sms.dart';
import 'core/repositories/message_repository.dart';
import 'data/repositories/message_repository_impl.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final MessageRepository messageRepository = MessageRepositoryImpl();
  final GetAllSms getAllSms = GetAllSms(messageRepository);
  runApp(MultiProvider(providers: [
    BlocProvider<SmsBloc>(
      create: (context) => SmsBloc(getAllSms: getAllSms) ,
    )
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScreen(title: 'Flutter Demo Home Page'), 
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;


  @override
  void initState() {
    super.initState();  
    
  }


  void _navigateToExpanseListScreen(BuildContext context) {  
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return  BlocBuilder<SmsBloc, SmsState>(builder: (context, state) {
            if (state is SmsLoaded) return const ExpanseListScreen();
            return const Center();
            },
          );
        }));
  }


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(      
      
      body:  Center(
        child:   Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Counter:'),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              ElevatedButton(
                onPressed: () => _navigateToExpanseListScreen(context),
                child: const Text(
                  'Expanse List',
                ),
              ),
            ],
          ),
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ), 
    );
  }
}

class MainScreen extends MyHomePage {
  const MainScreen({super.key, required super.title});
}
