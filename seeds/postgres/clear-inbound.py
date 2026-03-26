#!/usr/bin/env python3
"""
Clear All Stock Inbound Data for Mini Inventory Database (PostgreSQL)

Deletes all data from stock_inbound_item and stock_inbound tables.
Database connection is configured via .env file in the same directory.

Usage:
    python clear-inbound.py
    python clear-inbound.py --yes
"""

import argparse
import sys
import os


def load_env():
    """Load .env file from the same directory as the script."""
    env_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), '.env')
    env = {}
    if not os.path.exists(env_path):
        return env
    with open(env_path, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            if '=' in line:
                key, value = line.split('=', 1)
                env[key.strip()] = value.strip()
    return env


def get_db_connection(env):
    """Create PostgreSQL connection from env configuration."""
    conn_params = dict(
        host=env.get('DB_HOST', '127.0.0.1'),
        port=int(env.get('DB_PORT', '5432')),
        user=env.get('DB_USER', 'postgres'),
        password=env.get('DB_PASSWORD', 'postgres1234'),
        dbname=env.get('DB_NAME', 'dbinv'),
    )

    # Try psycopg2 first, then psycopg v3, then pg8000 (pure Python)
    try:
        import psycopg2
        return psycopg2.connect(**conn_params)
    except ImportError:
        pass

    try:
        import psycopg
        return psycopg.connect(**conn_params)
    except ImportError:
        pass

    try:
        import pg8000
        params = conn_params.copy()
        params['database'] = params.pop('dbname')
        return pg8000.connect(**params)
    except ImportError:
        pass

    print("[ERROR] No PostgreSQL driver found.", file=sys.stderr)
    print("  Install one of:", file=sys.stderr)
    print("    pip install psycopg2-binary   (x64)", file=sys.stderr)
    print("    pip install psycopg[binary]   (x64 with bundled libpq)", file=sys.stderr)
    print("    pip install pg8000            (pure Python, any platform)", file=sys.stderr)
    sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description='Delete all stock inbound data (PostgreSQL)',
    )
    parser.add_argument('--yes', action='store_true', help='Skip confirmation, delete immediately')

    args = parser.parse_args()

    env = load_env()
    conn = get_db_connection(env)
    db_name = env.get('DB_NAME', 'dbinv')

    # Count records before deletion
    cur = conn.cursor()
    cur.execute("SELECT COUNT(*) FROM stock_inbound_item")
    count_items = cur.fetchone()[0]
    cur.execute("SELECT COUNT(*) FROM stock_inbound")
    count_trx = cur.fetchone()[0]
    cur.close()

    if count_trx == 0:
        print(f"[clear-inbound] No data to delete (database: {db_name})")
        conn.close()
        return

    print(f"Database      : {db_name}")
    print(f"Transactions  : {count_trx:,} rows (stock_inbound)")
    print(f"Detail items  : {count_items:,} rows (stock_inbound_item)")

    if not args.yes:
        confirm = input("\nDelete all data above? (y/N): ").strip().lower()
        if confirm != 'y':
            print("[clear-inbound] Cancelled.")
            conn.close()
            return

    cur = conn.cursor()
    cur.execute("DELETE FROM stock_inbound_item")
    deleted_items = cur.rowcount
    cur.execute("DELETE FROM stock_inbound")
    deleted_trx = cur.rowcount
    conn.commit()
    cur.close()
    conn.close()

    print(f"\n[clear-inbound] Deleted: {deleted_trx:,} transactions, {deleted_items:,} detail items (database: {db_name})")


if __name__ == '__main__':
    main()
