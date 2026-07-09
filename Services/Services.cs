using LabelPrint.Data.Repositories.Interfaces;
using LabelPrint.Models;
using LabelPrint.Models.JsonModels;
using LabelPrint.Models.ViewModels;

namespace LabelPrint.Services;

public interface IPhienInService
{
    //Task<NhapLieuVM>              KhoiTaoPhienAsync();
    Task<NhapLieuVM>  KhoiTaoPhienAsync(string? clientIp = null);
    //Task<ApiResult<string>> XacNhanInAsync(int maPhien, string? clientIp = null);
    Task<NhapLieuVM>              LayPhienAsync(int maPhien);
    Task<NhapLieuVM>              ChuanBiCopyAsync(int maLichSu);
    Task<ApiResult<ChiTietInTem>> ThemChiTietAsync(ThemChiTietRequest req);
    Task<ApiResult<string>>       XoaChiTietAsync(int maChiTiet, int maPhien);
    //Task<ApiResult<string>>       XacNhanInAsync(int maPhien);
    Task<ApiResult<string>> XacNhanInAsync(int maPhien, string? clientIp = null);
    Task<PrintPreviewVM>          LayDuLieuInAsync(int maPhien);
    Task<PrintPreviewVM>          LayDuLieuInLaiAsync(int maLichSu);
    Task<ApiResult<string>>       XacNhanInLaiAsync(int maLichSu);
    Task<ApiResult<string>> DoiMauInAsync(int maPhien, int maMauIn);
}
public interface IMauInService
{
    Task<MauInEditorVM> LayEditorAsync(int? maMauIn, bool taoMoi = false, int? saoChepTu = null);
    Task<int>           LuuAsync(MauIn m, string json);
    Task                XoaAsync(int maMauIn);
    Task                SetMacDinhAsync(int maMauIn);
}
public interface IPrintService
{
    List<LabelItem> ExpandLabels(List<ChiTietInTem> ds, int soNhan);
    List<LabelItem> ExpandFromLichSu(LichSuInTem ls, int soNhan);
}

// ── PhienInService ─────────────────────────────────────────

