from faker import Faker
import sqlite3
import random
from datetime import datetime, timedelta
from dateutil.relativedelta import relativedelta

fake = Faker()

# ------------------------------
# Constants and Lookups
# ------------------------------
NUM_CUSTOMERS = 50000
NUM_PRODUCTS_STATIC = 30
NUM_PRODUCTS_DYNAMIC = 50
NUM_PRODUCTS_TOTAL = NUM_PRODUCTS_STATIC + NUM_PRODUCTS_DYNAMIC

PLAN_TYPES = {
    "Starter": 29,
    "Basic": 79,
    "Hopify Standard": 299,
    "Advanced": 399,
    "Plus": 2000
}
CUSTOMER_SEGMENTS = ["SMB", "Mid-Market", "Enterprise"]
TICKET_CATEGORIES = ["Billing", "Technical", "Onboarding", "Account Access", "General Inquiry"]
PAYMENT_METHODS = ["Card", "ACH", "PayPal", "Hop Pay"]
CHURN_REASONS = ["Too expensive", "Switched provider", "Lack of features", "Poor support", "Other"]

OFFICE_LOCATIONS = [
    ("Hopify NYC HQ", "150 Elgin St", "New York City", "NY", "10001", "United States"),
    ("Hopify Canada Hub", "123 King St", "Toronto", "ON", "M5H 1J9", "Canada"),
    ("Hopify Brazil Hub", "50 Paulista Ave", "Sao Paulo", "SP", "01310-100", "Brazil"),
    ("Hopify Germany Hub", "Unter den Linden 1", "Berlin", "BE", "10117", "Germany"),
    ("Hopify Singapore Hub", "1 Raffles Place", "Singapore", "Singapore", "048616", "Singapore")
]

print("[INFO] Database structure and constants initialized.")

# ------------------------------
# Dynamic Monthly Acquisition Plan (with dips, spikes, and marketing campaigns)
# ------------------------------
from collections import defaultdict

acquisition_plan = defaultdict(int)
start_month = datetime.now() - relativedelta(months=36)  # Extend to 3 years for v15
current_month = datetime.now() - relativedelta(months=1)
month_cursor = start_month

while month_cursor <= current_month:
    year_month = month_cursor.strftime('%Y-%m')
    if month_cursor.month in [6, 7, 8]:
        target_customers = random.randint(1200, 1800)
    elif month_cursor.month in [11, 12, 1]:
        target_customers = random.randint(2200, 3000)
    elif month_cursor.month == 4 and random.random() < 0.3:
        target_customers = random.randint(3000, 4000)
    else:
        target_customers = random.randint(1800, 2300)
    acquisition_plan[year_month] = target_customers
    month_cursor += relativedelta(months=1)

print(f"[INFO] Acquisition plan generated for {len(acquisition_plan)} months.")

# ------------------------------
# Connect and Create Schema
# ------------------------------
conn = sqlite3.connect("/Users/jade.herman/Documents/00_github/hopify_db_v1/data/hopify_saas_v1.db")
cursor = conn.cursor()

