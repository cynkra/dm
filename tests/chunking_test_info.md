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
- `dm_step_2 <- dm_step_1 %>% [next 100 operations]`
- `dm_step_2 %>% [remaining operations]`

## Implementation

The fix is in R/paste.R:
1. `dm_paste_impl()` collects all operations and counts them
2. `dm_paste_chunk_operations()` splits operations into chunks if needed
3. Chunks are combined with intermediate variable assignments

## Verification

To test the fix:
1. Create a dm with many tables and relationships (>50 tables)
2. Call dm_paste()
3. Check if output contains "dm_step_" variables when operation count > 100

## Compatibility

- Works with both magrittr pipe (%>%) and base R pipe (|>)
- Threshold is configurable (default: 100 operations per chunk)
- Maintains backward compatibility for small dm objects
- Generated code is valid R that can be executed

## Manual Test

```r
# Create large dm
large_dm <- dm()
for (i in 1:55) {
  table_name <- paste0("table_", i)
  large_dm <- large_dm %>% 
    dm(!!table_name := tibble(id = integer(0), main_id = integer(0))) %>%
    dm_add_pk(!!table_name, id) %>%
    dm_add_fk(!!table_name, main_id, main)
}

# Test chunking
output <- capture.output(dm_paste(large_dm))
any(grepl("dm_step_", output))  # Should be TRUE
```