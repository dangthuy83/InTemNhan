using LabelPrint.Data.Repositories.Interfaces;
using LabelPrint.Models;
using LabelPrint.Models.ViewModels;
using LabelPrint.Services;
using Microsoft.AspNetCore.Mvc;

namespace LabelPrint.Controllers;

public class HomeController : Controller
{
    public IActionResult Index() => View();
    [Route("Error")]
    public IActionResult Error() => View();
}

public class PhienInController(IPhienInService svc) : Controller
{
   
    public async Task<IActionResult> Index()
    {
        try   { return View(await svc.KhoiTaoPhienAsync(HttpContext.Connection.RemoteIpAddress?.ToString())); }
        catch (Exception ex) { TempData["Error"]=ex.Message; return RedirectToAction("Index","Home"); }
    }
    public async Task<IActionResult> Tiep(int maPhien) => View("Index", await svc.LayPhienAsync(maPhien));

    [HttpPost] public async Task<IActionResult> ThemDong([FromBody] ThemChiTietRequest req)  => Json(await svc.ThemChiTietAsync(req));
    [HttpPost] public async Task<IActionResult> XoaDong([FromBody]  XoaDongReq req)           => Json(await svc.XoaChiTietAsync(req.MaChiTiet, req.MaPhien));
    [HttpPost] public async Task<IActionResult> XacNhan([FromBody] XacNhanReq req)    => Json(await svc.XacNhanInAsync(req.MaPhien, HttpContext.Connection.RemoteIpAddress?.ToString()));
    //[HttpPost] public async Task<IActionResult> XacNhan([FromBody]  XacNhanReq req)            => Json(await svc.XacNhanInAsync(req.MaPhien));

    [HttpPost] public async Task<IActionResult> DoiMauIn([FromBody] DoiMauInReq req) => Json(await svc.DoiMauInAsync(req.MaPhien, req.MaMauIn));
    public async Task<IActionResult> Print(int maPhien)  => View(await svc.LayDuLieuInAsync(maPhien));
    public async Task<IActionResult> InLai(int maLichSu) => View("Print", await svc.LayDuLieuInLaiAsync(maLichSu));
    [HttpPost] public async Task<IActionResult> XacNhanInLai([FromBody] MaLichSuReq req) => Json(await svc.XacNhanInLaiAsync(req.MaLichSu));
}
public record XoaDongReq(int MaChiTiet, int MaPhien);
public record XacNhanReq(int MaPhien);
public record DoiMauInReq(int MaPhien, int MaMauIn);