cursor.executescript("""
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS subscriptions;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS churn_events;
DROP TABLE IF EXISTS support_tickets;
DROP TABLE IF EXISTS app_installs;
DROP TABLE IF EXISTS discounts;
DROP TABLE IF EXISTS order_discounts;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS locations;
DROP TABLE IF EXISTS marketing_campaigns;
DROP TABLE IF EXISTS web_traffic;
DROP TABLE IF EXISTS benchmarks;

CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT,
    email TEXT,
    billing_address TEXT,
    shipping_address TEXT,
    signup_date TEXT,
    customer_segment TEXT,
    acquisition_source TEXT
);

CREATE TABLE subscriptions (
    subscription_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    plan_type TEXT,
    subscription_price REAL,
    start_date TEXT,
    end_date TEXT,
    status TEXT,
    change_type TEXT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    order_date TEXT,
    total_amount REAL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INTEGER PRIMARY KEY,
    order_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    subtotal REAL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE payments (
    payment_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    payment_amount REAL,
    payment_date TEXT,
    payment_method TEXT,
    success INTEGER,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE churn_events (
    churn_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    churn_date TEXT,
    churn_reason TEXT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE support_tickets (
    ticket_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    ticket_category TEXT,
    created_at TEXT,
    resolved_at TEXT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE app_installs (
    install_id INTEGER PRIMARY KEY,
    location_id INTEGER,
    product_id INTEGER,
    install_date TEXT,
    FOREIGN KEY (location_id) REFERENCES locations(location_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE discounts (
    discount_id INTEGER PRIMARY KEY,
    discount_code TEXT,
    discount_percent INTEGER,
    start_date TEXT,
    end_date TEXT
);

CREATE TABLE order_discounts (
    order_id INTEGER,
    discount_id INTEGER,
    PRIMARY KEY (order_id, discount_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (discount_id) REFERENCES discounts(discount_id)
);

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    name TEXT,
    category TEXT,
    price REAL,
    revenue_type TEXT
);

CREATE TABLE locations (
    location_id INTEGER PRIMARY KEY,
    name TEXT,
    address TEXT,
    city TEXT,
    state TEXT,
    postal_code TEXT,
    country TEXT
);

CREATE TABLE marketing_campaigns (
    campaign_id INTEGER PRIMARY KEY,
    campaign_name TEXT NOT NULL,
    channel TEXT NOT NULL,
    campaign_type TEXT,
    start_date TEXT,
    end_date TEXT,
    total_cost REAL
);

CREATE TABLE web_traffic (
    traffic_id INTEGER PRIMARY KEY AUTOINCREMENT,
    traffic_date TEXT,
    source_channel TEXT,
    visitors INTEGER,
    leads INTEGER,
    mqls INTEGER
);

CREATE TABLE benchmarks (
    benchmark_id INTEGER PRIMARY KEY AUTOINCREMENT,
    metric_category TEXT NOT NULL,
    segment TEXT NOT NULL,
    metric_name TEXT NOT NULL,
    target_value REAL,
    description TEXT
);
""")

print("[INFO] Database schema created.")


# ------------------------------
# Products (Static and Dynamic)
# ------------------------------
product_id = 1
categories = ['POS Hardware & Software', 'Payments & Finance', 'Financial Services', 'Apps & Integrations',
              'Storefront Tools', 'Marketing & Growth', 'Logistics & Shipping']

# Static products
for i in range(NUM_PRODUCTS_STATIC):
    cursor.execute("""
        INSERT INTO products VALUES (?, ?, ?, ?, ?)
    """, (
        product_id,
        f"Static Product {i+1}",
        random.choice(categories),
        round(random.uniform(20, 500), 2),
        random.choice(["One-Time", "Subscription"])
    ))
    product_id += 1

# Dynamic products
for i in range(NUM_PRODUCTS_DYNAMIC):
    cursor.execute("""
        INSERT INTO products VALUES (?, ?, ?, ?, ?)
    """, (
        product_id,
        fake.catch_phrase(),
        random.choice(categories),
        round(random.uniform(20, 500), 2),
        random.choice(["One-Time", "Subscription"])
    ))
    product_id += 1

print("[INFO] Inserted products.")

# ------------------------------
# Office Locations
# ------------------------------
for i, (name, address, city, state, postal_code, country) in enumerate(OFFICE_LOCATIONS, 1):
    cursor.execute("""
        INSERT INTO locations VALUES (?, ?, ?, ?, ?, ?, ?)
    """, (i, name, address, city, state, postal_code, country))

print("[INFO] Inserted office locations.")

# ------------------------------
# Customers Based on Plan (with segment distribution and logging)
# ------------------------------
customer_id = 1
customers_list = []

