-- =============================================
-- Sample Data cho Category Table
-- Dữ liệu mẫu để test cấu trúc category
-- =============================================

-- Xóa dữ liệu cũ (nếu có)
DELETE FROM categories;

-- Reset sequence
ALTER SEQUENCE categories_id_seq RESTART WITH 1;

-- Insert dữ liệu mẫu
INSERT INTO categories (name, slug, description, parent_id, sort_order, is_active) VALUES
-- Level 0 - Root categories
('Electronics', 'electronics', 'Electronic devices and gadgets', NULL, 1, true),
('Clothing', 'clothing', 'Fashion and apparel', NULL, 2, true),
('Books', 'books', 'Books and publications', NULL, 3, true),
('Home & Garden', 'home-garden', 'Home improvement and gardening', NULL, 4, true),

-- Level 1 - Electronics subcategories
('Smartphones', 'smartphones', 'Mobile phones and accessories', 1, 1, true),
('Laptops', 'laptops', 'Laptop computers and accessories', 1, 2, true),
('Audio & Video', 'audio-video', 'Audio and video equipment', 1, 3, true),
('Gaming', 'gaming', 'Gaming consoles and accessories', 1, 4, true),

-- Level 1 - Clothing subcategories
('Men''s Clothing', 'mens-clothing', 'Clothing for men', 2, 1, true),
('Women''s Clothing', 'womens-clothing', 'Clothing for women', 2, 2, true),
('Kids'' Clothing', 'kids-clothing', 'Clothing for children', 2, 3, true),
('Accessories', 'accessories', 'Fashion accessories', 2, 4, true),

-- Level 1 - Books subcategories
('Fiction', 'fiction', 'Fiction books', 3, 1, true),
('Non-Fiction', 'non-fiction', 'Non-fiction books', 3, 2, true),
('Educational', 'educational', 'Educational books and textbooks', 3, 3, true),
('Children''s Books', 'childrens-books', 'Books for children', 3, 4, true),

-- Level 1 - Home & Garden subcategories
('Furniture', 'furniture', 'Home furniture', 4, 1, true),
('Kitchen & Dining', 'kitchen-dining', 'Kitchen and dining items', 4, 2, true),
('Garden Tools', 'garden-tools', 'Gardening tools and equipment', 4, 3, true),
('Home Decor', 'home-decor', 'Home decoration items', 4, 4, true),

-- Level 2 - Smartphones subcategories
('iPhone', 'iphone', 'Apple iPhone smartphones', 5, 1, true),
('Samsung Galaxy', 'samsung-galaxy', 'Samsung Galaxy smartphones', 5, 2, true),
('Google Pixel', 'google-pixel', 'Google Pixel smartphones', 5, 3, true),
('Other Brands', 'other-smartphones', 'Other smartphone brands', 5, 4, true),

-- Level 2 - Laptops subcategories
('MacBook', 'macbook', 'Apple MacBook laptops', 6, 1, true),
('Windows Laptops', 'windows-laptops', 'Windows-based laptops', 6, 2, true),
('Chromebooks', 'chromebooks', 'Google Chromebook laptops', 6, 3, true),
('Gaming Laptops', 'gaming-laptops', 'High-performance gaming laptops', 6, 4, true),

-- Level 2 - Men's Clothing subcategories
('Shirts', 'mens-shirts', 'Men''s shirts and tops', 9, 1, true),
('Pants', 'mens-pants', 'Men''s pants and trousers', 9, 2, true),
('Shoes', 'mens-shoes', 'Men''s footwear', 9, 3, true),
('Outerwear', 'mens-outerwear', 'Men''s jackets and coats', 9, 4, true),

-- Level 2 - Women's Clothing subcategories
('Dresses', 'womens-dresses', 'Women''s dresses', 10, 1, true),
('Tops', 'womens-tops', 'Women''s tops and blouses', 10, 2, true),
('Bottoms', 'womens-bottoms', 'Women''s pants and skirts', 10, 3, true),
('Shoes', 'womens-shoes', 'Women''s footwear', 10, 4, true),

