# Personal Finance Database Guide

This guide provides essential PostgreSQL commands for inspecting and managing the personal finance database.

## Getting Started

### Prerequisites
- Podman installed
- podman-compose installed

### Database Setup
```bash
# Start the database container
podman-compose up -d

# Connect to the database
podman exec -it personal-finance-db psql -U financeapp -d personal_finance
```

## Database Commands

### Basic Database Navigation
| Command | Description |
|---------|-------------|
| `\l` | List all databases |
| `\dt` | List all tables |
| `\d table_name` | Show table structure |
| `\q` or `Ctrl+D` | Exit psql |

### Useful Queries

#### Table Structure
```sql
-- View table columns and their types
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'transactions';
```

#### Data Inspection
```sql
-- Count total rows
SELECT COUNT(*) FROM transactions;

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

