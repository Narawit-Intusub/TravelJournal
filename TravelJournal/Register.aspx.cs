using System;
using System.Data.SqlClient;
using System.Web.UI;

namespace TravelJournal
{
    public partial class Register : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            string username = txtUsername.Text.Trim();
            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text.Trim();
            string fullName = txtFullName.Text.Trim();

            // Hash password
            string passwordHash = HashPassword(password);

            try
            {
                // เรียก Stored Procedure sp_RegisterUser
                SqlParameter[] parameters = new SqlParameter[]
                {
                    new SqlParameter("@Username", username),
                    new SqlParameter("@Email", email),
                    new SqlParameter("@Password", passwordHash),
                    new SqlParameter("@FullName", fullName)
                };

                var result = DBHelper.ExecuteStoredProcedure("sp_RegisterUser", parameters);

                // Set Role เป็น User (default)
                if (result.Rows.Count > 0)
                {
                    int newUserID = Convert.ToInt32(result.Rows[0]["NewUserID"]);
                    DBHelper.ExecuteNonQuery("UPDATE Users SET Role = 'User' WHERE UserID = @UserID",
                        new SqlParameter[] { new SqlParameter("@UserID", newUserID) });
                }

                // Registration สำเร็จ - redirect ไป Login
                lblMessage.ForeColor = System.Drawing.Color.Green;
                lblMessage.Text = "Registration successful! Redirecting to login...";

                Response.AddHeader("REFRESH", "2;URL=Login.aspx");
            }
            catch (SqlException ex)
            {
                // ตรวจสอบ error ของ unique constraint
                if (ex.Message.Contains("Username") || ex.Message.Contains("UNIQUE"))
                {
                    lblMessage.Text = "Username or Email already exists!";
                }
                else
                {
                    lblMessage.Text = "Error: " + ex.Message;
                }
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Error: " + ex.Message;
            }
        }

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