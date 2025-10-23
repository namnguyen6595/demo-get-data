-- =====================================================
-- SAMPLE DATA FOR CATEGORY HIERARCHICAL STRUCTURE
-- =====================================================
-- Dữ liệu mẫu để minh họa cấu trúc phân cấp category

-- Xóa dữ liệu cũ (nếu có)
TRUNCATE TABLE categories RESTART IDENTITY CASCADE;

-- Insert root categories (Level 0)
INSERT INTO categories (id, name, slug, description, parent_id, sort_order, is_active) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'Điện tử', 'dien-tu', 'Danh mục các sản phẩm điện tử', NULL, 1, true),
('550e8400-e29b-41d4-a716-446655440002', 'Thời trang', 'thoi-trang', 'Danh mục thời trang và phụ kiện', NULL, 2, true),
('550e8400-e29b-41d4-a716-446655440003', 'Nhà cửa & Đời sống', 'nha-cua-doi-song', 'Danh mục đồ dùng gia đình', NULL, 3, true),
('550e8400-e29b-41d4-a716-446655440004', 'Sách & Văn phòng phẩm', 'sach-van-phong-pham', 'Sách và đồ dùng văn phòng', NULL, 4, true);

-- Insert level 1 categories (Children of root categories)
INSERT INTO categories (id, name, slug, description, parent_id, sort_order, is_active) VALUES
-- Children of Điện tử
('550e8400-e29b-41d4-a716-446655440011', 'Điện thoại & Phụ kiện', 'dien-thoai-phu-kien', 'Điện thoại di động và phụ kiện', '550e8400-e29b-41d4-a716-446655440001', 1, true),
('550e8400-e29b-41d4-a716-446655440012', 'Máy tính & Laptop', 'may-tinh-laptop', 'Máy tính để bàn và laptop', '550e8400-e29b-41d4-a716-446655440001', 2, true),
('550e8400-e29b-41d4-a716-446655440013', 'Thiết bị âm thanh', 'thiet-bi-am-thanh', 'Loa, tai nghe, âm thanh', '550e8400-e29b-41d4-a716-446655440001', 3, true),

-- Children of Thời trang
('550e8400-e29b-41d4-a716-446655440021', 'Thời trang Nam', 'thoi-trang-nam', 'Quần áo và phụ kiện nam', '550e8400-e29b-41d4-a716-446655440002', 1, true),
('550e8400-e29b-41d4-a716-446655440022', 'Thời trang Nữ', 'thoi-trang-nu', 'Quần áo và phụ kiện nữ', '550e8400-e29b-41d4-a716-446655440002', 2, true),
('550e8400-e29b-41d4-a716-446655440023', 'Giày dép', 'giay-dep', 'Giày dép nam nữ', '550e8400-e29b-41d4-a716-446655440002', 3, true),

-- Children of Nhà cửa & Đời sống
('550e8400-e29b-41d4-a716-446655440031', 'Nội thất', 'noi-that', 'Bàn ghế, tủ kệ, nội thất', '550e8400-e29b-41d4-a716-446655440003', 1, true),
('550e8400-e29b-41d4-a716-446655440032', 'Đồ gia dụng', 'do-gia-dung', 'Đồ dùng nhà bếp, gia dụng', '550e8400-e29b-41d4-a716-446655440003', 2, true);

-- Insert level 2 categories (Grandchildren)
INSERT INTO categories (id, name, slug, description, parent_id, sort_order, is_active) VALUES
-- Children of Điện thoại & Phụ kiện
('550e8400-e29b-41d4-a716-446655440111', 'iPhone', 'iphone', 'Điện thoại iPhone', '550e8400-e29b-41d4-a716-446655440011', 1, true),
('550e8400-e29b-41d4-a716-446655440112', 'Samsung', 'samsung', 'Điện thoại Samsung', '550e8400-e29b-41d4-a716-446655440011', 2, true),
('550e8400-e29b-41d4-a716-446655440113', 'Ốp lưng & Bao da', 'op-lung-bao-da', 'Phụ kiện bảo vệ điện thoại', '550e8400-e29b-41d4-a716-446655440011', 3, true),
('550e8400-e29b-41d4-a716-446655440114', 'Sạc & Cáp', 'sac-cap', 'Sạc và cáp kết nối', '550e8400-e29b-41d4-a716-446655440011', 4, true),

