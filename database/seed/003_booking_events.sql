INSERT INTO booking_events (
    booking_id,
    event_type,
    payload,
    created_at
)
SELECT
    id,
    CASE
        WHEN row_number() OVER () % 3 = 1 THEN 'booking_created'
        WHEN row_number() OVER () % 3 = 2 THEN 'booking_confirmed'
        ELSE 'booking_updated'
    END,
    jsonb_build_object(
        'source', 'seed',
        'message', 'Sample booking event'
    ),
    created_at + INTERVAL '1 hour'
FROM (
    SELECT id, created_at
    FROM hotel_bookings
    ORDER BY created_at
    LIMIT 30
) b;