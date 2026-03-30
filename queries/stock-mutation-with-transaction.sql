-- ============================================================================
-- STOCK MUTATION VIEW
-- ============================================================================
-- Description: Menampilkan mutasi stock per item product per warehouse dengan
--              qty awal, qty masuk, qty keluar, dan qty akhir
--              (hanya item yang memiliki transaksi atau saldo awal)
-- Database: PostgreSQL
-- ============================================================================

DROP VIEW IF EXISTS v_stock_mutation;

CREATE VIEW v_stock_mutation AS
SELECT
    ip.item_product_id,
    ip.product_code,
    ip.product_name,
    w.warehouse_id,
    w.warehouse_code,
    COALESCE(sbb.qty_awal, 0) AS qty_awal,
    COALESCE(inb.qty_masuk, 0) AS qty_masuk,
    COALESCE(outb.qty_keluar, 0) AS qty_keluar,
    COALESCE(sbb.qty_awal, 0) + COALESCE(inb.qty_masuk, 0) - COALESCE(outb.qty_keluar, 0) AS qty_akhir
FROM item_product ip
CROSS JOIN warehouse w
LEFT JOIN (
    -- Ambil saldo awal terbaru per item per warehouse
    SELECT
        sb.item_product_id,
        sb.warehouse_id,
        sb.qty_beginning AS qty_awal
    FROM stock_beginning_balance sb
    INNER JOIN (
        SELECT item_product_id, warehouse_id, MAX(period_date) AS max_period
        FROM stock_beginning_balance
        GROUP BY item_product_id, warehouse_id
    ) latest ON sb.item_product_id = latest.item_product_id
            AND sb.warehouse_id = latest.warehouse_id
            AND sb.period_date = latest.max_period
) sbb ON sbb.item_product_id = ip.item_product_id
     AND sbb.warehouse_id = w.warehouse_id
LEFT JOIN (
    -- Aggregate total qty masuk dari stock_inbound_item per warehouse
    SELECT
        sii.item_product_id,
        si.warehouse_id,
        SUM(sii.qty_received) AS qty_masuk
    FROM stock_inbound_item sii
    INNER JOIN stock_inbound si ON si.stock_inbound_id = sii.stock_inbound_id
    WHERE si.status IN ('confirmed', 'closed')
    GROUP BY sii.item_product_id, si.warehouse_id
) inb ON inb.item_product_id = ip.item_product_id
     AND inb.warehouse_id = w.warehouse_id
LEFT JOIN (
    -- Aggregate total qty keluar dari stock_outbound_item per warehouse
    SELECT
        soi.item_product_id,
        so.warehouse_id,
        SUM(soi.qty_shipped) AS qty_keluar
    FROM stock_outbound_item soi
    INNER JOIN stock_outbound so ON so.stock_outbound_id = soi.stock_outbound_id
    WHERE so.status IN ('confirmed', 'closed')
    GROUP BY soi.item_product_id, so.warehouse_id
) outb ON outb.item_product_id = ip.item_product_id
      AND outb.warehouse_id = w.warehouse_id
WHERE ip.is_active = TRUE
  AND w.is_active = TRUE
  AND (sbb.qty_awal IS NOT NULL OR inb.qty_masuk IS NOT NULL OR outb.qty_keluar IS NOT NULL)
ORDER BY ip.product_code, w.warehouse_code;
