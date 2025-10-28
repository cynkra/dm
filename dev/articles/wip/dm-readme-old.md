# 

{dm} is an R package that provides tools for working with multiple
related tables, stored as data frames or in a relational database.

## Background

Relational databases and flat tables, like data frames or spreadsheets,
present data in fundamentally different ways.

In data frames and spreadsheets, all data is presented together in one
large table with many rows and columns. This means that the data is
accessible in one location but has the disadvantage that the same values
may be repeated multiple times, resulting in bloated tables with
redundant data. In the worst case scenario, a data frame may have many
rows and columns but only a single value different in each row.

Relational databases, on the other hand, do not keep all data together
but split it into multiple smaller tables. That separation into
sub-tables has several advantages:

- all information is stored only once, avoiding repetition and
  conserving memory
- all information is updated only once and in one place, improving
  consistency and avoiding errors that may result from updating the same
  value in multiple locations
- all information is organized by topic and segmented into smaller
  tables that are easier to handle

Separation of data, thus, helps with data quality, and explains the
continuing popularity of relational databases in production-level data
management.

The downside of this approach is that it is harder to merge together
information from different data sources and to identify which entities
refer to the same object, a common task when modeling or plotting data.
To be mapped uniquely, the entities would need to be designated as
*keys*, and the separate tables collated together through a process
called *joining*.

In R, there already exist packages that support handling inter-linked
tables but the code is complex and requires multiple command sequences.
The goal of the {dm} package is to simplify the data management
processes in R while keeping the advantages of relational data models
and the core concept of splitting one table into multiple tables. In
this way, you can have the best of both worlds: manage your data as a
collection of linked tables, then flatten multiple tables into one for
an analysis with {dplyr} or other packages, on an as-needed basis.

Although {dm} is built upon relational data models, it is not a database
itself. It can work transparently with both relational database systems
and in-memory data, and copy data [from and to
databases](https://cynkra.github.io/dm/articles/dm.html#copy).
