-- =============================================
-- Category Table Schema - Hierarchical Structure
-- =============================================

-- Drop table if exists (for development)
DROP TABLE IF EXISTS categories CASCADE;

-- Create categories table
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    parent_id INTEGER NULL,
    level INTEGER NOT NULL DEFAULT 0,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    image_url VARCHAR(500),
    meta_title VARCHAR(255),
    meta_description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraint
    CONSTRAINT fk_categories_parent 
        FOREIGN KEY (parent_id) 
        REFERENCES categories(id) 
        ON DELETE CASCADE,
    
    -- Check constraint to prevent self-reference
    CONSTRAINT chk_categories_no_self_reference 
        CHECK (id != parent_id)
);

-- =============================================
-- Indexes for Performance Optimization
-- =============================================

-- Index for parent_id (most important for hierarchical queries)
CREATE INDEX idx_categories_parent_id ON categories(parent_id);

-- Index for level (useful for querying by depth)
CREATE INDEX idx_categories_level ON categories(level);

-- Index for active categories
CREATE INDEX idx_categories_active ON categories(is_active) WHERE is_active = TRUE;

-- Index for slug (for URL lookups)
CREATE INDEX idx_categories_slug ON categories(slug);

-- Composite index for parent_id + sort_order (for ordered children)
CREATE INDEX idx_categories_parent_sort ON categories(parent_id, sort_order);

-- =============================================
-- Functions for Hierarchical Operations
-- =============================================

-- Function to get all children of a category (recursive)
CREATE OR REPLACE FUNCTION get_category_children(category_id INTEGER)
RETURNS TABLE (
    id INTEGER,
    name VARCHAR(255),
    slug VARCHAR(255),
    level INTEGER,
    path TEXT
) AS $$
BEGIN
    RETURN QUERY
    WITH RECURSIVE category_tree AS (
        -- Base case: the category itself
        SELECT 
            c.id,
            c.name,
            c.slug,
            c.level,
            c.name::TEXT as path
        FROM categories c
        WHERE c.id = category_id
        
        UNION ALL
        
        -- Recursive case: children
        SELECT 
            c.id,
            c.name,
            c.slug,
            c.level,
            (ct.path || ' > ' || c.name)::TEXT as path
        FROM categories c
        INNER JOIN category_tree ct ON c.parent_id = ct.id
        WHERE c.is_active = TRUE
    )
    SELECT * FROM category_tree ORDER BY level, sort_order;
END;
$$ LANGUAGE plpgsql;

-- Function to get category path (breadcrumb)
CREATE OR REPLACE FUNCTION get_category_path(category_id INTEGER)
RETURNS TABLE (
    id INTEGER,
    name VARCHAR(255),
    slug VARCHAR(255),
    level INTEGER
) AS $$
BEGIN
    RETURN QUERY
    WITH RECURSIVE category_path AS (
        -- Base case: start from the given category
        SELECT 
            c.id,
            c.name,
            c.slug,
            c.level
        FROM categories c
        WHERE c.id = category_id
        
        UNION ALL
        
        -- Recursive case: go up to parent
        SELECT 
            c.id,
            c.name,
            c.slug,
            c.level
        FROM categories c
        INNER JOIN category_path cp ON c.id = cp.parent_id
    )
    SELECT * FROM category_path ORDER BY level;
END;
$$ LANGUAGE plpgsql;

-- Function to update category level (when parent changes)
CREATE OR REPLACE FUNCTION update_category_level()
RETURNS TRIGGER AS $$
BEGIN
    -- Update level based on parent
    IF NEW.parent_id IS NULL THEN
        NEW.level := 0;
    ELSE
        SELECT level + 1 INTO NEW.level 
        FROM categories 
        WHERE id = NEW.parent_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- Triggers
-- =============================================

-- Trigger to automatically update level when parent changes
CREATE TRIGGER trg_update_category_level
    BEFORE INSERT OR UPDATE ON categories
    FOR EACH ROW
    EXECUTE FUNCTION update_category_level();

-- Trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_categories_updated_at
    BEFORE UPDATE ON categories
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =============================================
-- Sample Data
-- =============================================

-- Insert root categories
INSERT INTO categories (name, slug, description, level, sort_order) VALUES
('Electronics', 'electronics', 'Electronic devices and gadgets', 0, 1),
('Clothing', 'clothing', 'Fashion and apparel', 0, 2),
('Books', 'books', 'Books and literature', 0, 3),
('Home & Garden', 'home-garden', 'Home improvement and gardening', 0, 4);

-- Insert Electronics subcategories
INSERT INTO categories (name, slug, description, parent_id, level, sort_order) VALUES
('Smartphones', 'smartphones', 'Mobile phones and accessories', 1, 1, 1),
('Laptops', 'laptops', 'Portable computers', 1, 1, 2),
('Tablets', 'tablets', 'Tablet computers', 1, 1, 3),
('Audio', 'audio', 'Headphones, speakers, and audio equipment', 1, 1, 4);

-- Insert Clothing subcategories
INSERT INTO categories (name, slug, description, parent_id, level, sort_order) VALUES
('Men''s Clothing', 'mens-clothing', 'Clothing for men', 2, 1, 1),
('Women''s Clothing', 'womens-clothing', 'Clothing for women', 2, 1, 2),
('Kids'' Clothing', 'kids-clothing', 'Clothing for children', 2, 1, 3),
('Shoes', 'shoes', 'Footwear for all ages', 2, 1, 4);

-- Insert third level categories (sub-subcategories)
INSERT INTO categories (name, slug, description, parent_id, level, sort_order) VALUES
('iPhone', 'iphone', 'Apple iPhone smartphones', 5, 2, 1),
('Samsung Galaxy', 'samsung-galaxy', 'Samsung Galaxy smartphones', 5, 2, 2),
('Android Phones', 'android-phones', 'Other Android smartphones', 5, 2, 3),
('Gaming Laptops', 'gaming-laptops', 'High-performance gaming laptops', 6, 2, 1),
('Business Laptops', 'business-laptops', 'Professional business laptops', 6, 2, 2),
('Student Laptops', 'student-laptops', 'Affordable laptops for students', 6, 2, 3);

-- =============================================
-- Useful Queries
-- =============================================

-- Query to get all root categories
-- SELECT * FROM categories WHERE parent_id IS NULL ORDER BY sort_order;

-- Query to get direct children of a category
-- SELECT * FROM categories WHERE parent_id = 1 AND is_active = TRUE ORDER BY sort_order;

-- Query to get all descendants of a category (using recursive CTE)
-- WITH RECURSIVE descendants AS (
--     SELECT * FROM categories WHERE id = 1
--     UNION ALL
--     SELECT c.* FROM categories c
--     INNER JOIN descendants d ON c.parent_id = d.id
-- )
-- SELECT * FROM descendants ORDER BY level, sort_order;

-- Query to get category breadcrumb
-- SELECT * FROM get_category_path(10);

-- Query to get all children of a category
-- SELECT * FROM get_category_children(1);