-- Migration script to create dimensions table

CREATE TABLE dimensions (
    id SERIAL PRIMARY KEY,
    dimension_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);