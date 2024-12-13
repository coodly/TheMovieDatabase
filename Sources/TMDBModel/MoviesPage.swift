public struct MoviesPage: Codable {
  public let page: Int
  public let totalPages: Int
  public let results: [Movie]

  package var cursor: Cursor<Movie> {
    return Cursor<Movie>(page: page, totalPages: totalPages, items: results)
  }
}