for year_month, target in acquisition_plan.items():
    month_start = datetime.strptime(year_month + "-01", "%Y-%m-%d")
    month_end = month_start + relativedelta(months=1) - timedelta(days=1)

    if month_start.month in [6, 7, 8]:
        source = "Summer Dip - Organic"
    elif month_start.month in [11, 12, 1]:
        source = "Holiday Season Spike - Campaign"
    elif month_start.month == 4 and random.random() < 0.3:
        source = "Spring Marketing Campaign"
    else:
        source = "Organic Growth"

    for _ in range(target):
        signup_date = fake.date_time_between_dates(month_start, month_end)
        segment = random.choices(CUSTOMER_SEGMENTS, weights=[0.6, 0.3, 0.1])[0]

        cursor.execute("""
            INSERT INTO customers VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            customer_id,
            fake.name(),
            fake.email(),
            fake.address(),
            fake.address(),
            signup_date.strftime("%Y-%m-%d %H:%M:%S"),
            segment,
            source
        ))
        customers_list.append((customer_id, segment))
        customer_id += 1

print(f"[INFO] Inserted {len(customers_list)} customers.")

# ------------------------------
# Subscriptions with History (Segment-aware)
# ------------------------------
sub_id = 1
for cust_id, segment in customers_list:
    start = fake.date_time_between(start_date='-2y', end_date='-180d')
    if segment == 'SMB':
        plan_sequence = random.choices([("Starter", 29), ("Basic", 79), ("Hopify Standard", 299)], weights=[0.7, 0.25, 0.05], k=random.randint(1, 2))
    elif segment == 'Mid-Market':
        plan_sequence = random.choices([("Basic", 79), ("Hopify Standard", 299), ("Advanced", 399)], weights=[0.15, 0.5, 0.35], k=random.randint(1, 3))
    else:
        plan_sequence = random.choices([("Hopify Standard", 299), ("Advanced", 399), ("Plus", 2000)], weights=[0.1, 0.4, 0.5], k=random.randint(2, 4))

    for idx, (plan, price) in enumerate(plan_sequence):
        change_type = "signup" if idx == 0 else random.choice(["upgrade", "reactivation", "upgrade"])
        end = None
        if idx < len(plan_sequence) - 1:
            end = start + timedelta(days=random.randint(60, 180))
            status = "cancelled"
        else:
            if random.random() < (0.2 if segment == 'SMB' else 0.1 if segment == 'Mid-Market' else 0.05):
                end = start + timedelta(days=random.randint(60, 300))
                status = "cancelled"
            else:
                status = "active"

        cursor.execute("""
            INSERT INTO subscriptions VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            sub_id, cust_id, plan, price,
            start.strftime("%Y-%m-%d %H:%M:%S"),
            end.strftime("%Y-%m-%d %H:%M:%S") if end else None,
            status,
            change_type
        ))

        start = end if end else start
        sub_id += 1

print("[INFO] Inserted subscriptions with historical changes.")