-- Level 2 - Fiction subcategories
('Mystery & Thriller', 'mystery-thriller', 'Mystery and thriller novels', 13, 1, true),
('Romance', 'romance', 'Romance novels', 13, 2, true),
('Science Fiction', 'science-fiction', 'Science fiction books', 13, 3, true),
('Fantasy', 'fantasy', 'Fantasy novels', 13, 4, true),

-- Level 2 - Furniture subcategories
('Living Room', 'living-room-furniture', 'Living room furniture', 17, 1, true),
('Bedroom', 'bedroom-furniture', 'Bedroom furniture', 17, 2, true),
('Dining Room', 'dining-room-furniture', 'Dining room furniture', 17, 3, true),
('Office', 'office-furniture', 'Office furniture', 17, 4, true),

-- Level 3 - iPhone subcategories
('iPhone 15 Series', 'iphone-15-series', 'Latest iPhone 15 models', 21, 1, true),
('iPhone 14 Series', 'iphone-14-series', 'iPhone 14 models', 21, 2, true),
('iPhone 13 Series', 'iphone-13-series', 'iPhone 13 models', 21, 3, true),
('iPhone Accessories', 'iphone-accessories', 'iPhone cases and accessories', 21, 4, true),

-- Level 3 - MacBook subcategories
('MacBook Pro', 'macbook-pro', 'MacBook Pro laptops', 25, 1, true),
('MacBook Air', 'macbook-air', 'MacBook Air laptops', 25, 2, true),
('MacBook Accessories', 'macbook-accessories', 'MacBook cases and accessories', 25, 3, true),

-- Level 3 - Men's Shirts subcategories
('Dress Shirts', 'mens-dress-shirts', 'Formal dress shirts', 29, 1, true),
('Casual Shirts', 'mens-casual-shirts', 'Casual shirts and t-shirts', 29, 2, true),
('Polo Shirts', 'mens-polo-shirts', 'Polo shirts', 29, 3, true),

-- Level 3 - Women's Dresses subcategories
('Evening Dresses', 'womens-evening-dresses', 'Formal evening dresses', 33, 1, true),
('Casual Dresses', 'womens-casual-dresses', 'Casual day dresses', 33, 2, true),
('Summer Dresses', 'womens-summer-dresses', 'Light summer dresses', 33, 3, true),

-- Level 3 - Mystery & Thriller subcategories
('Detective Stories', 'detective-stories', 'Classic detective novels', 37, 1, true),
('Psychological Thrillers', 'psychological-thrillers', 'Psychological thriller novels', 37, 2, true),
('Crime Fiction', 'crime-fiction', 'Crime and mystery fiction', 37, 3, true),

-- Level 3 - Living Room Furniture subcategories
('Sofas', 'sofas', 'Living room sofas and couches', 41, 1, true),
('Coffee Tables', 'coffee-tables', 'Coffee and side tables', 41, 2, true),
('TV Stands', 'tv-stands', 'TV stands and entertainment centers', 41, 3, true),

-- Level 4 - iPhone 15 Series subcategories
('iPhone 15 Pro Max', 'iphone-15-pro-max', 'iPhone 15 Pro Max model', 45, 1, true),
('iPhone 15 Pro', 'iphone-15-pro', 'iPhone 15 Pro model', 45, 2, true),
('iPhone 15 Plus', 'iphone-15-plus', 'iPhone 15 Plus model', 45, 3, true),
('iPhone 15', 'iphone-15', 'iPhone 15 base model', 45, 4, true);

-- Cập nhật lại level cho tất cả categories (để đảm bảo tính chính xác)
UPDATE categories SET level = (
    WITH RECURSIVE category_levels AS (
        SELECT id, 0 as calculated_level
        FROM categories
        WHERE parent_id IS NULL
        
        UNION ALL
        
        SELECT c.id, cl.calculated_level + 1
        FROM categories c
        INNER JOIN category_levels cl ON c.parent_id = cl.id
    )
    SELECT calculated_level
    FROM category_levels
    WHERE category_levels.id = categories.id
);

-- Hiển thị kết quả
SELECT 
    id,
    name,
    slug,
    level,
    parent_id,
    sort_order,
    is_active,
    created_at
FROM categories
ORDER BY level, parent_id, sort_order;