public class LichSuController(
    ILichSuRepository repo,
    IPhienInService   phienSvc) : Controller
{
    public async Task<IActionResult> Index(string? tuNgay, string? denNgay, string? keyword, string? tenMay)
    {
        var vm = new LichSuVM { TuNgay=tuNgay, DenNgay=denNgay, Keyword=keyword, TenMay=tenMay };
        if (string.IsNullOrWhiteSpace(tuNgay) && string.IsNullOrWhiteSpace(keyword))
        { vm.TuNgay=DateTime.Today.AddDays(-7).ToString("yyyy-MM-dd"); vm.DenNgay=DateTime.Today.ToString("yyyy-MM-dd"); }
        vm.DsLichSu = await repo.LocAsync(vm.TuNgay, vm.DenNgay, keyword, tenMay);
        vm.ThongKe  = await repo.ThongKeAsync();
        return View(vm);
    }
    [HttpPost] public async Task<IActionResult> Xoa([FromBody] MaLichSuReq req)
    {
        try { await repo.XoaAsync(req.MaLichSu); return Json(ApiResult<string>.Ok("", "Đã xóa.")); }
        catch (Exception ex) { return Json(ApiResult<string>.Fail(ex.Message)); }
    }
    

    public async Task<IActionResult> TimKiem(string? keyword)
    {
        var vm = new TimKiemVM { Keyword=keyword };
        if (!string.IsNullOrWhiteSpace(keyword)) { vm.KetQua=await repo.TimKiemAsync(keyword); vm.DaTimKiem=true; }
        return View(vm);
    }

    public async Task<IActionResult> Copy(int maLichSu)
    {
        try
        {
            var vm = await phienSvc.ChuanBiCopyAsync(maLichSu);
            ViewBag.CopyData = System.Text.Json.JsonSerializer.Serialize(new {
                tenSanPham=vm.TenSanPham, maCode=vm.MaCode, soPhieu=vm.SoPhieu,
                namPhieu=vm.NamPhieu, chiNhanh=vm.ChiNhanh, tenLoaiGiay=vm.TenLoaiGiay,
                soLuongSp=vm.SoLuongSanPham, soLuongNhan=vm.SoLuongNhan,soLuongPsp=vm.SoLuongPsp,ghiChu=vm.ghiChu,
                nguoiKiem=vm.NguoiKiem??"", nguoiDongGoi=vm.NguoiDongGoi??"",
                ngaySanXuat=vm.NgaySanXuat??"", maLichSuGoc=maLichSu
            });
            return View("~/Views/PhienIn/Index.cshtml", vm);
        }
        catch (Exception ex) { TempData["Error"]=ex.Message; return RedirectToAction("TimKiem"); }
    }
    public async Task<IActionResult> XuatExcel(string? tuNgay, string? denNgay, string? keyword, string? tenMay)
{
    var ds = await repo.LocAsync(tuNgay, denNgay, keyword, tenMay);

    using var wb = new ClosedXML.Excel.XLWorkbook();
    var ws = wb.Worksheets.Add("Lịch sử in tem");

    // Header
    var headers = new[] { "STT", "Tên SP", "Mã code", "Phiếu SP", "Loại giấy",
                           "SL SP/Tem", "SL Tem in",
                           "Ca SX", "Ngày SX", "Người kiểm", "Người đóng gói", "Ghi chú" };
    for (int i = 0; i < headers.Length; i++)
    {
        var cell = ws.Cell(1, i + 1);
        cell.Value = headers[i];
        cell.Style.Fill.BackgroundColor = ClosedXML.Excel.XLColor.FromHtml("#4472C4");
        cell.Style.Font.FontColor       = ClosedXML.Excel.XLColor.White;
        cell.Style.Font.Bold            = true;
        cell.Style.Alignment.Horizontal = ClosedXML.Excel.XLAlignmentHorizontalValues.Center;
    }

    // Data
    int row = 2;
    foreach (var ls in ds)
    {
        ws.Cell(row, 1).Value  = ls.Stt;
        ws.Cell(row, 2).Value  = ls.TenSanPham;
        ws.Cell(row, 3).Value  = ls.MaCode;
        ws.Cell(row, 4).Value  = ls.PhieuSanPham;
        ws.Cell(row, 5).Value  = ls.TenLoaiGiay;
        ws.Cell(row, 6).Value  = ls.SoLuongSanPham;
        ws.Cell(row, 7).Value  = ls.SoLuongNhan;
        ws.Cell(row, 8).Value  = ls.TenCa ?? "";
        ws.Cell(row, 9).Value  = ls.NgaySanXuat?.ToString("dd/MM/yyyy") ?? "";
        ws.Cell(row, 10).Value = ls.NguoiKiem ?? "";
        ws.Cell(row, 11).Value = ls.NguoiDongGoi ?? "";
        ws.Cell(row, 12).Value = ls.GhiChu ?? "";

        // Căn giữa toàn bộ dòng
        ws.Row(row).Style.Alignment.Horizontal = ClosedXML.Excel.XLAlignmentHorizontalValues.Center;
        row++;
    }

    // Auto-width
    ws.Columns().AdjustToContents();

    // Xuất file
    using var ms = new MemoryStream();
    wb.SaveAs(ms);
    ms.Position = 0;
    var tenFile = $"LichSuInTem_{DateTime.Today:dd-MM-yyyy}.xlsx";
    return File(ms.ToArray(),
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        tenFile);
}
}

public class MauInController(IMauInService svc) : Controller
{
    public IActionResult Index() => RedirectToAction("Editor");
    public async Task<IActionResult> Editor(int? maMauIn, bool taoMoi = false, int? saoChepTu = null)
        => View(await svc.LayEditorAsync(maMauIn, taoMoi, saoChepTu));

