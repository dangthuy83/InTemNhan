using System.Text.Json;
using System.Text.Json.Serialization;

namespace LabelPrint.Models.JsonModels;

public class CauHinhTruong
{
    [JsonPropertyName("x")]             public double X           { get; set; }
    [JsonPropertyName("y")]             public double Y           { get; set; }
    [JsonPropertyName("font")]          public string Font        { get; set; } = "Arial";
    [JsonPropertyName("co_chu")]        public int    CoChu       { get; set; } = 10;
    [JsonPropertyName("in_dam")]        public bool   InDam       { get; set; }
    [JsonPropertyName("in_nghieng")]    public bool   InNghieng   { get; set; }
    [JsonPropertyName("can_chinh")]     public string CanChinh    { get; set; } = "left";
    [JsonPropertyName("mau_chu")]       public string MauChu      { get; set; } = "#000000";
    [JsonPropertyName("hien_thi")]      public bool   HienThi     { get; set; } = true;
    [JsonPropertyName("hien_thi_nhan")] public bool   HienThiNhan { get; set; }
    [JsonPropertyName("nhan")]          public string Nhan        { get; set; } = "";
}

public class LayoutMauIn
{
    [JsonPropertyName("rong_nhan")]         public double  RongNhan      { get; set; } = 91.95;
    [JsonPropertyName("cao_nhan")]          public double  CaoNhan       { get; set; } = 59.94;
    [JsonPropertyName("so_hang")]           public int     SoHang        { get; set; } = 4;
    [JsonPropertyName("so_cot")]            public int     SoCot         { get; set; } = 2;
    [JsonPropertyName("rong_trang_mm")]     public double  RongTrangMm   { get; set; } = 215.90;
    [JsonPropertyName("cao_trang_mm")]      public double  CaoTrangMm    { get; set; } = 279.40;
    [JsonPropertyName("le_tren")]           public double  LeTren        { get; set; } = 3.50;
    [JsonPropertyName("le_duoi")]           public double  LeDuoi        { get; set; } = 6.20;
    [JsonPropertyName("le_trai")]           public double  LeTrai        { get; set; } = 10.00;
    [JsonPropertyName("le_phai")]           public double  LePhai        { get; set; } = 10.00;
    [JsonPropertyName("khoang_cach_ngang")] public double  KhoangCachNgang { get; set; } = 11.90;

    // Gap dọc mặc định (dùng khi GapDocVung không có giá trị)
    [JsonPropertyName("khoang_cach_doc")]   public double  KhoangCachDoc { get; set; } = 9.90;

    // Gap dọc từng vùng riêng biệt: index=0 là gap giữa hàng 1–2, index=1 là hàng 2–3, v.v.
    // null hoặc list rỗng = dùng KhoangCachDoc cho tất cả
    [JsonPropertyName("gap_doc_vung")]      public List<double>? GapDocVung { get; set; }

    // Bước hàng: khoảng cách từ top ô tem hàng N đến top ô tem hàng N+1 (mm).
    // Bằng khoảng cách giữa 2 dòng dữ liệu cùng vị trí trên 2 hàng tem liền kề.
    // Nếu null hoặc 0 thì fallback về CaoNhan + KhoangCachDoc.
    [JsonPropertyName("buoc_hang")]         public double? BuocHang      { get; set; }

    /// <summary>Lấy gap dọc cho vùng giữa hàng hangIndex và hangIndex+1</summary>
    public double LayGapDoc(int hangIndex)
    {
        if (GapDocVung != null && hangIndex >= 0 && hangIndex < GapDocVung.Count)
            return GapDocVung[hangIndex];
        return KhoangCachDoc;
    }

    /// <summary>
    /// Tính toạ độ top (mm) của hàng row (0-based).
    /// Nếu BuocHang được set thì dùng trực tiếp (khớp phôi in thực tế).
    /// Fallback: tính từ CaoNhan + GapDocVung như cũ.
    /// </summary>
    
