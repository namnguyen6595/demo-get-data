-- =====================================================
-- CATEGORY TABLE SCHEMA WITH HIERARCHICAL STRUCTURE
-- =====================================================
-- Sử dụng Adjacency List Model để tạo cấu trúc phân cấp
-- Mỗi category có thể có parent_id trỏ đến category cha

-- Tạo extension để sử dụng UUID (nếu chưa có)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tạo bảng categories
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    parent_id UUID REFERENCES categories(id) ON DELETE CASCADE,
    level INTEGER DEFAULT 0 NOT NULL,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    meta_title VARCHAR(255),
    meta_description TEXT,
    image_url VARCHAR(500),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    updated_by UUID
);

-- Tạo indexes để tối ưu performance
CREATE INDEX idx_categories_parent_id ON categories(parent_id);
CREATE INDEX idx_categories_slug ON categories(slug);
CREATE INDEX idx_categories_level ON categories(level);
CREATE INDEX idx_categories_is_active ON categories(is_active);
CREATE INDEX idx_categories_sort_order ON categories(sort_order);
CREATE INDEX idx_categories_created_at ON categories(created_at);

-- Tạo index composite cho truy vấn phổ biến
CREATE INDEX idx_categories_parent_active_sort ON categories(parent_id, is_active, sort_order);

-- Tạo function để tự động update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Tạo trigger để tự động update updated_at
CREATE TRIGGER update_categories_updated_at 
    BEFORE UPDATE ON categories 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Tạo function để tự động cập nhật level khi insert/update
CREATE OR REPLACE FUNCTION update_category_level()
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

-- Tạo trigger để tự động cập nhật level
CREATE TRIGGER update_category_level_trigger
    BEFORE INSERT OR UPDATE ON categories
    FOR EACH ROW
    EXECUTE FUNCTION update_category_level();

-- Tạo function để kiểm tra circular reference (tránh vòng lặp)
CREATE OR REPLACE FUNCTION check_category_circular_reference()
RETURNS TRIGGER AS $$
DECLARE
    current_id UUID;
    max_depth INTEGER := 10; -- Giới hạn độ sâu tối đa
    depth INTEGER := 0;
BEGIN
    -- Nếu parent_id là NULL thì không cần kiểm tra
    IF NEW.parent_id IS NULL THEN
        RETURN NEW;
    END IF;
    
    -- Nếu parent_id trỏ đến chính nó
    IF NEW.parent_id = NEW.id THEN
        RAISE EXCEPTION 'Category cannot be its own parent';
    END IF;
    
    -- Kiểm tra circular reference bằng cách đi ngược lên cây
    current_id := NEW.parent_id;
    
    WHILE current_id IS NOT NULL AND depth < max_depth LOOP
        -- Nếu tìm thấy chính nó trong chuỗi parent
        IF current_id = NEW.id THEN
            RAISE EXCEPTION 'Circular reference detected in category hierarchy';
        END IF;
        
        -- Lấy parent của current_id
        SELECT parent_id INTO current_id 
        FROM categories 
        WHERE id = current_id;
        
        depth := depth + 1;
    END LOOP;
    
    -- Kiểm tra độ sâu tối đa
    IF depth >= max_depth THEN
        RAISE EXCEPTION 'Category hierarchy depth exceeds maximum allowed level';
    END IF;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Tạo trigger để kiểm tra circular reference
CREATE TRIGGER check_category_circular_reference_trigger
    BEFORE INSERT OR UPDATE ON categories
    FOR EACH ROW
    EXECUTE FUNCTION check_category_circular_reference();

-- Tạo view để dễ dàng lấy thông tin category với path
CREATE OR REPLACE VIEW categories_with_path AS
WITH RECURSIVE category_path AS (
    -- Base case: categories gốc (không có parent)
    SELECT 
        id,
        name,
        slug,
        description,
        parent_id,
        level,
        sort_order,
        is_active,
        meta_title,
        meta_description,
        image_url,
        created_at,
        updated_at,
        name as path,
        slug as slug_path,
        ARRAY[id] as path_ids
    FROM categories 
    WHERE parent_id IS NULL
    
    UNION ALL
    
    -- Recursive case: categories con
    SELECT 
        c.id,
        c.name,
        c.slug,
        c.description,
        c.parent_id,
        c.level,
        c.sort_order,
        c.is_active,
        c.meta_title,
        c.meta_description,
        c.image_url,
        c.created_at,
        c.updated_at,
        cp.path || ' > ' || c.name as path,
        cp.slug_path || '/' || c.slug as slug_path,
        cp.path_ids || c.id as path_ids
    FROM categories c
    INNER JOIN category_path cp ON c.parent_id = cp.id
)
SELECT * FROM category_path;

-- Comments để mô tả các trường
COMMENT ON TABLE categories IS 'Bảng danh mục với cấu trúc phân cấp sử dụng Adjacency List Model';
COMMENT ON COLUMN categories.id IS 'ID duy nhất của category';
COMMENT ON COLUMN categories.name IS 'Tên hiển thị của category';
COMMENT ON COLUMN categories.slug IS 'URL-friendly name, duy nhất trong toàn bộ hệ thống';
COMMENT ON COLUMN categories.description IS 'Mô tả chi tiết về category';
COMMENT ON COLUMN categories.parent_id IS 'ID của category cha, NULL nếu là category gốc';
COMMENT ON COLUMN categories.level IS 'Cấp độ trong cây phân cấp (0 = gốc, 1 = cấp 1, ...)';
COMMENT ON COLUMN categories.sort_order IS 'Thứ tự sắp xếp trong cùng cấp';
COMMENT ON COLUMN categories.is_active IS 'Trạng thái hoạt động của category';
COMMENT ON COLUMN categories.meta_title IS 'Meta title cho SEO';
COMMENT ON COLUMN categories.meta_description IS 'Meta description cho SEO';
COMMENT ON COLUMN categories.image_url IS 'URL hình ảnh đại diện cho category';