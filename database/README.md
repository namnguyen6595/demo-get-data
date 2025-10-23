# Cấu trúc Database Category với Hierarchical Structure

## Tổng quan

Hệ thống category này được thiết kế sử dụng **Adjacency List Model** để tạo cấu trúc phân cấp (hierarchical structure) trong PostgreSQL. Mỗi category có thể có một hoặc nhiều category con, tạo thành cây phân cấp không giới hạn độ sâu.

## Cấu trúc Files

```
database/
├── category_schema.sql    # Schema chính với bảng, indexes, triggers
├── sample_data.sql       # Dữ liệu mẫu minh họa
├── useful_queries.sql    # Các query hữu ích thường dùng
└── README.md            # Tài liệu hướng dẫn
```

## Đặc điểm chính

### 1. Cấu trúc bảng `categories`

| Trường | Kiểu dữ liệu | Mô tả |
|--------|-------------|--------|
| `id` | UUID | Primary key, tự động generate |
| `name` | VARCHAR(255) | Tên hiển thị của category |
| `slug` | VARCHAR(255) | URL-friendly name, unique |
| `description` | TEXT | Mô tả chi tiết |
| `parent_id` | UUID | Foreign key tự tham chiếu, NULL = root |
| `level` | INTEGER | Cấp độ trong cây (0=root, 1=level1...) |
| `sort_order` | INTEGER | Thứ tự sắp xếp trong cùng cấp |
| `is_active` | BOOLEAN | Trạng thái hoạt động |
| `meta_title` | VARCHAR(255) | SEO meta title |
| `meta_description` | TEXT | SEO meta description |
| `image_url` | VARCHAR(500) | URL hình ảnh đại diện |
| `created_at` | TIMESTAMP | Thời gian tạo |
| `updated_at` | TIMESTAMP | Thời gian cập nhật |

### 2. Tính năng tự động

- **Auto-update `updated_at`**: Tự động cập nhật khi có thay đổi
- **Auto-calculate `level`**: Tự động tính toán cấp độ dựa trên parent
- **Circular reference prevention**: Ngăn chặn tham chiếu vòng tròn
- **Depth limit**: Giới hạn độ sâu tối đa (mặc định 10 cấp)

### 3. Indexes được tối ưu

- `idx_categories_parent_id`: Tối ưu truy vấn children
- `idx_categories_slug`: Tối ưu tìm kiếm theo slug
- `idx_categories_level`: Tối ưu truy vấn theo cấp độ
- `idx_categories_parent_active_sort`: Composite index cho truy vấn phổ biến

## Cách sử dụng

### 1. Khởi tạo database

```sql
-- Chạy lần lượt các file sau:
\i database/category_schema.sql
\i database/sample_data.sql
```

### 2. Các thao tác cơ bản

#### Thêm category mới
```sql
INSERT INTO categories (name, slug, description, parent_id, sort_order) 
VALUES ('Tên category', 'slug-category', 'Mô tả', 'parent-uuid', 1);
```

#### Lấy tất cả children của một category
```sql
WITH RECURSIVE children AS (
    SELECT * FROM categories WHERE slug = 'parent-slug'
    UNION ALL
    SELECT c.* FROM categories c
    JOIN children p ON c.parent_id = p.id
)
SELECT * FROM children;
```

#### Lấy breadcrumb path
```sql
SELECT * FROM categories_with_path WHERE slug = 'target-slug';
```

### 3. Sử dụng các function có sẵn

```sql
-- Sắp xếp lại children theo alphabet
SELECT reorder_category_children('parent-uuid');

-- Di chuyển category sang parent mới
SELECT move_category('category-uuid', 'new-parent-uuid');

-- Xóa category với xử lý children
SELECT delete_category_with_options('category-uuid', 'move_to_parent');
```

## Ví dụ cấu trúc dữ liệu

```
Điện tử (Level 0)
├─ Điện thoại & Phụ kiện (Level 1)
│  ├─ iPhone (Level 2)
│  │  ├─ iPhone 15 Series (Level 3)
│  │  ├─ iPhone 14 Series (Level 3)
│  │  └─ iPhone 13 Series (Level 3)
│  ├─ Samsung (Level 2)
│  │  ├─ Galaxy S Series (Level 3)
│  │  ├─ Galaxy A Series (Level 3)
│  │  └─ Galaxy Note Series (Level 3)
│  ├─ Ốp lưng & Bao da (Level 2)
│  └─ Sạc & Cáp (Level 2)
├─ Máy tính & Laptop (Level 1)
│  ├─ Laptop Gaming (Level 2)
│  ├─ Laptop Văn phòng (Level 2)
│  └─ PC Gaming (Level 2)
└─ Thiết bị âm thanh (Level 1)
```

## Ưu điểm của thiết kế này

1. **Đơn giản**: Dễ hiểu và implement
2. **Linh hoạt**: Không giới hạn số lượng cấp độ
3. **Performance**: Indexes được tối ưu cho các truy vấn phổ biến
4. **An toàn**: Có các trigger kiểm tra tính toàn vẹn dữ liệu
5. **Mở rộng**: Dễ dàng thêm các trường mới khi cần

## Lưu ý khi sử dụng

1. **Không xóa trực tiếp**: Sử dụng function `delete_category_with_options()` để xử lý children
2. **Kiểm tra circular reference**: Hệ thống tự động kiểm tra, nhưng nên cẩn thận khi di chuyển category
3. **Backup trước khi thay đổi**: Luôn backup database trước khi thực hiện các thao tác lớn
4. **Performance với dữ liệu lớn**: Với hàng triệu records, cân nhắc sử dụng Materialized Path hoặc Nested Set Model

## Queries thường dùng

Tham khảo file `useful_queries.sql` để có danh sách đầy đủ các query hữu ích cho:
- Hiển thị cây phân cấp
- Tìm kiếm category
- Lấy ancestors/descendants
- Thống kê và báo cáo
- Kiểm tra tính toàn vẹn dữ liệu