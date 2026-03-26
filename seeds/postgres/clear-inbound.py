#!/usr/bin/env python3
"""
Clear All Stock Inbound Data for Mini Inventory Database (PostgreSQL)

Menghapus seluruh data pada tabel stock_inbound_item dan stock_inbound.
Koneksi database dikonfigurasi melalui file .env di direktori yang sama.

Usage:
    python clear-inbound.py
    python clear-inbound.py --yes
"""

import argparse
import sys
import os


def load_env():
    """Load .env file dari direktori yang sama dengan script."""
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
    """Buat koneksi PostgreSQL dari konfigurasi env."""
    try:
        import psycopg2
    except ImportError:
        print("[ERROR] Package psycopg2 belum ter-install.", file=sys.stderr)
        print("  Install dengan: pip install psycopg2-binary", file=sys.stderr)
        sys.exit(1)

    return psycopg2.connect(
        host=env.get('DB_HOST', '127.0.0.1'),
        port=int(env.get('DB_PORT', '5432')),
        user=env.get('DB_USER', 'postgres'),
        password=env.get('DB_PASSWORD', 'postgres1234'),
        dbname=env.get('DB_NAME', 'dbinv'),
    )


def main():
    parser = argparse.ArgumentParser(
        description='Hapus seluruh data stock inbound (PostgreSQL)',
    )
    parser.add_argument('--yes', action='store_true', help='Skip konfirmasi, langsung hapus')

    args = parser.parse_args()

    env = load_env()
    conn = get_db_connection(env)
    db_name = env.get('DB_NAME', 'dbinv')

    # Hitung jumlah data sebelum dihapus
    cur = conn.cursor()
    cur.execute("SELECT COUNT(*) FROM stock_inbound_item")
    count_items = cur.fetchone()[0]
    cur.execute("SELECT COUNT(*) FROM stock_inbound")
    count_trx = cur.fetchone()[0]
    cur.close()

    if count_trx == 0:
        print(f"[clear-inbound] Tidak ada data untuk dihapus (database: {db_name})")
        conn.close()
        return

    print(f"Database     : {db_name}")
    print(f"Transaksi    : {count_trx:,} rows (stock_inbound)")
    print(f"Detail item  : {count_items:,} rows (stock_inbound_item)")

    if not args.yes:
        confirm = input("\nHapus semua data di atas? (y/N): ").strip().lower()
        if confirm != 'y':
            print("[clear-inbound] Dibatalkan.")
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

    print(f"\n[clear-inbound] Dihapus: {deleted_trx:,} transaksi, {deleted_items:,} detail item (database: {db_name})")


if __name__ == '__main__':
    main()
