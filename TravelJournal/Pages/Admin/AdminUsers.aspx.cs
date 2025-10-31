using System;
using System.Data;
using System.Data.SqlClient;
using System.EnterpriseServices;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using TravelJournal;

namespace TravelJournal
{
    public partial class AdminUsers : Page
    {
        // ViewState keys for sorting
        private const string VS_SORT_EXPRESSION = "SortExpression";
        private const string VS_SORT_DIRECTION = "SortDirection";
        private const string VS_LOGS_SORT_EXPRESSION = "LogsSortExpression";
        private const string VS_LOGS_SORT_DIRECTION = "LogsSortDirection";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            if (Session["Role"] == null || Session["Role"].ToString() != "Admin")
            {
                Response.Write("<script>alert('Access Denied!'); window.location='~/Pages/User/Dashboard.aspx';</script>");
                return;
            }

            if (!IsPostBack)
            {
                lblAdminName.Text = "Admin: " + Session["FullName"].ToString();
                ViewState[VS_SORT_EXPRESSION] = "UserID";
                ViewState[VS_SORT_DIRECTION] = "DESC";
                ViewState[VS_LOGS_SORT_EXPRESSION] = "ActivityLogID";
                ViewState[VS_LOGS_SORT_DIRECTION] = "DESC";
                LoadUsers();
                LoadStatistics();
            }
        }

