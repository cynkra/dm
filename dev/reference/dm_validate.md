# Validator

`dm_validate()` checks the internal consistency of a `dm` object.

## Usage

``` r
dm_validate(x)
```

## Arguments

- x:

  An object.

## Value

Returns the `dm`, invisibly, after finishing all checks.

## Details

In theory, with the exception of
[`new_dm()`](https://dm.cynkra.com/dev/reference/dm.md), all `dm`
objects created or modified by functions in this package should be
valid, and this function should not be needed. Please file an issue if
any dm operation creates an invalid object.

## Examples

``` r
dm_validate(dm())

bad_dm <- structure(list(bad = "dm"), class = "dm")
try(dm_validate(bad_dm))
#> Error in abort_dm_invalid("A `dm` needs to be a list of one item named `def`.") : 
#>   This `dm` is invalid, reason: A `dm` needs to be a list of one item named `def`.
```
