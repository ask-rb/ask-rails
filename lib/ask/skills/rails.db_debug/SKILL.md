---
name: rails.db_debug
description: Step-by-step methodology for debugging database performance issues in Rails
---

Use this skill when investigating slow queries, N+1 problems, missing indexes, or
general database performance issues in a Rails application.

## Step 1: Identify the Slow Queries

Use `ReadLog.new.call(lines: 200, search: "SELECT")` to find recent database
queries in the application log. Look for:

- Queries taking > 100ms (look for "duration:" or "↳" markers in Rails logs)
- Repetitive queries with the same structure (potential N+1)
- Queries running in loops (same query, different IDs)

If you need more detail, narrow the search: `ReadLog.new.call(lines: 500, level: "WARN")`.

## Step 2: Understand the Schema

For each model involved in the slow queries, inspect it:

```ruby
ReadModel.new.call(name: "User")
ReadModel.new.call(name: "Post")
```

Focus on:
- **Columns** — are there columns that look like foreign keys without indexes?
- **Associations** — what associations exist and what `class_name` do they use?
- **Validators** — any database-level constraints that could be missing?

Run `ReadModel.new.call(name: "User", detail: "columns")` if you only need columns.

## Step 3: Check for Missing Indexes

Query the database for actual indexes:

```ruby
QueryDatabase.new.call(
  sql: "SELECT tablename, indexname, indexdef FROM pg_indexes WHERE schemaname = 'public' ORDER BY tablename, indexname",
  limit: 200
)
```

Look for:
- Foreign key columns that lack indexes (e.g. `user_id` without index)
- Columns used in `WHERE` clauses without indexes
- Composite indexes that could cover multiple query patterns

If an index is missing, check if adding one would help:
```ruby
QueryDatabase.new.call(
  sql: "EXPLAIN ANALYZE SELECT * FROM posts WHERE user_id = 1",
  limit: 10
)
```

## Step 4: Detect N+1 Queries

N+1 manifests as the same query repeated with different IDs:

```ruby
# Search for repetitive query patterns
ReadLog.new.call(lines: 500, search: "WHERE.*IN")
```

Common N+1 patterns:
- Loading `Post.all` then accessing `post.comments` individually
- Loading `User.all` then accessing `user.profile` individually
- Serializing associations in views without eager loading

Fix with `.includes(:association)`, `.eager_load(:association)`, or
`.preload(:association)`.

## Step 5: Profile Slow Queries with EXPLAIN

For any identified slow query, get the execution plan:

```ruby
QueryDatabase.new.call(
  sql: "EXPLAIN (ANALYZE, BUFFERS) SELECT posts.* FROM posts WHERE posts.user_id = 1 ORDER BY posts.created_at DESC LIMIT 20",
  limit: 10
)
```

What to look for in explain output:
- **Sequential scans** (`Seq Scan`) — missing index
- **Sort operations** — missing index on sort column
- **Nested loop joins** with high row counts — missing composite index
- **Bitmap heap scans** with high costs — index may be suboptimal

If `ANALYZE` takes too long, use `EXPLAIN (BUFFERS)` without `ANALYZE` for cost estimates.

## Step 6: Check Bulk Loading and Batch Operations

If the issue involves importing or updating many records:

```ruby
QueryDatabase.new.call(
  sql: "SELECT schemaname, tablename, seq_scan, seq_tup_read, idx_scan, idx_tup_fetch FROM pg_stat_user_tables ORDER BY seq_scan DESC",
  limit: 20
)
```

High `seq_scan` counts compared to `idx_scan` indicate tables where indexes
are missing and sequential scans are happening frequently.

## Failure Mode Guide

| Symptom | Likely Cause | Action |
|---------|-------------|--------|
| Query takes >1s | Missing index on WHERE column | Check pg_indexes, add index |
| Same query 50x in log | N+1 in controller/view | Add `.includes()` |
| Query slow AFTER adding index | Wrong index type or order | Verify index column order matches query |
| `EXPLAIN ANALYZE` hanging | Table lock or very large table | Use `EXPLAIN (BUFFERS)` without ANALYZE |
| Missing `pg_indexes` output | Not Postgres | Use `SHOW INDEX FROM <table>` for MySQL |
