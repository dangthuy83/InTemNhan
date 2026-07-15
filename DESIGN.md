# DESIGN.md

> Single Source of Truth cho current architecture và current design của LabelPrint.

## Metadata

- Trạng thái tài liệu: Active với documented gaps.
- Design authority: Đỗ Đăng Thủy.
- Cập nhật gần nhất: `2026-07-13`.
- Review gần nhất: `2026-07-13`.

## System context

LabelPrint là ứng dụng ASP.NET Core MVC chạy trong mạng LAN nội bộ. Người dùng thao tác bằng trình duyệt; ứng dụng và MySQL chạy trên một máy nội bộ, các máy người dùng truy cập qua LAN.

## Technology stack

- .NET 8 ASP.NET Core MVC và Razor Views.
- Dapper `2.1.35`.
- MySql.Data `9.1.0` và MySQL.
- ClosedXML `0.105.0`.
- Microsoft.AspNetCore.Mvc.Razor.RuntimeCompilation `8.0.0`.
- Bootstrap 5 và Bootstrap Icons theo project convention hiện hữu.

Phiên bản package được xác minh từ `LabelPrint.csproj`; Bootstrap-related design được xác minh từ project instruction/source usage nhưng chưa có dependency lock riêng trong project.

## Architecture pattern

Pattern ưu tiên là:

```text
Controller → Service → Repository → Database
```

