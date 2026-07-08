using LabelPrint.Models.JsonModels;

namespace LabelPrint.Models.ViewModels;

public class NhapLieuVM
{
    public int    MaPhien         { get; set; }
    public MauIn? MauIn           { get; set; }
    public string  TenSanPham     { get; set; } = "";
    public string  MaCode         { get; set; } = "";
    public string  SoPhieu        { get; set; } = "";
    public int     NamPhieu       { get; set; } = DateTime.Now.Year;
    public string  ChiNhanh       { get; set; } = "";
    public string  TenLoaiGiay    { get; set; } = "";
    public int     SoLuongSanPham { get; set; }
    public int     SoLuongNhan    { get; set; }
    public int?    SoLuongPsp     { get; set; }
    public int?    MaCa           { get; set; }
    public string? NgaySanXuat    { get; set; }
    public string? NguoiKiem      { get; set; }
    public string? NguoiDongGoi   { get; set; }
    public string? ghiChu   { get; set; }
    public List<DropdownSanPham> DsSanPham     { get; set; } = [];
    public List<string>          DsLoaiGiay    { get; set; } = [];
    public List<CaSanXuat>       DsCa          { get; set; } = [];
    public string  ChiNhanhMacDinh { get; set; } = "HNI-OFF";
    public int     StickyNamPhieu  { get; set; } = DateTime.Now.Year;
    public string  StickyChiNhanh  { get; set; } = "";
    public List<MauIn> DsMauIn { get; set; } = [];
    public List<ChiTietInTem> DsChiTiet { get; set; } = [];
    public int TongNhan  => DsChiTiet.Sum(x => x.SoLuongNhan);
    public int TongTrang => DsChiTiet.Sum(x => x.SoTrang);
}

public class ThemChiTietRequest
{
    public int     MaPhien        { get; set; }
    public string  TenSanPham     { get; set; } = "";
    public string  MaCode         { get; set; } = "";
    public string  SoPhieu        { get; set; } = "";
    public int     NamPhieu       { get; set; }
    public string  ChiNhanh       { get; set; } = "";
    public string  TenLoaiGiay    { get; set; } = "";
    public int     SoLuongSanPham { get; set; }
    public int     SoLuongNhan    { get; set; }
    // thêm 2 dòng ngay bên dưới:
    public int?    SoLuongPsp     { get; set; }
    public string? GhiChu         { get; set; }
    public int?    MaCa           { get; set; }
    public string? NgaySanXuat    { get; set; }
    public string? NguoiKiem      { get; set; }
    public string? NguoiDongGoi   { get; set; }
    public string  LoaiTao        { get; set; } = "moi";
    public int?    MaLichSuGoc    { get; set; }
}

public class TimKiemVM
{
    public string?           Keyword   { get; set; }
    public List<LichSuInTem> KetQua    { get; set; } = [];
    public bool              DaTimKiem { get; set; }
}

public class LichSuVM
{
    public string?           TuNgay   { get; set; }
    public string?           DenNgay  { get; set; }
    public string?           Keyword  { get; set; }
    public string?           TenMay   { get; set; }
    public List<LichSuInTem> DsLichSu { get; set; } = [];
    public List<ThongKeSanPhamVM> ThongKe { get; set; } = [];
}

public class ThongKeSanPhamVM
{
    public string   TenSanPham { get; set; } = "";
    public string   MaCode     { get; set; } = "";
    public int      SoLanIn    { get; set; }
    public int      TongNhan   { get; set; }
    public DateTime LanInCuoi  { get; set; }
}

public class PrintPreviewVM
{
    public MauIn           MauIn   { get; set; } = new();
    public CauHinhMauIn    CauHinh { get; set; } = new();
    public List<LabelItem> Labels  { get; set; } = [];
    public bool            LaInLai { get; set; }
    public int?            MaPhien { get; set; }
    public int?            MaLichSu { get; set; }
}

public class LabelItem
{
    public string TenSanPham   { get; set; } = "";
    public string MaCode       { get; set; } = "";
    public string PhieuSanPham { get; set; } = "";
    public string TenLoaiGiay  { get; set; } = "";
    public string SoLuong      { get; set; } = "";
    public string TenCa        { get; set; } = "";
    public string NgaySanXuat  { get; set; } = "";
    public string NguoiKiem    { get; set; } = "";
    public string NguoiDongGoi { get; set; } = "";
    public string Stt          { get; set; } = "";
}

public class MauInEditorVM
{
    public MauIn        MauIn   { get; set; } = new();
    public CauHinhMauIn CauHinh { get; set; } = new();
    public List<MauIn>  DsMauIn { get; set; } = [];
    public bool         IsNew   { get; set; }
}

public class CauHinhHeThongVM
{
    public List<CauHinhHeThong> DsCauHinh       { get; set; } = [];
    public string               TenCongTy       { get; set; } = "";
    public string               ChiNhanhMacDinh { get; set; } = "HNI-OFF";
}

public class ApiResult<T>
{
    public bool   Success { get; set; }
    public string Message { get; set; } = "";
    public T?     Data    { get; set; }
    public static ApiResult<T> Ok(T data, string msg = "")   => new() { Success=true,  Data=data, Message=msg };
    public static ApiResult<T> Fail(string msg)               => new() { Success=false, Message=msg };
}
