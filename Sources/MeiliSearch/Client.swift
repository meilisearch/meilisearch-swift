import Foundation

/**
 A `MeiliSearch` instance represents a Meilisearch client used to easily integrate
 your Swift product with the Meilisearch server.

 - warning: `Meilisearch` instances are thread safe and can be shared across threads
 or dispatch queues.
 */
public struct MeiliSearch {
  // MARK: Properties

  /**
   Current and immutable Meilisearch configuration. To change this configuration please
   create a new Meilisearch instance.
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

   - parameter host:   The host to the Meilisearch http server.
   - parameter apiKey:    The authorisation key to communicate with Meilisearch.
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
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    Indexes.create(uid: uid, primaryKey: primaryKey, config: self.config, completion)
  }

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
    params: IndexesQuery? = nil,
    _ completion: @escaping (Result<IndexesResults, Swift.Error>) -> Void) {
    Indexes.getAll(config: self.config, params: params, completion)
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
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
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
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.index(uid).delete(completion)
  }

  // MARK: WAIT FOR TASK

  /**
    Wait for a task to be succesfull or failed.

    Using a task returned by an asynchronous route of MeiliSearch, wait for completion.

    - parameter: taskId:              The id of the task.
    - parameter: options             Optionnal configuration for timeout and interval
    - parameter: completion:          The completion closure used to notify when the server
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
    - parameter: options:             Optionnal configuration for timeout and interval
    - parameter completion:          The completion closure used to notify when the server
  **/
  public func waitForTask(
    task: Task,
    options: WaitOptions? = nil,
    _ completion: @escaping (Result<Task, Swift.Error>
  ) -> Void) {
    self.tasks.waitForTask(task: task, options: options, completion)
  }

  public func waitForTask(
    task: TaskInfo,
    options: WaitOptions? = nil,
    _ completion: @escaping (Result<Task, Swift.Error>
  ) -> Void) {
    self.tasks.waitForTask(taskUid: task.taskUid, options: options, completion)
  }

  // MARK: Tasks

 /**
   Get the information of a task.

   - parameter taskUid:    The task identifier.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Key` value.
   If the request was sucessful or `Error` if a failure occured.
   */
  public func getTask(
    taskUid: Int,
    _ completion: @escaping (Result<Task, Swift.Error>) -> Void) {
    self.tasks.get(taskUid: taskUid, completion)
  }

  /**
   List tasks based on an optional pagination criteria

   - parameter completion: The completion closure used to notify when the server
   - parameter params: A TasksQuery object with pagination metadata.
   completes the query request, it returns a `Result` object that contains `Key` value.
   If the request was sucessful or `Error` if a failure occured.
   */
  public func getTasks(
    params: TasksQuery? = nil,
    _ completion: @escaping (Result<Results<Task>, Swift.Error>) -> Void) {
    self.tasks.getAll(params: params, completion)
  }

  // MARK: Keys

  /**
   Get all keys.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Key` value.
   If the request was sucessful or `Error` if a failure occured.
   */
  public func getKeys(
    params: KeysQuery? = nil,
    _ completion: @escaping (Result<Results<Key>, Swift.Error>) -> Void) {
      self.keys.getAll(params: params, completion)
  }

  /**
   Get one key's information using the key value.

   - parameter key:  The key value.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Key` value.
   If the request was sucessful or `Error` if a failure occured.
   */
  public func getKey(
    key: String,
    _ completion: @escaping (Result<Key, Swift.Error>) -> Void) {
    self.keys.get(key: key, completion)
  }

  /**
    Create an API key.

   - parameter keyParams:   Parameters object required to create a key.
   - parameter completion:  The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Key` value.
   If the request was sucessful or `Error` if a failure occured.
   */
  public func createKey(
    _ keyParams: KeyParams,
    _ completion: @escaping (Result<Key, Swift.Error>) -> Void) {
    self.keys.create(keyParams, completion)
  }

  /**
    Update an API key.

   - parameter key:         The key value.
   - parameter keyParams:   Parameters object required to update a key.
   - parameter completion:  The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Key` value.
   If the request was sucessful or `Error` if a failure occured.
   */
  public func updateKey(
    key: String,
    keyParams: KeyUpdateParams,
    _ completion: @escaping (Result<Key, Swift.Error>) -> Void) {
    self.keys.update(
      key: key,
      keyParams: keyParams,
      completion
    )
  }

  /**
    Delete an API key.

   - parameter key:  The key value.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Key` value.
   If the request was sucessful or `Error` if a failure occured.
   */
  public func deleteKey(
    key: String,
    _ completion: @escaping (Result<(), Swift.Error>) -> Void) {
    self.keys.delete(
      key: key,
      completion
    )
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
   Get health of Meilisearch server.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Health` value.
   If the request was sucessful or `Error` if a failure occured.
   */
  public func health(_ completion: @escaping (Result<Health, Swift.Error>) -> Void) {
    self.system.health(completion)
  }

  /**
   Returns whether Meilisearch server is healthy or not.

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
   Get version of Meilisearch.

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
  public func createDump(_ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.dumps.create(completion)
  }
}
