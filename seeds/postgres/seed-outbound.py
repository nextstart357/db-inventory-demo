#!/usr/bin/env python3
"""
Stock Outbound Transaction Generator for Mini Inventory Database (PostgreSQL)

Generates and executes deterministic INSERT statements for stock_outbound and
stock_outbound_item tables directly to the database. Connection is configured via
.env file in the same directory. All UUIDs are deterministic (uuid5) so the
output is always identical for the same parameters.

Usage:
    python seed-outbound.py --periode=2026-01 --samples=1000 --item-max=5
    python seed-outbound.py --periode=2026-01 --samples=100 --product=PRD-0002,PRD-0003,PRD-0004
    python seed-outbound.py --periode=2026-01 --daily-min=3
    python seed-outbound.py --periode=2026-01 --samples=200 --daily-min=5 --item-max=3
    python seed-outbound.py --periode=2026-01 --samples=100 -o backup-outbound.sql

Output is deterministic: the same parameters always produce identical output.
"""

import argparse
import uuid
import random
import sys
import os
import io
import calendar


# =============================================================================
# STATIC MASTER DATA (must match mini-inventory-seed.sql)
# =============================================================================

WAREHOUSES = [
    'd1000000-0000-4000-8000-000000000001',  # WH001
    'd1000000-0000-4000-8000-000000000002',  # WH002
    'd1000000-0000-4000-8000-000000000003',  # WH003
]

CUSTOMERS = [
    'c1000000-0000-4000-8000-000000000001',  # CST001
    'c1000000-0000-4000-8000-000000000002',  # CST002
    'c1000000-0000-4000-8000-000000000003',  # CST003
]

TOTAL_PRODUCTS = 600

# Namespace UUIDs for deterministic uuid5 generation
NS_ITEM_PRODUCT   = uuid.UUID('e1000000-0000-4000-8000-000000000000')
NS_OUTBOUND       = uuid.UUID('f3000000-0000-4000-8000-000000000000')
NS_OUTBOUND_ITEM  = uuid.UUID('f4000000-0000-4000-8000-000000000000')


# =============================================================================
# DATABASE HELPERS
# =============================================================================

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


_pg8000_mode = False


def get_db_connection(env):
    """Create PostgreSQL connection from env configuration."""
    global _pg8000_mode
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
        _pg8000_mode = True
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


def lookup_products(conn, product_codes):
    """Query product details from database by product_code."""
    cur = conn.cursor()
    placeholders = ','.join(['%s'] * len(product_codes))
    cur.execute(
        f"SELECT item_product_id, product_code, purchase_price, selling_price, uom "
        f"FROM item_product WHERE product_code IN ({placeholders}) "
        f"ORDER BY product_code",
        product_codes
    )
    rows = cur.fetchall()
    cur.close()

    found_codes = {r[1] for r in rows}
    missing = [c for c in product_codes if c not in found_codes]
    if missing:
        print(f"[ERROR] Product code not found in database: {', '.join(missing)}", file=sys.stderr)
        sys.exit(1)

    return [{
        'item_product_id': str(r[0]),
        'product_code': r[1],
        'purchase_price': float(r[2]),
        'selling_price': float(r[3]),
        'uom': r[4],
    } for r in rows]


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

def product_id(n):
    """Deterministic item_product_id for product number n (1-600).

    Format matches mini-inventory-seed.sql: hardcoded UUID with e1 prefix
    and 12-digit zero-padded n. Identical across PostgreSQL/MySQL/Oracle.
    """
    return f'e1000000-0000-4000-8000-{n:012d}'


