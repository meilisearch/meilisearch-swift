///Documentation: https://www.meilisearch.com/docs/reference/api/keys#actions
public enum KeyAction: Equatable, Codable {
  case wildcard
  case search
  case documentsWildcard
  case documentsAdd
  case documentsGet
  case documentsDelete
  case indexesWildcard
  case indexesCreate
  case indexesGet
  case indexesUpdate
  case indexesDelete
  case indexesSwap
  case tasksWildcard
  case tasksGet
  case tasksCancel
  case tasksDelete
  case settingsWildcard
  case settingsGet
  case settingsUpdate
  case statsGet
  case dumpsCreate
  case snapshotsCreate
  case version
  case keysGet
  case keysCreate
  case keysUpdate
  case keysDelete
  case unknown(String)

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)

    self = KeyAction(rawValue)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()

    try container.encode(self.value)
  }
}

public extension KeyAction {
  init(_ value: String) {
    switch value {
    case "*":
      self = .wildcard
    case "search":
      self = .search
    case "documents.*":
      self = .documentsWildcard
    case "documents.add":
      self = .documentsAdd
    case "documents.get":
      self = .documentsGet
    case "documents.delete":
      self = .documentsDelete
    case "indexes.*":
      self = .indexesWildcard
    case "indexes.create":
      self = .indexesCreate
    case "indexes.get":
      self = .indexesGet
    case "indexes.update":
      self = .indexesUpdate
    case "indexes.delete":
      self = .indexesDelete
    case "indexes.swap":
      self = .indexesSwap
    case "tasks.*":
      self = .tasksWildcard
    case "tasks.get":
      self = .tasksGet
    case "tasks.cancel":
      self = .tasksCancel
    case "tasks.delete":
      self = .tasksDelete
    case "settings.*":
      self = .settingsWildcard
    case "settings.get":
      self = .settingsGet
    case "settings.update":
      self = .settingsUpdate
    case "stats.get":
      self = .statsGet
    case "dumps.create":
      self = .dumpsCreate
    case "snapshots.create":
      self = .snapshotsCreate
    case "version":
      self = .version
    case "keys.get":
      self = .keysGet
    case "keys.create":
      self = .keysCreate
    case "keys.update":
      self = .keysUpdate
    case "keys.delete":
      self = .keysDelete
    default:
      self = .unknown(value)
    }
  }

  var value: String {
    switch self {
    case .wildcard:
      return "*"
    case .search:
      return "search"
    case .documentsWildcard:
      return "documents.*"
    case .documentsAdd:
      return "documents.add"
    case .documentsGet:
      return "documents.get"
    case .documentsDelete:
      return "documents.delete"
    case .indexesWildcard:
      return "indexes.*"
    case .indexesCreate:
      return "indexes.create"
    case .indexesGet:
      return "indexes.get"
    case .indexesUpdate:
      return "indexes.update"
    case .indexesDelete:
      return "indexes.delete"
    case .indexesSwap:
      return "indexes.swap"
    case .tasksWildcard:
      return "tasks.*"
    case .tasksGet:
      return "tasks.get"
    case .tasksCancel:
      return "tasks.cancel"
    case .tasksDelete:
      return "tasks.delete"
    case .settingsWildcard:
      return "settings.*"
    case .settingsGet:
      return "settings.get"
    case .settingsUpdate:
      return "settings.update"
    case .statsGet:
      return "stats.get"
    case .dumpsCreate:
      return "dumps.create"
    case .snapshotsCreate:
      return "snapshots.create"
    case .version:
      return "version"
    case .keysGet:
      return "keys.get"
    case .keysCreate:
      return "keys.create"
    case .keysUpdate:
      return "keys.update"
    case .keysDelete:
      return "keys.delete"
    case .unknown(let string):
      return string
    }
  }
}

extension KeyAction: CaseIterable {
  public static var allCases: [KeyAction] {
    [
      .wildcard,
      .search,
      .documentsWildcard,
      .documentsAdd,
      .documentsGet,
      .documentsDelete,
      .indexesWildcard,
      .indexesCreate,
      .indexesGet,
      .indexesUpdate,
      .indexesDelete,
      .indexesSwap,
      .tasksWildcard,
      .tasksGet,
      .tasksCancel,
      .tasksDelete,
      .settingsWildcard,
      .settingsGet,
      .settingsUpdate,
      .statsGet,
      .dumpsCreate,
      .snapshotsCreate,
      .version,
      .keysGet,
      .keysCreate,
      .keysUpdate,
      .keysDelete,
    ]
  }
}
