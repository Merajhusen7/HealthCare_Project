# Healthcare Patient Booking Database

A database design for a healthcare system used by patients to:

- Create online accounts or be registered for in-person visits.
- Search and book doctors.
- Schedule consultations, checkups, laboratory tests, and imaging services.
- Submit service requests.
- View appointment status and released test results.
- Access support for multiple facilities and specialties.

## Project Contents

| File | Purpose |
|---|---|
| [ER_DIAGRAM.mmd](ER_DIAGRAM.mmd) | Full Mermaid ER diagram |
| [ER_DIAGRAM_CORE.mmd](ER_DIAGRAM_CORE.mmd) | Smaller patient-focused Mermaid ER diagram |
| [VIEW_THE_DIAGRAM.md](VIEW_THE_DIAGRAM.md) | Instructions for viewing and reading the diagrams |
| [docker-compose.yml](docker-compose.yml) | PostgreSQL and pgAdmin containers |
| [sql/01_schema.sql](sql/01_schema.sql) | PostgreSQL table definitions |
| [sql/00_snowflake_schema.sql](sql/00_snowflake_schema.sql) | Snowflake table definitions |
| [.env.example](.env.example) | Default environment variable template |
| [README_DATABASE.md](README_DATABASE.md) | Database-specific setup and Snowflake notes |

## Run the Local Database

Docker Desktop must be installed and running.

From the project directory:

```powershell
Copy-Item .env.example .env
docker compose up -d
```

The initial schema is loaded automatically with no demo or seed data.

## Services

| Service | Address | Purpose |
|---|---|---|
| PostgreSQL | `localhost:5432` | Healthcare database |
| pgAdmin | `http://localhost:5050` | Web-based database administration |

Default pgAdmin credentials are in [.env.example](.env.example). Before production use, replace every default password.

## Register PostgreSQL in pgAdmin

1. Open <http://localhost:5050>.
2. Sign in with the configured pgAdmin credentials.
3. Select **Add New Server**.
4. Enter these connection values:

| Field | Value |
|---|---|
| Host | `postgres` |
| Port | `5432` |
| Maintenance database | `healthcare` |
| Username | `healthcare_admin` |
| Password | Value of `POSTGRES_PASSWORD` in `.env` |

Use `postgres` as the host because pgAdmin and PostgreSQL communicate through the Docker network. Use `localhost:5432` only for applications running outside Docker.

## Database Tables

### Patient and Account

- `patient`
- `patient_account`
- `account_session`
- `patient_address`
- `consent`

### Doctors and Facilities

- `doctor`
- `specialty`
- `doctor_specialty`
- `facility`
- `doctor_availability`

### Tests and Checkups

- `service_category`
- `health_service`
- `doctor_service`
- `service_request`
- `service_request_status_history`
- `request_result`
- `result_document`

### Appointments

- `appointment`
- `appointment_service`
- `appointment_status_history`
- `appointment_action`

## Common Commands

```powershell
docker compose ps
docker compose logs postgres
docker compose logs pgadmin
docker compose exec postgres psql -U healthcare_admin -d healthcare
docker compose down
```

Stop the containers and delete their database volumes:

```powershell
docker compose down -v
```

Use `down -v` carefully because it permanently removes all local database data.

## Snowflake

Snowflake is a managed cloud platform and does not provide an official local Docker database image. Snowflake DDL is provided in [sql/00_snowflake_schema.sql](sql/00_snowflake_schema.sql).

Before deployment, create a Snowflake database, schema, warehouse, role, and network security policy appropriate to your environment.

## Security Notes

- Change all default passwords.
- Do not commit `.env` to source control.
- Encrypt databases and document storage.
- Apply least-privilege database roles.
- Record patient consent and audit status changes.
- Do not store credentials or sensitive medical documents in the code repository.
