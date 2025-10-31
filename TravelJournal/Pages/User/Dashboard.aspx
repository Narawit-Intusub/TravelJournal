<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="TravelJournal.Dashboard" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Dashboard - Travel Journal</title>
    <!-- Leaflet CSS -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <!-- Custom CSS -->
    <link href="~/Content/Css/Dashboard.css" rel="stylesheet" type="text/css" />
    <!-- Leaflet JS -->
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
</head>
<body>
<form id="form1" runat="server">
    <div class="container">
        <!-- Header Section -->
        <div class="header">
            <div class="header-nav">
                <asp:Label ID="lblWelcome" runat="server"></asp:Label>
                &nbsp;|&nbsp;
                <asp:HyperLink ID="hlProfile" runat="server" NavigateUrl="~/Pages/User/Profile.aspx">👤 My Profile</asp:HyperLink>
                &nbsp;|&nbsp;
                <asp:Panel ID="pnlAdminLink" runat="server" Visible="false" style="display:inline;">
                    <asp:HyperLink ID="hlUserManagement" runat="server" NavigateUrl="~/Pages/Admin/AdminUsers.aspx">👥 User Management</asp:HyperLink>
                    &nbsp;|&nbsp;
                    <asp:HyperLink ID="hlAdmin" runat="server" NavigateUrl="~/Pages/Admin/LocationStatistics.aspx">📊 Location Stats</asp:HyperLink>
                    &nbsp;|&nbsp;
                </asp:Panel>
                <asp:LinkButton ID="lnkLogout" runat="server" OnClick="lnkLogout_Click" CausesValidation="False">⏻ Logout</asp:LinkButton>
            </div>
            <h1>✈️ Travel Journal</h1>
            <p style="margin: 0; opacity: 0.9;">บันทึกการเดินทางของคุณ</p>
        </div>

        <!-- Add New Travel Entry Form -->
        <div class="form-card">
            <h3>📝 เพิ่มบันทึกการเดินทางใหม่</h3>
            
            <asp:Label ID="lblMessage" runat="server" CssClass="message-label message-error"></asp:Label>
            
            <table class="form-table">
                <tr>
                    <td>หัวข้อ:</td>
                    <td>
                        <asp:TextBox ID="txtTitle" runat="server" placeholder="เช่น เที่ยวภูเขา, ไปทะเล"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvTitle" runat="server"
                            ControlToValidate="txtTitle" ErrorMessage="*" ForeColor="Red" CssClass="validator" />
                    </td>
                </tr>
                <tr>
                    <td>รายละเอียด:</td>
                    <td>
                        <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" 
                            placeholder="เขียนประสบการณ์การเดินทางของคุณ..."></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td>วันที่เดินทาง:</td>
                    <td>
                        <asp:TextBox ID="txtTravelDate" runat="server" TextMode="Date"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvDate" runat="server"
                            ControlToValidate="txtTravelDate" ErrorMessage="*" ForeColor="Red" CssClass="validator" />
                    </td>
                </tr>
                <tr>
                    <td>ให้คะแนน (1-5):</td>
                    <td>
                        <asp:DropDownList ID="ddlRating" runat="server">
                            <asp:ListItem Value="1">⭐ 1 - แย่</asp:ListItem>
                            <asp:ListItem Value="2">⭐⭐ 2 - พอใช้</asp:ListItem>
                            <asp:ListItem Value="3" Selected="True">⭐⭐⭐ 3 - ดี</asp:ListItem>
                            <asp:ListItem Value="4">⭐⭐⭐⭐ 4 - ดีมาก</asp:ListItem>
                            <asp:ListItem Value="5">⭐⭐⭐⭐⭐ 5 - ยอดเยี่ยม</asp:ListItem>
                        </asp:DropDownList>
                    </td>
                </tr>
                <tr>
                    <td colspan="2"><hr class="section-divider" /></td>
                </tr>
                <tr>
                    <td>ชื่อสถานที่:</td>
                    <td>
                        <asp:TextBox ID="txtLocationName" runat="server" placeholder="เช่น วัดพระแก้ว, หาดป่าตอง"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvLocation" runat="server"
                            ControlToValidate="txtLocationName" ErrorMessage="*" ForeColor="Red" CssClass="validator" />
                    </td>
                </tr>
                <tr>
                    <td>ที่อยู่:</td>
                    <td>
                        <asp:TextBox ID="txtAddress" runat="server" placeholder="ที่อยู่โดยละเอียด"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td>เมือง:</td>
                    <td>
                        <asp:TextBox ID="txtCity" runat="server" placeholder="เช่น กรุงเทพ, เชียงใหม่"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td>ประเทศ:</td>
                    <td>
                        <asp:TextBox ID="txtCountry" runat="server" placeholder="เช่น ไทย, ญี่ปุ่น"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td>ละติจูด:</td>
                    <td>
                        <asp:TextBox ID="txtLatitude" runat="server" placeholder="คลิกบนแผนที่เพื่อรับพิกัด"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvLat" runat="server"
                            ControlToValidate="txtLatitude" ErrorMessage="*" ForeColor="Red" CssClass="validator" />
                        <asp:RangeValidator ID="rvLat" runat="server"
                            ControlToValidate="txtLatitude" MinimumValue="-90" MaximumValue="90" Type="Double"
                            ErrorMessage="ละติจูดไม่ถูกต้อง" ForeColor="Red" Display="Dynamic" />
                    </td>
                </tr>
                <tr>
                    <td>ลองจิจูด:</td>
                    <td>
                        <asp:TextBox ID="txtLongitude" runat="server" placeholder="คลิกบนแผนที่เพื่อรับพิกัด"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvLng" runat="server"
                            ControlToValidate="txtLongitude" ErrorMessage="*" ForeColor="Red" CssClass="validator" />
                        <asp:RangeValidator ID="rvLng" runat="server"
                            ControlToValidate="txtLongitude" MinimumValue="-180" MaximumValue="180" Type="Double"
                            ErrorMessage="ลองจิจูดไม่ถูกต้อง" ForeColor="Red" Display="Dynamic" />
                    </td>
                </tr>
                <tr>
                    <td>หมวดหมู่:</td>
                    <td>
                        <asp:DropDownList ID="ddlCategory" runat="server">
                            <asp:ListItem Value="ธรรมชาติ">🏞️ ธรรมชาติ</asp:ListItem>
                            <asp:ListItem Value="วัฒนธรรม">🏛️ วัฒนธรรม</asp:ListItem>
                            <asp:ListItem Value="อาหาร">🍜 อาหาร</asp:ListItem>
                            <asp:ListItem Value="ผจญภัย">🏔️ ผจญภัย</asp:ListItem>
                            <asp:ListItem Value="ช้อปปิ้ง">🛍️ ช้อปปิ้ง</asp:ListItem>
                            <asp:ListItem Value="อื่นๆ">📌 อื่นๆ</asp:ListItem>
                        </asp:DropDownList>
                    </td>
                </tr>
                <tr>
                    <td colspan="2" align="center">
                        <br />
                        <asp:Button ID="btnAddEntry" runat="server" Text="✅ บันทึกการเดินทาง" 
                            OnClick="btnAddEntry_Click" CssClass="btn-primary" />
                    </td>
                </tr>
            </table>
        </div>

        <!-- Leaflet Map -->
        <div class="map-section">
            <h3>🗺️ แผนที่การเดินทางของฉัน (คลิกเพื่อเลือกพิกัด)</h3>
            <div id="map"></div>
        </div>

        <!-- Timeline -->
        <div id="timeline">
            <h3>📅 ไทม์ไลน์การเดินทาง</h3>
            <asp:Repeater ID="rptTimeline" runat="server" OnItemCommand="rptTimeline_ItemCommand">
                <ItemTemplate>
                    <div class="timeline-item">
                        <asp:Button ID="btnDelete" runat="server"
                            Text="🗑️ ลบ"
                            CommandName="DeleteEntry"
                            CommandArgument='<%# Eval("EntryID") %>'
                            CssClass="delete-btn"
                            OnClientClick="return confirm('คุณแน่ใจหรือว่าต้องการลบบันทึกนี้?');"
                            CausesValidation="False" />
                        
                        <div class="timeline-item-date">
                            📅 <%# Eval("TravelDate", "{0:dd/MM/yyyy}") %>
                        </div>
                        <strong><%# Eval("Title") %></strong>
                        
                        <div class="timeline-item-location">
                            📍 <%# Eval("LocationName") %>, <%# Eval("City") %>, <%# Eval("Country") %>
                        </div>
                        
                        <div class="timeline-item-details">
                            ⭐ คะแนน: <%# Eval("Rating") %>/5 | 
                            🏷️ หมวดหมู่: <%# Eval("Category") %>
                        </div>
                        
                        <div class="timeline-item-description">
                            <%# Eval("Description") %>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <!-- Hidden Field for Map Data -->
        <asp:HiddenField ID="hfMapData" runat="server" />
    </div>
</form>

<!-- Dashboard Map Script -->
    <script src="<%= ResolveUrl("~/Scripts/dashboard-map.js") %>"></script>
    <script type="text/javascript">
        // Set Client IDs for JavaScript to access
        window.latitudeClientId = '<%= txtLatitude.ClientID %>';
        window.longitudeClientId = '<%= txtLongitude.ClientID %>';
        window.mapDataClientId = '<%= hfMapData.ClientID %>';
    </script>
</body>
</html>