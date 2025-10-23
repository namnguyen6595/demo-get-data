-- =============================================
-- Example Queries cho Category Table
-- Các câu truy vấn mẫu để sử dụng với cấu trúc category
-- =============================================

-- 1. Lấy tất cả categories theo cấp độ
SELECT 
    id,
    name,
    slug,
    level,
    parent_id,
    sort_order
FROM categories
WHERE is_active = true
ORDER BY level, parent_id, sort_order;

-- 2. Lấy tất cả root categories (level 0)
SELECT 
    id,
    name,
    slug,
    description
FROM categories
WHERE parent_id IS NULL AND is_active = true
ORDER BY sort_order;

-- 3. Lấy tất cả subcategories của một category cụ thể
SELECT 
    c.id,
    c.name,
    c.slug,
    c.level,
    c.sort_order
FROM categories c
WHERE c.parent_id = 1 -- Electronics
  AND c.is_active = true
ORDER BY c.sort_order;

-- 4. Lấy tất cả categories con (recursive) của một category
SELECT * FROM get_category_children(1); -- Electronics và tất cả subcategories

-- 5. Lấy tất cả categories cha (recursive) của một category
SELECT * FROM get_category_parents(45); -- iPhone 15 Pro Max và tất cả parent categories

-- 6. Lấy category tree với full path
SELECT 
    id,
    name,
    slug,
    level,
    display_name,
    full_path
FROM category_tree_view
ORDER BY level, sort_order;

-- 7. Lấy categories theo level cụ thể
SELECT 
    id,
    name,
    slug,
    parent_id
FROM categories
WHERE level = 2 AND is_active = true
ORDER BY parent_id, sort_order;

-- 8. Đếm số lượng subcategories của mỗi category
SELECT 
    p.id,
    p.name,
    p.slug,
    COUNT(c.id) as subcategory_count
FROM categories p
LEFT JOIN categories c ON p.id = c.parent_id AND c.is_active = true
WHERE p.is_active = true
GROUP BY p.id, p.name, p.slug
ORDER BY subcategory_count DESC;

-- 9. Lấy categories với thông tin parent
SELECT 
    c.id,
    c.name,
    c.slug,
    c.level,
    c.parent_id,
    p.name as parent_name,
    p.slug as parent_slug
FROM categories c
LEFT JOIN categories p ON c.parent_id = p.id
WHERE c.is_active = true
ORDER BY c.level, c.parent_id, c.sort_order;

-- 10. Tìm categories có tên chứa từ khóa
SELECT 
    id,
    name,
    slug,
    level,
    parent_id
FROM categories
WHERE name ILIKE '%phone%' AND is_active = true
ORDER BY level, sort_order;

-- 11. Lấy categories theo slug pattern
SELECT 
    id,
    name,
    slug,
    level,
    parent_id
FROM categories
WHERE slug LIKE 'iphone%' AND is_active = true
ORDER BY level, sort_order;

-- 12. Lấy categories có nhiều hơn 3 subcategories
SELECT 
    p.id,
    p.name,
    p.slug,
    COUNT(c.id) as subcategory_count
FROM categories p
LEFT JOIN categories c ON p.id = c.parent_id AND c.is_active = true
WHERE p.is_active = true
GROUP BY p.id, p.name, p.slug
HAVING COUNT(c.id) > 3
ORDER BY subcategory_count DESC;

-- 13. Lấy categories theo khoảng thời gian tạo
SELECT 
    id,
    name,
    slug,
    level,
    created_at
FROM categories
WHERE created_at >= '2024-01-01' 
  AND created_at < '2024-12-31'
  AND is_active = true
ORDER BY created_at DESC;

-- 14. Lấy categories inactive
SELECT 
    id,
    name,
    slug,
    level,
    parent_id,
    updated_at
FROM categories
WHERE is_active = false
ORDER BY updated_at DESC;

-- 15. Lấy category breadcrumb (path từ root đến category)
WITH RECURSIVE category_path AS (
    SELECT 
        id,
        name,
        slug,
        parent_id,
        level,
        name as path,
        1 as depth
    FROM categories
    WHERE id = 45 -- iPhone 15 Pro Max
    
    UNION ALL
    
    SELECT 
        c.id,
        c.name,
        c.slug,
        c.parent_id,
        c.level,
        c.name || ' > ' || cp.path as path,
        cp.depth + 1
    FROM categories c
    INNER JOIN category_path cp ON c.id = cp.parent_id
)
SELECT 
    id,
    name,
    slug,
    level,
    path,
    depth
FROM category_path
ORDER BY depth DESC;

-- 16. Lấy categories theo sort_order trong cùng level
SELECT 
    id,
    name,
    slug,
    level,
    parent_id,
    sort_order
FROM categories
WHERE parent_id = 1 -- Electronics subcategories
  AND is_active = true
ORDER BY sort_order;

-- 17. Cập nhật sort_order cho categories trong cùng level
-- Ví dụ: Đổi thứ tự của Smartphones và Laptops
UPDATE categories 
SET sort_order = 2 
WHERE id = 5; -- Smartphones

UPDATE categories 
SET sort_order = 1 
WHERE id = 6; -- Laptops

-- 18. Lấy categories với số lượng sản phẩm (giả sử có bảng products)
-- SELECT 
--     c.id,
--     c.name,
--     c.slug,
--     c.level,
--     COUNT(p.id) as product_count
-- FROM categories c
-- LEFT JOIN products p ON c.id = p.category_id AND p.is_active = true
-- WHERE c.is_active = true
-- GROUP BY c.id, c.name, c.slug, c.level
-- ORDER BY c.level, c.sort_order;

-- 19. Lấy categories theo mô tả
SELECT 
    id,
    name,
    slug,
    description,
    level
FROM categories
WHERE description ILIKE '%smartphone%' 
  AND is_active = true
ORDER BY level, sort_order;

-- 20. Lấy categories có slug trùng lặp (kiểm tra data integrity)
SELECT 
    slug,
    COUNT(*) as count
FROM categories
GROUP BY slug
HAVING COUNT(*) > 1;