-- Children of Máy tính & Laptop
('550e8400-e29b-41d4-a716-446655440121', 'Laptop Gaming', 'laptop-gaming', 'Laptop chơi game', '550e8400-e29b-41d4-a716-446655440012', 1, true),
('550e8400-e29b-41d4-a716-446655440122', 'Laptop Văn phòng', 'laptop-van-phong', 'Laptop cho công việc', '550e8400-e29b-41d4-a716-446655440012', 2, true),
('550e8400-e29b-41d4-a716-446655440123', 'PC Gaming', 'pc-gaming', 'Máy tính để bàn gaming', '550e8400-e29b-41d4-a716-446655440012', 3, true),

-- Children of Thời trang Nam
('550e8400-e29b-41d4-a716-446655440211', 'Áo sơ mi Nam', 'ao-so-mi-nam', 'Áo sơ mi nam các loại', '550e8400-e29b-41d4-a716-446655440021', 1, true),
('550e8400-e29b-41d4-a716-446655440212', 'Quần Jean Nam', 'quan-jean-nam', 'Quần jean nam', '550e8400-e29b-41d4-a716-446655440021', 2, true),
('550e8400-e29b-41d4-a716-446655440213', 'Áo thun Nam', 'ao-thun-nam', 'Áo thun nam', '550e8400-e29b-41d4-a716-446655440021', 3, true),

-- Children of Thời trang Nữ
('550e8400-e29b-41d4-a716-446655440221', 'Váy đầm', 'vay-dam', 'Váy đầm nữ các loại', '550e8400-e29b-41d4-a716-446655440022', 1, true),
('550e8400-e29b-41d4-a716-446655440222', 'Áo kiểu Nữ', 'ao-kieu-nu', 'Áo kiểu nữ', '550e8400-e29b-41d4-a716-446655440022', 2, true),
('550e8400-e29b-41d4-a716-446655440223', 'Quần Jean Nữ', 'quan-jean-nu', 'Quần jean nữ', '550e8400-e29b-41d4-a716-446655440022', 3, true);

-- Insert level 3 categories (Great-grandchildren)
INSERT INTO categories (id, name, slug, description, parent_id, sort_order, is_active) VALUES
-- Children of iPhone
('550e8400-e29b-41d4-a716-446655441111', 'iPhone 15 Series', 'iphone-15-series', 'iPhone 15, 15 Plus, 15 Pro, 15 Pro Max', '550e8400-e29b-41d4-a716-446655440111', 1, true),
('550e8400-e29b-41d4-a716-446655441112', 'iPhone 14 Series', 'iphone-14-series', 'iPhone 14, 14 Plus, 14 Pro, 14 Pro Max', '550e8400-e29b-41d4-a716-446655440111', 2, true),
('550e8400-e29b-41d4-a716-446655441113', 'iPhone 13 Series', 'iphone-13-series', 'iPhone 13, 13 Mini, 13 Pro, 13 Pro Max', '550e8400-e29b-41d4-a716-446655440111', 3, true),

-- Children of Samsung
('550e8400-e29b-41d4-a716-446655441121', 'Galaxy S Series', 'galaxy-s-series', 'Samsung Galaxy S flagship', '550e8400-e29b-41d4-a716-446655440112', 1, true),
('550e8400-e29b-41d4-a716-446655441122', 'Galaxy A Series', 'galaxy-a-series', 'Samsung Galaxy A mid-range', '550e8400-e29b-41d4-a716-446655440112', 2, true),
('550e8400-e29b-41d4-a716-446655441123', 'Galaxy Note Series', 'galaxy-note-series', 'Samsung Galaxy Note', '550e8400-e29b-41d4-a716-446655440112', 3, true);

-- Hiển thị thống kê sau khi insert
SELECT 
    level,
    COUNT(*) as category_count,
    STRING_AGG(name, ', ' ORDER BY sort_order) as categories
FROM categories 
GROUP BY level 
ORDER BY level;

-- Hiển thị cấu trúc cây đầy đủ
SELECT 
    REPEAT('  ', level) || '├─ ' || name as tree_structure,
    level,
    slug,
    CASE WHEN parent_id IS NULL THEN 'ROOT' ELSE 'CHILD' END as type
FROM categories 
ORDER BY 
    COALESCE(
        (SELECT string_agg(lpad(sort_order::text, 3, '0'), '' ORDER BY lvl) 
         FROM (
             WITH RECURSIVE path AS (
                 SELECT id, parent_id, sort_order, 0 as lvl
                 FROM categories c1 
                 WHERE c1.id = categories.id
                 
                 UNION ALL
                 
                 SELECT c2.id, c2.parent_id, c2.sort_order, p.lvl + 1
                 FROM categories c2
                 INNER JOIN path p ON c2.id = p.parent_id
             )
             SELECT sort_order, lvl FROM path ORDER BY lvl DESC
         ) sub), 
        lpad(sort_order::text, 3, '0')
    );