public class PhienInService(
    IPhienInRepository   phienRepo, IChiTietRepository chiTietRepo,
    ILichSuRepository    lichSuRepo, IMauInRepository  mauInRepo,
    ICaSanXuatRepository caRepo,   IDropdownRepository dropRepo,
    ICauHinhRepository   cfgRepo,  IPrintService       printSvc,
    MayTinhService       mayTinhSvc) : IPhienInService
{
    private async Task<string> ChiNhanhMD() => await cfgRepo.LayGiaTriAsync("chi_nhanh_mac_dinh") ?? "HNI-OFF";

    private static string? ValidateThemChiTiet(ThemChiTietRequest req, out DateOnly? ngaySanXuat)
    {
        ngaySanXuat = null;

        if (req.MaPhien <= 0) return "Phiên không hợp lệ.";
        if (string.IsNullOrWhiteSpace(req.TenSanPham)) return "Vui lòng nhập tên sản phẩm.";
        if (string.IsNullOrWhiteSpace(req.MaCode)) return "Vui lòng nhập mã code.";
        if (string.IsNullOrWhiteSpace(req.SoPhieu)) return "Vui lòng nhập số phiếu.";
        if (string.IsNullOrWhiteSpace(req.ChiNhanh)) return "Vui lòng nhập chi nhánh.";
        if (string.IsNullOrWhiteSpace(req.TenLoaiGiay)) return "Vui lòng nhập loại giấy.";
        if (req.NamPhieu < 2020 || req.NamPhieu > 2099) return "Năm phiếu phải nằm trong khoảng 2020-2099.";
        if (req.SoLuongSanPham <= 0) return "Số lượng SP/1 tem phải lớn hơn 0.";
        if (req.SoLuongNhan <= 0) return "Số lượng tem cần in phải lớn hơn 0.";
        if (req.SoLuongPsp.HasValue && req.SoLuongPsp.Value <= 0) return "Số lượng PSP phải lớn hơn 0 nếu có nhập.";
        if (req.MaCa.HasValue && req.MaCa.Value <= 0) return "Ca sản xuất không hợp lệ.";
        if (req.LoaiTao != "moi" && req.LoaiTao != "copy") return "Loại tạo chỉ được là 'moi' hoặc 'copy'.";
        if (req.LoaiTao == "copy" && (!req.MaLichSuGoc.HasValue || req.MaLichSuGoc.Value <= 0))
            return "Dữ liệu copy thiếu mã lịch sử gốc.";

        DateOnly parsed = default;
        if (!string.IsNullOrWhiteSpace(req.NgaySanXuat)
            && !DateOnly.TryParseExact(req.NgaySanXuat, "yyyy-MM-dd",
                System.Globalization.CultureInfo.InvariantCulture,
                System.Globalization.DateTimeStyles.None, out parsed))
            return "Ngày sản xuất không đúng định dạng yyyy-MM-dd.";

        if (!string.IsNullOrWhiteSpace(req.NgaySanXuat))
            ngaySanXuat = parsed;

        return null;
    }

    private static string? NormalizeNguoiDongGoi(string? value)
    {
        if (string.IsNullOrWhiteSpace(value)) return null;

        var normalized = value.Trim();
        normalized = System.Text.RegularExpressions.Regex.Replace(normalized, @"[\r\n;]+", ",");
        normalized = System.Text.RegularExpressions.Regex.Replace(normalized, @"\s*,+\s*", ", ");
        normalized = System.Text.RegularExpressions.Regex.Replace(normalized, @"\s+", " ");
        normalized = normalized.Trim(' ', ',');

        return string.IsNullOrWhiteSpace(normalized) ? null : normalized;
    }

    private static string? ValidateMauInTruocKhiIn(MauIn? mauIn, out CauHinhMauIn cauHinh)
    {
        cauHinh = new CauHinhMauIn();
        if (mauIn == null) return "Template của phiên không còn tồn tại. Vui lòng quay lại chọn template khác.";
        if (string.IsNullOrWhiteSpace(mauIn.TenMau)) return "Template thiếu tên mẫu.";
        if (mauIn.SoNhanMoiTrang <= 0) return $"Template '{mauIn.TenMau}' có số nhãn mỗi trang không hợp lệ.";

        try
        {
            cauHinh = string.IsNullOrWhiteSpace(mauIn.CauHinhTruong)
                ? new CauHinhMauIn()
                : System.Text.Json.JsonSerializer.Deserialize<CauHinhMauIn>(mauIn.CauHinhTruong) ?? new CauHinhMauIn();
        }
        catch
        {
            return $"Template '{mauIn.TenMau}' có cấu hình JSON không hợp lệ.";
        }

        if (cauHinh.Layout == null) return $"Template '{mauIn.TenMau}' thiếu cấu hình layout.";
        var layout = cauHinh.Layout;
        if (layout.SoHang <= 0 || layout.SoCot <= 0) return $"Template '{mauIn.TenMau}' có số hàng/số cột không hợp lệ.";
        if (layout.RongNhan <= 0 || layout.CaoNhan <= 0) return $"Template '{mauIn.TenMau}' có kích thước nhãn không hợp lệ.";
        if (layout.RongTrangMm <= 0 || layout.CaoTrangMm <= 0) return $"Template '{mauIn.TenMau}' có kích thước trang không hợp lệ.";

        var sucChuaLayout = layout.SoHang * layout.SoCot;
        if (sucChuaLayout != mauIn.SoNhanMoiTrang)
            return $"Template '{mauIn.TenMau}' đang khai báo {mauIn.SoNhanMoiTrang} nhãn/trang nhưng layout là {layout.SoHang}x{layout.SoCot} = {sucChuaLayout}. Vui lòng kiểm tra lại template.";

        return null;
    }

    private static string? ValidateChiTietTruocKhiIn(ChiTietInTem ct, int soNhanMoiTrang)
    {
        var prefix = $"Dòng STT {ct.Stt}: ";
        if (ct.Stt <= 0) return "Dòng chi tiết có STT không hợp lệ.";
        if (string.IsNullOrWhiteSpace(ct.TenSanPham)) return prefix + "thiếu tên sản phẩm.";
        if (string.IsNullOrWhiteSpace(ct.MaCode)) return prefix + "thiếu mã code.";
        if (string.IsNullOrWhiteSpace(ct.SoPhieu)) return prefix + "thiếu số phiếu.";
        if (string.IsNullOrWhiteSpace(ct.ChiNhanh)) return prefix + "thiếu chi nhánh.";
        if (string.IsNullOrWhiteSpace(ct.TenLoaiGiay)) return prefix + "thiếu loại giấy.";
        if (ct.NamPhieu < 2020 || ct.NamPhieu > 2099) return prefix + "năm phiếu không hợp lệ.";
        if (ct.SoLuongSanPham <= 0) return prefix + "số lượng SP/1 tem phải lớn hơn 0.";
        if (ct.SoLuongNhan <= 0) return prefix + "số lượng tem cần in phải lớn hơn 0.";
        if (ct.SoTrang <= 0) return prefix + "số trang không hợp lệ.";
        if (ct.LoaiTao != "moi" && ct.LoaiTao != "copy") return prefix + "loại tạo không hợp lệ.";
        if (ct.LoaiTao == "copy" && (!ct.MaLichSuGoc.HasValue || ct.MaLichSuGoc.Value <= 0))
            return prefix + "dữ liệu copy thiếu mã lịch sử gốc.";

        var soTrangDung = (int)Math.Ceiling((double)ct.SoLuongNhan / soNhanMoiTrang);
        if (ct.SoTrang != soTrangDung)
            return prefix + $"số trang không khớp template hiện tại (đang là {ct.SoTrang}, đúng là {soTrangDung}). Vui lòng đổi lại template hoặc xóa/thêm lại dòng này.";

        return null;
    }

    private async Task<NhapLieuVM> BuildBaseVM(PhienInTem phien, MauIn mauIn,
        List<ChiTietInTem> ds, string? stickyChiNhanh = null)
    {
        var sp     = await dropRepo.LaySanPhamAsync();
        var giay   = await dropRepo.LayLoaiGiayAsync();
        var ca     = await caRepo.LayTatCaAsync();
        var cn     = await ChiNhanhMD();
        var dsMauIn = await mauInRepo.LayTatCaAsync();
        var last   = ds.LastOrDefault();
        return new NhapLieuVM
        {
            MaPhien         = phien.MaPhien, MauIn = mauIn,
            ChiNhanhMacDinh = cn,
            StickyNamPhieu  = last?.NamPhieu  ?? DateTime.Now.Year,
            StickyChiNhanh  = stickyChiNhanh ?? last?.ChiNhanh ?? cn,
            DsSanPham = sp, DsLoaiGiay = giay, DsCa = ca, DsChiTiet = ds,
            DsMauIn = dsMauIn
        };
    }
    
    public async Task<NhapLieuVM> KhoiTaoPhienAsync(string? clientIp = null)
    {
        var mauIn = await mauInRepo.LayMacDinhAsync()
            ?? throw new InvalidOperationException("Chưa có template mặc định. Vào Cấu hình → Mẫu in để tạo.");
        var phien = await phienRepo.TaoPhienMoiAsync(mauIn.MaMauIn, mayTinhSvc.LayTenMay(clientIp));
        return await BuildBaseVM(phien, mauIn, []);
    }

    public async Task<NhapLieuVM> LayPhienAsync(int maPhien)
    {
        var phien = await phienRepo.LayPhienAsync(maPhien) ?? throw new InvalidOperationException("Không tìm thấy phiên.");
        var mauIn = await mauInRepo.LayTheoIdAsync(phien.MaMauIn) ?? throw new InvalidOperationException("Không tìm thấy template.");
        var ds    = await chiTietRepo.LayDsAsync(maPhien);
        return await BuildBaseVM(phien, mauIn, ds);
    }

    public async Task<NhapLieuVM> ChuanBiCopyAsync(int maLichSu)
    {
        var ls = await lichSuRepo.LayTheoIdAsync(maLichSu)
            ?? throw new InvalidOperationException("Không tìm thấy bản ghi.");
        var parts    = ls.PhieuSanPham?.Split('/') ?? [];
        var soPhieu  = parts.Length > 0 ? parts[0] : "";
        var namPhieu = parts.Length > 1 && int.TryParse(parts[1], out var n) ? n : DateTime.Now.Year;
        var chiNhanh = parts.Length > 2 ? parts[2] : "";

        // Tạo phiên với template gốc nếu còn tồn tại, fallback về mặc định
        MauIn? mauInGoc = null;
        if (ls.MaMauIn.HasValue)
            mauInGoc = await mauInRepo.LayTheoIdAsync(ls.MaMauIn.Value);

        var vm = mauInGoc != null
            ? await KhoiTaoPhienVoiMauInAsync(mauInGoc)
            : await KhoiTaoPhienAsync();

        vm.TenSanPham = ls.TenSanPham; vm.MaCode = ls.MaCode;
        vm.SoPhieu = soPhieu; vm.NamPhieu = namPhieu; vm.ChiNhanh = chiNhanh;
        vm.TenLoaiGiay = ls.TenLoaiGiay; vm.SoLuongSanPham = ls.SoLuongSanPham;
        vm.SoLuongNhan = ls.SoLuongNhan;vm.SoLuongPsp = ls.SoLuongPsp; vm.NguoiKiem = ls.NguoiKiem;
        vm.NguoiDongGoi = ls.NguoiDongGoi; vm.NgaySanXuat = ls.NgaySanXuat?.ToString("yyyy-MM-dd");
        vm.ghiChu = ls.GhiChu;
        vm.StickyNamPhieu = namPhieu; vm.StickyChiNhanh = chiNhanh;
        return vm;
    }

    // Thêm helper method mới vào PhienInService:
    private async Task<NhapLieuVM> KhoiTaoPhienVoiMauInAsync(MauIn mauIn, string? clientIp = null)
    {
        var phien = await phienRepo.TaoPhienMoiAsync(mauIn.MaMauIn, mayTinhSvc.LayTenMay(clientIp));
        return await BuildBaseVM(phien, mauIn, []);
    }

    public async Task<ApiResult<ChiTietInTem>> ThemChiTietAsync(ThemChiTietRequest req)
    {
        try
        {
            var validationError = ValidateThemChiTiet(req, out var ngay);
            if (validationError != null)
                return ApiResult<ChiTietInTem>.Fail(validationError);
            
            var ct = new ChiTietInTem {
                MaPhien=req.MaPhien, TenSanPham=req.TenSanPham.Trim(),
                MaCode=req.MaCode.Trim(), SoPhieu=req.SoPhieu.Trim(), NamPhieu=req.NamPhieu,
                ChiNhanh=req.ChiNhanh.Trim(), TenLoaiGiay=req.TenLoaiGiay.Trim(),
                SoLuongSanPham=req.SoLuongSanPham, SoLuongNhan=req.SoLuongNhan,
                SoLuongPsp=req.SoLuongPsp, GhiChu=req.GhiChu?.Trim(),
                MaCa=req.MaCa, NgaySanXuat=ngay, NguoiKiem=req.NguoiKiem?.Trim(),
                NguoiDongGoi=NormalizeNguoiDongGoi(req.NguoiDongGoi), LoaiTao=req.LoaiTao, MaLichSuGoc=req.MaLichSuGoc
            };
            ct.MaChiTiet = await chiTietRepo.ThemAsync(ct);
            return ApiResult<ChiTietInTem>.Ok(ct, $"Đã thêm dòng STT {ct.Stt}");
        }
        catch (Exception ex) { return ApiResult<ChiTietInTem>.Fail(ex.Message); }
    }

    public async Task<ApiResult<string>> XoaChiTietAsync(int maChiTiet, int maPhien)
    {
        try { await chiTietRepo.XoaAsync(maChiTiet, maPhien); return ApiResult<string>.Ok("","Đã xóa."); }
        catch (Exception ex) { return ApiResult<string>.Fail(ex.Message); }
    }

    public async Task<ApiResult<string>> XacNhanInAsync(int maPhien, string? clientIp = null)
    {
        try {
            if (maPhien <= 0) return ApiResult<string>.Fail("Mã phiên không hợp lệ.");

            var phien = await phienRepo.LayPhienAsync(maPhien);
            if (phien == null) return ApiResult<string>.Fail("Không tìm thấy phiên.");
            if (phien.TrangThai != "nhap") return ApiResult<string>.Fail("Phiên không hợp lệ hoặc đã đóng.");

            var mauIn = await mauInRepo.LayTheoIdAsync(phien.MaMauIn);
            var templateError = ValidateMauInTruocKhiIn(mauIn, out _);
            if (templateError != null) return ApiResult<string>.Fail(templateError);

            var ds = await chiTietRepo.LayDsAsync(maPhien);
            if (ds.Count == 0) return ApiResult<string>.Fail("Phiên chưa có dòng nào.");
            foreach (var ct in ds)
            {
                var validationError = ValidateChiTietTruocKhiIn(ct, mauIn!.SoNhanMoiTrang);
                if (validationError != null)
                    return ApiResult<string>.Fail(validationError);
            }
            await phienRepo.DongPhienAsync(maPhien, mayTinhSvc.LayTenMay(clientIp));
            return ApiResult<string>.Ok("ok","Xác nhận thành công!");
        }
        catch (Exception ex) { return ApiResult<string>.Fail(ex.Message); }
    }
    public async Task<ApiResult<string>> DoiMauInAsync(int maPhien, int maMauIn)
    {
        try
        {
            var phien = await phienRepo.LayPhienAsync(maPhien);
            if (phien == null || phien.TrangThai != "nhap")
                return ApiResult<string>.Fail("Phiên không hợp lệ hoặc đã đóng.");
            var mauIn = await mauInRepo.LayTheoIdAsync(maMauIn);
            if (mauIn == null)
                return ApiResult<string>.Fail("Không tìm thấy template.");            
            await phienRepo.CapNhatMauInAsync(maPhien, maMauIn);
            var dsCapNhat = await chiTietRepo.LayDsAsync(maPhien);
            
            var payload = new {
                soTrang = dsCapNhat.ToDictionary(x => x.MaChiTiet, x => x.SoTrang),
                soNhanMoiTrang = mauIn.SoNhanMoiTrang
            };
            var json = System.Text.Json.JsonSerializer.Serialize(payload);
            return ApiResult<string>.Ok(json, $"Đã đổi template sang: {mauIn.TenMau}");
        }
        catch (Exception ex) { return ApiResult<string>.Fail(ex.Message); }
    }

    public async Task<PrintPreviewVM> LayDuLieuInAsync(int maPhien)
    {
        var phien   = await phienRepo.LayPhienAsync(maPhien) ?? throw new InvalidOperationException("Không tìm thấy phiên.");
        var mauIn   = await mauInRepo.LayTheoIdAsync(phien.MaMauIn) ?? throw new InvalidOperationException("Không tìm thấy template.");
        var ds      = await chiTietRepo.LayDsAsync(maPhien);
        var cauHinh = CauHinhMauIn.FromJson(mauIn.CauHinhTruong);
        return new PrintPreviewVM { MauIn=mauIn, CauHinh=cauHinh, Labels=printSvc.ExpandLabels(ds, mauIn.SoNhanMoiTrang), MaPhien=maPhien };
    }

    public async Task<PrintPreviewVM> LayDuLieuInLaiAsync(int maLichSu)
    {
        var ls = await lichSuRepo.LayTheoIdAsync(maLichSu)
            ?? throw new InvalidOperationException("Không tìm thấy lịch sử.");

        // Ưu tiên template gốc, fallback về mặc định nếu đã bị xóa
        MauIn? mauIn = null;
        if (ls.MaMauIn.HasValue)
            mauIn = await mauInRepo.LayTheoIdAsync(ls.MaMauIn.Value);
        mauIn ??= await mauInRepo.LayMacDinhAsync()
            ?? throw new InvalidOperationException("Không tìm thấy template.");

        return new PrintPreviewVM {
            MauIn   = mauIn,
            CauHinh = CauHinhMauIn.FromJson(mauIn.CauHinhTruong),
            Labels  = printSvc.ExpandFromLichSu(ls, mauIn.SoNhanMoiTrang),
            LaInLai = true,
            MaLichSu = maLichSu
        };
    }

    public async Task<ApiResult<string>> XacNhanInLaiAsync(int maLichSu)
    {
        try
        {
            var ls = await lichSuRepo.LayTheoIdAsync(maLichSu);
            if (ls == null) return ApiResult<string>.Fail("Không tìm thấy lịch sử.");

            await lichSuRepo.TangLanInLaiAsync(maLichSu);
            return ApiResult<string>.Ok("", "Đã xác nhận in lại.");
        }
        catch (Exception ex) { return ApiResult<string>.Fail(ex.Message); }
    }
}

