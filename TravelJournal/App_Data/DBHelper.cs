using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace TravelJournal
{
    /// <summary>
    /// Database Helper Class สำหรับจัดการการเชื่อมต่อและทำงานกับ SQL Server
    /// </summary>
    public class DBHelper
    {
        private static string connectionString = ConfigurationManager.ConnectionStrings["TravelJournalDB"].ConnectionString;

        /// <summary>
        /// Execute Non-Query (INSERT, UPDATE, DELETE)
        /// </summary>
        public static int ExecuteNonQuery(string query, SqlParameter[] parameters = null)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (parameters != null)
                    {
                        cmd.Parameters.AddRange(parameters);
                    }

                    conn.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Execute Scalar (SELECT COUNT, SELECT TOP 1)
        /// </summary>
        public static object ExecuteScalar(string query, SqlParameter[] parameters = null)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (parameters != null)
                    {
                        cmd.Parameters.AddRange(parameters);
                    }

                    conn.Open();
                    return cmd.ExecuteScalar();
                }
            }
        }

        /// <summary>
        /// Execute Reader (SELECT with multiple rows)
        /// </summary>
        public static DataTable ExecuteQuery(string query, SqlParameter[] parameters = null)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (parameters != null)
                    {
                        cmd.Parameters.AddRange(parameters);
                    }

                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        adapter.Fill(dt);
                        return dt;
                    }
                }
            }
        }

        /// <summary>
        /// Execute Stored Procedure with Parameters
        /// </summary>
        public static DataTable ExecuteStoredProcedure(string procedureName, SqlParameter[] parameters = null)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand(procedureName, conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    if (parameters != null)
                    {
                        cmd.Parameters.AddRange(parameters);
                    }

                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        adapter.Fill(dt);
                        return dt;
                    }
                }
            }
        }

        /// <summary>
        /// Execute Stored Procedure Non-Query (INSERT, UPDATE via SP)
        /// </summary>
        public static int ExecuteStoredProcedureNonQuery(string procedureName, SqlParameter[] parameters = null)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand(procedureName, conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    if (parameters != null)
                    {
                        cmd.Parameters.AddRange(parameters);
                    }

                    conn.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Execute Stored Procedure และส่งคืน Output Parameter
        /// </summary>
        public static object ExecuteStoredProcedureWithOutput(string procedureName, SqlParameter[] parameters, string outputParamName)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand(procedureName, conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    if (parameters != null)
                    {
                        cmd.Parameters.AddRange(parameters);
                    }

                    conn.Open();
                    cmd.ExecuteNonQuery();

                    return cmd.Parameters[outputParamName].Value;
                }
            }
        }
    }

    /// <summary>
    /// User Data Model
    /// </summary>
    public class User
    {
        public int UserID { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public string PasswordHash { get; set; }
        public string FullName { get; set; }
        public DateTime? DateOfBirth { get; set; }
        public string ProfileImage { get; set; }
        public DateTime CreatedDate { get; set; }
        public DateTime? LastLogin { get; set; }
        public bool IsActive { get; set; }
    }

    /// <summary>
    /// Travel Entry Data Model
    /// </summary>
    public class TravelEntry
    {
        public int EntryID { get; set; }
        public int UserID { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public DateTime TravelDate { get; set; }
        public int Rating { get; set; }
        public DateTime CreatedDate { get; set; }
    }

    /// <summary>
    /// Location Data Model
    /// </summary>
    public class Location
    {
        public int LocationID { get; set; }
        public string LocationName { get; set; }
        public string Address { get; set; }
        public string City { get; set; }
        public string Country { get; set; }
        public decimal Latitude { get; set; }
        public decimal Longitude { get; set; }
        public string Category { get; set; }
        public int VisitCount { get; set; }
        public decimal AverageRating { get; set; }
        public int PopularityScale { get; set; }
    }
}