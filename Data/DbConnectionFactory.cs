using MySql.Data.MySqlClient;
using System.Data;

namespace LabelPrint.Data;

public interface IDbConnectionFactory { IDbConnection CreateConnection(); }

public class MySqlConnectionFactory(string cs) : IDbConnectionFactory
{
    public IDbConnection CreateConnection() => new MySqlConnection(cs);
}
