import Foundation

/**
 A `MeiliSearch` instance represents a MeiliSearch client used to easily integrate
 your Swift product with the MeiliSearch server.

 - warning: `MeiliSearch` instances are thread safe and can be shared across threads
 or dispatch queues.
 */
public struct MeiliSearch {
  // MARK: Properties

  /**
   Current and immutable MeiliSearch configuration. To change this configuration please
   create a new MeiliSearch instance.
   */
  private let request: Request
  private(set) var config: Config
  private let keys: Keys
  private let stats: Stats
  private let system: System
  private let dumps: Dumps
  private let tasks: Tasks

  // MARK: Initializers

  /**
   Create an instance of MeiliSearch client.

   - parameter host:   The host to the MeiliSearch http server.
   - parameter apiKey:    The authorisation key to communicate with MeiliSearch.
   - parameter session:   A custom produced URLSessionProtocol.
   */
  public init(host: String, apiKey: String? = nil, session: URLSessionProtocol? = nil, request: Request? = nil) throws {
    self.config = try Config(host: host, apiKey: apiKey, session: session).validate()
    if let request: Request = request {
      self.request = request
    } else {
      self.request = Request(self.config)
    }
    self.keys = Keys(self.request)
    self.stats = Stats(self.request)
    self.system = System(self.request)
    self.dumps = Dumps(self.request)
    self.tasks = Tasks(self.request)
  }

  // MARK: Index
  /**
  Create an instance of Index.

  - parameter uid:        The unique identifier for the `Index` to be created.
   */
  public func index(_ uid: String) -> Indexes {
    Indexes(config: self.config, uid: uid)
  }

  /**
   Create a new index.

  - parameter uid:        The unique identifier for the `Index` to be created.
  - parameter primaryKey: the unique field of a document.
  - parameter completion: The completion closure used to notify when the server
   completes the write request, it returns a `Result` object that contains `Index`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func createIndex(
    uid: String,
    primaryKey: String? = nil,
    _ completion: @escaping (Result<Task, Swift.Error>) -> Void) {
    Indexes.create(uid: uid, primaryKey: primaryKey, config: self.config, completion)
  }

  /**
   Get or create an index.

  - parameter uid:        The unique identifier for the `Index` to be created.
  - parameter primaryKey: the unique field of a document.
  - parameter completion: The completion closure used to notify when the server
   completes the write request, it returns a `Result` object that contains `Index`
   value. If the request was sucessful or `Error` if a failure occured.
   */

  // TODO: remove in another PR
  // public func getOrCreateIndex(
  //   uid: String,
  //   primaryKey: String? = nil,
  //   _ completion: @escaping (Result<Index, Swift.Error>) -> Void) {
  //   Indexes.getOrCreate(uid: uid, primaryKey: primaryKey, config: self.config, completion)
  // }

  /**
   Get an index.

   - parameter uid:        The unique identifier for the `Index` to be found.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Index`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func getIndex(
    _ uid: String,
    _ completion: @escaping (Result<Index, Swift.Error>) -> Void) {
    self.index(uid).get(completion)
  }

  /**
   List all indexes.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `[Index]`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func getIndexes(
    _ completion: @escaping (Result<[Index], Swift.Error>) -> Void) {
    Indexes.getAll(config: self.config, completion)
  }

  /**
   Update the primaryKey of the index.

  - parameter uid:        The unique identifier of the index
  - parameter primaryKey: the unique field of a document.
  - parameter completion: The completion closure used to notify when the server
   completes the update request, it returns a `Result` object that contains `()`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func updateIndex(
    uid: String,
    primaryKey: String,
    _ completion: @escaping (Result<Task, Swift.Error>) -> Void) {
    self.index(uid).update(primaryKey: primaryKey, completion)
  }

  /**
   Delete an index.

  - parameter uid:        The unique identifier of the index.
  - parameter completion: The completion closure used to notify when the server
   completes the delete request, it returns a `Result` object that contains `()`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func deleteIndex(
    _ uid: String,
    _ completion: @escaping (Result<Task, Swift.Error>) -> Void) {
    self.index(uid).delete(completion)
  }

  // MARK: WAIT FOR TASK

  /**
    Wait for a task to be succesfull or failed.

    Using a task returned by an asynchronous route of MeiliSearch, wait for completion.

    - parameter taskId:              The id of the task.
    - parameter: options             Optionnal configuration for timeout and interval
    - parameter completion:          The completion closure used to notify when the server
  **/
  public func waitForTask(
    taskUid: Int,
    options: WaitOptions? = nil,
    _ completion: @escaping (Result<Task, Swift.Error>
  ) -> Void) {
    self.tasks.waitForTask(taskUid: taskUid, options: options, completion)
  }