# ------------------------------
# Orders, Order Items, Payments (Segment-aware with skew)
# ------------------------------
order_id = 1
item_id = 1
payment_id = 1
for cust_id, segment in customers_list:
    if segment == 'Enterprise':
        num_orders = random.randint(3, 6)
    elif segment == 'Mid-Market':
        num_orders = random.randint(2, 4)
    else:
        num_orders = random.randint(1, 3)

    for _ in range(num_orders):
        order_date = fake.date_time_between(start_date='-2y', end_date=datetime.today())
        total = 0

        cursor.execute("INSERT INTO orders VALUES (?, ?, ?, ?)", (
            order_id, cust_id, order_date.strftime("%Y-%m-%d %H:%M:%S"), 0.0
        ))

        if segment == 'Enterprise':
            preferred_categories = ['POS Hardware & Software', 'Payments & Finance', 'Financial Services', 'Apps & Integrations']
            weights = [0.4, 0.3, 0.2, 0.1]
        elif segment == 'Mid-Market':
            preferred_categories = ['Apps & Integrations', 'Storefront Tools', 'Marketing & Growth']
            weights = [0.4, 0.4, 0.2]
        else:
            preferred_categories = ['Storefront Tools', 'Marketing & Growth', 'Logistics & Shipping']
            weights = [0.5, 0.3, 0.2]

        for _ in range(random.randint(1, 5)):
            category = random.choices(preferred_categories, weights=weights)[0]
            cursor.execute("SELECT product_id, price FROM products WHERE category = ? ORDER BY RANDOM() LIMIT 1", (category,))
            result = cursor.fetchone()
            if result:
                pid, price = result
                qty = random.randint(1, 3)
                subtotal = round(price * qty, 2) if price else 0
                total += subtotal

                cursor.execute("INSERT INTO order_items VALUES (?, ?, ?, ?, ?)", (
                    item_id, order_id, pid, qty, subtotal
                ))
                item_id += 1

        cursor.execute("UPDATE orders SET total_amount = ? WHERE order_id = ?", (round(total, 2), order_id))

        pay_date = fake.date_time_between(start_date=order_date, end_date=datetime.today())
        method = random.choice(PAYMENT_METHODS)
        success = 1 if random.random() > 0.03 else 0
        cursor.execute("INSERT INTO payments VALUES (?, ?, ?, ?, ?, ?)", (
            payment_id, cust_id, round(total, 2), pay_date.strftime("%Y-%m-%d %H:%M:%S"), method, success
        ))
        payment_id += 1

        order_id += 1

print("[INFO] Inserted orders, order items, and payments.")

# ------------------------------
# Support Tickets (Segment-Aware with defensive handling)
# ------------------------------
ticket_id = 1
sample_size = min(20000, len(customers_list))
sampled_customers = random.sample(customers_list, sample_size)

for cust_id, segment in sampled_customers:
    if segment == 'Enterprise':
        num_tickets = random.choices([5, 6, 7, 8, 9, 10], weights=[20, 30, 25, 15, 7, 3])[0]
        resolution_range = (6, 36)
    elif segment == 'Mid-Market':
        num_tickets = random.choices([2, 3, 4, 5, 6], weights=[30, 30, 20, 15, 5])[0]
        resolution_range = (12, 72)
    else:
        num_tickets = random.choices([0, 1, 2, 3], weights=[50, 30, 15, 5])[0]
        resolution_range = (24, 120)

    for _ in range(num_tickets):
        created = fake.date_time_between(start_date='-1y', end_date='-7d')
        resolution_hours = random.randint(*resolution_range)
        resolved = created + timedelta(hours=resolution_hours)

        if resolved <= created:
            resolved = created + timedelta(hours=1)

        category = random.choice(TICKET_CATEGORIES)

        cursor.execute("""
            INSERT INTO support_tickets VALUES (?, ?, ?, ?, ?)
        """, (
            ticket_id,
            cust_id,
            category,
            created.strftime("%Y-%m-%d %H:%M:%S"),
            resolved.strftime("%Y-%m-%d %H:%M:%S")
        ))

        ticket_id += 1

print("[INFO] Inserted support tickets.")

# ------------------------------
# Churn Events (Segment-aware with support friction and decay adjustments)
# ------------------------------
cursor.execute("""
    SELECT 
        c.customer_id,
        c.customer_segment,
        c.signup_date,
        COUNT(st.ticket_id) AS total_tickets,
        MIN(st.created_at) AS first_ticket_date,
        AVG(JULIANDAY(st.resolved_at) - JULIANDAY(st.created_at)) AS avg_resolution_days,
        SUM(CASE WHEN st.ticket_category = 'Billing' THEN 1 ELSE 0 END) AS billing_tickets
    FROM customers c
    LEFT JOIN support_tickets st
    ON c.customer_id = st.customer_id
    GROUP BY c.customer_id
""")

