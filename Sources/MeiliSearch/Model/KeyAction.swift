///Documentation: https://www.meilisearch.com/docs/reference/api/keys#actions
public enum KeyAction: Equatable {
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
}

public extension KeyAction {
  init(_ value: String) {
    self = switch value {
    case "*":
      .wildcard
    case "search":
      .search
    case "documents.*":
      .documentsWildcard
    case "documents.add":
      .documentsAdd
    case "documents.get":
      .documentsGet
    case "documents.delete":
      .documentsDelete
    case "indexes.*":
      .indexesWildcard
    case "indexes.create":
      .indexesCreate
    case "indexes.get":
      .indexesGet
    case "indexes.update":
      .indexesUpdate
    case "indexes.delete":
      .indexesDelete
    case "indexes.swap":
        .indexesSwap
    case "tasks.*":
        .tasksWildcard
    case "tasks.get":
        .tasksGet
    case "tasks.cancel":
        .tasksCancel
    case "tasks.delete":
        .tasksDelete
    case "settings.*":
        .settingsWildcard
    case "settings.get":
        .settingsGet
    case "settings.update":
        .settingsUpdate
    case "stats.get":
        .statsGet
    case "dumps.create":
        .dumpsCreate
    case "snapshots.create":
        .snapshotsCreate
    case "version":
        .version
    case "keys.get":
        .keysGet
    case "keys.create":
        .keysCreate
    case "keys.update":
        .keysUpdate
    case "keys.delete":
        .keysDelete
    default:
        .unknown(value)
    }
  }
  
  var value: String {
    switch self {
    case .wildcard:
      "*"
    case .search:
      "search"
    case .documentsWildcard:
      "documents.*"
    case .documentsAdd:
      "documents.add"
    case .documentsGet:
      "documents.get"
    case .documentsDelete:
      "documents.delete"
    case .indexesWildcard:
      "indexes.*"
    case .indexesCreate:
      "indexes.create"
    case .indexesGet:
      "indexes.get"
    case .indexesUpdate:
      "indexes.update"
    case .indexesDelete:
      "indexes.delete"
    case .indexesSwap:
      "indexes.swap"
    case .tasksWildcard:
      "tasks.*"
    case .tasksGet:
      "tasks.get"
    case .tasksCancel:
      "tasks.cancel"
    case .tasksDelete:
      "tasks.delete"
    case .settingsWildcard:
      "settings.*"
    case .settingsGet:
      "settings.get"
    case .settingsUpdate:
      "settings.update"
    case .statsGet:
      "stats.get"
    case .dumpsCreate:
      "dumps.create"
    case .snapshotsCreate:
      "snapshots.create"
    case .version:
      "version"
    case .keysGet:
      "keys.get"
    case .keysCreate:
      "keys.create"
    case .keysUpdate:
      "keys.update"
    case .keysDelete:
      "keys.delete"
    case .unknown(let string):
      string
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
