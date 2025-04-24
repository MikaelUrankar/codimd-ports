psql -U postgres -c "CREATE DATABASE codimd;"
psql -U postgres -c "CREATE USER codimd WITH password 'codimd';"
psql -U postgres -c "GRANT ALL privileges ON DATABASE codimd TO codimd;"
psql -U postgres -c "ALTER DATABASE codimd OWNER to codimd;"
