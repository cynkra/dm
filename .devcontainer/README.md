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

### Features

- Socket connections enabled via shared volume (`/var/run/postgresql`)
- Network connections available on standard port 5432
- Environment variables pre-configured for easy R connections
- Health checks to ensure database is ready before starting dev environment

## Usage

1. Open the project in VS Code
2. When prompted, reopen in devcontainer (or use Command Palette > "Dev Containers: Reopen in Container")
3. The PostgreSQL database will start automatically
4. Test connectivity by running: `Rscript .devcontainer/test-postgres.R`

## Database Connection in R

The devcontainer environment supports multiple connection methods:

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

## Environment Variables

The following environment variables are set in the devcontainer:

- `PGHOST=postgres`
- `PGPORT=5432`
- `PGUSER=compose`
- `PGPASSWORD=YourStrong!Passw0rd`
- `PGDATABASE=test`
- `PGSOCKET=/var/run/postgresql`
- `DM_TEST_DOCKER_HOST=postgres`

## Troubleshooting

1. **Database not starting**: Check if port 5432 is already in use on your host
2. **Connection failures**: Run the test script to diagnose connection issues
3. **Permission issues**: The PostgreSQL socket directory is configured with 0777 permissions
4. **Container conflicts**: Ensure no other PostgreSQL containers are running with the same name

## Notes

- The PostgreSQL data is persisted in a Docker volume (`postgres-data`)
- Socket connections are available through the shared `postgres-socket` volume
- The database includes `pg_stat_statements` extension for performance monitoring
- All SQL statements are logged for development debugging
