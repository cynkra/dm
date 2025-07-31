# Test for dm_paste() chunking functionality

This test verifies that the dm_paste() function correctly chunks long pipe chains
into smaller segments to avoid C stack overflow errors and improve readability.

## Test case

Create a dm with 55+ tables, each having a primary key and foreign key relationship.
This should generate 165+ operations (55 PKs + 55 FKs + 1 main PK + extras),
which exceeds the chunking threshold of 100.

## Expected behavior

With the fix, dm_paste() should generate:
- `dm_step_1 <- dm(...) %>% [first 100 operations]`
- `dm_step_1 %>% [remaining operations]`

## Implementation

The fix is in R/paste.R:
1. `dm_paste_impl()` collects all operations and counts them
2. `dm_paste_chunk_operations()` splits operations into chunks if needed
3. Chunks are combined with intermediate variable assignments

## Verification

To test the fix:
1. Create a dm with many tables and relationships
2. Call dm_paste()
3. Check if output contains "dm_step_" variables when operation count > 100