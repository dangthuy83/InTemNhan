# TASKS.md

> Single Source of Truth cho actionable work items và trạng thái task.

## Metadata

- Task owner/planner: Đỗ Đăng Thủy.
- Current milestone: Chưa được đặt tên chính thức.
- Review gần nhất: `2026-07-14`.

## Status vocabulary

- `Candidate`: Cần authority review trước khi trở thành task.
- `Proposed`: Đã được đề xuất nhưng chưa Ready.
- `Ready`: Scope, dependencies, acceptance và verification đủ để bắt đầu.
- `In Progress`: Đang thực hiện.
- `Blocked`: Có blocker explicit.
- `Review`: Đang chờ review hoặc verification.
- `Completed`: Acceptance và required verification đã đạt.
- `Partial`, `Failed`, `Skipped`, `Deferred`: Dùng theo completion evidence và authority tương ứng.

## Active Tasks

Chưa có active task được Task owner xác nhận.

## Completed tasks

| ID | Outcome | Status | Evidence |
|---|---|---|---|
| T-001 | Lịch sử in tem hiển thị mẫu in đã sử dụng sau cột thời gian in; tìm kiếm/lọc hỗ trợ tên/mã mẫu; Excel export giữ nguyên không thêm mẫu in | Completed | `2026-07-15`, `dotnet build` exit code `0`, `0` warnings, `0` errors |

## Candidate work requiring authority review

Các mục dưới đây chưa phải committed tasks và không có trạng thái Ready/In Progress:

| ID | Candidate outcome | Source | Readiness gap |
|---|---|---|---|
| CT-001 | Xác định Product goals | [PRODUCT.md#goals](PRODUCT.md#goals) | Thiếu Product authority decision về nội dung |
| CT-002 | Xác định Product non-goals | [PRODUCT.md#non-goals](PRODUCT.md#non-goals) | Thiếu Product authority decision về nội dung |
| CT-003 | Xác định current objective, active task và next action | [WORKING_CONTEXT.md](WORKING_CONTEXT.md) | Chưa được Project owner quyết định |
| CT-004 | Quyết định Razor Runtime Compilation policy | [DESIGN.md#runtime-compilation-divergence](DESIGN.md#runtime-compilation-divergence) | Intended environment policy chưa quyết định |
| CT-005 | Xác định test strategy | [DESIGN.md#known-design-gaps-and-divergences](DESIGN.md#known-design-gaps-and-divergences) | Chưa có test project hoặc required verification baseline |
| CT-006 | Review security boundary cho endpoints ghi/xóa | [DESIGN.md#security-and-trust-boundaries](DESIGN.md#security-and-trust-boundaries) | Cần xác định scope và acceptance trước khi thành task |
| CT-007 | Xác định frontend responsive/accessibility/Visual QA expectations | [DESIGN.md#frontend-design](DESIGN.md#frontend-design) | Thiếu Product/Design acceptance |
| CT-008 | Đối chiếu repository schema với database thật | [DESIGN.md#database-schema-boundary](DESIGN.md#database-schema-boundary) | Cần approval riêng để kết nối database thật |
| CT-009 | Sửa `MauIn/Editor`: không đổi được mẫu in mặc định và field label không hiện khi field value rỗng dù đã bật hiện tên trường | User request `2026-07-15` | Cần phase Analyze/Design/Implement riêng, kiểm tra editor save/default-template flow và print/editor label rendering |

## Verification state

| Method | Status | Evidence/limitation |
|---|---|---|
| `dotnet restore` | Verified | HEAD `88542d440c5b9dfabbf875866025ba0d9f277c69`, `2026-07-14`; exit code `0`, `0` warnings, `0` errors; packages up-to-date, chưa chứng minh network download/cache-cold restore |
| `dotnet build` | Verified | HEAD `88542d440c5b9dfabbf875866025ba0d9f277c69`, `2026-07-14`; approved retry exit code `0`, `0` warnings, `0` errors; sandbox attempt trước đó exit code `1` với environment-specific `MSB3491` |
| `dotnet run` | Unverified | Không chạy; database/environment gate vẫn áp dụng |
| `dotnet test` | Not configured | Chưa phát hiện test project |
| Database verification | Not performed | Cần approval riêng |

## Ownership boundary

Candidate item không tự trở thành Product Requirement, Roadmap commitment hoặc active task. Task owner phải xác nhận objective, scope, source, acceptance và verification trước khi đổi trạng thái.