// ── MauInService ───────────────────────────────────────────
public class MauInService(IMauInRepository repo) : IMauInService
{
    public async Task<MauInEditorVM> LayEditorAsync(int? maMauIn, bool taoMoi = false, int? saoChepTu = null)
    {
        var ds  = await repo.LayTatCaAsync();

        if (taoMoi)
        {
            MauIn? mauNguon = null;
            if (saoChepTu.HasValue && saoChepTu.Value > 0)
                mauNguon = await repo.LayTheoIdAsync(saoChepTu.Value);
            mauNguon ??= ds.FirstOrDefault();

            var mauMoi = new MauIn
            {
                MaMauIn = 0,
                TenMau = "",
                KhoGiay = mauNguon?.KhoGiay ?? "letter",
                SoNhanMoiTrang = mauNguon?.SoNhanMoiTrang ?? 8,
                LaMacDinh = false,
                CauHinhTruong = mauNguon?.CauHinhTruong
            };

            return new MauInEditorVM
            {
                MauIn = mauMoi,
                CauHinh = CauHinhMauIn.FromJson(mauMoi.CauHinhTruong),
                DsMauIn = ds,
                IsNew = true
            };
        }

        var mauIn = maMauIn.HasValue ? await repo.LayTheoIdAsync(maMauIn.Value) : ds.FirstOrDefault();
        mauIn ??= new MauIn();
        return new MauInEditorVM { MauIn=mauIn, CauHinh=CauHinhMauIn.FromJson(mauIn.CauHinhTruong), DsMauIn=ds, IsNew=false };
    }
    public async Task<int> LuuAsync(MauIn m, string json)
    {
        m.CauHinhTruong = json;
        if (m.MaMauIn == 0)
        {
            // Thêm mới — nếu la_mac_dinh=true thì SetMacDinh SAU khi có ID
            // Tạm set false để INSERT, rồi gọi SetMacDinh riêng (tránh 2 row = 1)
            var laMacDinh = m.LaMacDinh;
            m.LaMacDinh   = false;
            var id = await repo.ThemAsync(m);
            if (laMacDinh) await repo.SetMacDinhAsync(id);
            return id;
        }
        await repo.CapNhatAsync(m);
        if (m.LaMacDinh) await repo.SetMacDinhAsync(m.MaMauIn);
        return m.MaMauIn;
    }
    public Task XoaAsync(int id)       => repo.XoaAsync(id);
    public Task SetMacDinhAsync(int id) => repo.SetMacDinhAsync(id);
}

