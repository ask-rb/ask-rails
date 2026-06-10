# ask-rails — Rails Integration

## Purpose

The only gem a Rails app needs to join the ask-rb ecosystem. Provides:
- **Railtie** (not Engine — no routes, no UI, no views to mount)
- **AR session persistence** — save/load agent sessions to the database
- **Session factory** — `Ask::Rails.agent_session` creates a pre-configured agent
- **Service gem discovery** — auto-discovers installed `ask-*` gems, reads their context modules, injects them into the system prompt
- **Generators** — `rails generate ask_rails:install`
- **Configuration** — `config.ask_rails.default_model`, `max_turns`, etc.
- **Rails-aware tools** — `ReadFile`, `RunCommand`, `SearchCodebase`, `ReadRoute`,
  **`QueryDatabase`**, **`ReadModel`**, **`ReadLog`**

## Dependencies

- **Runtime:** `rails >= 7.1`, `ask-core`, `ask-tools`, `ask-tools-shell`, `ask-agent`, `ask-auth`
- **Build/test:** minitest, mocha, rake, sqlite3

## Current State

The gem is at v0.1.0 on RubyGems with the following already built:
- Railtie ✅
- AR persistence ✅
- Session factory ✅
- Service gem discovery ✅
- Generators ✅
- Configuration ✅
- `ReadFile` tool ✅
- `RunCommand` tool ✅
- `SearchCodebase` tool ✅
- `ReadRoute` tool ✅

## What Needs to Be Built — v0.2.0

Three new Rails-aware tools that give agents deep access to a running Rails app.
Each tool lives in `lib/ask/rails/tools/` and inherits from `Ask::Rails::Tool < Ask::Tool`.

---

### Tool 1: `Ask::Rails::QueryDatabase`

**Why ReadFile isn't enough:** The agent could read `config/database.yml` and use the Code tool to run SQL, but it would need to establish a connection, handle the connection pool, format results, and worry about write queries in production. This tool does all that correctly in one call.

**Implementation** (`lib/ask/rails/tools/query_database.rb`):

```ruby
class Ask::Rails::QueryDatabase < Ask::Rails::Tool
  description "Run a read-only SQL query against the application database. " \
               "Returns columns and rows. Only SELECT is allowed in production."

  param :sql,    type: :string, desc: "SQL query (SELECT only in production)", required: true
  param :limit,  type: :integer, desc: "Max rows to return", required: false
end
```

**Key behaviors:**
- In production, reject any query that doesn't match `/\A\s*SELECT\b/i`
- Use `ActiveRecord::Base.connection_pool.with_connection` for thread safety
- Auto-append `LIMIT` if not present (default 50)
- Return `{ columns: [...], rows: [...], count: N }`
- Rescue `ActiveRecord::StatementInvalid` with the SQL error message
- Never run `INSERT`, `UPDATE`, `DELETE`, `DROP`, `TRUNCATE`, `ALTER` in any environment

**Edge cases to handle:**
- Connection pool timeout (wait, retry once, then fail with clear message)
- Queries returning 10,000+ rows (truncate to limit)
- Binary/bytea columns (exclude from results or Base64 encode)
- ActiveRecord not connected (app may be in `rails console` or `db:drop` state)
- `PG::Error` vs `Mysql2::Error` vs `SQLite3::Exception` — ruby_llm-schema normalizes these away

---

### Tool 2: `Ask::Rails::ReadModel`

**Why ReadFile isn't enough:** Reading `app/models/user.rb` gives raw Ruby. `ReadModel` introspects the class via ActiveRecord's reflection API and returns structured data the agent can act on immediately.

**Implementation** (`lib/ask/rails/tools/read_model.rb`):

```ruby
class Ask::Rails::ReadModel < Ask::Rails::Tool
  description "Inspect an ActiveRecord model — attributes, associations, " \
               "validations, scopes, indexes, and callbacks."

  param :name,   type: :string, desc: "Model class name (e.g. 'User', 'Blog::Post')", required: true
  param :detail, type: :string, desc: "Which details: 'all' (default), 'columns', 'associations', 'validations'", required: false
end
```

**Return format:**
```json
{
  "name": "User",
  "table_name": "users",
  "columns": [
    { "name": "id", "type": "integer", "null": false, "default": null, "primary_key": true },
    { "name": "email", "type": "string", "null": false, "default": null },
    { "name": "admin", "type": "boolean", "null": true, "default": false }
  ],
  "associations": {
    "has_many": [{ "name": "posts", "class_name": "Post", "foreign_key": "user_id" }],
    "belongs_to": [{ "name": "account", "class_name": "Account", "foreign_key": "account_id" }]
  },
  "validations": [
    { "attribute": "email", "type": "presence" },
    { "attribute": "email", "type": "uniqueness", "options": { "case_sensitive": false } }
  ],
  "scopes": [{ "name": "active", "lambda": "-> { where(active: true) }" }]
}
```

**Key behaviors:**
- Use `model.constantize` to resolve the class
- Use `model.columns_hash`, `model.reflect_on_all_associations`, `model.validators` etc.
- Handle: model not found, STI models, namespaced models (`Blog::Post`)
- If `detail: "columns"` is given, only return column info (useful for large models)

**Edge cases:**
- Model class doesn't exist -> clear error with similar model names suggested
- Model has 50+ columns -> truncate or paginate
- Abstract classes (`self.abstract_class = true`) -> note in response
- `attr_accessor` vs database columns -> only show DB columns
- Single Table Inheritance — show `inheritance_column` and subclasses

