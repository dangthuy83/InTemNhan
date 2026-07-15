# WORKING_CONTEXT.md

> RAM nhẹ của project: current focus, blocker, handoff và next action cho lần tiếp tục kế tiếp.

## Session handoff metadata

- Cập nhật: `2026-07-15`, Asia/Bangkok.
- Cập nhật bởi: Codex theo approval của Đỗ Đăng Thủy.
- Lifecycle: Đang phát triển và tiếp tục hoàn thiện.
- Current milestone: Chưa được đặt tên chính thức.
- Active task refs: Chưa có active task được xác nhận.

## Current objective

Current delivery objective chưa được Project owner quyết định. Phiên `2026-07-15` đã hoàn tất task hiển thị mẫu in đã sử dụng trong lịch sử in tem và task `MauIn/Editor` về đổi mẫu mặc định/hiển thị tên trường khi value rỗng.

## Active scope

Chưa có delivery scope đang active.

## Current status

- Completion state: Task hiển thị mẫu in trong lịch sử `completed`; Technical Baseline Verification trước đó `passed_with_limitations`.
- Lịch sử in tem hiện hiển thị mẫu in sau cột thời gian in, dùng snapshot `ten_mau_in`/fallback theo `ma_mau_in`, và tìm kiếm/lọc hỗ trợ tên/mã mẫu; Excel export không thêm cột mẫu in theo yêu cầu.
- `MauIn/Editor` đã xử lý lưu/đổi mẫu in mặc định nhất quán hơn: cập nhật nội dung mẫu không ghi đè `la_mac_dinh`, đặt mặc định đi qua transaction riêng và editor reload sau khi lưu để badge/checkbox phản ánh DB mới.
- Print preview/output đã cho phép field có bật hiện tên trường vẫn render label/prefix khi value rỗng; giữ hành vi ẩn field rỗng nếu không bật hiện tên trường.
- Ứng dụng cơ bản đáp ứng nhu cầu ban đầu và đã được triển khai thực tế.
- Exact deployed application commit: `f6432734ccc979dd6d8646debd6d0d54d1e2b24f`.
- Documentation-migration baseline: `92fac6a21ae4f3f18739b06babb24925251bea2f`.
- Framework pin: `804aea8d024b760ef853f1d5a182e5cc176d0990`.
- Documentation remediation: Đã thực hiện.
- Post-remediation documentation validation: Đã hoàn tất; links, anchors, Markdown structure, provenance, ownership và sensitive-data boundary đã được kiểm tra.
- Technical Baseline Verification: `dotnet restore` và `dotnet build` đã Verified ngày `2026-07-14` tại exact HEAD `88542d440c5b9dfabbf875866025ba0d9f277c69`.
- Delivery verification `2026-07-15`: `dotnet build` exit code `0`, `0` warnings, `0` errors sau thay đổi lịch sử mẫu in.
- Delivery verification `2026-07-15`: `dotnet build` exit code `0`, `0` warnings, `0` errors sau thay đổi `MauIn/Editor` và print label rendering.
- Remaining limitations: cache-cold/network restore, `dotnet run`, runtime configuration, automated tests, database connection/schema, browser/render và physical print chưa được verified; `dotnet test` hiện Not configured.

## Confirmed continuation facts

- Project/Product/Design/Decision/Roadmap/Task/Release authority: Đỗ Đăng Thủy — Source: owner confirmation.
- `MEMORY/` được giữ làm supporting/historical source và không còn là Project SSOT — Source: [AGENTS.md](AGENTS.md).
- Kết nối database thật và chạy `database/Schemas.sql` cần approval riêng — Source: [D-004](DECISIONS.md#d-004--database-schema-execution-boundary).
- Restore/build đã Verified tại exact HEAD `88542d440c5b9dfabbf875866025ba0d9f277c69`; run chưa verified và test chưa configured — Source: [AGENTS.md#commands-and-verification](AGENTS.md#commands-and-verification).

## Blockers, gaps and pending approvals

| ID | Type | Description | Impact | Owner/approver | Next action |
|---|---|---|---|---|---|
| WC-001 | Gap | Product goals và non-goals chưa quyết định | Hạn chế planning và scope decisions | Đỗ Đăng Thủy | Clarify khi cần |
| WC-002 | Gap | Current objective và active task chưa quyết định | Chưa có delivery task để tiếp tục | Đỗ Đăng Thủy | Chọn task sau validation |
| WC-003 | Gap | Razor Runtime Compilation policy chưa quyết định | Không thể kết luận intended environment behavior | Đỗ Đăng Thủy | Clarify |
| WC-004 | Approval | Database thật không được truy cập trong scope hiện tại | Không có live DB evidence | Đỗ Đăng Thủy | Xin approval riêng nếu cần |

## Next actions

1. Project owner chọn current objective và active task tiếp theo.
2. Giữ các verification limitation còn lại explicit; chỉ mở verification scope mới khi có authority phù hợp.

## Relevant source links

- Product: [PRODUCT.md](PRODUCT.md).
- Design: [DESIGN.md](DESIGN.md).
- Decisions: [DECISIONS.md](DECISIONS.md).
- Roadmap: [ROADMAP.md](ROADMAP.md).
- Tasks: [TASKS.md](TASKS.md).
- Deployment record: [CHANGELOG.md](CHANGELOG.md).

## Handover note

Không cần đọc toàn bộ legacy memory để tiếp tục. Đọc README, AGENTS và các owner files liên quan đến intent. Chỉ dùng `MEMORY/` khi cần provenance/historical support và phải đối chiếu trước khi promote fact.