churn_id = 1
for row in cursor.fetchall():
    cust_id, segment, signup_date_str, total_tickets, first_ticket_date, avg_resolution_days, billing_tickets = row
    signup_date = datetime.strptime(signup_date_str, "%Y-%m-%d %H:%M:%S")

    churn_prob = 0.05 if segment == 'Enterprise' else 0.15 if segment == 'Mid-Market' else 0.4
    days_since_signup = (datetime.today() - signup_date).days
    if days_since_signup < 90:
        churn_prob *= 0.2
    elif days_since_signup < 180:
        churn_prob *= 0.5

    if total_tickets >= 5:
        churn_prob += 0.15 if segment == 'SMB' else 0.1
    elif 1 <= total_tickets <= 4:
        churn_prob -= 0.05

    if avg_resolution_days and avg_resolution_days > 3:
        churn_prob += 0.05 if segment == 'Enterprise' else 0.1

    if billing_tickets and billing_tickets >= 2:
        churn_prob += 0.15 if segment == 'Enterprise' else 0.1

    if not first_ticket_date:
        first_ticket_delay_days = 999
    else:
        first_ticket_date_obj = datetime.strptime(first_ticket_date, "%Y-%m-%d %H:%M:%S")
        first_ticket_delay_days = (first_ticket_date_obj - signup_date).days

    if first_ticket_delay_days > 90:
        churn_prob += 0.1 if segment == 'SMB' else 0.05

    churn_prob = min(churn_prob, 0.9)

    if random.random() < churn_prob:
        churn_date = fake.date_time_between(start_date=signup_date + timedelta(days=30), end_date=datetime.today()).strftime("%Y-%m-%d %H:%M:%S")
        cursor.execute("INSERT INTO churn_events VALUES (?, ?, ?, ?)", (
            churn_id, cust_id, churn_date, random.choice(CHURN_REASONS)
        ))
        churn_id += 1

print("[INFO] Inserted churn events.")

# ------------------------------
# App Installs per Location
# ------------------------------
install_id = 1
for location_id in range(1, len(OFFICE_LOCATIONS) + 1):
    for _ in range(random.randint(5, 12)):
        pid = random.randint(1, NUM_PRODUCTS_TOTAL)
        install_date = fake.date_time_between(start_date='-1y', end_date=datetime.today())
        cursor.execute("INSERT INTO app_installs VALUES (?, ?, ?, ?)", (
            install_id, location_id, pid, install_date.strftime("%Y-%m-%d %H:%M:%S")
        ))
        install_id += 1

print("[INFO] Inserted app installs.")

# ------------------------------
# Discounts and Order Discounts
# ------------------------------
for i in range(1, 51):
    code = f"SALE{i:02d}"
    percent = random.choice([5, 10, 15, 20, 25, 30])
    start = fake.date_time_between(start_date='-1y', end_date='-30d')
    end = start + timedelta(days=random.randint(7, 90))
    cursor.execute("INSERT INTO discounts VALUES (?, ?, ?, ?, ?)", (
        i, code, percent,
        start.strftime("%Y-%m-%d %H:%M:%S"),
        end.strftime("%Y-%m-%d %H:%M:%S")
    ))

cursor.execute("SELECT order_id FROM orders ORDER BY RANDOM() LIMIT 20000")
for row in cursor.fetchall():
    cursor.execute("INSERT INTO order_discounts VALUES (?, ?)", (row[0], random.randint(1, 50)))

print("[INFO] Inserted discounts and applied to orders.")


# ------------------------------
# Marketing Campaigns
# ------------------------------
campaigns = [
    ("Summer Splash Sale", "Paid Search", "Lead Gen", "2024-06-01", "2024-08-31", 50000),
    ("Black Friday Push", "Social Media", "Lead Gen", "2024-11-01", "2024-12-01", 120000),
    ("Organic Growth", "Organic", "Brand Awareness", "2023-01-01", "2025-01-01", 0)
]

