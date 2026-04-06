-- ============================================================================
-- STOCK RECONCILIATION VIEW
-- ============================================================================
-- Description: Membandingkan nilai stock di table item_product dengan
--              kalkulasi dari transaksi:
--              beginning_balance + inbound - outbound = calculated_stock
--              Menampilkan selisih (variance) untuk identifikasi ketidaksesuaian
-- Database: PostgreSQL
-- ============================================================================

DROP VIEW IF EXISTS v_stock_reconciliation;

CREATE VIEW v_stock_reconciliation AS
SELECT
    ip.item_product_id,
    ip.product_code,
    ip.product_name,
    ip.uom,
    ip.stock                                                            AS stock_on_master,
    COALESCE(bb.qty_beginning, 0)                                       AS qty_beginning,
    COALESCE(inb.qty_inbound, 0)                                        AS qty_inbound,
    COALESCE(outb.qty_outbound, 0)                                      AS qty_outbound,
    COALESCE(bb.qty_beginning, 0)
        + COALESCE(inb.qty_inbound, 0)
        - COALESCE(outb.qty_outbound, 0)                                AS stock_calculated,
    ip.stock - (
        COALESCE(bb.qty_beginning, 0)
        + COALESCE(inb.qty_inbound, 0)
        - COALESCE(outb.qty_outbound, 0)
    )                                                                   AS variance,
    CASE
        WHEN ip.stock = (
            COALESCE(bb.qty_beginning, 0)
            + COALESCE(inb.qty_inbound, 0)
            - COALESCE(outb.qty_outbound, 0)
        ) THEN 'MATCH'
        ELSE 'MISMATCH'
    END                                                                 AS reconcile_status
FROM item_product ip
LEFT JOIN (
    -- Aggregate beginning balance per item (semua warehouse, periode terbaru)
    SELECT
        sb.item_product_id,
        SUM(sb.qty_beginning) AS qty_beginning
    FROM stock_beginning_balance sb
    INNER JOIN (
        SELECT item_product_id, warehouse_id, MAX(period_date) AS max_period
        FROM stock_beginning_balance
        GROUP BY item_product_id, warehouse_id
    ) latest ON sb.item_product_id = latest.item_product_id
            AND sb.warehouse_id = latest.warehouse_id
            AND sb.period_date = latest.max_period
    GROUP BY sb.item_product_id
) bb ON bb.item_product_id = ip.item_product_id
LEFT JOIN (
    -- Aggregate total qty masuk dari semua stock_inbound (status confirmed/closed)
    SELECT
        sii.item_product_id,
        SUM(sii.qty_received) AS qty_inbound
    FROM stock_inbound_item sii
    INNER JOIN stock_inbound si ON si.stock_inbound_id = sii.stock_inbound_id
    WHERE si.status IN ('confirmed', 'closed')
    GROUP BY sii.item_product_id
) inb ON inb.item_product_id = ip.item_product_id
LEFT JOIN (
    -- Aggregate total qty keluar dari semua stock_outbound (status confirmed/closed)
    SELECT
        soi.item_product_id,
        SUM(soi.qty_shipped) AS qty_outbound
    FROM stock_outbound_item soi
    INNER JOIN stock_outbound so ON so.stock_outbound_id = soi.stock_outbound_id
    WHERE so.status IN ('confirmed', 'closed')
    GROUP BY soi.item_product_id
) outb ON outb.item_product_id = ip.item_product_id
WHERE ip.is_active = TRUE
ORDER BY ip.product_code;

-- ============================================================================
-- USAGE
-- ============================================================================
-- Tampilkan semua item beserta hasil rekonsiliasi:
--   SELECT * FROM v_stock_reconciliation;
--
-- Tampilkan hanya item yang tidak cocok (ada selisih):
--   SELECT * FROM v_stock_reconciliation WHERE reconcile_status = 'MISMATCH';
--
-- Tampilkan hanya item yang cocok:
--   SELECT * FROM v_stock_reconciliation WHERE reconcile_status = 'MATCH';
-- ============================================================================
