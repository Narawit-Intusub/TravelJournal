using System;
using System.Data;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace TravelJournal
{
    public partial class LocationStatistics : Page
    {
        // ViewState keys for sorting
        private const string VS_SORT_EXPRESSION = "SortExpression";
        private const string VS_SORT_DIRECTION = "SortDirection";

        protected void Page_Load(object sender, EventArgs e)
        {
            // ตรวจสอบว่า Login แล้วหรือไม่
            if (Session["UserID"] == null)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            // ตรวจสอบว่าเป็น Admin หรือไม่
            if (Session["Role"] == null || Session["Role"].ToString() != "Admin")
            {
                Response.Write("<script>alert('Access Denied! Admin only.'); window.location='Dashboard.aspx';</script>");
                return;
            }

            if (!IsPostBack)
            {
                lblAdminWelcome.Text = "Admin: " + Session["FullName"].ToString();
                ViewState[VS_SORT_EXPRESSION] = "VisitCount";
                ViewState[VS_SORT_DIRECTION] = "DESC";
                LoadStatistics();
            }
        }

        protected void lnkAdminLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            System.Web.Security.FormsAuthentication.SignOut();
            Response.Redirect("~/Login.aspx");
        }

        private void LoadStatistics()
        {
            try
            {
                // เรียก Stored Procedure เพื่อดึงสถิติ
                DataTable dt = DBHelper.ExecuteStoredProcedure("sp_GetLocationStatistics", null);

                if (dt.Rows.Count > 0)
                {
                    // คำนวณ Summary Statistics
                    int totalLocations = dt.Rows.Count;
                    int totalVisits = 0;
                    decimal totalRating = 0;
                    int countWithRating = 0;

                    foreach (DataRow row in dt.Rows)
                    {
                        totalVisits += Convert.ToInt32(row["VisitCount"]);

                        if (row["AverageRating"] != DBNull.Value)
                        {
                            decimal avgRating = Convert.ToDecimal(row["AverageRating"]);
                            if (avgRating > 0)
                            {
                                totalRating += avgRating;
                                countWithRating++;
                            }
                        }
                    }

                    decimal overallAvgRating = countWithRating > 0 ? totalRating / countWithRating : 0;

                    // แสดง Summary
                    lblTotalLocations.Text = totalLocations.ToString();
                    lblTotalVisits.Text = totalVisits.ToString();
                    lblAverageRating.Text = overallAvgRating.ToString("F2") + " / 5";

                    // Apply sorting
                    if (ViewState[VS_SORT_EXPRESSION] != null)
                    {
                        DataView dv = dt.DefaultView;
                        dv.Sort = ViewState[VS_SORT_EXPRESSION] + " " + ViewState[VS_SORT_DIRECTION];
                        dt = dv.ToTable();
                    }

                    // Bind data to GridView
                    gvStatistics.DataSource = dt;
                    gvStatistics.DataBind();

                    // สร้าง JSON สำหรับ Google Map
                    GenerateMapData(dt);
                }
                else
                {
                    lblTotalLocations.Text = "0";
                    lblTotalVisits.Text = "0";
                    lblAverageRating.Text = "N/A";
                }
            }
            catch (Exception ex)
            {
                // Handle error
                lblTotalLocations.Text = "Error: " + ex.Message;
            }
        }

        private void GenerateMapData(DataTable dt)
        {
            StringBuilder jsonBuilder = new StringBuilder();
            jsonBuilder.Append("[");

            for (int i = 0; i < dt.Rows.Count; i++)
            {
                if (i > 0) jsonBuilder.Append(",");

                DataRow row = dt.Rows[i];

                jsonBuilder.Append("{");
                jsonBuilder.AppendFormat("\"LocationName\":\"{0}\",",
                    row["LocationName"].ToString().Replace("\"", "\\\""));
                jsonBuilder.AppendFormat("\"City\":\"{0}\",",
                    row["City"] != DBNull.Value ? row["City"].ToString().Replace("\"", "\\\"") : "");
                jsonBuilder.AppendFormat("\"Country\":\"{0}\",",
                    row["Country"] != DBNull.Value ? row["Country"].ToString().Replace("\"", "\\\"") : "");
                jsonBuilder.AppendFormat("\"Category\":\"{0}\",",
                    row["Category"] != DBNull.Value ? row["Category"].ToString().Replace("\"", "\\\"") : "");
                jsonBuilder.AppendFormat("\"Latitude\":{0},", row["Latitude"]);
                jsonBuilder.AppendFormat("\"Longitude\":{0},", row["Longitude"]);
                jsonBuilder.AppendFormat("\"VisitCount\":{0},", row["VisitCount"]);
                jsonBuilder.AppendFormat("\"AverageRating\":{0},",
                    row["AverageRating"] != DBNull.Value ?
                    Convert.ToDecimal(row["AverageRating"]).ToString("F2") : "0");
                jsonBuilder.AppendFormat("\"PopularityScale\":{0}", row["PopularityScale"]);
                jsonBuilder.Append("}");
            }

            jsonBuilder.Append("]");
            hfMapData.Value = jsonBuilder.ToString();

            // Generate chart data
            GenerateChartData(dt);
        }

        private void GenerateChartData(DataTable dt)
        {
            try
            {
                // 1. Popularity Distribution
                int[] popularityCount = new int[6]; // Index 0 unused, 1-5 for scales
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    int scale = Convert.ToInt32(dt.Rows[i]["PopularityScale"]);
                    popularityCount[scale]++;
                }

                // 2. Top 10 Locations by Visit Count
                DataView dv = dt.DefaultView;
                dv.Sort = "VisitCount DESC";
                DataTable topDt = dv.ToTable();

                StringBuilder topLabels = new StringBuilder("[");
                StringBuilder topValues = new StringBuilder("[");
                int topCount = Math.Min(10, topDt.Rows.Count);
                for (int i = 0; i < topCount; i++)
                {
                    if (i > 0)
                    {
                        topLabels.Append(",");
                        topValues.Append(",");
                    }
                    topLabels.AppendFormat("\"{0}\"", topDt.Rows[i]["LocationName"].ToString().Replace("\"", "\\\""));
                    topValues.Append(topDt.Rows[i]["VisitCount"]);
                }
                topLabels.Append("]");
                topValues.Append("]");

                // 3. Category Distribution
                System.Collections.Generic.Dictionary<string, int> categoryCount = new System.Collections.Generic.Dictionary<string, int>();
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    string category = dt.Rows[i]["Category"] != DBNull.Value ? dt.Rows[i]["Category"].ToString() : "ไม่ระบุ";
                    if (categoryCount.ContainsKey(category))
                        categoryCount[category]++;
                    else
                        categoryCount[category] = 1;
                }

                StringBuilder catLabels = new StringBuilder("[");
                StringBuilder catValues = new StringBuilder("[");
                int catIndex = 0;
                foreach (var cat in categoryCount)
                {
                    if (catIndex > 0)
                    {
                        catLabels.Append(",");
                        catValues.Append(",");
                    }
                    catLabels.AppendFormat("\"{0}\"", cat.Key.Replace("\"", "\\\""));
                    catValues.Append(cat.Value);
                    catIndex++;
                }
                catLabels.Append("]");
                catValues.Append("]");

                // 4. Average Rating by Category
                System.Collections.Generic.Dictionary<string, System.Collections.Generic.List<decimal>> categoryRatings =
                    new System.Collections.Generic.Dictionary<string, System.Collections.Generic.List<decimal>>();

                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    string category = dt.Rows[i]["Category"] != DBNull.Value ? dt.Rows[i]["Category"].ToString() : "ไม่ระบุ";
                    decimal rating = dt.Rows[i]["AverageRating"] != DBNull.Value ? Convert.ToDecimal(dt.Rows[i]["AverageRating"]) : 0;

                    if (rating > 0)
                    {
                        if (!categoryRatings.ContainsKey(category))
                            categoryRatings[category] = new System.Collections.Generic.List<decimal>();
                        categoryRatings[category].Add(rating);
                    }
                }

                StringBuilder ratingLabels = new StringBuilder("[");
                StringBuilder ratingValues = new StringBuilder("[");
                int ratingIndex = 0;
                foreach (var cat in categoryRatings)
                {
                    if (ratingIndex > 0)
                    {
                        ratingLabels.Append(",");
                        ratingValues.Append(",");
                    }
                    decimal avgRating = 0;
                    foreach (var r in cat.Value)
                        avgRating += r;
                    avgRating = avgRating / cat.Value.Count;

                    ratingLabels.AppendFormat("\"{0}\"", cat.Key.Replace("\"", "\\\""));
                    ratingValues.AppendFormat("{0:F2}", avgRating);
                    ratingIndex++;
                }
                ratingLabels.Append("]");
                ratingValues.Append("]");

                // Create JSON for charts
                StringBuilder chartJson = new StringBuilder();
                chartJson.Append("{");
                chartJson.AppendFormat("\"popularityDistribution\":{{\"scale1\":{0},\"scale2\":{1},\"scale3\":{2},\"scale4\":{3},\"scale5\":{4}}},",
                    popularityCount[1], popularityCount[2], popularityCount[3], popularityCount[4], popularityCount[5]);
                chartJson.AppendFormat("\"topLocations\":{{\"labels\":{0},\"values\":{1}}},", topLabels, topValues);
                chartJson.AppendFormat("\"categoryDistribution\":{{\"labels\":{0},\"values\":{1}}},", catLabels, catValues);
                chartJson.AppendFormat("\"ratingByCategory\":{{\"labels\":{0},\"values\":{1}}}", ratingLabels, ratingValues);
                chartJson.Append("}");

                hfChartData.Value = chartJson.ToString();
            }
            catch (Exception ex)
            {
                hfChartData.Value = "{}";
                System.Diagnostics.Debug.WriteLine("Chart data error: " + ex.Message);
            }
        }

        protected void gvStatistics_Sorting(object sender, GridViewSortEventArgs e)
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

            LoadStatistics();
        }

        protected void gvStatistics_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvStatistics.PageIndex = e.NewPageIndex;
            LoadStatistics();
        }
    }
}