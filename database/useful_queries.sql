-- =====================================================
-- USEFUL QUERIES FOR HIERARCHICAL CATEGORY STRUCTURE
-- =====================================================
-- Các query hữu ích để làm việc với cấu trúc phân cấp category

-- =====================================================
-- 1. LẤY TOÀN BỘ CÂY PHÂN CẤP VỚI ĐỊNH DẠNG TREE
-- =====================================================
WITH RECURSIVE category_tree AS (
    -- Base case: Lấy tất cả root categories
    SELECT 
        id,
        name,
        slug,
        parent_id,
        level,
        sort_order,
        is_active,
        name as path,
        ARRAY[sort_order] as sort_path,
        REPEAT('  ', level) || '├─ ' || name as tree_display
    FROM categories 
    WHERE parent_id IS NULL
    
    UNION ALL
    
    -- Recursive case: Lấy children
    SELECT 
        c.id,
        c.name,
        c.slug,
        c.parent_id,
        c.level,
        c.sort_order,
        c.is_active,
        ct.path || ' > ' || c.name as path,
        ct.sort_path || c.sort_order as sort_path,
        REPEAT('  ', c.level) || '├─ ' || c.name as tree_display
    FROM categories c
    INNER JOIN category_tree ct ON c.parent_id = ct.id
)
SELECT 
    tree_display,
    name,
    slug,
    level,
    path,
    is_active
FROM category_tree 
ORDER BY sort_path;

-- =====================================================
-- 2. LẤY TẤT CẢ CON CỦA MỘT CATEGORY (DESCENDANTS)
-- =====================================================
-- Thay 'dien-tu' bằng slug của category muốn tìm
WITH RECURSIVE descendants AS (
    -- Base case: Category gốc
    SELECT 
        id, name, slug, parent_id, level, 0 as relative_level
    FROM categories 
    WHERE slug = 'dien-tu'
    
    UNION ALL
    
    -- Recursive case: Tìm tất cả con
    SELECT 
        c.id, c.name, c.slug, c.parent_id, c.level, d.relative_level + 1
    FROM categories c
    INNER JOIN descendants d ON c.parent_id = d.id
)
SELECT 
    REPEAT('  ', relative_level) || name as indented_name,
    name,
    slug,
    level,
    relative_level
FROM descendants 
ORDER BY level, name;

-- =====================================================
-- 3. LẤY ĐƯỜNG DẪN TỪ ROOT ĐẾN MỘT CATEGORY (ANCESTORS)
-- =====================================================
-- Thay 'iphone-15-series' bằng slug của category muốn tìm
WITH RECURSIVE ancestors AS (
    -- Base case: Category hiện tại
    SELECT 
        id, name, slug, parent_id, level, 0 as distance_from_target
    FROM categories 
    WHERE slug = 'iphone-15-series'
    
    UNION ALL
    
    -- Recursive case: Đi ngược lên parent
    SELECT 
        c.id, c.name, c.slug, c.parent_id, c.level, a.distance_from_target + 1
    FROM categories c
    INNER JOIN ancestors a ON c.id = a.parent_id
)
SELECT 
    name,
    slug,
    level,
    distance_from_target,
    STRING_AGG(name, ' > ' ORDER BY level) OVER (
        ORDER BY level ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) as breadcrumb
FROM ancestors 
ORDER BY level;

-- =====================================================
-- 4. LẤY CHILDREN TRỰC TIẾP CỦA MỘT CATEGORY
-- =====================================================
SELECT 
    c.name,
    c.slug,
    c.description,
    c.level,
    c.sort_order,
    c.is_active,
    COUNT(child.id) as children_count
FROM categories c
LEFT JOIN categories child ON child.parent_id = c.id
WHERE c.slug = 'thoi-trang'  -- Thay bằng slug của parent category
GROUP BY c.id, c.name, c.slug, c.description, c.level, c.sort_order, c.is_active
ORDER BY c.sort_order;

-- =====================================================
-- 5. ĐẾM SỐ LƯỢNG CON Ở MỖI CẤP
-- =====================================================
SELECT 
    p.name as parent_name,
    p.slug as parent_slug,
    p.level as parent_level,
    COUNT(c.id) as direct_children_count,
    STRING_AGG(c.name, ', ' ORDER BY c.sort_order) as children_names
FROM categories p
LEFT JOIN categories c ON c.parent_id = p.id
GROUP BY p.id, p.name, p.slug, p.level
HAVING COUNT(c.id) > 0
ORDER BY p.level, p.sort_order;

-- =====================================================
-- 6. TÌM KIẾM CATEGORY THEO TÊN (FULL-TEXT SEARCH)
-- =====================================================
SELECT 
    name,
    slug,
    description,
    level,
    (SELECT STRING_AGG(anc.name, ' > ' ORDER BY anc.level) 
     FROM (
         WITH RECURSIVE ancestors AS (
             SELECT id, name, parent_id, level
             FROM categories 
             WHERE id = categories.id
             
             UNION ALL
             
             SELECT c.id, c.name, c.parent_id, c.level
             FROM categories c
             INNER JOIN ancestors a ON c.id = a.parent_id
         )
         SELECT name, level FROM ancestors ORDER BY level
     ) anc
    ) as full_path
FROM categories 
WHERE 
    is_active = true 
    AND (
        name ILIKE '%phone%' OR 
        description ILIKE '%phone%' OR
        slug ILIKE '%phone%'
    )
ORDER BY level, name;

