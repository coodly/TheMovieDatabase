package struct MoviesPage: Codable {
  let page: Int
  let totalPages: Int
  let results: [Movie]

  package var cursor: Cursor<Movie> {
    return Cursor<Movie>(page: page, totalPages: totalPages, items: results)
  }
}