  /**
    Wait for a task to be succeeded or failed.

    Using a task returned by an asynchronous route of MeiliSearch, wait for completion.

    - parameter task:                The task.
    - parameter: options             Optionnal configuration for timeout and interval
    - parameter completion:          The completion closure used to notify when the server
  **/
  public func waitForTask(
    task: Task,
    options: WaitOptions? = nil,
    _ completion: @escaping (Result<Task, Swift.Error>
  ) -> Void) {
    self.tasks.waitForTask(task: task, options: options, completion)
  }

  // MARK: Tasks

 /**
   Get the information of a task.

   - parameter taskUid:    The task identifier.
   - parameter completion:The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Key` value.
   If the request was sucessful or `Error` if a failure occured.
   */
  public func getTask(
    taskUid: Int,
    _ completion: @escaping (Result<Task, Swift.Error>) -> Void) {
    self.tasks.get(taskUid: taskUid, completion)
  }

  /**
   Get all tasks.

   - parameter completion:The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Key` value.
   If the request was sucessful or `Error` if a failure occured.
   */
  public func getTasks(
    _ completion: @escaping (Result<Results<Task>, Swift.Error>) -> Void) {
    self.tasks.getAll(completion)
  }

  // MARK: Keys

  /**
   Each instance of MeiliSearch has three keys: a master, a private, and a public. Each key has a given
   set of permissions on the API routes.

   - parameter masterKey:  Master key to access the `keys` function.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Key` value.
   If the request was sucessful or `Error` if a failure occured.
   */
  public func keys(
    _ completion: @escaping (Result<Key, Swift.Error>) -> Void) {
    self.keys.get(completion)
  }

  // MARK: Stats

  /**
   Get stats of all indexes.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `AllStats`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func allStats(
    _ completion: @escaping (Result<AllStats, Swift.Error>) -> Void) {
    self.stats.allStats(completion)
  }

  // MARK: System

  /**
   Get health of MeiliSearch server.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Health` value.
   If the request was sucessful or `Error` if a failure occured.
   */
  public func health(_ completion: @escaping (Result<Health, Swift.Error>) -> Void) {
    self.system.health(completion)
  }

  /**
   Get health of MeiliSearch server.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Bool` that is `true`
   If the request was sucessful or `false` if a failure occured.
   */
  public func isHealthy(_ completion: @escaping (Bool) -> Void) {
    self.health { result in
      switch result {
      case .success:
        completion(true)
      case .failure:
        completion(false)
      }
    }
  }

  /**
   Get version of MeiliSearch.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Version`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func version(
    _ completion: @escaping (Result<Version, Swift.Error>) -> Void) {
    self.system.version(completion)
  }

  /**
   Triggers a dump creation process. Once the process is complete, a dump is created in the dumps folder.
   If the dumps folder does not exist yet, it will be created.

   - parameter completion: The completion closure used to notify when the server
   completes the dump request, it returns a `Dump` object that contains `uid`
   value that can be used later to check the status of the dump.
   If the request was successful or `Error` if a failure occurred.
   */
  public func createDump(_ completion: @escaping (Result<Dump, Swift.Error>) -> Void) {
    self.dumps.create(completion)
  }

  /**
   Get the status of a dump creation process using the uid returned after calling the dump creation route.
   The returned status could be:

   `Dump.Status.inProgress`: Dump creation is in progress.
   `Dump.Status.failed`: An error occurred during the dump process, and the task was aborted.
   `Dump.Status.done`: Dump creation is finished and was successful.

   - parameter completion: The completion closure used to notify when the server
   completes the dump request, it returns a `Dump` object that contains `uid`
   value that can be used later to check the status of the Dump.
   If the request was successful or `Error` if a failure occurred.
   */
  public func getDumpStatus(
    _ uid: String,
    _ completion: @escaping (Result<Dump, Swift.Error>) -> Void) {
    self.dumps.status(uid, completion)
  }
}
