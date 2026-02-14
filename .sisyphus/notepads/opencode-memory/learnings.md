# Opencode Memory Plugin — Learnings

## Session: ses_3a5a47a05ffeoNYfz2RARYsHX9
Started: 2026-02-14

### Architecture Decisions
- SQLite + FTS5 + vec0 replaces mem0+qdrant entirely
- Markdown at ~/CODEX/80-memory/ is source of truth
- SQLite DB at ~/.local/share/opencode-memory/index.db is derived index
- OpenAI text-embedding-3-small for embeddings (1536 dimensions)
- Hybrid search: 0.7 vector weight + 0.3 BM25 weight
- Chunking: 400 tokens, 80 overlap (tiktoken cl100k_base)

### Key Patterns from Openclaw
- MemoryIndexManager pattern (1590 lines) — file watching, chunking, indexing
- Hybrid scoring with weighted combination
- Embedding cache by content_hash + model
- Two sources: "memory" (markdown files) + "sessions" (transcripts)
- Two tools: memory_search (hybrid query) + memory_get (read lines)

### Technical Stack
- Runtime: bun
- Test framework: bun test (TDD)
- SQLite: better-sqlite3 (synchronous API)
- Embeddings: openai npm package
- Chunking: tiktoken (cl100k_base encoding)
- File watching: chokidar
- Validation: zod (for tool schemas)

### Vec0 Extension Findings (Task 1)
- **vec0 extension**: NOT AVAILABLE - requires vec0.so shared library not present
- **Alternative solution**: sqlite-vec package (v0.1.7-alpha.2) successfully tested
- **Loading mechanism**: `sqliteVec.load(db)` loads vector extension into database
- **Test result**: Works with Node.js (better-sqlite3 native module compatible)
- **Note**: better-sqlite3 does NOT work with Bun runtime (native module incompatibility)
- **Testing command**: `node -e "const Database = require('better-sqlite3'); const sqliteVec = require('sqlite-vec'); const db = new Database(':memory:'); sqliteVec.load(db); console.log('OK')"`

### Bun Runtime Limitations
- better-sqlite3 native module NOT compatible with Bun (ERR_DLOPEN_FAILED)
- Use Node.js for any code requiring better-sqlite3
- Alternative: bun:sqlite API (similar API, but not same library)

## Wave Progress
- Wave 1: IN PROGRESS (Task 1)
- Wave 2-6: PENDING

### Configuration Module Implementation (Task: Config Module)
- **TDD approach**: RED-GREEN-REFACTOR cycle successfully applied
- **Pattern**: Default config object + resolveConfig() function for merging
- **Path expansion**: `expandPath()` helper function handles `~` → `$HOME` expansion
- **Test coverage**: 10 tests covering defaults, overrides, path expansion, and config merging
- **TypeScript best practices**: Proper type exports from types.ts, type imports in config.ts
- **Defaults match openclaw**: chunking (400/80), search weights (0.7/0.3), minScore (0.35), maxResults (6)
- **Bun test framework**: Fast execution (~20ms for 10 tests), clean output

### Database Schema Implementation (Task 2)
- **TDD approach**: RED-GREEN-REFACTOR cycle successfully applied for db module
- **Schema tables**: meta, files, chunks, embedding_cache, chunks_fts (FTS5), chunks_vec (vec0)
- **WAL mode**: Enabled via `db.pragma('journal_mode = WAL')` for better concurrency
- **Foreign keys**: Enabled via `db.pragma('foreign_keys = ON')`
- **sqlite-vec integration**: Loaded via `sqliteVec.load(db)` for vector search capabilities
- **FTS5 virtual table**: External content table referencing chunks for full-text search
- **vec0 virtual table**: 1536-dimension float array for OpenAI text-embedding-3-small embeddings
- **Test execution**: Use Node.js with tsx for TypeScript execution (not Bun runtime)
- **Buffer handling**: Float32Array must be converted to Buffer via `Buffer.from(array.buffer)` for SQLite binding
- **In-memory databases**: WAL mode returns 'memory' for :memory: DBs, 'wal' for file-based DBs
- **Test coverage**: 9 tests covering table creation, data insertion, FTS5, vec0, WAL mode, and clean closure
- **Error handling**: better-sqlite3 throws "The database connection is not open" for operations on closed DBs

