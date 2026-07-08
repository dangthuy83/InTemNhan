# LabelPrint — Tổng quan Project

## Mục đích
Ứng dụng in tem nhãn sản xuất, thay thế hệ thống VBA/Excel cũ. Triển khai LAN nội bộ.

## Tech Stack
- **.NET 8 MVC** + Razor Views
- **Dapper** (ORM nhẹ, map snake_case → PascalCase tự động qua `MatchNamesWithUnderscores = true`)
- **MySql.Data** — DB: `payroll_db` trên MySQL
- **Bootstrap 5** + Bootstrap Icons (`bi-*`)
- **ClosedXML** — xuất Excel
- Razor Runtime Compilation bật trong Development
- Ưu tiên code dễ bảo trì.
- Không tự ý đổi cấu trúc dự án nếu chưa phân tích ảnh hưởng.

## Cấu trúc thư mục
```
LabelPrintFull/
├── Controllers/Controllers.cs          ← 6 controllers trong 1 file
├── Models/
│   ├── DomainModels.cs                 ← Entity classes + DateOnlyTypeHandler
│   ├── JsonModels/CauHinhModels.cs     ← CauHinhTruong, LayoutMauIn, CauHinhMauIn
│   └── ViewModels/ViewModels.cs        ← ViewModels + ApiResult<T>
├── Data/
│   ├── DbConnectionFactory.cs
│   └── Repositories/
│       ├── Interfaces/IRepositories.cs ← 7 interfaces
│       └── Implementations/Repositories.cs ← 7 repository classes
├── Services/Services.cs                ← 3 interfaces + 4 service classes
├── Views/
│   ├── Shared/_Layout.cshtml
│   ├── Home/Index.cshtml, Error.cshtml
│   ├── PhienIn/Index.cshtml, Print.cshtml
│   ├── LichSu/Index.cshtml, TimKiem.cshtml
│   ├── MauIn/Editor.cshtml
│   ├── CaSanXuat/Index.cshtml
│   └── CauHinh/Index.cshtml
├── wwwroot/css/site.css
├── Program.cs
├── appsettings.json
└── may_tinh.json                       ← map IP → tên máy (runtime file)
```

## Connection String
```
Server=127.0.0.1;Database=payroll_db;Uid=...;CharSet=utf8mb4;SslMode=none;Allow User Variables=True;
```
> **`Allow User Variables=True`** bắt buộc — dùng trong `ChiTietRepository.XoaAsync` (SET @r=0)
> **Lưu ý vận hành**: database `payroll_db` hiện đang lưu dữ liệu thật. Không tự chạy migration, seed, truncate, delete hàng loạt, hoặc thao tác dữ liệu trực tiếp nếu chưa được xác nhận rõ.

## DI Registration (Program.cs)
```csharp
builder.Services.AddScoped<IPhienInRepository,   PhienInRepository>();
builder.Services.AddScoped<IChiTietRepository,   ChiTietRepository>();
builder.Services.AddScoped<ILichSuRepository,    LichSuRepository>();
builder.Services.AddScoped<IMauInRepository,     MauInRepository>();
builder.Services.AddScoped<ICaSanXuatRepository, CaSanXuatRepository>();
builder.Services.AddScoped<IDropdownRepository,  DropdownRepository>();
builder.Services.AddScoped<ICauHinhRepository,   CauHinhRepository>();
builder.Services.AddScoped<IPhienInService,      PhienInService>();
builder.Services.AddScoped<IMauInService,        MauInService>();
builder.Services.AddScoped<IPrintService,        PrintService>();
builder.Services.AddSingleton<MayTinhService>();   // ← Singleton, đọc may_tinh.json
```

## Dapper Setup
```csharp
Dapper.DefaultTypeMap.MatchNamesWithUnderscores = true;  // ma_phien → MaPhien
Dapper.SqlMapper.AddTypeHandler(new DateOnlyTypeHandler()); // DateOnly từ MySQL
```

## Pattern kiến trúc
**Controller → Service → Repository → DB**

Thứ tự triển khai tính năng mới:
1. SQL schema / stored procedure
2. DomainModels.cs
3. IRepositories.cs (interface)
4. Repositories.cs (implementation)
5. Services.cs (interface + implementation)
6. Controllers.cs
7. Views

## Preferences làm việc
- Hiểu kiến trúc dự án trước khi sửa code.
- **Xác nhận thiết kế trước khi code**
- Giao tiếp bằng **tiếng Việt**
- Cập nhật lại memory mỗi khi có thay đổi lớn hoặc khi có phương án được xác nhận
- GitHub repo chính: `https://github.com/dangthuy83/InTemNhan.git`.
- Từ 2026-07-08: sau các thay đổi code hoặc các xác nhận thiết kế/cần theo dõi, commit và push lên GitHub khi người dùng yêu cầu/đã thống nhất. Không commit secret/runtime config thật như `appsettings*.json` và `may_tinh.json`; dùng các file `*.example.json` đã sanitize.
