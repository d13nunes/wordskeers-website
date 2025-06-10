# Database Migration v1 to v2

This directory contains the migration script to upgrade the WordSeekr database from v1 to v2 schema.

## Files

- `schema.sql` - Original v1 database schema
- `schema_v2.sql` - New v2 database schema
- `migrationV2.js` - Migration script to upgrade from v1 to v2
- `grids.sqlite` - Current database file (will be backed up during migration)

## Running the Migration

### Prerequisites

Make sure you have the required dependencies installed:

```bash
npm install sqlite3
```

### Execute Migration

Run the migration script:

```bash
node database/migrationV2.js
```

### What the Migration Does

1. **Creates a backup** of your current database as `grids_backup_v1.sqlite`
2. **Adds new columns** to `word_search_grids`:
   - `rows` and `columns` (replacing the single `size` field)
3. **Creates new tables**:
   - `quotes` - for quote-based puzzles
   - `scores` - for tracking player performance
4. **Updates constraints** in `word_placements` table
5. **Migrates existing data** from old score fields to new scores table
6. **Creates performance indexes** for better query performance
7. **Validates** the migration was successful

### Schema Changes Summary

#### v1 → v2 Changes:

**word_search_grids table:**
- ✅ Added: `rows` (INTEGER)
- ✅ Added: `columns` (INTEGER)
- ❌ Removed: `played_at` (moved to scores table)
- ❌ Removed: `time_taken` (moved to scores table)

**New tables:**
- ✅ `quotes` - Quote-based puzzles with grid_id reference
- ✅ `scores` - Player performance tracking with grid_id reference

**word_placements table:**
- ❌ Removed: `quote_id` field (simplified to only reference grids)
- ✅ Updated: Constraints to ensure grid_id is always set

### Safety Features

- **Automatic backup** before any changes
- **Transaction-based** migration (rollback on failure)
- **Validation** after migration
- **Idempotent** - can be run multiple times safely

### Rollback

If you need to rollback, simply restore from the backup:

```bash
cp database/grids_backup_v1.sqlite database/grids.sqlite
```

### Validation

The migration script includes validation that checks:
- All required tables exist
- All required columns exist
- Data integrity is maintained
- Record counts are preserved

## Notes

- The migration preserves all existing data
- Old columns (`played_at`, `time_taken`) are kept for backward compatibility
- You can optionally remove them by uncommenting the relevant lines in the migration script
- The migration assumes the original `size` field represents a square grid (e.g., size=10 means 10x10) 