// ── PrintService ───────────────────────────────────────────
public class PrintService : IPrintService
{
    private static List<LabelItem> SapXepTheoChongSlot(List<LabelItem> labels, int soNhan)
    {
        if (soNhan <= 0) throw new InvalidOperationException("Template có số nhãn mỗi trang không hợp lệ.");
        if (labels.Count == 0) return labels;

        var result = new List<LabelItem>();
        var baseCount = labels.Count / soNhan;
        var extra = labels.Count % soNhan;
        var pages = (int)Math.Ceiling((double)labels.Count / soNhan);
        var cursor = 0;
        var stacks = new List<List<LabelItem>>();

        for (var slot = 0; slot < soNhan; slot++)
        {
            var take = baseCount + (slot < extra ? 1 : 0);
            stacks.Add(labels.Skip(cursor).Take(take).ToList());
            cursor += take;
        }

        for (var page = 0; page < pages; page++)
        {
            for (var slot = 0; slot < soNhan; slot++)
            {
                result.Add(page < stacks[slot].Count ? stacks[slot][page] : new LabelItem { LaTrong = true });
            }
        }

        return result;
    }
    
    public List<LabelItem> ExpandLabels(List<ChiTietInTem> ds, int soNhan)
    {
        if (soNhan <= 0) throw new InvalidOperationException("Template có số nhãn mỗi trang không hợp lệ.");

        // Bước 1: Expand tất cả nhãn, STT từ 1 → tổng số nhãn
        var result = new List<LabelItem>();
        int stt = 1;
        foreach (var ct in ds.OrderBy(c => c.Stt))
        {
            var ngay = ct.NgaySanXuat?.ToString("dd/MM/yyyy") ?? "";
            for (int i = 1; i <= ct.SoLuongNhan; i++)
                result.Add(new LabelItem {
                    TenSanPham=ct.TenSanPham, MaCode=ct.MaCode, PhieuSanPham=ct.PhieuSanPham,
                    TenLoaiGiay=ct.TenLoaiGiay, SoLuong=ct.SoLuongSanPham.ToString(),
                    TenCa=ct.TenCa??"", NgaySanXuat=ngay,
                    NguoiKiem=ct.NguoiKiem??"", NguoiDongGoi=ct.NguoiDongGoi??"",
                    Stt=(stt++).ToString()
                });
        }

        return SapXepTheoChongSlot(result, soNhan);
    }
   