Đây là preferred pattern, không phải mandatory invariant. [D-002](DECISIONS.md#d-002--preferred-layering-pattern) sở hữu rationale lịch sử.

## Accepted current design exceptions

- `CaSanXuatController` truy cập repository trực tiếp.
- `CauHinhController` truy cập repository trực tiếp và sử dụng `MayTinhService`.
- Đây là current design đã được Design authority chấp nhận, không phải technical debt mặc định.

Xem [D-003](DECISIONS.md#d-003--direct-repository-access-trong-hai-controller).

## Components and responsibilities

| Component | Trách nhiệm hiện hành | Source evidence |
|---|---|---|
| Controllers | MVC endpoints và request/response handling | `Controllers/Controllers.cs` |
| Services | Business/application processing cho module dùng service layer | `Services/Services.cs` |
| Repositories | Dapper queries, transactions và database access | `Data/Repositories/` |
| Domain models | Database/domain mapping và DateOnly handler | `Models/DomainModels.cs` |
| JSON models | Template và layout configuration | `Models/JsonModels/CauHinhModels.cs` |
| ViewModels | Dữ liệu controller–view và API result | `Models/ViewModels/ViewModels.cs` |
| Razor Views | Nhập liệu, cấu hình, lịch sử, template editor và print preview | `Views/` |
| MayTinhService | Runtime mapping giữa địa chỉ máy và tên máy | `Services/Services.cs` |

## Project file grouping

Project chủ động gom nhiều class vào các shared files:

- `Controllers/Controllers.cs`.
- `Models/DomainModels.cs`.
- `Models/JsonModels/CauHinhModels.cs`.
- `Models/ViewModels/ViewModels.cs`.
- `Data/Repositories/Interfaces/IRepositories.cs`.
- `Data/Repositories/Implementations/Repositories.cs`.
- `Services/Services.cs`.

Đây là current project convention; thay đổi cấu trúc cần phân tích ảnh hưởng và xác nhận riêng.

## Data and configuration design

- Dapper dùng `MatchNamesWithUnderscores = true`.
- `DateOnlyTypeHandler` được đăng ký trong startup.
- Repository hiện dùng MySQL user variable trong một query renumber; connection configuration phải hỗ trợ behavior này.
- `lich_su_in_tem` lưu metadata mẫu in tại thời điểm đóng phiên gồm `ma_mau_in`, `ten_mau_in` và `kho_giay`; lịch sử ưu tiên hiển thị snapshot `ten_mau_in` thay vì join tên mẫu hiện tại.
- Runtime có thể tải shared configuration theo path cấu hình hoặc dùng local configuration fallback.
- Raw credential, connection string, internal IP và hostname không thuộc tài liệu project.
- Runtime machine mapping là sensitive local configuration, không phải Project Knowledge.

## Build output design

`Directory.Build.props` chuyển intermediate/output sang `build/obj` và `build/bin`, đồng thời loại `obj/**` và `bin/**` cũ khỏi default compile inputs. Các thư mục `bin/`, `obj/`, `build/` là generated artifacts, không phải verification evidence mặc định.

## Database schema boundary

- `database/Schemas.sql` được authority xác nhận là script production.
- Script chứa destructive `DROP` statements.
- Không được chạy trên database thật nếu chưa có approval riêng.
- Repository schema artifact không tự chứng minh live database state.
- Không có live-database validation trong documentation-remediation session.

Xem [D-004](DECISIONS.md#d-004--database-schema-execution-boundary).

## Transaction and concurrency design

Source hiện có transaction, row locking và uniqueness protection cho một số luồng phiên in. Đây là implemented design được quan sát tĩnh; chưa có runtime concurrency evidence trong migration.

## Runtime Compilation divergence

- Implemented state: `AddRazorRuntimeCompilation()` đang được gọi không điều kiện trong `Program.cs`.
- Intended environment policy: Chưa quyết định.
- Không tuyên bố runtime compilation chỉ dành cho Development hoặc mọi environment cho đến khi Design authority quyết định.

## Frontend design

- Frontend là server-rendered Razor Views, dùng Bootstrap-based UI.
- Người dùng thao tác bằng trình duyệt trong LAN.
- Project có nhập liệu phiên in, lịch sử, cấu hình, template editor và print preview.
- Màn hình lịch sử in tem hiển thị mẫu in sau cột thời gian in; dữ liệu cũ thiếu mẫu dùng fallback hiển thị rõ ràng.
- Physical print output phải phù hợp phôi in sẵn.
- Responsive, accessibility và Visual QA acceptance chưa được authority xác định đầy đủ.
- Impeccable profile chưa được xác định; thiếu capability không được làm thay đổi Product behavior hoặc stack.

## Security and trust boundaries

- LAN nội bộ không tự đồng nghĩa toàn bộ input đều trusted.
- Database credential, connection string và machine mappings là sensitive.
- Kết nối database thật và thực thi production schema cần approval riêng.
- Static discovery chưa xác nhận policy hoàn chỉnh cho authentication, authorization và antiforgery.
- Không tự tạo security behavior hoặc sửa code trong documentation migration.

## Known design gaps and divergences

| ID | Type | Description | Sources in tension | Impact | Next action |
|---|---|---|---|---|---|
| DG-001 | Gap | Razor Runtime Compilation policy chưa quyết định | Product/Design authority và `Program.cs` | Chưa thể khẳng định environment policy | Clarify |
| DG-002 | Gap | Live database schema chưa được đối chiếu | `database/Schemas.sql` và unknown runtime state | Không chứng minh production schema parity | Approval-gated verification |
| DG-003 | Gap | Product requirements chưa được phân loại đầy đủ | PRODUCT gaps và implemented features | Chưa thể trace đầy đủ Design về Product | Product review |
| DG-004 | Gap | Frontend acceptance/QA criteria chưa xác định | Current UI và missing Product expectations | Hạn chế review completion | Clarify |
| DG-005 | Gap | Test strategy chưa được xác định | Source project và không có test project | Không có automated verification baseline | Planning decision |

Direct repository access trong hai controller không còn được ghi là divergence vì authority đã xác nhận đó là accepted current design.

## Traceability

- Product: [PRODUCT.md](PRODUCT.md).
- Historical rationale: [DECISIONS.md](DECISIONS.md).
- Candidate work: [TASKS.md](TASKS.md).
