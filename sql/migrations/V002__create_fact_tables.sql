-- Migration to create fact tables

CREATE TABLE IF NOT EXISTS fact_sales (
    id SERIAL PRIMARY KEY,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    sales_date DATE NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE TABLE IF NOT EXISTS fact_inventory (
    id SERIAL PRIMARY KEY,
    product_id INT NOT NULL,
    inventory_date DATE NOT NULL,
    quantity_in_stock INT NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Additional fact tables can be added here.