    public double TinhTopMm(int row)
{
    if (BuocHang.HasValue && BuocHang.Value > 0)
    {
        // BuocHang là bước cơ bản, GapDocVung là offset bù sai số tích lũy
        double y = LeTren + row * BuocHang.Value;
        for (int r = 0; r < row; r++)
            y += LayGapDoc(r);
        return y;
    }

    // Fallback giữ tương thích ngược với template cũ chưa có BuocHang
    double yFallback = LeTren;
    for (int r = 0; r < row; r++)
        yFallback += CaoNhan + LayGapDoc(r);
    return yFallback;
}
}

public class CauHinhMauIn
{
    [JsonPropertyName("layout")]         public LayoutMauIn   Layout       { get; set; } = new();
    [JsonPropertyName("ten_san_pham")]   public CauHinhTruong TenSanPham   { get; set; } = new() { X=5,  Y=4,  CoChu=14, InDam=true,  Nhan="Tên SP" };
    [JsonPropertyName("ma_code")]        public CauHinhTruong MaCode       { get; set; } = new() { X=5,  Y=15, CoChu=12, InDam=true,  MauChu="#FF0000", Nhan="Mã code" };
    [JsonPropertyName("phieu_san_pham")] public CauHinhTruong PhieuSanPham { get; set; } = new() { X=5,  Y=24, CoChu=10, Nhan="Phiếu SP" };
    [JsonPropertyName("ten_loai_giay")]  public CauHinhTruong TenLoaiGiay  { get; set; } = new() { X=5,  Y=31, CoChu=10, Nhan="Loại giấy" };
    [JsonPropertyName("so_luong")]       public CauHinhTruong SoLuong      { get; set; } = new() { X=5,  Y=38, CoChu=10, Nhan="Số lượng" };
    [JsonPropertyName("ten_ca")]         public CauHinhTruong TenCa        { get; set; } = new() { X=5,  Y=44, CoChu=10, Nhan="Ca sx" };
    [JsonPropertyName("ngay_san_xuat")]  public CauHinhTruong NgaySanXuat  { get; set; } = new() { X=48, Y=44, CoChu=10, Nhan="Ngày SX" };
    [JsonPropertyName("nguoi_kiem")]     public CauHinhTruong NguoiKiem    { get; set; } = new() { X=5,  Y=50, CoChu=10, Nhan="Người Kiểm tra" };
    [JsonPropertyName("nguoi_dong_goi")] public CauHinhTruong NguoiDongGoi { get; set; } = new() { X=5,  Y=56, CoChu=10, Nhan="Người đóng gói" };
    [JsonPropertyName("nguoi_dong_goi_truncate_right_mm")] public double NguoiDongGoiTruncateRightMm { get; set; } = 26.0;
    [JsonPropertyName("stt")]            public CauHinhTruong Stt          { get; set; } = new() { X=72, Y=56, CoChu=10, CanChinh="right", Nhan="STT" };

    private static readonly JsonSerializerOptions _opts = new() { WriteIndented = false };
    public string ToJson() => JsonSerializer.Serialize(this, _opts);

    public static CauHinhMauIn FromJson(string? json)
    {
        if (string.IsNullOrWhiteSpace(json)) return new();
        try { return JsonSerializer.Deserialize<CauHinhMauIn>(json) ?? new(); }
        catch { return new(); }
    }

    public List<(string Key, string Label, CauHinhTruong Config)> AllFields() =>
    [
        ("ten_san_pham",   "Tên SP",           TenSanPham),
        ("ma_code",        "Mã code",          MaCode),
        ("phieu_san_pham", "Phiếu SP",         PhieuSanPham),
        ("ten_loai_giay",  "Loại giấy",        TenLoaiGiay),
        ("so_luong",       "Số lượng",         SoLuong),
        ("ten_ca",         "Ca sx",            TenCa),
        ("ngay_san_xuat",  "Ngày SX",          NgaySanXuat),
        ("nguoi_kiem",     "Người Kiểm tra",   NguoiKiem),
        ("nguoi_dong_goi", "Người đóng gói",   NguoiDongGoi),
        ("stt",            "STT",              Stt),
    ];
}