---

### Tool 3: `Ask::Rails::ReadLog`

**Why ReadFile isn't enough:** Production logs are huge and rotate. `ReadFile` hits a 2000-line limit on a file with 50,000 lines. `ReadLog` can filter by level, time range, and search term server-side.

**Implementation** (`lib/ask/rails/tools/read_log.rb`):

```ruby
class Ask::Rails::ReadLog < Ask::Rails::Tool
  description "Read application log files with filtering. Supports Rails default " \
               "logger and log rotation."

  param :lines,      type: :integer, desc: "Number of recent lines (default 50, max 500)", required: false
  param :level,      type: :string, desc: "Filter by level: 'ERROR', 'WARN', 'INFO', 'DEBUG'", required: false
  param :search,     type: :string, desc: "Search term (plain text or regex)", required: false
  param :file,       type: :string, desc: "Log file name (default: log/production.log or log/development.log)", required: false
end
```

**Key behaviors:**
- Determine Rails.env and pick the right log file automatically
- Use `Rails.root.join("log/#{env}.log")` as default
- Handle log rotation — read the current file plus `.1` `.2` etc. rotated archives
- Read from the end of the file (reverse seek) for recent lines
- Filter by level: `ERROR`, `WARN`, `INFO`, `DEBUG` (match against logfmt pattern)
- Filter by search term (case-insensitive match)
- Max 500 lines returned (configurable limit in tool definition)

**Edge cases:**
- Log file doesn't exist -> return empty with explanation
- Log file is huge (1GB+) -> read from the end only, warn about truncated output
- Log rotation with gzip (.gz) -> handle with `zlib`
- Custom logger (Lograge, Semantic Logger, etc.) -> note that parsing works for default Rails logger, custom formats may reduce filter accuracy
- No read permission -> clear error, suggest checking file permissions
- JSON logger (rails 8+) -> parse JSON lines and return structured format

---

## Implementation Steps (for all 3 tools)

1. Create each tool file in `lib/ask/rails/tools/`
2. Require them in the entry point so they're auto-discovered by the Railtie
3. Write tests for each tool (see Testing below)
4. Update `lib/ask-rails.rb` or `lib/ask/rails.rb` to require the new tool files
5. Update the completion checklist below

## Testing

### QueryDatabase tests
- Test with SQLite3 in-memory database (the test dummy app should have this)
- Create a test table, insert data, query it
- Test: simple SELECT, SELECT with LIMIT, SELECT without LIMIT (should be added)
- Test: INSERT rejected (raise clear error, even in test)
- Test: malformed SQL returns ActiveRecord::StatementInvalid error
- Test: connection pool timeout (mock to verify error message)
- Test: empty results, single row, multiple rows
- Test: production guard — verify non-SELECT queries are rejected

### ReadModel tests
- Create test models within the dummy app
- Test: column listing (name, type, null, default, primary_key)
- Test: associations (has_many, belongs_to, has_one, has_and_belongs_to_many)
- Test: validators (presence, uniqueness, numericality, length, custom)
- Test: scopes
- Test: model not found (wrong name)
- Test: namespaced model (e.g., `Admin::User`)
- Test: STI model
- Test: detail: "columns" returns only column info
- Test: abstract class

### ReadLog tests
- Create a temporary log file with known content
- Test: reads recent N lines from the end
- Test: filters by level (ERROR, WARN, INFO)
- Test: filters by search term
- Test: file not found returns empty
- Test: handles rotated log files (`.log.1`, `.log.2.gz`)
- Test: respects max lines limit
- Test: JSON logger format (Rails 8+)

## Version & Release

1. Bump version to `0.2.0` in `lib/ask/rails/version.rb`
2. Update `CHANGELOG.md`:
   ```markdown
   ## 0.2.0 (YYYY-MM-DD)

   ### Added
   - Ask::Rails::QueryDatabase — read-only SQL queries via ActiveRecord
   - Ask::Rails::ReadModel — structured model introspection (columns, associations, validations)
   - Ask::Rails::ReadLog — filtered log reading with level and search filters
   ```
3. Commit and push: `git commit -m "feat: add QueryDatabase, ReadModel, ReadLog tools"`
4. Build: `gem build ask-rails.gemspec`
5. Release: `gem push ask-rails-0.2.0.gem`
6. Tag: `git tag v0.2.0 && git push --tags`
7. Update ask-docs with the new tools

## Completion Checklist

- [ ] QueryDatabase tool implemented and tested
  - [ ] SELECT works, INSERT/UPDATE/DELETE rejected
  - [ ] Production guard enforced
  - [ ] Limit auto-applied
  - [ ] Connection pool errors handled
- [ ] ReadModel tool implemented and tested
  - [ ] Columns listed with full metadata
  - [ ] Associations shown
  - [ ] Validations shown
  - [ ] Scopes shown
  - [ ] STI/namespaced handled
  - [ ] Model not found handled
- [ ] ReadLog tool implemented and tested
  - [ ] Reads from end of file
  - [ ] Level filtering works
  - [ ] Search filtering works
  - [ ] Rotation files handled
  - [ ] Missing file handled
- [ ] All tests pass with >90% coverage
- [ ] Version bumped to 0.2.0
- [ ] CHANGELOG updated
- [ ] Released to RubyGems
- [ ] Tagged with v0.2.0
- [ ] ask-docs updated with new tool documentation
