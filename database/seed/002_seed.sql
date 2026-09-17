INSERT INTO hotel_bookings (
    id,
    org_id,
    hotel_id,
    city,
    checkin_date,
    checkout_date,
    amount,
    status,
    created_at
)
SELECT
    gen_random_uuid(),
    (
        ARRAY[
            '11111111-1111-1111-1111-111111111111'::uuid,
            '22222222-2222-2222-2222-222222222222'::uuid,
            '33333333-3333-3333-3333-333333333333'::uuid,
            '44444444-4444-4444-4444-444444444444'::uuid
        ]
    )[1 + floor(random() * 4)::int],
    'HOTEL-' || LPAD((1 + floor(random() * 20))::int::text, 3, '0'),
    (
        ARRAY[
            'delhi',
            'mumbai',
            'bangalore',
            'hyderabad',
            'pune',
            'chennai'
        ]
    )[1 + floor(random() * 6)::int],
    CURRENT_DATE + floor(random() * 30)::int,
    CURRENT_DATE + 30 + floor(random() * 10)::int,
    ROUND((500 + random() * 9500)::numeric, 2),
    (
        ARRAY[
            'confirmed',
            'cancelled',
            'completed',
            'pending'
        ]
    )[1 + floor(random() * 4)::int],
    NOW() - (floor(random() * 60)::int || ' days')::interval
FROM generate_series(1, 100);