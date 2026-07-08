using LabelPrint.Models;
using LabelPrint.Data;
using LabelPrint.Data.Repositories.Implementations;
using LabelPrint.Data.Repositories.Interfaces;
using LabelPrint.Services;


var builder = WebApplication.CreateBuilder(args);

// ==========================================
// LOAD SHARED CONFIG TỪ SHELLAPP
// ==========================================
var sharedConfigPath = builder.Configuration["SharedConfigPath"];

if (!string.IsNullOrEmpty(sharedConfigPath) && File.Exists(sharedConfigPath))
{
    builder.Configuration.AddJsonFile(
        sharedConfigPath,
        optional: true,
        reloadOnChange: true  // Tự cập nhật khi ShellApp lưu config mới
    );
    Console.WriteLine($"✓ Đã load shared config từ: {sharedConfigPath}");
}
else
{
    Console.WriteLine($"⚠ Không tìm thấy shared config tại: {sharedConfigPath}");
    Console.WriteLine("  → Sẽ dùng connection string trong appsettings.json local");
}
// ==========================================

// ... phần còn lại của Program.cs giữ nguyên

builder.Services.AddControllersWithViews().AddRazorRuntimeCompilation();
builder.Services.AddSingleton<IDbConnectionFactory>(_ =>
    new MySqlConnectionFactory(builder.Configuration.GetConnectionString("DefaultConnection")!));
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
builder.Services.AddSingleton<MayTinhService>();
// Dapper: map snake_case DB columns → PascalCase C# properties
// VD: ma_phien → MaPhien, ten_san_pham → TenSanPham, v.v.
Dapper.DefaultTypeMap.MatchNamesWithUnderscores = true;

// Đăng ký TypeHandler cho DateOnly (Dapper + MySQL)
Dapper.SqlMapper.AddTypeHandler(new DateOnlyTypeHandler());

var app = builder.Build();
if (!app.Environment.IsDevelopment()) app.UseExceptionHandler("/Home/Error");
app.UseStaticFiles();
app.UseRouting();
app.MapControllerRoute(name: "default", pattern: "{controller=Home}/{action=Index}/{id?}");
app.Run();