for i, (name, channel, ctype, start, end, cost) in enumerate(campaigns, 1):
    cursor.execute("""
        INSERT INTO marketing_campaigns VALUES (?, ?, ?, ?, ?, ?, ?)
    """, (i, name, channel, ctype, start, end, cost))

print("[INFO] Sample marketing campaigns inserted.")

# ------------------------------
# Web Traffic Data (with AUTOINCREMENT handling)
# ------------------------------
channels = ['Paid Search', 'Social Media', 'Organic']
months = [datetime.now() - relativedelta(months=i) for i in range(0, 24)]

for month in months:
    for channel in channels:
        visitors = random.randint(10000, 30000) if channel != 'Organic' else random.randint(50000, 100000)
        leads = int(visitors * random.uniform(0.02, 0.05))
        mqls = int(leads * random.uniform(0.2, 0.4))
        cursor.execute("""
            INSERT INTO web_traffic (traffic_date, source_channel, visitors, leads, mqls)
            VALUES (?, ?, ?, ?, ?)
        """, (month.strftime("%Y-%m"), channel, visitors, leads, mqls))

print("[INFO] Sample web traffic data inserted.")


# ------------------------------
# Benchmarks
# ------------------------------
benchmarks = [
    ("Revenue KPIs", "All Segments", "MRR Target", 2000000, "Monthly recurring revenue goal"),
    ("Revenue KPIs", "All Segments", "NRR % Target", 120, "Target Net Revenue Retention percentage"),
    ("Revenue KPIs", "All Segments", "GRR % Target", 95, "Target Gross Revenue Retention percentage"),
    ("Customer KPIs", "All Segments", "Monthly Churn % Target", 3.5, "Target monthly churn rate"),
    ("Customer KPIs", "All Segments", "Monthly New Customers Target", 2000, "Target new customer acquisition volume"),
    ("Support KPIs", "All Segments", "Avg Resolution Time Target (hrs)", 48, "Target average resolution time for tickets"),
    ("Support KPIs", "All Segments", "Support to Churn Correlation %", 0.3, "Expected churn from high support volume"),
    ("Marketing KPIs", "All Segments", "MQL Conversion Rate %", 15, "Expected conversion from MQL to paying customer"),
    ("Marketing KPIs", "All Segments", "CAC Target", 500, "Customer acquisition cost target (USD)"),
    ("Revenue KPIs", "Enterprise", "ARPU Target", 1700, "Enterprise ARPU target"),
    ("Revenue KPIs", "Mid-Market", "ARPU Target", 1600, "Mid-Market ARPU target"),
    ("Revenue KPIs", "SMB", "ARPU Target", 1500, "SMB ARPU target"),

    # Add Retention % Targets by Segment
    ("Customer KPIs", "Enterprise", "Retention % Target", 90, "12-month retention target for Enterprise cohorts"),
    ("Customer KPIs", "Mid-Market", "Retention % Target", 80, "12-month retention target for Mid-Market cohorts"),
    ("Customer KPIs", "SMB", "Retention % Target", 70, "12-month retention target for SMB cohorts")
]


cursor.executemany("""
    INSERT INTO benchmarks (metric_category, segment, metric_name, target_value, description) 
    VALUES (?, ?, ?, ?, ?)
""", benchmarks)

print("[INFO] Sample benchmarks (global and segment-specific) inserted.")


# ------------------------------
# Finalize and Close Connection
# ------------------------------
conn.commit()
conn.close()

print("\n🎉 Hopify v15 (SaaS Full Lifecycle Dataset) created successfully! 🎉")
print("✅ Includes:")
print("- Dynamic multi-year historical data")
print("- Segment-aware subscriptions, churn, support, payments")
print("- Orders and product category skew by segment")
print("- Marketing campaigns, web traffic, lead conversions")
print("- Benchmarks for key SaaS and Marketing metrics")
print("- Full event timestamping and behavioral modeling")
print("- Cross-sell, upsell, support impact on churn, and more")
print("\n[INFO] All data has been committed and the connection has been closed.")
