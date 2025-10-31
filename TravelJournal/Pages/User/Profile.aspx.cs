using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace TravelJournal
{
    public partial class Profile : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // ตรวจสอบว่า Login แล้วหรือไม่
            if (Session["UserID"] == null)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadUserProfile();
                LoadUserLocations();

                // แสดง Admin Link ถ้าเป็น Admin
                if (Session["Role"] != null && Session["Role"].ToString() == "Admin")
                {
                    pnlAdminLink.Visible = true;
                }
            }
        }

        private void LoadUserProfile()
        {
            int userID = Convert.ToInt32(Session["UserID"]);

            SqlParameter[] parameters = new SqlParameter[]
            {
                new SqlParameter("@UserID", userID)
            };

            DataTable dt = DBHelper.ExecuteStoredProcedure("sp_GetUserProfile", parameters);

            if (dt.Rows.Count > 0)
            {
                DataRow row = dt.Rows[0];

                // Profile Header
                string fullName = row["FullName"].ToString();
                lblProfileName.Text = fullName;
                lblUsername.Text = row["Username"].ToString();
                lblEmail.Text = row["Email"].ToString();
                lblMemberSince.Text = Convert.ToDateTime(row["CreatedDate"]).ToString("dd/MM/yyyy");

                if (row["LastLogin"] != DBNull.Value)
                {
                    lblLastLogin.Text = Convert.ToDateTime(row["LastLogin"]).ToString("dd/MM/yyyy HH:mm");
                }
                else
                {
                    lblLastLogin.Text = "Never";
                }

                // Statistics
                lblTotalEntries.Text = row["TotalEntries"].ToString();
                lblTotalLocations.Text = row["TotalLocations"].ToString();

                // Edit Form
                txtFullName.Text = fullName;
                txtEmail.Text = row["Email"].ToString();

                if (row["DateOfBirth"] != DBNull.Value)
                {
                    txtDateOfBirth.Text = Convert.ToDateTime(row["DateOfBirth"]).ToString("yyyy-MM-dd");
                }

                // Profile Image
                string profileImagePath = row["ProfileImage"].ToString();
                if (!string.IsNullOrEmpty(profileImagePath) && File.Exists(Server.MapPath(profileImagePath)))
                {
                    imgProfile.ImageUrl = profileImagePath;
                    imgProfile.Visible = true;
                    pnlDefaultAvatar.Visible = false;
                }
                else
                {
                    // แสดง Default Avatar (ตัวอักษรแรกของชื่อ)
                    lblAvatarInitial.Text = fullName.Substring(0, 1).ToUpper();
                    imgProfile.Visible = false;
                    pnlDefaultAvatar.Visible = true;
                }
            }
        }

        private void LoadUserLocations()
        {
            int userID = Convert.ToInt32(Session["UserID"]);

            string query = @"
                SELECT 
                    LocationID,
                    LocationName,
                    City,
                    Country,
                    Category,
                    VisitCount,
                    LastVisitDate,
                    AvgRating
                FROM vw_UserUniqueLocations
                WHERE UserID = @UserID
                ORDER BY LastVisitDate DESC";

            SqlParameter[] parameters = new SqlParameter[]
            {
                new SqlParameter("@UserID", userID)
            };

            DataTable dt = DBHelper.ExecuteQuery(query, parameters);

            if (dt.Rows.Count > 0)
            {
                rptLocations.DataSource = dt;
                rptLocations.DataBind();
                lblLocationCount.Text = dt.Rows.Count.ToString();
                lblNoLocations.Visible = false;
            }
            else
            {
                rptLocations.DataSource = null;
                rptLocations.DataBind();
                lblLocationCount.Text = "0";
                lblNoLocations.Visible = true;
            }
        }

        protected void btnUpdateProfile_Click(object sender, EventArgs e)
        {
            try
            {
                int userID = Convert.ToInt32(Session["UserID"]);
                string fullName = txtFullName.Text.Trim();
                string email = txtEmail.Text.Trim();
                DateTime? dateOfBirth = null;

                if (!string.IsNullOrEmpty(txtDateOfBirth.Text))
                {
                    dateOfBirth = Convert.ToDateTime(txtDateOfBirth.Text);
                }

                // Get current profile image path
                string currentImagePath = null;
                string query = "SELECT ProfileImage FROM Users WHERE UserID = @UserID";
                DataTable dtImage = DBHelper.ExecuteQuery(query, new SqlParameter[] { new SqlParameter("@UserID", userID) });
                if (dtImage.Rows.Count > 0 && dtImage.Rows[0]["ProfileImage"] != DBNull.Value)
                {
                    currentImagePath = dtImage.Rows[0]["ProfileImage"].ToString();
                }

                SqlParameter[] parameters = new SqlParameter[]
                {
                    new SqlParameter("@UserID", userID),
                    new SqlParameter("@FullName", fullName),
                    new SqlParameter("@Email", email),
                    new SqlParameter("@DateOfBirth", (object)dateOfBirth ?? DBNull.Value),
                    new SqlParameter("@ProfileImage", (object)currentImagePath ?? DBNull.Value)
                };

                DBHelper.ExecuteStoredProcedure("sp_UpdateUserProfile", parameters);

                // Update Session
                Session["FullName"] = fullName;

                lblMessage.Text = "✅ Profile updated successfully!";
                lblMessage.ForeColor = System.Drawing.Color.Green;

                // Reload profile
                LoadUserProfile();
            }
            catch (Exception ex)
            {
                lblMessage.Text = "❌ Error: " + ex.Message;
                lblMessage.ForeColor = System.Drawing.Color.Red;
            }
        }

        protected void btnUploadImage_Click(object sender, EventArgs e)
        {
            try
            {
                if (fuProfileImage.HasFile)
                {
                    string fileName = fuProfileImage.FileName;
                    string fileExtension = Path.GetExtension(fileName).ToLower();

                    // ตรวจสอบประเภทไฟล์
                    string[] allowedExtensions = { ".jpg", ".jpeg", ".png", ".gif" };
                    if (Array.IndexOf(allowedExtensions, fileExtension) == -1)
                    {
                        lblMessage.Text = "❌ Please upload image files only (JPG, PNG, GIF)";
                        lblMessage.ForeColor = System.Drawing.Color.Red;
                        return;
                    }

                    // ตรวจสอบขนาดไฟล์ (Max 5MB)
                    if (fuProfileImage.PostedFile.ContentLength > 5242880)
                    {
                        lblMessage.Text = "❌ File size must be less than 5MB";
                        lblMessage.ForeColor = System.Drawing.Color.Red;
                        return;
                    }

                    // สร้างโฟลเดอร์ ProfileImages ถ้ายังไม่มี
                    string uploadFolder = Server.MapPath("~/ProfileImages/");
                    if (!Directory.Exists(uploadFolder))
                    {
                        Directory.CreateDirectory(uploadFolder);
                    }

                    // สร้างชื่อไฟล์ใหม่ (UserID_timestamp.extension)
                    int userID = Convert.ToInt32(Session["UserID"]);
                    string newFileName = $"{userID}_{DateTime.Now.Ticks}{fileExtension}";
                    string filePath = Path.Combine(uploadFolder, newFileName);

                    // ลบรูปเก่าถ้ามี
                    string oldImageQuery = "SELECT ProfileImage FROM Users WHERE UserID = @UserID";
                    DataTable dtOldImage = DBHelper.ExecuteQuery(oldImageQuery,
                        new SqlParameter[] { new SqlParameter("@UserID", userID) });

                    if (dtOldImage.Rows.Count > 0 && dtOldImage.Rows[0]["ProfileImage"] != DBNull.Value)
                    {
                        string oldImagePath = Server.MapPath(dtOldImage.Rows[0]["ProfileImage"].ToString());
                        if (File.Exists(oldImagePath))
                        {
                            File.Delete(oldImagePath);
                        }
                    }

                    // บันทึกไฟล์
                    fuProfileImage.SaveAs(filePath);

                    // อัปเดต Database
                    string relativePath = "~/ProfileImages/" + newFileName;
                    string updateQuery = "UPDATE Users SET ProfileImage = @ProfileImage WHERE UserID = @UserID";
                    DBHelper.ExecuteNonQuery(updateQuery, new SqlParameter[]
                    {
                        new SqlParameter("@ProfileImage", relativePath),
                        new SqlParameter("@UserID", userID)
                    });

                    lblMessage.Text = "✅ Profile photo uploaded successfully!";
                    lblMessage.ForeColor = System.Drawing.Color.Green;

                    // Reload profile
                    LoadUserProfile();
                }
                else
                {
                    lblMessage.Text = "❌ Please select an image file";
                    lblMessage.ForeColor = System.Drawing.Color.Red;
                }
            }
            catch (Exception ex)
            {
                lblMessage.Text = "❌ Error uploading image: " + ex.Message;
                lblMessage.ForeColor = System.Drawing.Color.Red;
            }
        }

        protected void rptLocations_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DeleteLocation")
            {
                try
                {
                    int locationID = Convert.ToInt32(e.CommandArgument);
                    int userID = Convert.ToInt32(Session["UserID"]);

                    // ลบ Entries ทั้งหมดที่เกี่ยวข้องกับ Location นี้
                    string deleteQuery = @"
                        DELETE FROM TravelEntries 
                        WHERE EntryID IN (
                            SELECT DISTINCT TE.EntryID 
                            FROM TravelEntries TE
                            INNER JOIN EntryLocations EL ON TE.EntryID = EL.EntryID
                            WHERE EL.LocationID = @LocationID AND TE.UserID = @UserID
                        )";

                    SqlParameter[] parameters = new SqlParameter[]
                    {
                        new SqlParameter("@LocationID", locationID),
                        new SqlParameter("@UserID", userID)
                    };

                    DBHelper.ExecuteNonQuery(deleteQuery, parameters);

                    lblMessage.ForeColor = System.Drawing.Color.Green;
                    lblMessage.Text = "✅ Location and all related entries deleted successfully!";

                    // Reload data
                    LoadUserProfile();
                    LoadUserLocations();
                }
                catch (Exception ex)
                {
                    lblMessage.ForeColor = System.Drawing.Color.Red;
                    lblMessage.Text = "❌ Error deleting location: " + ex.Message;
                }
            }
        }

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            FormsAuthentication.SignOut();
            Response.Redirect("~/Login.aspx");
        }
    }
}