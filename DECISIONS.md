# DECISIONS.md

> Historical Record cho các Project Decisions đã được Đỗ Đăng Thủy chấp thuận.

## Metadata

- Decision authority: Đỗ Đăng Thủy.
- Review gần nhất: `2026-07-13`.
- Maintenance rule: Thay đổi semantics bằng Decision superseding; không rewrite chronology để thay đổi nghĩa lịch sử.

## Decision index

| ID | Title | Status | Date |
|---|---|---|---|
| D-001 | In lại sử dụng template hiện hành | Accepted | 2026-07-09 |
| D-002 | Controller–Service–Repository là preferred pattern | Accepted | 2026-07-13 |
| D-003 | Direct repository access trong hai controller là current design | Accepted | 2026-07-13 |
| D-004 | `Schemas.sql` là production script với approval gate | Accepted | 2026-07-13 |

## D-001 — In lại sử dụng template hiện hành

- Status: Accepted.
- Date: `2026-07-09`.
- Decision authority: Đỗ Đăng Thủy.
- Related sources: [PRODUCT.md#behavioral-rules](PRODUCT.md#behavioral-rules), `MEMORY/06_bugs_fixed_gotchas.md`, related implementation in `Services/Services.cs`.
- Supersession: Không có.

### Context

Template hoặc phôi in sẵn có thể thay đổi sau lần in ban đầu. Khi in lại, output cần phù hợp phôi hiện hành. Project cũng cần xác định mức lịch sử cần lưu cho reprint.

### Decision

- Không lưu snapshot template vào lịch sử in.
- In lại sử dụng template hiện tại theo `ma_mau_in`.
- Chỉ fallback sang template mặc định khi lịch sử không có `ma_mau_in` hoặc template gốc đã bị xóa.
- Hiện chỉ ghi nhận số lần in lại; chưa lưu lịch sử chi tiết của từng lần in lại.

### Rationale

Sử dụng template hiện tại giúp bản in lại phù hợp với phôi hiện hành thay vì cố tái tạo layout cũ không còn phù hợp. Lịch sử chi tiết từng lần in lại chưa được xác định là nhu cầu cần mở rộng schema.

### Consequences

- Reprint có thể khác layout ban đầu nếu template hiện hành đã thay đổi.
- Nếu cần audit chi tiết từng lần in lại, phải thiết kế log/schema riêng và xin xác nhận DB/schema.
- Product behavior hiện hành phải trace về Decision này.

## D-002 — Preferred layering pattern

- Status: Accepted.
- Date: `2026-07-13`.
- Decision authority: Đỗ Đăng Thủy.
- Related sources: [DESIGN.md#architecture-pattern](DESIGN.md#architecture-pattern), [AGENTS.md#architecture-and-file-conventions](AGENTS.md#architecture-and-file-conventions).
- Supersession: Nội dung này làm rõ wording mandatory trước đây trong legacy `AGENTS.md`.

### Context

Legacy project instruction mô tả mọi data flow bắt buộc đi qua Controller, Service, Repository và DB, trong khi implementation có module truy cập repository trực tiếp.

### Decision

`Controller → Service → Repository → DB` là preferred pattern, không phải mandatory invariant.

### Rationale

Layering vẫn là hướng thiết kế ưu tiên, nhưng project cho phép module đơn giản sử dụng repository trực tiếp khi current design được authority chấp nhận.

### Consequences

- Tính hợp lệ của direct repository access được đánh giá theo module cụ thể.
- Không tự kết luận mọi bypass service layer là defect.
- AGENTS và Design phải dùng wording `preferred`.

## D-003 — Direct repository access trong hai controller

- Status: Accepted.
- Date: `2026-07-13`.
- Decision authority: Đỗ Đăng Thủy.
- Related sources: [DESIGN.md#accepted-current-design-exceptions](DESIGN.md#accepted-current-design-exceptions), `Controllers/Controllers.cs`.
- Supersession: Không có.

### Context

`CaSanXuatController` và `CauHinhController` đang truy cập repository trực tiếp; `CauHinhController` còn sử dụng `MayTinhService`.

### Decision

Các dependency trên là current design được chấp nhận.

### Rationale

Design authority không yêu cầu thêm service layer chỉ để đồng nhất hình thức với các module khác.

### Consequences

- Không tự tạo technical-debt task hoặc refactor cho hai controller này.
- Nếu behavior hoặc complexity thay đổi, architecture có thể được review lại bằng Decision mới.

## D-004 — Database schema execution boundary

- Status: Accepted.
- Date: `2026-07-13`.
- Decision authority: Đỗ Đăng Thủy.
- Related sources: [DESIGN.md#database-schema-boundary](DESIGN.md#database-schema-boundary), [AGENTS.md#database-safety](AGENTS.md#database-safety), `database/Schemas.sql`.
- Supersession: Không có.

### Context

`database/Schemas.sql` là schema artifact có destructive `DROP` statements và có thể tác động database đang phục vụ người dùng.

### Decision

- `database/Schemas.sql` là script production.
- Chỉ được chạy trên database thật khi có approval riêng.

### Rationale

Explicit approval gate bảo vệ dữ liệu thật và buộc người thực hiện xác nhận target, impact, recovery và authorization trước khi chạy destructive script.

### Consequences

- Script không thuộc normal restore/build/test/run verification.
- Không được tự động thực thi.
- Repository file không tự chứng minh live database đang khớp schema.
