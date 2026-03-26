-- Sample Snowflake Table Creation Script

-- Creating a sample table for users
CREATE TABLE users (
    user_id INT AUTOINCREMENT PRIMARY KEY,
    username STRING NOT NULL,
    email STRING NOT NULL UNIQUE,
    password STRING NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Creating a sample table for orders
CREATE TABLE orders (
    order_id INT AUTOINCREMENT PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10, 2) NOT NULL,
    status STRING DEFAULT 'PENDING'
);

-- Creating a sample table for products
CREATE TABLE products (
    product_id INT AUTOINCREMENT PRIMARY KEY,
    product_name STRING NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Creating a many-to-many relationship table between users and products
CREATE TABLE user_favorites (
    user_id INT REFERENCES users(user_id),
    product_id INT REFERENCES products(product_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, product_id)
);