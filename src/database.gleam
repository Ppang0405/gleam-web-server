import gleam/dynamic/decode
import gleam/io
import gleam/result
import sqlight

/// Type representing the database connection
pub type Connection =
  sqlight.Connection

/// Initializes the database and creates necessary tables
/// 
/// Creates a 'view_stats' table with columns for page name and view count.
/// Returns a Result containing the database connection or an error.
pub fn init() -> Result(Connection, sqlight.Error) {
  use conn <- result.try(sqlight.open("data.db"))

  let create_table_sql =
    "
    CREATE TABLE IF NOT EXISTS view_stats (
      page TEXT PRIMARY KEY,
      count INTEGER DEFAULT 0
    )
  "

  use _result <- result.try(sqlight.exec(create_table_sql, conn))

  // Initialize homepage view count if it doesn't exist
  let init_sql =
    "
    INSERT OR IGNORE INTO view_stats (page, count) 
    VALUES ('homepage', 0)
  "

  use _result <- result.try(sqlight.exec(init_sql, conn))

  io.println("✅ Database initialized successfully")
  Ok(conn)
}

/// Increments the view count for a given page
/// 
/// Parameters:
///   - conn: Database connection
///   - page: The page name to increment views for
/// 
/// Returns the updated view count or an error
pub fn increment_view_count(
  conn: Connection,
  page: String,
) -> Result(Int, sqlight.Error) {
  // Increment the count
  let update_sql =
    "
    UPDATE view_stats 
    SET count = count + 1 
    WHERE page = ?
  "

  use _result <- result.try(sqlight.query(
    update_sql,
    on: conn,
    with: [sqlight.text(page)],
    expecting: decode.success(Nil),
  ))

  // Get the updated count
  get_view_count(conn, page)
}

/// Retrieves the view count for a given page
/// 
/// Parameters:
///   - conn: Database connection
///   - page: The page name to get views for
/// 
/// Returns the view count or 0 if not found
pub fn get_view_count(
  conn: Connection,
  page: String,
) -> Result(Int, sqlight.Error) {
  let select_sql =
    "
    SELECT count FROM view_stats WHERE page = ?
  "

  let count_decoder = {
    use count <- decode.field(0, decode.int)
    decode.success(count)
  }

  use rows <- result.try(sqlight.query(
    select_sql,
    on: conn,
    with: [sqlight.text(page)],
    expecting: count_decoder,
  ))

  case rows {
    [count, ..] -> Ok(count)
    [] -> Ok(0)
  }
}

/// Closes the database connection
/// 
/// Parameters:
///   - conn: Database connection to close
pub fn close(conn: Connection) -> Result(Nil, sqlight.Error) {
  sqlight.close(conn)
}
