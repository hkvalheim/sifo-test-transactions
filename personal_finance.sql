CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    sifo_code VARCHAR(50),
    description TEXT,
    parent_id INTEGER REFERENCES categories(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    booking_date DATE NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    sender VARCHAR(255),
    receiver VARCHAR(255),
    name VARCHAR(255),
    title VARCHAR(255),
    currency VARCHAR(3),
    payment_type VARCHAR(50),
    category_id INTEGER REFERENCES categories(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE category_keywords (
    id SERIAL PRIMARY KEY,
    category_id INTEGER REFERENCES categories(id),
    keyword VARCHAR(100) NOT NULL,
    weight DECIMAL(3,2) DEFAULT 1.0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
