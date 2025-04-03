podman cp ./sql/export_finance_data.sql personal-finance-db:/tmp/
podman exec -it personal-finance-db psql -U financeapp -d personal_finance -f /tmp/export_finance_data.sql
podman exec personal-finance-db psql -U financeapp -d personal_finance -t -A -c "SELECT jsonb_pretty(export_finance_data(2024)::jsonb);" > finance_data_pretty.json