def selling_price(n):
    """Selling price for product n (same formula as seed SQL, markup 20-40%)."""
    cat = n % 6
    base_prices = {
        0: 500000  + (n * 1000) % 9500000,   # Elektronik
        1: 50000   + (n * 100)  % 450000,     # Fashion
        2: 5000    + (n * 10)   % 95000,      # Makanan
        3: 25000   + (n * 50)   % 475000,     # Kesehatan
        4: 100000  + (n * 200)  % 1900000,    # Rumah Tangga
        5: 150000  + (n * 300)  % 1350000,    # Olahraga
    }
    markup_rates = {
        0: 1.2 + (n % 21) * 0.01,
        1: 1.25 + (n % 16) * 0.01,
        2: 1.3 + (n % 11) * 0.01,
        3: 1.25 + (n % 16) * 0.01,
        4: 1.2 + (n % 21) * 0.01,
        5: 1.25 + (n % 16) * 0.01,
    }
    return int(base_prices[cat] * markup_rates[cat])


def product_uom(n):
    """UOM for product n (same logic as seed SQL)."""
    if n % 6 == 2:
        uoms = ['pcs', 'box', 'pack', 'kg', 'liter']
        return uoms[(n // 6) % 5]
    return 'pcs'


def parse_periode(s):
    """Parse YYYY-MM string, return (year, month)."""
    parts = s.split('-')
    if len(parts) != 2:
        raise ValueError(f"Period format must be YYYY-MM, received: '{s}'")
    return int(parts[0]), int(parts[1])


def build_date_schedule(rng, days_in_month, total_samples, daily_min=None):
    """Build date schedule for all transactions.

    If daily_min is provided, each day is guaranteed to have at least N transactions.
    Remaining transactions are distributed randomly. Results are sorted chronologically.
    """
    if daily_min:
        schedule = []
        for d in range(1, days_in_month + 1):
            schedule.extend([d] * daily_min)
        remaining = total_samples - len(schedule)
        for _ in range(remaining):
            schedule.append(rng.randint(1, days_in_month))
        schedule.sort()
    else:
        schedule = [rng.randint(1, days_in_month) for _ in range(total_samples)]
    return schedule


# =============================================================================
# GENERATOR
# =============================================================================

def generate(args, output, fixed_products=None):
    year, month = parse_periode(args.periode)
    days_in_month = calendar.monthrange(year, month)[1]

    # Deterministic random seed (same params = same output)
    # Offset +50 so the random sequence differs from seed-inbound.py
    rng_seed = year * 100 + month + 50
    rng = random.Random(rng_seed)

    period_tag = f"{year}-{month:02d}"

    # --- Build date schedule ---
    daily_min = getattr(args, 'daily_min', None)
    date_schedule = build_date_schedule(rng, days_in_month, args.samples, daily_min)

    # --- Header ---
    if fixed_products:
        product_codes = ', '.join(p['product_code'] for p in fixed_products)
        product_info = f"-- Products  : {product_codes} (fixed)\n"
    else:
        product_info = f"-- Item Max   : {args.item_max}\n"

    daily_info = f"-- Daily Min  : {daily_min}\n" if daily_min else ""

    output.write(
        f"-- ============================================================================\n"
        f"-- GENERATED STOCK OUTBOUND TRANSACTIONS\n"
        f"-- ============================================================================\n"
        f"-- Periode    : {period_tag}\n"
        f"-- Samples    : {args.samples}\n"
        f"{product_info}"
        f"{daily_info}"
        f"-- Random Seed: {rng_seed}\n"
        f"-- Generated by seed-outbound.py\n"
        f"-- ============================================================================\n\n"
    )

    # --- Cleanup previously generated data for this period ---
    prefix = f"OUT/{period_tag}/"
    output.write(
        f"-- Delete previously generated data for this period\n"
        f"DELETE FROM stock_outbound_item WHERE stock_outbound_id IN (\n"
        f"    SELECT stock_outbound_id FROM stock_outbound\n"
        f"    WHERE outbound_number LIKE '{prefix}%'\n"
        f");\n"
        f"DELETE FROM stock_outbound WHERE outbound_number LIKE '{prefix}%';\n\n"
    )

    # --- Status distribution: 80% confirmed, 20% draft ---
    status_pool = ['confirmed'] * 4 + ['draft']

    total_trx = 0
    total_items_all = 0

    for i in range(1, args.samples + 1):
        outbound_number = f"OUT/{period_tag}/{i:04d}"
        outbound_id = str(uuid.uuid5(NS_OUTBOUND, outbound_number))
        ref_number = f"SO/{period_tag}/{i:04d}"

        day = date_schedule[i - 1]
        outbound_date = f"{year}-{month:02d}-{day:02d}"

        warehouse_id = rng.choice(WAREHOUSES)
        customer_id = rng.choice(CUSTOMERS)
        status = rng.choice(status_pool)

        # --- Determine products for this transaction ---
        if fixed_products:
            selected = fixed_products
        else:
            num_items = rng.randint(1, args.item_max)
            product_numbers = rng.sample(range(1, TOTAL_PRODUCTS + 1), num_items)
            selected = [{
                'item_product_id': product_id(pn),
                'product_code': f'PRD-{pn:04d}',
                'selling_price': selling_price(pn),
                'uom': product_uom(pn),
            } for pn in product_numbers]

        # --- Build item lines ---
        items = []
        for line, prod in enumerate(selected, 1):
            qty = rng.randint(1, 50)
            price = prod['selling_price']
            amount = qty * price
            item_id = str(uuid.uuid5(NS_OUTBOUND_ITEM, f"{outbound_number}-{line}"))

            items.append({
                'id': item_id,
                'line': line,
                'product_id': prod['item_product_id'],
                'product_code': prod['product_code'],
                'qty': qty,
                'uom': prod['uom'],
                'price': price,
                'amount': amount,
            })

        num_items = len(items)
        sum_qty = sum(it['qty'] for it in items)
        sum_amount = sum(it['amount'] for it in items)

        # --- INSERT stock_outbound ---
        output.write(
            f"INSERT INTO stock_outbound ("
            f"stock_outbound_id, outbound_number, outbound_date, "
            f"warehouse_id, customer_id, reference_number, notes, "
            f"total_items, total_qty, total_amount, status, created_by"
            f") VALUES (\n"
            f"    '{outbound_id}', '{outbound_number}', '{outbound_date}',\n"
            f"    '{warehouse_id}', '{customer_id}',\n"
            f"    '{ref_number}', 'Generated outbound #{i}',\n"
            f"    {num_items}, {sum_qty}, {sum_amount:.2f},\n"
            f"    '{status}', 'GENERATOR'\n"
            f");\n"
        )

        # --- INSERT stock_outbound_item ---
        output.write(
            f"INSERT INTO stock_outbound_item ("
            f"stock_outbound_item_id, stock_outbound_id, line_number, "
            f"item_product_id, qty_shipped, uom, unit_price, total_amount, "
            f"notes, created_by"
            f") VALUES\n"
        )
        for j, it in enumerate(items):
            comma = ',' if j < len(items) - 1 else ';'
            output.write(
                f"(   '{it['id']}', '{outbound_id}', {it['line']},\n"
                f"    '{it['product_id']}', {it['qty']}, '{it['uom']}',\n"
                f"    {it['price']:.2f}, {it['amount']:.2f},\n"
                f"    '{it['product_code']}', 'GENERATOR'\n"
                f"){comma}\n"
            )

        output.write("\n")
        total_trx += 1
        total_items_all += num_items

    # --- Footer ---
    output.write(
        f"-- ============================================================================\n"
        f"-- SUMMARY\n"
        f"-- ============================================================================\n"
        f"-- Total transactions: {total_trx}\n"
        f"-- Total line items: {total_items_all}\n"
        f"-- Periode         : {period_tag}\n"
        f"-- ============================================================================\n"
    )

    return total_trx, total_items_all


# =============================================================================
# MAIN
# =============================================================================

def main():
    parser = argparse.ArgumentParser(
        description='Generate stock outbound seed data (PostgreSQL)',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            'Examples:\n'
            '  python seed-outbound.py --periode=2026-01 --samples=1000 --item-max=5\n'
            '  python seed-outbound.py --periode=2026-01 --samples=100 --product=PRD-0002,PRD-0003,PRD-0004\n'
            '  python seed-outbound.py --periode=2026-01 --daily-min=3\n'
            '  python seed-outbound.py --periode=2026-01 --samples=200 --daily-min=5 --item-max=3\n'
            '  python seed-outbound.py --periode=2026-01 --samples=100 -o backup-outbound.sql\n'
            '\n'
            'Output is deterministic: the same parameters always produce identical output.\n'
            'Database connection is configured via .env file in the same directory.\n'
        )
    )
    parser.add_argument('--periode',    required=True, help='Transaction period in YYYY-MM format (e.g. 2026-01)')
    parser.add_argument('--samples',    type=int, default=None, help='Number of outbound transactions (default: 100, or auto if --daily-min)')
    parser.add_argument('--item-max',   type=int, default=5, help='Max items per transaction, range 1..N (default: 5)')
    parser.add_argument('--product',    default=None, help='Comma-separated product_code list (e.g. PRD-0002,PRD-0003,PRD-0004). If set, --item-max is ignored')
    parser.add_argument('--daily-min',  type=int, default=None, dest='daily_min', help='Minimum transactions per day. If --samples not given, total = days x daily-min')
    parser.add_argument('-o', '--output', default=None, help='Save SQL to file (in addition to database execution)')

    args = parser.parse_args()

    # --- Resolve samples vs daily-min ---
    try:
        year, month = parse_periode(args.periode)
    except ValueError as e:
        parser.error(str(e))

    days_in_month = calendar.monthrange(year, month)[1]

    if args.daily_min:
        if args.daily_min < 1:
            parser.error('--daily-min must be >= 1')
        min_required = days_in_month * args.daily_min
        if args.samples is None:
            args.samples = min_required
        elif args.samples < min_required:
            parser.error(
                f'--samples ({args.samples}) must be >= days x daily-min '
                f'({days_in_month} x {args.daily_min} = {min_required})'
            )
    else:
        if args.samples is None:
            args.samples = 100

    # Validation
    if args.samples < 1:
        parser.error('--samples must be >= 1')
    if not args.product:
        if args.item_max < 1:
            parser.error('--item-max must be >= 1')
        if args.item_max > TOTAL_PRODUCTS:
            parser.error(f'--item-max must not exceed total products ({TOTAL_PRODUCTS})')

    # --- Database connection ---
    env = load_env()
    conn = get_db_connection(env)
    db_name = env.get('DB_NAME', 'dbinv')

    # --- Lookup fixed products (if --product is provided) ---
    fixed_products = None
    if args.product:
        codes = [c.strip() for c in args.product.split(',')]
        if not codes:
            parser.error('--product must not be empty')
        fixed_products = lookup_products(conn, codes)

    # --- Generate SQL to buffer ---
    buf = io.StringIO()
    total_trx, total_items = generate(args, buf, fixed_products)
    sql = buf.getvalue()
    buf.close()

    # --- Save to file if -o is provided ---
    if args.output:
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write(sql)

    # --- Execute to database ---
    cur = conn.cursor()
    if _pg8000_mode:
        # pg8000 only supports single-statement per execute()
        for stmt in sql.split(';\n'):
            stmt = stmt.strip()
            has_sql = any(l.strip() and not l.strip().startswith('--') for l in stmt.splitlines())
            if has_sql:
                cur.execute(stmt)
    else:
        cur.execute(sql)
    conn.commit()
    cur.close()
    conn.close()

    print(
        f"[seed-outbound] {total_trx} transactions, "
        f"{total_items} line items for periode {args.periode} "
        f"-> {db_name}",
        file=sys.stderr
    )


if __name__ == '__main__':
    main()