-- =====================================================
-- 7. LẤY CATEGORY VỚI THÔNG TIN THỐNG KÊ
-- =====================================================
WITH category_stats AS (
    SELECT 
        c.id,
        c.name,
        c.slug,
        c.level,
        c.parent_id,
        -- Đếm số children trực tiếp
        (SELECT COUNT(*) FROM categories WHERE parent_id = c.id) as direct_children,
        -- Đếm tổng số descendants
        (WITH RECURSIVE descendants AS (
            SELECT id FROM categories WHERE parent_id = c.id
            UNION ALL
            SELECT cat.id FROM categories cat
            INNER JOIN descendants d ON cat.parent_id = d.id
        ) SELECT COUNT(*) FROM descendants) as total_descendants,
        -- Kiểm tra có phải leaf node không
        CASE WHEN NOT EXISTS(SELECT 1 FROM categories WHERE parent_id = c.id) 
             THEN true ELSE false END as is_leaf
    FROM categories c
)
SELECT 
    REPEAT('  ', level) || name as indented_name,
    slug,
    level,
    direct_children,
    total_descendants,
    is_leaf,
    CASE 
        WHEN level = 0 THEN 'Root Category'
        WHEN is_leaf THEN 'Leaf Category'
        ELSE 'Branch Category'
    END as category_type
FROM category_stats
ORDER BY level, name;

-- =====================================================
-- 8. KIỂM TRA TÍNH TOÀN VẸN CỦA CẤU TRÚC CÂY
-- =====================================================
-- Kiểm tra các vấn đề có thể xảy ra trong cấu trúc cây
SELECT 
    'Orphaned Categories' as issue_type,
    COUNT(*) as count,
    STRING_AGG(name, ', ') as affected_categories
FROM categories 
WHERE parent_id IS NOT NULL 
  AND parent_id NOT IN (SELECT id FROM categories)

UNION ALL

SELECT 
    'Inactive Parents with Active Children' as issue_type,
    COUNT(DISTINCT c.parent_id) as count,
    STRING_AGG(DISTINCT p.name, ', ') as affected_categories
FROM categories c
JOIN categories p ON c.parent_id = p.id
WHERE c.is_active = true AND p.is_active = false

UNION ALL

SELECT 
    'Categories with Incorrect Level' as issue_type,
    COUNT(*) as count,
    STRING_AGG(c.name, ', ') as affected_categories
FROM categories c
LEFT JOIN categories p ON c.parent_id = p.id
WHERE (c.parent_id IS NULL AND c.level != 0) 
   OR (c.parent_id IS NOT NULL AND c.level != p.level + 1);

-- =====================================================
-- 9. CẬP NHẬT SORT_ORDER CHO TẤT CẢ CHILDREN CỦA MỘT PARENT
-- =====================================================
-- Function để reorder children của một parent category
CREATE OR REPLACE FUNCTION reorder_category_children(parent_category_id UUID)
RETURNS VOID AS $$
BEGIN
    WITH ordered_children AS (
        SELECT id, ROW_NUMBER() OVER (ORDER BY name) as new_order
        FROM categories 
        WHERE parent_id = parent_category_id
    )
    UPDATE categories 
    SET sort_order = oc.new_order
    FROM ordered_children oc
    WHERE categories.id = oc.id;
END;
$$ LANGUAGE plpgsql;

-- Sử dụng: SELECT reorder_category_children('550e8400-e29b-41d4-a716-446655440001');

-- =====================================================
-- 10. DI CHUYỂN MỘT CATEGORY VÀ TẤT CẢ CON CỦA NÓ
-- =====================================================
-- Function để di chuyển một category sang parent mới
CREATE OR REPLACE FUNCTION move_category(
    category_id UUID, 
    new_parent_id UUID DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
    -- Kiểm tra circular reference trước khi di chuyển
    IF new_parent_id IS NOT NULL THEN
        WITH RECURSIVE check_path AS (
            SELECT id, parent_id FROM categories WHERE id = new_parent_id
            UNION ALL
            SELECT c.id, c.parent_id 
            FROM categories c
            JOIN check_path cp ON c.parent_id = cp.id
        )
        SELECT COUNT(*) INTO @temp_count
        FROM check_path 
        WHERE id = category_id;
        
        IF @temp_count > 0 THEN
            RAISE EXCEPTION 'Cannot move category: would create circular reference';
        END IF;
    END IF;
    
    -- Cập nhật parent_id
    UPDATE categories 
    SET parent_id = new_parent_id
    WHERE id = category_id;
    
    -- Trigger sẽ tự động cập nhật level cho category này và tất cả descendants
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 11. XÓA CATEGORY VÀ XỬ LÝ CHILDREN
-- =====================================================
-- Function để xóa category với các tùy chọn xử lý children
CREATE OR REPLACE FUNCTION delete_category_with_options(
    category_id UUID,
    handle_children TEXT DEFAULT 'move_to_parent' -- 'move_to_parent', 'delete_all', 'promote_to_root'
)
RETURNS VOID AS $$
DECLARE
    parent_of_deleted UUID;
BEGIN
    -- Lấy parent_id của category sẽ bị xóa
    SELECT parent_id INTO parent_of_deleted 
    FROM categories 
    WHERE id = category_id;
    
    -- Xử lý children theo option
    CASE handle_children
        WHEN 'move_to_parent' THEN
            -- Di chuyển tất cả children lên parent của category bị xóa
            UPDATE categories 
            SET parent_id = parent_of_deleted
            WHERE parent_id = category_id;
            
        WHEN 'promote_to_root' THEN
            -- Đưa tất cả children thành root categories
            UPDATE categories 
            SET parent_id = NULL
            WHERE parent_id = category_id;
            
        WHEN 'delete_all' THEN
            -- Xóa tất cả descendants (CASCADE sẽ xử lý)
            NULL; -- Không cần làm gì, CASCADE sẽ xử lý
    END CASE;
    
    -- Xóa category
    DELETE FROM categories WHERE id = category_id;
END;
$$ LANGUAGE plpgsql;