# Devcontainer Setup for dm Package

This directory contains the devcontainer configuration for the dm package development environment.

## Files

- `devcontainer.json` - Main devcontainer configuration
- `docker-compose.yml` - Docker Compose file defining the development services
- `test-postgres.R` - Script to test PostgreSQL connectivity

## Services

### PostgreSQL Database

- **Image**: `postgres:latest` (latest PostgreSQL version)
- **Container**: `devcontainer-postgres`
- **Port**: 5432
- **Database**: test
- **User**: compose
- **Password**: YourStrong!Passw0rd

### MariaDB Database

- **Image**: `mariadb:latest` (latest MariaDB version)
- **Container**: `devcontainer-mariadb`
- **Port**: 3306
- **Database**: test
- **User**: compose
- **Password**: YourStrong!Passw0rd

### SQL Server Database

- **Image**: `mcr.microsoft.com/mssql/server:2022-latest` (SQL Server 2022 Express)
- **Container**: `devcontainer-mssql`
- **Port**: 1433
- **Database**: test (created automatically)
- **User**: SA
- **Password**: YourStrong!Passw0rd

### Features

- Socket connections enabled via shared volume (`/var/run/postgresql`)
- Network connections available on standard ports (5432 for PostgreSQL, 3306 for MariaDB, 1433 for SQL Server)
- Environment variables pre-configured for easy R connections
- Health checks ensure databases are ready before starting dev environment
- Service-specific host environment variables for targeted testing

## Usage

1. Open the project in VS Code
2. When prompted, reopen in devcontainer (or use Command Palette > "Dev Containers: Reopen in Container")
3. All database services (PostgreSQL, MariaDB, SQL Server) will start automatically
4. Test connectivity by running: `Rscript .devcontainer/test-postgres.R`

### Running Tests with Different Backends

```bash
# Test with PostgreSQL (default)
DM_TEST_SRC=postgres R -e 'testthat::test_local()'

# Test with MariaDB
DM_TEST_SRC=maria R -e 'testthat::test_local()'

# Test with SQL Server (requires ODBC drivers)
DM_TEST_SRC=mssql R -e 'testthat::test_local()'

# Test with data frames (no database)
DM_TEST_SRC=df R -e 'testthat::test_local()'
```

## Database Connection in R

The devcontainer environment supports multiple connection methods:

### PostgreSQL

```r
# Using environment variables (recommended)
con <- DBI::dbConnect(RPostgres::Postgres())

# Using explicit parameters
con <- DBI::dbConnect(
  RPostgres::Postgres(),
  host = "postgres",
  port = 5432,
  user = "compose",
  password = "YourStrong!Passw0rd",
  dbname = "test"
)

# Using socket connection (if available)
con <- DBI::dbConnect(
  RPostgres::Postgres(),
  host = "/var/run/postgresql",
  user = "compose",
  dbname = "test"
)
```

### MariaDB

```r
# Using explicit parameters
con <- DBI::dbConnect(
  RMariaDB::MariaDB(),
  host = "mariadb",
  port = 3306,
  username = "compose",
  password = "YourStrong!Passw0rd",
  dbname = "test"
)
```

### SQL Server

```r
# Using explicit parameters (requires ODBC drivers)
con <- DBI::dbConnect(
  odbc::odbc(),
  driver = "ODBC Driver 18 for SQL Server",
  server = "mssql",
  database = "test",
  uid = "SA",
  pwd = "YourStrong!Passw0rd",
  port = 1433,
  TrustServerCertificate = "yes"
)
```

## Environment Variables

The following environment variables are set in the devcontainer:

### PostgreSQL

- `PGHOST=postgres`
- `PGPORT=5432`
- `PGUSER=compose`
- `PGPASSWORD=YourStrong!Passw0rd`
- `PGDATABASE=test`
- `PGSOCKET=/var/run/postgresql`

### MariaDB

- `MYSQL_HOST=mariadb`
- `MYSQL_PORT=3306`
- `MYSQL_USER=compose`
- `MYSQL_PASSWORD=YourStrong!Passw0rd`
- `MYSQL_DATABASE=test`

### SQL Server

- `MSSQL_HOST=mssql`
- `MSSQL_PORT=1433`
- `MSSQL_USER=SA`
- `MSSQL_PASSWORD=YourStrong!Passw0rd`
- `MSSQL_DATABASE=test`

### Testing

- `DM_TEST_POSTGRES_HOST=postgres` (service-specific, takes precedence)
- `DM_TEST_MARIA_HOST=mariadb` (service-specific, takes precedence)
- `DM_TEST_MSSQL_HOST=mssql` (service-specific, takes precedence)

## Troubleshooting

1. **Database not starting**: Check if ports 5432 (PostgreSQL) or 3306 (MariaDB) are already in use on your host
2. **Connection failures**: Run the test script to diagnose connection issues
3. **Permission issues**: The PostgreSQL socket directory is configured with 0777 permissions
4. **Container conflicts**: Ensure no other database containers are running with the same names
5. **Environment variables not updated**: Use `devcontainer up --workspace-folder . --remove-existing-container` to recreate containers

## Notes

- Database data is persisted in Docker volumes (`postgres-data`, `mariadb-data`)
- Socket connections are available for PostgreSQL through the shared `postgres-socket` volume
- PostgreSQL includes `pg_stat_statements` extension for performance monitoring
- All PostgreSQL SQL statements are logged for development debugging
- MariaDB is configured with health checks to ensure availability before tests run
- Service-specific environment variables allow targeted testing of individual database backends
