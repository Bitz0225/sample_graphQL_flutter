import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();
  runApp(const MyApp());
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
        // the application has a blue toolbar. Then, without quitting the app,
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  late ValueNotifier<GraphQLClient> client;
  bool isFetch = false;

  @override
  void initState() {
    final link = HttpLink(
      'https://rickandmortyapi.com/graphql',
    );
     client = ValueNotifier(
      GraphQLClient(
        link: link,
        // The default store is the InMemoryStore, which does NOT persist to disk
        cache: GraphQLCache(store: HiveStore()),
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Stack(
          children: [
            Visibility(
              visible: !isFetch,
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isFetch = true;
                    });
                  },
                  child: const Text('Fetch'),
                ),
              ),
            ),
            Visibility(
              visible: isFetch,
              child: Query(
                options: QueryOptions(
                  document: gql(
                    """query {
  characters() {
      results {
              name
              image
              gender
      }
  }

}""",
                  ),
                ),
                builder: (QueryResult<Object?> result,
                    {Future<QueryResult<Object?>> Function(
                        FetchMoreOptions)?
                    fetchMore,
                      Future<QueryResult<Object?>?> Function()? refetch}) {
                  if (result.hasException) {
                    return Text(result.exception.toString());
                  }
                  if (result.isLoading) {
                    return const CircularProgressIndicator();
                  }
                  final List<dynamic> characters = result.data?['characters']['results'];
                  return ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: characters.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          child: ListTile(
                            leading: Image(
                              image: NetworkImage(
                                characters[index]['image'],
                              ),
                            ),
                            title: Text(
                              characters[index]['name'],
                            ),
                          ),
                        );
                      });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
