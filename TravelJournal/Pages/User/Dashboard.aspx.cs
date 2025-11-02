using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace TravelJournal
{
    public partial class Dashboard : Page
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
                // แสดงชื่อ User
                lblWelcome.Text = "Welcome, " + Session["FullName"].ToString();

                // ถ้าเป็น Admin ให้แสดงลิงก์ไป Admin Panel
                if (Session["Role"] != null && Session["Role"].ToString() == "Admin")
                {
                    pnlAdminLink.Visible = true;
                }

                // โหลดข้อมูล Travel Entries
                LoadTravelEntries();
            }
        }

        protected void btnAddEntry_Click(object sender, EventArgs e)
        {
            try
            {
                int userID = Convert.ToInt32(Session["UserID"]);
                string title = txtTitle.Text.Trim();
                string description = txtDescription.Text.Trim();
                DateTime travelDate = Convert.ToDateTime(txtTravelDate.Text);
                int rating = Convert.ToInt32(ddlRating.SelectedValue);

                string locationName = txtLocationName.Text.Trim();
                string address = txtAddress.Text.Trim();
                string city = txtCity.Text.Trim();
                string country = txtCountry.Text.Trim();
                decimal latitude = Convert.ToDecimal(txtLatitude.Text);
                decimal longitude = Convert.ToDecimal(txtLongitude.Text);
                string category = ddlCategory.SelectedValue;

                // เรียก Stored Procedure
                SqlParameter[] parameters = new SqlParameter[]
                {
                    new SqlParameter("@UserID", userID),
                    new SqlParameter("@Title", title),
                    new SqlParameter("@Description", description),
                    new SqlParameter("@TravelDate", travelDate),
                    new SqlParameter("@Rating", rating),
                    new SqlParameter("@LocationName", locationName),
                    new SqlParameter("@Address", (object)address ?? DBNull.Value),
                    new SqlParameter("@City", (object)city ?? DBNull.Value),
                    new SqlParameter("@Country", (object)country ?? DBNull.Value),
                    new SqlParameter("@Latitude", latitude),
                    new SqlParameter("@Longitude", longitude),
                    new SqlParameter("@Category", (object)category ?? DBNull.Value)
                };

                DBHelper.ExecuteStoredProcedure("sp_AddTravelEntry", parameters);

                lblMessage.ForeColor = System.Drawing.Color.Green;
                lblMessage.Text = "Travel entry added successfully!";

                // Clear form
                ClearForm();

                // Reload data
                LoadTravelEntries();
            }
            catch (Exception ex)
            {
                lblMessage.ForeColor = System.Drawing.Color.Red;
                lblMessage.Text = "Error: " + ex.Message;
            }
        }

        private void LoadTravelEntries()
        {
            try
            {
                int userID = Convert.ToInt32(Session["UserID"]);

                SqlParameter[] parameters = new SqlParameter[]
                {
            new SqlParameter("@UserID", userID)
                };

                DataTable dt = DBHelper.ExecuteStoredProcedure("sp_GetUserTravelEntries", parameters);

                rptTimeline.DataSource = dt;
                rptTimeline.DataBind();

                if (dt.Rows.Count > 0)
                {
                    StringBuilder jsonBuilder = new StringBuilder();
                    jsonBuilder.Append("[");

                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        if (i > 0) jsonBuilder.Append(",");

                        // ✅ เพิ่มการเช็ค DBNull
                        string locationName = dt.Rows[i]["LocationName"] != DBNull.Value ?
                            dt.Rows[i]["LocationName"].ToString() : "";
                        string city = dt.Rows[i]["City"] != DBNull.Value ?
                            dt.Rows[i]["City"].ToString() : "";
                        string country = dt.Rows[i]["Country"] != DBNull.Value ?
                            dt.Rows[i]["Country"].ToString() : "";

                        jsonBuilder.Append("{");
                        jsonBuilder.AppendFormat("\"LocationName\":\"{0}\",", locationName);
                        jsonBuilder.AppendFormat("\"City\":\"{0}\",", city);
                        jsonBuilder.AppendFormat("\"Country\":\"{0}\",", country);
                        jsonBuilder.AppendFormat("\"Latitude\":{0},", dt.Rows[i]["Latitude"]);
                        jsonBuilder.AppendFormat("\"Longitude\":{0},", dt.Rows[i]["Longitude"]);
                        jsonBuilder.AppendFormat("\"Rating\":{0},", dt.Rows[i]["Rating"]);

                        if (dt.Rows[i]["TravelDate"] != DBNull.Value)
                        {
                            DateTime travelDate = Convert.ToDateTime(dt.Rows[i]["TravelDate"]);
                            jsonBuilder.AppendFormat("\"TravelDate\":\"{0:dd/MM/yyyy}\"", travelDate);
                        }
                        else
                        {
                            jsonBuilder.Append("\"TravelDate\":\"\"");
                        }

                        jsonBuilder.Append("}");
                    }

                    jsonBuilder.Append("]");
                    hfMapData.Value = jsonBuilder.ToString();
                }
                else
                {
                    hfMapData.Value = "[]";
                }
            }
            catch (Exception ex)
            {
                lblMessage.ForeColor = System.Drawing.Color.Red;
                lblMessage.Text = "Error loading entries: " + ex.Message;
            }
        }

        private void ClearForm()
        {
            txtTitle.Text = "";
            txtDescription.Text = "";
            txtTravelDate.Text = "";
            ddlRating.SelectedIndex = 2;
            txtLocationName.Text = "";
            txtAddress.Text = "";
            txtCity.Text = "";
            txtCountry.Text = "";
            txtLatitude.Text = "";
            txtLongitude.Text = "";
            ddlCategory.SelectedIndex = 0;
        }

        protected void rptTimeline_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DeleteEntry")
            {
                try
                {
                    int entryID = Convert.ToInt32(e.CommandArgument);
                    int userID = Convert.ToInt32(Session["UserID"]);

                    // ลบ Entry
                    string deleteQuery = "DELETE FROM TravelEntries WHERE EntryID = @EntryID AND UserID = @UserID";
                    SqlParameter[] parameters = new SqlParameter[]
                    {
                        new SqlParameter("@EntryID", entryID),
                        new SqlParameter("@UserID", userID)
                    };

                    DBHelper.ExecuteNonQuery(deleteQuery, parameters);

                    lblMessage.ForeColor = System.Drawing.Color.Green;
                    lblMessage.Text = "Travel entry deleted successfully!";

                    // Reload data
                    LoadTravelEntries();
                }
                catch (Exception ex)
                {
                    lblMessage.ForeColor = System.Drawing.Color.Red;
                    lblMessage.Text = "Error deleting entry: " + ex.Message;
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