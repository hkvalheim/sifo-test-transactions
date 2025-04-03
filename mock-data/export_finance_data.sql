-- Function to export financial data as JSON
CREATE OR REPLACE FUNCTION export_finance_data(year INTEGER DEFAULT 2024)
RETURNS JSON AS $$
BEGIN
    RETURN (
        SELECT json_build_object(
            'categories', (
                SELECT json_agg(cat_data)
                FROM (
                    SELECT 
                        c.id,
                        c.name,
                        c.sifo_code,
                        c.description,
                        c.parent_id,
                        (
                            SELECT json_agg(json_build_object(
                                'id', k.id,
                                'keyword', k.keyword,
                                'weight', k.weight
                            ))
                            FROM category_keywords k
                            WHERE k.category_id = c.id
                        ) as keywords,
                        (
                            SELECT json_build_object(
                                'transaction_count', COUNT(t.id),
                                'total_amount', ROUND(SUM(t.amount)::numeric, 2),
                                'average_amount', ROUND(AVG(t.amount)::numeric, 2)
                            )
                            FROM transactions t
                            WHERE t.category_id = c.id
                            AND EXTRACT(YEAR FROM t.booking_date) = $1
                        ) as statistics
                    FROM categories c
                    ORDER BY c.parent_id NULLS FIRST, c.id
                ) cat_data
            ),
            'transactions', (
                SELECT json_agg(trans_data)
                FROM (
                    SELECT 
                        t.id,
                        to_char(t.booking_date, 'YYYY-MM-DD') as date,
                        t.amount,
                        t.sender,
                        t.receiver,
                        t.title,
                        t.currency,
                        t.payment_type,
                        json_build_object(
                            'id', c.id,
                            'name', c.name,
                            'parent_id', c.parent_id
                        ) as category
                    FROM transactions t
                    LEFT JOIN categories c ON t.category_id = c.id
                    WHERE EXTRACT(YEAR FROM t.booking_date) = $1
                    ORDER BY t.booking_date DESC
                ) trans_data
            ),
            'summary', (
                SELECT json_build_object(
                    'total_income', ROUND(SUM(CASE WHEN amount > 0 THEN amount ELSE 0 END)::numeric, 2),
                    'total_expenses', ROUND(ABS(SUM(CASE WHEN amount < 0 THEN amount ELSE 0 END))::numeric, 2),
                    'net_amount', ROUND(SUM(amount)::numeric, 2),
                    'transaction_count', COUNT(*),
                    'categories_count', (SELECT COUNT(*) FROM categories),
                    'year', $1
                )
                FROM transactions
                WHERE EXTRACT(YEAR FROM booking_date) = $1
            )
        )
    );
END;
$$ LANGUAGE plpgsql;

-- Example usage:
-- SELECT export_finance_data(2024);

-- For pretty-printed output:
-- SELECT jsonb_pretty(export_finance_data(2024)::jsonb);