### Node.js Test Execution
- **Issue**: better-sqlite3 not compatible with Bun runtime (native module)
- **Solution**: Use Node.js with tsx (TypeScript executor) for running tests
- **Command**: `npx tsx --test src/__tests__/db.test.ts`
- **Node.test API**: Uses `describe`, `it`, `before`, `after` from 'node:test' module
- **Assertions**: Use `assert` from 'node:assert' module
- **Cleanup**: Use `after()` hooks for database cleanup, not `afterEach()` (node:test difference)

### Embedding Provider Implementation (Task: Embeddings Module)
- **TDD approach**: RED-GREEN-REFACTOR cycle successfully applied for embeddings module
- **Mock database**: Created in-memory mock for testing since better-sqlite3 incompatible with Bun
- **Float32 precision**: embeddings stored/retrieved via Float32Array has limited precision (use toBeCloseTo in tests)
- **Cache implementation**: content_hash + model composite key in embedding_cache table
- **Retry logic**: Exponential backoff (1s, 2s, 4s) for 429/500 errors, max 3 retries
- **Test coverage**: 11 tests covering embed(), embedBatch(), cache hits/misses, API failures, retries, buffer conversion
- **Helper functions**: embeddingToBuffer() and bufferToEmbedding() for Float32Array ↔ Buffer conversion
- **Bun spyOn**: Use mockClear() to reset call count without replacing mock implementation
- **Buffer size**: Float32 embedding stored as Buffer with size = dimensions * 4 bytes

### FTS5 BM25 Search Implementation (Task: FTS5 Search Module)
- **TDD approach**: RED-GREEN-REFACTOR cycle successfully applied for search module
- **buildFtsQuery()**: Extracts alphanumeric tokens via regex `/[A-Za-z0-9_]+/g`, quotes them, joins with AND
- **FTS5 escaping**: Tokens are quoted to handle special characters (e.g., `"term"`)
- **BM25 score normalization**: `bm25RankToScore(rank)` converts BM25 rank to 0-1 score using `1 / (1 + normalized)`
- **FTS5 external content tables**: The schema uses `content='chunks', content_rowid='rowid'` but requires manual insertion into chunks_fts
- **Test data setup**: Must manually insert into chunks_fts after inserting into chunks (external content doesn't auto-populate)
- **BM25 ranking**: Results are ordered by `rank` column (lower rank = better match for FTS5)
- **Error handling**: searchFTS catches SQL errors and returns empty array (graceful degradation)
- **MaxResults parameter**: Respects LIMIT clause in SQL query
- **SearchResult interface**: Includes id, filePath, startLine, endLine, text, contentHash, source, score (all required)
- **Prefix matching**: FTS5 supports prefix queries automatically via token matching (e.g., "test" matches "testing")
- **No matches**: Returns empty array when query has no valid tokens or no matches found
- **Test coverage**: 7 tests covering basic search, exact keywords, partial words, no matches, ranking, maxResults, and metadata

### Hybrid Search Implementation (Task: Hybrid Search Combiner)
- **TDD approach**: RED-GREEN-REFACTOR cycle successfully applied for hybrid search
- **Weighted scoring**: Combined score = vectorWeight * vectorScore + textWeight * textScore (default: 0.7/0.3)
- **Result merging**: Uses Map<string, HybridSearchResult> to merge results by chunk ID, preventing duplicates
- **Dual-score tracking**: Each result tracks both vectorScore and textScore separately, allowing for degraded modes
- **Graceful degradation**: Works with FTS5-only (vector search fails) or vector-only (FTS5 fails)
- **minScore filtering**: Results below minScore threshold are filtered out after score calculation
- **Score sorting**: Results sorted by combined score in descending order before applying maxResults limit
- **Vector search fallback**: searchVector catches errors and returns empty array, allowing FTS5-only operation
- **FTS5 query fallback**: searchFTS catches SQL errors and returns empty array, allowing vector-only operation
- **Database cleanup**: beforeEach must delete from chunks_fts, chunks_vec, chunks, and files to avoid state bleed
- **Virtual table corruption**: Deleting from FTS5/vec0 virtual tables can cause corruption - use try/catch to recreate
- **SearchResult type conflict**: SearchResult is imported from types.ts, don't re-export in search.ts
- **Test isolation**: Virtual tables (chunks_fts, chunks_vec) must be cleared and potentially recreated between tests
- **Buffer conversion**: queryEmbedding converted to Buffer via Buffer.from(new Float32Array(array).buffer)
- **Debug logging**: process.env.DEBUG_SEARCH flag enables detailed logging of FTS5 and vector search results
- **Test coverage**: 9 tests covering combination, weighting, minScore filtering, deduplication, sorting, maxResults, degraded modes (FTS5-only, vector-only), and custom weights