    [HttpPost]
    public async Task<IActionResult> Luu([FromBody] LuuMauInReq req)
    {
        try {
            if (string.IsNullOrWhiteSpace(req.TenMau)) return Json(ApiResult<int>.Fail("Tên mẫu không được để trống."));
            var m = new MauIn { MaMauIn=req.MaMauIn, TenMau=req.TenMau.Trim(), KhoGiay=req.KhoGiay, SoNhanMoiTrang=req.SoNhanMoiTrang, LaMacDinh=req.LaMacDinh, GhiChu=req.GhiChu };
            var id = await svc.LuuAsync(m, req.CauHinhJson);
            return Json(ApiResult<int>.Ok(id, "Lưu template thành công!"));
        } catch (Exception ex) { return Json(ApiResult<int>.Fail(ex.Message)); }
    }
    [HttpPost] public async Task<IActionResult> SetMacDinh([FromBody] MaMauInReq req) { await svc.SetMacDinhAsync(req.MaMauIn); return Json(ApiResult<string>.Ok("","Đã đặt làm mặc định.")); }
    [HttpPost] public async Task<IActionResult> Xoa([FromBody] MaMauInReq req) { await svc.XoaAsync(req.MaMauIn); return Json(ApiResult<string>.Ok("","Đã xóa.")); }
}
public class LuuMauInReq
{
    public int     MaMauIn        { get; set; }
    public string  TenMau         { get; set; } = "";
    public string  KhoGiay        { get; set; } = "letter";
    public int     SoNhanMoiTrang { get; set; } = 8;
    public bool    LaMacDinh      { get; set; }
    public string? GhiChu         { get; set; }
    public string  CauHinhJson    { get; set; } = "{}";
}
public record MaMauInReq(int MaMauIn);

public class CaSanXuatController(ICaSanXuatRepository repo) : Controller
{
    public async Task<IActionResult> Index() => View(await repo.LayTatCaAsync(false));
    [HttpPost] public async Task<IActionResult> Them([FromBody] TenCaReq req) {
        if (string.IsNullOrWhiteSpace(req.TenCa)) return Json(ApiResult<int>.Fail("Tên ca không được để trống."));
        return Json(ApiResult<int>.Ok(await repo.ThemAsync(req.TenCa.Trim()), "Thêm ca thành công.")); }
    [HttpPost] public async Task<IActionResult> AnHien([FromBody] AnHienReq req) { await repo.AnHienAsync(req.MaCa,req.An); return Json(ApiResult<string>.Ok("","Cập nhật thành công.")); }
}
public record TenCaReq(string TenCa);
public record AnHienReq(int MaCa, bool An);

//public class CauHinhController(ICauHinhRepository repo) : Controller
public class CauHinhController(ICauHinhRepository repo, MayTinhService mayTinhSvc) : Controller
{
    public async Task<IActionResult> Index()
    {
        var ds = await repo.LayTatCaAsync();
        return View(new CauHinhHeThongVM {
            DsCauHinh       = ds,
            TenCongTy       = ds.FirstOrDefault(x=>x.Khoa=="ten_cong_ty")?.GiaTri ?? "",
            ChiNhanhMacDinh = ds.FirstOrDefault(x=>x.Khoa=="chi_nhanh_mac_dinh")?.GiaTri ?? "HNI-OFF"
        });
    }
    [HttpPost]
    public async Task<IActionResult> Luu([FromBody] List<CauHinhItemReq> items)
    {
        try { foreach (var i in items) await repo.LuuAsync(i.Khoa, i.GiaTri); return Json(ApiResult<string>.Ok("","Đã lưu cấu hình.")); }
        catch (Exception ex) { return Json(ApiResult<string>.Fail(ex.Message)); }
    }
    [HttpGet]  public IActionResult LayDsMay() => Json(mayTinhSvc.LayTatCa());
    [HttpPost] public IActionResult LuuDsMay([FromBody] List<MayTinhRecord> ds)
    {
        try { mayTinhSvc.Luu(ds); return Json(ApiResult<string>.Ok("", "Đã lưu danh sách máy.")); }
        catch (Exception ex) { return Json(ApiResult<string>.Fail(ex.Message)); }
    }
}
public record CauHinhItemReq(string Khoa, string GiaTri);
public record MaLichSuReq(int MaLichSu);
