Storing all data related to a problem in a single table or data frame ("the dataset") can result in many repetitive values. Separation into multiple tables helps data quality but poses a different challenge: if information from different tables is required jointly, a "merge" or "join" operation must be carried out. {dm} is a new package that fills a gap in the R ecosystem: it makes working with multiple tables just as easy as working with a single table.

In the relational database model, a "data model" consists of:

- tables (both the definition and the data),

- primary and foreign key constraints.

Primary keys uniquely identify rows in a table. Foreign keys establish a link between rows in two tables. The {dm} package combines these concepts with data manipulation powered by the tidyverse: entire data models are handled in a single entity, a "dm" object.

Data models are defined by combining a set of tables and establishing relationships through primary and foreign key constraints. The {dm} package also provides tools for normalization (decomposition into multiple tables). Once a "dm" is defined, the following transformations can be applied:

- Basic data manipulation on individual tables: adding, removing or renaming columns, filtering, aggregation

- Joins: combining multiple tables into one

All transformations take relationships between tables into account. For example, the filter operation also affects related tables.

"dm" objects are storage agnostic, they work efficiently with in-memory data and with databases, and can be copied from and to databases.

Use cases for the {dm} package include a Shiny application that supports complex filters across multiple tables, and processing a data model with ~10⁹ rows on a MSSQL database.

In this presentation, Kirill introduces the basics of relational data models, demonstrates the most important features of the {dm} package, and presents a few use cases.
