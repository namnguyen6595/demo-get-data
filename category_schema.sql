-- =============================================
-- Category Table Schema
-- Hệ thống quản lý category với khả năng có category con
-- =============================================

-- Tạo bảng categories
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    parent_id INTEGER REFERENCES categories(id) ON DELETE CASCADE,
    level INTEGER NOT NULL DEFAULT 0,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tạo indexes để tối ưu performance
CREATE INDEX idx_categories_parent_id ON categories(parent_id);
CREATE INDEX idx_categories_level ON categories(level);
CREATE INDEX idx_categories_slug ON categories(slug);
CREATE INDEX idx_categories_is_active ON categories(is_active);
CREATE INDEX idx_categories_sort_order ON categories(sort_order);
CREATE INDEX idx_categories_parent_sort ON categories(parent_id, sort_order);

-- Tạo function để tự động cập nhật updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Tạo trigger để tự động cập nhật updated_at
CREATE TRIGGER update_categories_updated_at 
    BEFORE UPDATE ON categories 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Tạo function để tính level tự động
CREATE OR REPLACE FUNCTION calculate_category_level()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.parent_id IS NULL THEN
        NEW.level = 0;
    ELSE
        SELECT level + 1 INTO NEW.level 
        FROM categories 
        WHERE id = NEW.parent_id;
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Tạo trigger để tự động tính level
CREATE TRIGGER calculate_categories_level
    BEFORE INSERT OR UPDATE ON categories
    FOR EACH ROW
    EXECUTE FUNCTION calculate_category_level();

-- Tạo function để lấy tất cả category con (recursive)
CREATE OR REPLACE FUNCTION get_category_children(category_id INTEGER)
RETURNS TABLE(
    id INTEGER,
    name VARCHAR(255),
    slug VARCHAR(255),
    level INTEGER,
    parent_id INTEGER,
    path TEXT
) AS $$
BEGIN
    RETURN QUERY
    WITH RECURSIVE category_tree AS (
        -- Base case: category gốc
        SELECT 
            c.id,
            c.name,
            c.slug,
            c.level,
            c.parent_id,
            c.name::TEXT as path
        FROM categories c
        WHERE c.id = category_id
        
        UNION ALL
        
        -- Recursive case: các category con
        SELECT 
            c.id,
            c.name,
            c.slug,
            c.level,
            c.parent_id,
            (ct.path || ' > ' || c.name)::TEXT as path
        FROM categories c
        INNER JOIN category_tree ct ON c.parent_id = ct.id
        WHERE c.is_active = true
    )
    SELECT * FROM category_tree ORDER BY level, sort_order;
END;
$$ LANGUAGE plpgsql;

-- Tạo function để lấy tất cả category cha (recursive)
CREATE OR REPLACE FUNCTION get_category_parents(category_id INTEGER)
RETURNS TABLE(
    id INTEGER,
    name VARCHAR(255),
    slug VARCHAR(255),
    level INTEGER,
    parent_id INTEGER,
    path TEXT
) AS $$
BEGIN
    RETURN QUERY
    WITH RECURSIVE category_tree AS (
        -- Base case: category hiện tại
        SELECT 
            c.id,
            c.name,
            c.slug,
            c.level,
            c.parent_id,
            c.name::TEXT as path
        FROM categories c
        WHERE c.id = category_id
        
        UNION ALL
        
        -- Recursive case: các category cha
        SELECT 
            c.id,
            c.name,
            c.slug,
            c.level,
            c.parent_id,
            (c.name || ' > ' || ct.path)::TEXT as path
        FROM categories c
        INNER JOIN category_tree ct ON c.id = ct.parent_id
        WHERE c.is_active = true
    )
    SELECT * FROM category_tree ORDER BY level;
END;
$$ LANGUAGE plpgsql;

-- Tạo function để kiểm tra circular reference
CREATE OR REPLACE FUNCTION check_circular_reference()
RETURNS TRIGGER AS $$
BEGIN
    -- Nếu parent_id = id thì là circular reference
    IF NEW.parent_id = NEW.id THEN
        RAISE EXCEPTION 'Category cannot be its own parent';
    END IF;
    
    -- Kiểm tra circular reference trong cây phân cấp
    IF NEW.parent_id IS NOT NULL THEN
        IF EXISTS (
            WITH RECURSIVE category_tree AS (
                SELECT id, parent_id
                FROM categories
                WHERE id = NEW.parent_id
                
                UNION ALL
                
                SELECT c.id, c.parent_id
                FROM categories c
                INNER JOIN category_tree ct ON c.id = ct.parent_id
            )
            SELECT 1 FROM category_tree WHERE id = NEW.id
        ) THEN
            RAISE EXCEPTION 'Circular reference detected';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Tạo trigger để kiểm tra circular reference
CREATE TRIGGER check_categories_circular_reference
    BEFORE INSERT OR UPDATE ON categories
    FOR EACH ROW
    EXECUTE FUNCTION check_circular_reference();

-- Tạo view để dễ dàng query category với thông tin cha
CREATE VIEW category_with_parent AS
SELECT 
    c.id,
    c.name,
    c.slug,
    c.description,
    c.parent_id,
    c.level,
    c.sort_order,
    c.is_active,
    c.created_at,
    c.updated_at,
    p.name as parent_name,
    p.slug as parent_slug
FROM categories c
LEFT JOIN categories p ON c.parent_id = p.id;

-- Tạo view để hiển thị category tree
CREATE VIEW category_tree_view AS
SELECT 
    c.id,
    c.name,
    c.slug,
    c.level,
    c.parent_id,
    c.is_active,
    REPEAT('  ', c.level) || c.name as display_name,
    CASE 
        WHEN c.parent_id IS NULL THEN c.name
        ELSE (
            WITH RECURSIVE path_tree AS (
                SELECT id, name, parent_id, name as path
                FROM categories
                WHERE id = c.parent_id
                
                UNION ALL
                
                SELECT c2.id, c2.name, c2.parent_id, c2.name || ' > ' || pt.path
                FROM categories c2
                INNER JOIN path_tree pt ON c2.id = pt.parent_id
            )
            SELECT path FROM path_tree WHERE parent_id IS NULL
        ) || ' > ' || c.name
    END as full_path
FROM categories c
WHERE c.is_active = true
ORDER BY c.level, c.sort_order, c.name;