    public List<LabelItem> ExpandFromLichSu(LichSuInTem ls, int soNhan)
    {
        var ngay  = ls.NgaySanXuat?.ToString("dd/MM/yyyy") ?? "";
        var count = Math.Max(1, ls.SoLuongNhan);
        var result = Enumerable.Range(1, count).Select(i => new LabelItem {
            TenSanPham=ls.TenSanPham, MaCode=ls.MaCode, PhieuSanPham=ls.PhieuSanPham,
            TenLoaiGiay=ls.TenLoaiGiay, SoLuong=ls.SoLuongSanPham.ToString(),
            TenCa=ls.TenCa??"", NgaySanXuat=ngay,
            NguoiKiem=ls.NguoiKiem??"", NguoiDongGoi=ls.NguoiDongGoi??"",
            Stt=i.ToString()   // ← 1, 2, 3 ... N
        }).ToList();

        return SapXepTheoChongSlot(result, soNhan);
    }
}
    // ── MayTinhService ─────────────────────────────────────────
    
    public class MayTinhRecord
    {
        [System.Text.Json.Serialization.JsonPropertyName("ip")]
        public string Ip     { get; set; } = "";
        [System.Text.Json.Serialization.JsonPropertyName("tenMay")]
        public string TenMay { get; set; } = "";
    }

    public class MayTinhService
    {
        private readonly string _path;
        private List<MayTinhRecord> _cache = [];

        public MayTinhService(IWebHostEnvironment env)
        {
            _path = Path.Combine(env.ContentRootPath, "may_tinh.json");
            Load();
        }

        private void Load()
        {
            if (!File.Exists(_path)) { _cache = []; return; }
            try { _cache = System.Text.Json.JsonSerializer.Deserialize<List<MayTinhRecord>>(File.ReadAllText(_path)) ?? []; }
            catch { _cache = []; }
        }

        public string LayTenMay(string? ip)
        {
            if (string.IsNullOrWhiteSpace(ip)) return Environment.MachineName;

            var normalizedIp = NormalizeIp(ip);
            if (IsLoopback(normalizedIp))
                return LayTenMayLocal();

            var found = _cache.FirstOrDefault(x => string.Equals(x.Ip, normalizedIp, StringComparison.OrdinalIgnoreCase));
            return found?.TenMay ?? normalizedIp;
        }

        private string LayTenMayLocal()
        {
            var localIps = System.Net.Dns.GetHostAddresses(System.Net.Dns.GetHostName())
                .Select(x => NormalizeIp(x.ToString()))
                .Where(x => !IsLoopback(x))
                .ToHashSet(StringComparer.OrdinalIgnoreCase);

            var found = _cache.FirstOrDefault(x => localIps.Contains(NormalizeIp(x.Ip)));
            return found?.TenMay ?? Environment.MachineName;
        }

        private static string NormalizeIp(string ip)
        {
            ip = ip.Trim();
            if (!System.Net.IPAddress.TryParse(ip, out var parsed)) return ip;
            if (parsed.IsIPv4MappedToIPv6) return parsed.MapToIPv4().ToString();
            return parsed.ToString();
        }

        private static bool IsLoopback(string ip)
            => System.Net.IPAddress.TryParse(ip, out var parsed) && System.Net.IPAddress.IsLoopback(parsed);

        public List<MayTinhRecord> LayTatCa() => _cache.ToList();

        public void Luu(List<MayTinhRecord> ds)
        {
            _cache = ds;
            File.WriteAllText(_path, System.Text.Json.JsonSerializer.Serialize(ds,
                new System.Text.Json.JsonSerializerOptions { WriteIndented = true }));
        }
    }
