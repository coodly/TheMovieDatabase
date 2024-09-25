public struct Details: OptionSet, Sendable {
  public let rawValue : Int
  package let key: String
    
  public init(rawValue: Int, key: String) {
    self.rawValue = rawValue
    self.key = key
  }
    
  public init(rawValue: Int) {
    self.rawValue = rawValue
    self.key = ""
  }
    
  public static let credits = Details(rawValue: 1 << 0, key: "credits")
  public static let similar = Details(rawValue: 1 << 1, key: "similar")
  public static let reviews = Details(rawValue: 1 << 2, key: "reviews")
  public static let translations = Details(rawValue: 1 << 3, key: "translations")
  public static let videos = Details(rawValue: 1 << 4, key: "videos")
  public static let images = Details(rawValue: 1 << 5, key: "images")
    
  package static let allValues: [Details] = [.credits, .similar, .reviews, .translations, .videos, .images]
}