        private void LoadUsers()
        {
            try
            {
                DataTable dt = DBHelper.ExecuteStoredProcedure("sp_GetAllUsers", null);

                // Apply sorting
                if (ViewState[VS_SORT_EXPRESSION] != null)
                {
                    DataView dv = dt.DefaultView;
                    dv.Sort = ViewState[VS_SORT_EXPRESSION] + " " + ViewState[VS_SORT_DIRECTION];
                    dt = dv.ToTable();
                }

                gvUsers.DataSource = dt;
                gvUsers.DataBind();
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        private void LoadStatistics()
        {
            try
            {
                DataTable dt = DBHelper.ExecuteStoredProcedure("sp_GetAllUsers", null);
                lblTotalUsers.Text = dt.Rows.Count.ToString();

                int activeCount = 0;
                int newToday = 0;
                int totalEntries = 0;

                foreach (DataRow row in dt.Rows)
                {
                    if (Convert.ToBoolean(row["IsActive"]))
                        activeCount++;

                    DateTime createdDate = Convert.ToDateTime(row["CreatedDate"]);
                    if (createdDate.Date == DateTime.Now.Date)
                        newToday++;

                    totalEntries += Convert.ToInt32(row["TotalEntries"]);
                }

                lblActiveUsers.Text = activeCount.ToString();
                lblNewUsersToday.Text = newToday.ToString();
                lblTotalEntries.Text = totalEntries.ToString();
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string searchText = txtSearch.Text.Trim();
            if (string.IsNullOrEmpty(searchText))
            {
                LoadUsers();
                return;
            }

            try
            {
                DataTable dt = DBHelper.ExecuteStoredProcedure("sp_GetAllUsers", null);
                DataView dv = dt.DefaultView;
                dv.RowFilter = string.Format(
                    "Username LIKE '%{0}%' OR Email LIKE '%{0}%' OR FullName LIKE '%{0}%'",
                    searchText.Replace("'", "''"));

                // Apply sorting to search results
                if (ViewState[VS_SORT_EXPRESSION] != null)
                {
                    dv.Sort = ViewState[VS_SORT_EXPRESSION] + " " + ViewState[VS_SORT_DIRECTION];
                }

                gvUsers.DataSource = dv;
                gvUsers.DataBind();
                ShowMessage($"Found {dv.Count} user(s)", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            gvUsers.PageIndex = 0;
            LoadUsers();
            LoadStatistics();
            pnlUserLogs.Visible = false;
            ShowMessage("Refreshed!", true);
        }

        protected void gvUsers_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvUsers.PageIndex = e.NewPageIndex;
            if (!string.IsNullOrEmpty(txtSearch.Text.Trim()))
            {
                btnSearch_Click(sender, EventArgs.Empty);
            }
            else
            {
                LoadUsers();
            }
        }

        protected void gvUsers_Sorting(object sender, GridViewSortEventArgs e)
        {
            string sortExpression = e.SortExpression;
            string sortDirection = "ASC";

            // Toggle sort direction
            if (ViewState[VS_SORT_EXPRESSION] != null && ViewState[VS_SORT_EXPRESSION].ToString() == sortExpression)
            {
                sortDirection = ViewState[VS_SORT_DIRECTION].ToString() == "ASC" ? "DESC" : "ASC";
            }

            ViewState[VS_SORT_EXPRESSION] = sortExpression;
            ViewState[VS_SORT_DIRECTION] = sortDirection;

            if (!string.IsNullOrEmpty(txtSearch.Text.Trim()))
            {
                btnSearch_Click(sender, EventArgs.Empty);
            }
            else
            {
                LoadUsers();
            }
        }

        protected void gvUsers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            // Ignore paging commands
            if (e.CommandName == "Page")
                return;

            // Only process our custom commands
            if (e.CommandName != "ViewLogs" && e.CommandName != "ToggleStatus" && e.CommandName != "DeleteUser")
                return;

            int userID = Convert.ToInt32(e.CommandArgument);
            int adminID = Convert.ToInt32(Session["UserID"]);

            if (userID == adminID && (e.CommandName == "DeleteUser" || e.CommandName == "ToggleStatus"))
            {
                ShowMessage("Cannot modify your own account!", false);
                return;
            }

            switch (e.CommandName)
            {
                case "ViewLogs":
                    ViewUserLogs(userID);
                    break;
                case "ToggleStatus":
                    ToggleUserStatus(userID, adminID);
                    break;
                case "DeleteUser":
                    DeleteUser(userID, adminID);
                    break;
            }
        }

        private void ViewUserLogs(int userID)
        {
            try
            {
                SqlParameter[] parameters = new SqlParameter[]
                {
                    new SqlParameter("@UserID", userID),
                    new SqlParameter("@TopRecords", 1000)  // Increased for paging
                };

                DataTable dt = DBHelper.ExecuteStoredProcedure("sp_GetUserActivityLogs", parameters);

                if (dt.Rows.Count > 0)
                {
                    // Store UserID in ViewState for paging
                    ViewState["CurrentUserID"] = userID;

                    lblSelectedUser.Text = dt.Rows[0]["Username"].ToString();

                    // Apply sorting
                    if (ViewState[VS_LOGS_SORT_EXPRESSION] != null)
                    {
                        DataView dv = dt.DefaultView;
                        dv.Sort = ViewState[VS_LOGS_SORT_EXPRESSION] + " " + ViewState[VS_LOGS_SORT_DIRECTION];
                        dt = dv.ToTable();
                    }

                    gvLogs.PageIndex = 0;
                    gvLogs.DataSource = dt;
                    gvLogs.DataBind();
                    pnlUserLogs.Visible = true;
                }
                else
                {
                    ShowMessage("No logs found", false);
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        protected void gvLogs_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvLogs.PageIndex = e.NewPageIndex;

            if (ViewState["CurrentUserID"] != null)
            {
                int userID = Convert.ToInt32(ViewState["CurrentUserID"]);
                ViewUserLogs(userID);
            }
        }

        protected void gvLogs_Sorting(object sender, GridViewSortEventArgs e)
        {
            string sortExpression = e.SortExpression;
            string sortDirection = "ASC";

            // Toggle sort direction
            if (ViewState[VS_LOGS_SORT_EXPRESSION] != null && ViewState[VS_LOGS_SORT_EXPRESSION].ToString() == sortExpression)
            {
                sortDirection = ViewState[VS_LOGS_SORT_DIRECTION].ToString() == "ASC" ? "DESC" : "ASC";
            }

            ViewState[VS_LOGS_SORT_EXPRESSION] = sortExpression;
            ViewState[VS_LOGS_SORT_DIRECTION] = sortDirection;

            if (ViewState["CurrentUserID"] != null)
            {
                int userID = Convert.ToInt32(ViewState["CurrentUserID"]);
                ViewUserLogs(userID);
            }
        }

        private void ToggleUserStatus(int userID, int adminID)
        {
            try
            {
                SqlParameter[] parameters = new SqlParameter[]
                {
                    new SqlParameter("@UserID", userID),
                    new SqlParameter("@AdminUserID", adminID)
                };

                DataTable result = DBHelper.ExecuteStoredProcedure("sp_ToggleUserStatus", parameters);

                if (result.Rows.Count > 0)
                {
                    ShowMessage("Status changed!", true);
                    LoadUsers();
                    LoadStatistics();
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        private void DeleteUser(int userID, int adminID)
        {
            try
            {
                SqlParameter[] parameters = new SqlParameter[]
                {
                    new SqlParameter("@UserID", userID),
                    new SqlParameter("@AdminUserID", adminID)
                };

                DBHelper.ExecuteStoredProcedure("sp_DeleteUser", parameters);
                ShowMessage("User deleted!", true);
                LoadUsers();
                LoadStatistics();
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        protected void btnCloseLogs_Click(object sender, EventArgs e)
        {
            pnlUserLogs.Visible = false;
            ViewState["CurrentUserID"] = null;
        }

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            FormsAuthentication.SignOut();
            Response.Redirect("~/Login.aspx");
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            pnlMessage.Visible = true;
            pnlMessage.CssClass = isSuccess ? "message message-success" : "message message-error";
            lblMessage.Text = message;
        }
    }
}