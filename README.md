# Personal Finance Database

This repository contains the database setup and test data generation for a personal finance tracking system.

## Prerequisites
- Podman installed
- podman-compose installed

## Project Structure
```
.
├── README.md
├── podman-compose.yml
├── backups/           # Directory for database backups
└── sql/              # SQL scripts including test data
```

## Getting Started

### 1. Initial Setup
```bash
# Start the database container
podman-compose up -d

# Verify the container is running
podman ps
```

### 2. Database Connection
```bash
# Connect to the database
podman exec -it personal-finance-db psql -U financeapp -d personal_finance
```

## Database Operations

### Backup and Restore
```bash
# Create full database backup (saved to ./backups directory)
podman exec personal-finance-db pg_dump -U financeapp -d personal_finance -F c > \
    ./backups/backup_$(date +%Y%m%d).dump

# Backup transactions table only
podman exec personal-finance-db pg_dump -U financeapp -d personal_finance -t transactions -F c > \
    ./backups/transactions_backup_$(date +%Y%m%d).dump

# Restore from backup
cat ./backups/backup_20240101.dump | \
    podman exec -i personal-finance-db pg_restore -U financeapp -d personal_finance
```

### Loading Test Data
```bash
# First, create a backup of existing data (recommended)
podman exec personal-finance-db pg_dump -U financeapp -d personal_finance -t transactions -F c > \
    ./backups/transactions_backup_$(date +%Y%m%d).dump

# Copy test data script into container and execute
podman cp ./sql/sifo_transactions_testdata.sql personal-finance-db:/tmp/
podman exec -it personal-finance-db psql -U financeapp -d personal_finance -f /tmp/sifo_transactions_testdata.sql

# Verify the test data
podman exec -it personal-finance-db psql -U financeapp -d personal_finance -c \
    "SELECT c.name as category, COUNT(*) as count, 
     ROUND(ABS(SUM(t.amount))::numeric, 2) as total_amount
     FROM transactions t
     JOIN categories c ON t.category_id = c.id
     WHERE EXTRACT(YEAR FROM t.booking_date) = 2024
     GROUP BY c.name
     ORDER BY c.name;"
```

### Useful Database Commands
When connected to psql, you can use these commands:

```sql
\l                  -- List all databases
\dt                 -- List all tables
\d transactions     -- Show transactions table structure
\d categories       -- Show categories table structure
\q                  -- Quit psql
```

### Common Queries
```sql
-- Count total transactions
SELECT COUNT(*) FROM transactions;

-- View table structure
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'transactions';

-- View recent transactions
SELECT * FROM transactions LIMIT 10;
```

#### Financial Analysis
```sql
-- Category Overview
SELECT c.name, COUNT(t.id) 
FROM categories c 
LEFT JOIN transactions t ON c.id = t.category_id 
GROUP BY c.name 
ORDER BY COUNT(t.id) DESC;

-- Monthly Expenses
SELECT 
    EXTRACT(YEAR FROM booking_date) AS year,
    EXTRACT(MONTH FROM booking_date) AS month,
    SUM(amount) AS total_amount
FROM transactions
WHERE amount < 0
GROUP BY year, month
ORDER BY year, month;
```

### Help Commands
| Command | Description |
|---------|-------------|
| `\?` | List all psql commands |
| `\h` | SQL commands help |
| `\conninfo` | Show connection info |

## Additional Resources
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Podman Documentation](https://docs.podman.io/)

