import 'package:quiz_api/controller/question_controller.dart';

import 'quiz_api.dart';

/// This class handles setting up this application.
///
/// Override methods from [RequestSink] to set up the resources your
/// application uses and the routes it exposes.
///
/// See the documentation in this file for the constructor, [setupRouter] and [willOpen]
/// for the purpose and order of the initialization methods.
///
/// Instances of this class are the type argument to [Application].
/// See http://aqueduct.io/docs/http/request_sink
/// for more details.
class QuizApiSink extends RequestSink {
  ManagedContext context;

  /// Constructor called for each isolate run by an [Application].
  ///
  /// This constructor is called for each isolate an [Application] creates to serve requests.
  /// The [appConfig] is made up of command line arguments from `aqueduct serve`.
  ///
  /// Configuration of database connections, [HTTPCodecRepository] and other per-isolate resources should be done in this constructor.
  QuizApiSink(ApplicationConfiguration appConfig) : super(appConfig) {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));

    var dataModel = new ManagedDataModel.fromCurrentMirrorSystem();

    var configValues = new QuizConfig(appConfig.configurationFilePath);

    var persistentStore = new PostgreSQLPersistentStore.fromConnectionInfo(
        configValues.database.username,
        configValues.database.password,
        configValues.database.host,
        configValues.database.port,
        configValues.database.databaseName);

    context = new ManagedContext(dataModel, persistentStore);
  }

  /// All routes must be configured in this method.
  ///
  /// This method is invoked after the constructor and before [willOpen] Routes must be set up in this method, as
  /// the router gets 'compiled' after this method completes and routes cannot be added later.
  @override
  void setupRouter(Router router) {
    // Prefer to use `pipe` and `generate` instead of `listen`.
    // See: https://aqueduct.io/docs/http/request_controller/

    router
        .route("/questions/[:index]")
        .generate(() => new QuestionController());

//    router.route("/example").listen((request) async {
//      return new Response.ok({"key": "value"});
//    });
  }

  /// Final initialization method for this instance.
  ///
  /// This method allows any resources that require asynchronous initialization to complete their
  /// initialization process. This method is invoked after [setupRouter] and prior to this
  /// instance receiving any requests.
  @override
  Future willOpen() async {}
}

class QuizConfig extends ConfigurationItem {
  QuizConfig(String filename) : super.fromFile(filename);
  DatabaseConnectionConfiguration database;
}
