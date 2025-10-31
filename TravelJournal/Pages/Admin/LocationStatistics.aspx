<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LocationStatistics.aspx.cs" Inherits="TravelJournal.LocationStatistics" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Location Statistics - Travel Journal Admin</title>
    <!-- Leaflet -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <!-- Custom CSS -->
    <link href="~/Content/Css/LocationStatistics.css" rel="stylesheet" type="text/css" />
</head>
<body>
<form id="form1" runat="server">
    <div class="container">
        <!-- Page Header -->
        <div class="page-header">
            <h1>📊 Location Statistics - Admin Dashboard</h1>
            <div class="header-nav">
                <asp:Label ID="lblAdminWelcome" runat="server"></asp:Label>
                &nbsp;|&nbsp;
                <asp:HyperLink ID="hlUserManagement" runat="server" NavigateUrl="~/Pages/Admin/AdminUsers.aspx">👥 User Management</asp:HyperLink>
                &nbsp;|&nbsp;
                <asp:LinkButton ID="lnkAdminLogout" runat="server" OnClick="lnkAdminLogout_Click" CausesValidation="False">⏻ Logout</asp:LinkButton>
            </div>
        </div>

        <!-- Summary Statistics -->
        <div class="summary-section">
            <h3>📈 สรุปภาพรวม</h3>
            <div class="summary-stats">
                <div class="stat-box">
                    <div class="stat-box-label">📍 จำนวนสถานที่ทั้งหมด</div>
                    <div class="stat-box-value">
                        <asp:Label ID="lblTotalLocations" runat="server">0</asp:Label>
                    </div>
                </div>
                <div class="stat-box">
                    <div class="stat-box-label">✈️ จำนวนการเข้าชมทั้งหมด</div>
                    <div class="stat-box-value">
                        <asp:Label ID="lblTotalVisits" runat="server">0</asp:Label>
                    </div>
                </div>
                <div class="stat-box">
                    <div class="stat-box-label">⭐ คะแนนเฉลี่ย</div>
                    <div class="stat-box-value">
                        <asp:Label ID="lblAverageRating" runat="server">0.0</asp:Label>
                    </div>
                </div>
            </div>
        </div>

        <!-- Map Section -->
        <div class="map-section">
            <h3>🗺️ แผนที่ความนิยมของสถานที่ (Scale 1-5)</h3>
            
            <!-- Legend -->
            <div class="legend">
                <strong>🎨 คำอธิบายสัญลักษณ์</strong>
                <div class="legend-items">
                    <div class="legend-item">
                        <span class="legend-color" style="background-color:#0066ff;"></span>
                        <span class="legend-text">Scale 5: นิยมมาก (100+ ครั้ง)</span>
                    </div>
                    <div class="legend-item">
                        <span class="legend-color" style="background-color:#00cc00;"></span>
                        <span class="legend-text">Scale 4: นิยม (50-99 ครั้ง)</span>
                    </div>
                    <div class="legend-item">
                        <span class="legend-color" style="background-color:#ff9900;"></span>
                        <span class="legend-text">Scale 3: ปานกลาง (20-49 ครั้ง)</span>
                    </div>
                    <div class="legend-item">
                        <span class="legend-color" style="background-color:#ff6600;"></span>
                        <span class="legend-text">Scale 2: น้อย (5-19 ครั้ง)</span>
                    </div>
                    <div class="legend-item">
                        <span class="legend-color" style="background-color:#ff0000;"></span>
                        <span class="legend-text">Scale 1: น้อยมาก (0-4 ครั้ง)</span>
                    </div>
                </div>
            </div>

            <div id="map"></div>
        </div>

        <hr class="section-divider" />

        <!-- Statistics Table -->
        <div class="table-section">
            <h3>📋 ตารางสถิติโดยละเอียด</h3>
            <div class="table-wrapper">
                <asp:GridView ID="gvStatistics" runat="server" 
                CssClass="stats-table" 
                AutoGenerateColumns="False"
                AllowSorting="True"
                AllowPaging="True"
                PageSize="10"
                OnSorting="gvStatistics_Sorting"
                OnPageIndexChanging="gvStatistics_PageIndexChanging"
                PagerStyle-CssClass="pager-style"
                PagerSettings-Mode="NumericFirstLast"
                PagerSettings-FirstPageText="« First"
                PagerSettings-LastPageText="Last »"
                PagerSettings-PageButtonCount="5">
                <Columns>
                    <asp:BoundField DataField="LocationName" HeaderText="Location Name" SortExpression="LocationName" />
                    <asp:BoundField DataField="City" HeaderText="City" SortExpression="City" />
                    <asp:BoundField DataField="Country" HeaderText="Country" SortExpression="Country" />
                    <asp:BoundField DataField="Category" HeaderText="Category" SortExpression="Category" />
                    <asp:BoundField DataField="VisitCount" HeaderText="Visit Count" SortExpression="VisitCount" />
                    <asp:BoundField DataField="AverageRating" HeaderText="Avg Rating" SortExpression="AverageRating" DataFormatString="{0:F2}" />
                    <asp:TemplateField HeaderText="Popularity Scale" SortExpression="PopularityScale">
                        <ItemTemplate>
                            <span class='<%# "popularity-" + Eval("PopularityScale") %>'>
                                <%# Eval("PopularityScale") %> / 5
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="LastUpdated" HeaderText="Last Updated" SortExpression="LastUpdated" DataFormatString="{0:dd/MM/yyyy HH:mm}" />
                </Columns>
                <PagerStyle CssClass="pager-style" HorizontalAlign="Center" />
            </asp:GridView>
            </div>
        </div>

        <!-- Info Box -->
        <div class="info-box">
            <p>
                <strong>💡 คำแนะนำ:</strong> 
                คลิกที่หัวตารางเพื่อเรียงลำดับข้อมูล • 
                ขนาดและสีของจุดบนแผนที่แสดงถึงความนิยมของสถานที่ • 
                กราฟแสดงข้อมูลในมุมมองต่างๆ เพื่อการวิเคราะห์ที่ดีขึ้น
            </p>
        </div>

        <!-- Hidden Fields for JSON Data -->
        <asp:HiddenField ID="hfMapData" runat="server" />
        <asp:HiddenField ID="hfChartData" runat="server" />
    </div>
</form>

<!-- Admin Statistics Script -->
<script src="<%= ResolveUrl("~/Scripts/admin-stats.js") %>"></script>
<script type="text/javascript">
    // Set Client IDs for JavaScript to access
    window.mapDataClientId = '<%= hfMapData.ClientID %>';
    window.chartDataClientId = '<%= hfChartData.ClientID %>';
</script>
</body>
</html>