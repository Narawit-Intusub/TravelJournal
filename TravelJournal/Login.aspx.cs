using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Security;
using System.Web.UI;

namespace TravelJournal
{
    public partial class Login : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // ถ้า Login แล้วให้ redirect ไป Dashboard
                if (Session["UserID"] != null)
                {
                    Response.Redirect("~/Pages/User/Dashboard.aspx"); ;
                }
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text.Trim();

            // Simple password hashing (ในการใช้งานจริงควรใช้ bcrypt หรือ PBKDF2)
            string passwordHash = HashPassword(password);

            try
            {
                // เรียก Stored Procedure sp_LoginUser
                SqlParameter[] parameters = new SqlParameter[]
                {
                    new SqlParameter("@Username", username),
                    new SqlParameter("@Password", passwordHash)
                };

                DataTable dt = DBHelper.ExecuteStoredProcedure("sp_LoginUser", parameters);

                if (dt.Rows.Count > 0 && dt.Rows[0]["UserID"] != DBNull.Value)
                {
                    // Login สำเร็จ
                    int userID = Convert.ToInt32(dt.Rows[0]["UserID"]);
                    string fullName = dt.Rows[0]["FullName"].ToString();
                    string role = dt.Rows[0]["Role"].ToString();

                    // เก็บข้อมูลใน Session
                    Session["UserID"] = userID;
                    Session["Username"] = username;
                    Session["FullName"] = fullName;
                    Session["Role"] = role;

                    // สร้าง Authentication Cookie
                    FormsAuthentication.SetAuthCookie(username, false);

                    // Log login activity
                    try
                    {
                        SqlParameter[] logParams = new SqlParameter[]
                        {
                            new SqlParameter("@UserID", userID),
                            new SqlParameter("@ActivityType", "Login"),
                            new SqlParameter("@ActivityDescription", "User logged in successfully"),
                            new SqlParameter("@IPAddress", Request.UserHostAddress),
                            new SqlParameter("@UserAgent", Request.UserAgent)
                        };
                        DBHelper.ExecuteStoredProcedure("sp_LogUserActivity", logParams);
                    }
                    catch { }

                    // Redirect ตาม Role
                    if (role == "Admin")
                    {
                        Response.Redirect("~/Pages/Admin/LocationStatistics.aspx");
                    }
                    else
                    {
                        Response.Redirect("~/Pages/User/Dashboard.aspx");
                    }
                }
                else
                {
                    // Login ไม่สำเร็จ
                    pnlError.Visible = true;
                    lblMessage.Text = "Invalid username or password!";
                }
            }
            catch (Exception ex)
            {
                pnlError.Visible = true;
                lblMessage.Text = "Error: " + ex.Message;
            }
        }

        /// <summary>
        /// Simple Password Hashing (ใช้ SHA256 เพื่อความง่าย)
        /// ในการใช้งานจริงควรใช้ bcrypt หรือ PBKDF2
        /// </summary>
        private string HashPassword(string password)
        {
            using (System.Security.Cryptography.SHA256 sha256 = System.Security.Cryptography.SHA256.Create())
            {
                byte[] bytes = sha256.ComputeHash(System.Text.Encoding.UTF8.GetBytes(password));
                System.Text.StringBuilder builder = new System.Text.StringBuilder();
                for (int i = 0; i < bytes.Length; i++)
                {
                    builder.Append(bytes[i].ToString("x2"));
                }
                return builder.ToString();
            }
        }
    }
}