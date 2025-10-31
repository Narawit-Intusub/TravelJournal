<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminUsers.aspx.cs" Inherits="TravelJournal.AdminUsers" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>User Management - Admin</title>
    <!-- Custom CSS -->
    <link href="~/Content/Css/AdminUsers.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <!-- Header -->
            <div class="header">
                <h1>👥 User Management</h1>
                <div class="nav-links">
                    <asp:Label ID="lblAdminName" runat="server"></asp:Label>
                    &nbsp;|&nbsp;
                    <asp:HyperLink ID="hlStats" runat="server" NavigateUrl="~/Pages/Admin/LocationStatistics.aspx">📊 Location Stats</asp:HyperLink> 
                    &nbsp;|&nbsp;
                    <asp:LinkButton ID="lnkLogout" runat="server" OnClick="lnkLogout_Click" CausesValidation="False">⏻ Logout</asp:LinkButton>
                </div>
            </div>

            <!-- Stats Cards -->
            <div class="stats-cards">
                <div class="stat-card">
                    <div class="stat-number">
                        <asp:Label ID="lblTotalUsers" runat="server">0</asp:Label>
                    </div>
                    <div class="stat-label">👥 ผู้ใช้ทั้งหมด</div>
                </div>
                <div class="stat-card green">
                    <div class="stat-number">
                        <asp:Label ID="lblActiveUsers" runat="server">0</asp:Label>
                    </div>
                    <div class="stat-label">✅ ผู้ใช้ที่ใช้งานอยู่</div>
                </div>
                <div class="stat-card orange">
                    <div class="stat-number">
                        <asp:Label ID="lblNewUsersToday" runat="server">0</asp:Label>
                    </div>
                    <div class="stat-label">🆕 สมาชิกใหม่วันนี้</div>
                </div>
                <div class="stat-card blue">
                    <div class="stat-number">
                        <asp:Label ID="lblTotalEntries" runat="server">0</asp:Label>
                    </div>
                    <div class="stat-label">✈️ บันทึกทั้งหมด</div>
                </div>
            </div>

            <!-- Message -->
            <asp:Panel ID="pnlMessage" runat="server" Visible="false">
                <asp:Label ID="lblMessage" runat="server"></asp:Label>
            </asp:Panel>

            <!-- Search Bar -->
            <div class="search-section">
                <div class="search-bar">
                    <asp:TextBox ID="txtSearch" runat="server" placeholder="🔍 ค้นหาด้วย username, email, หรือชื่อ..."></asp:TextBox>
                    <asp:Button ID="btnSearch" runat="server" Text="🔎 ค้นหา" OnClick="btnSearch_Click" CausesValidation="False" />
                    <asp:Button ID="btnRefresh" runat="server" Text="↻ รีเฟรช" OnClick="btnRefresh_Click" CausesValidation="False" 
                        CssClass="btn-refresh" />
                </div>
            </div>

            <!-- Users Table -->
            <div class="table-section">
                <div class="table-wrapper">
                    <asp:GridView ID="gvUsers" runat="server" 
                        CssClass="users-table" 
                        AutoGenerateColumns="False"
                        OnRowCommand="gvUsers_RowCommand"
                        DataKeyNames="UserID"
                        AllowPaging="True"
                        PageSize="10"
                        OnPageIndexChanging="gvUsers_PageIndexChanging"
                        AllowSorting="True"
                        OnSorting="gvUsers_Sorting">
                        <Columns>
                            <asp:BoundField DataField="UserID" HeaderText="ID" SortExpression="UserID" />
                            <asp:BoundField DataField="Username" HeaderText="Username" SortExpression="Username" />
                            <asp:BoundField DataField="FullName" HeaderText="ชื่อ-นามสกุล" SortExpression="FullName" />
                            <asp:BoundField DataField="Email" HeaderText="Email" SortExpression="Email" />
                            
                            <asp:TemplateField HeaderText="บทบาท" SortExpression="Role">
                                <ItemTemplate>
                                    <span class='<%# Eval("Role").ToString() == "Admin" ? "badge badge-admin" : "badge badge-user" %>'>
                                        <%# Eval("Role").ToString() == "Admin" ? "👑 Admin" : "👤 User" %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            
                            <asp:TemplateField HeaderText="สถานะ" SortExpression="IsActive">
                                <ItemTemplate>
                                    <span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "badge badge-active" : "badge badge-inactive" %>'>
                                        <%# Convert.ToBoolean(Eval("IsActive")) ? "✅ Active" : "🚫 Inactive" %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            
                            <asp:BoundField DataField="TotalEntries" HeaderText="บันทึก" SortExpression="TotalEntries" />
                            <asp:BoundField DataField="TotalLocations" HeaderText="สถานที่" SortExpression="TotalLocations" />
                            <asp:BoundField DataField="CreatedDate" HeaderText="สมัครเมื่อ" DataFormatString="{0:dd/MM/yyyy}" SortExpression="CreatedDate" />
                            <asp:BoundField DataField="LastLogin" HeaderText="เข้าสู่ระบบล่าสุด" DataFormatString="{0:dd/MM/yyyy HH:mm}" SortExpression="LastLogin" />
                            
                            <asp:TemplateField HeaderText="จัดการ">
                                <ItemTemplate>
                                    <asp:Button ID="btnViewLogs" runat="server" 
                                        Text="📋 Logs" 
                                        CommandName="ViewLogs" 
                                        CommandArgument='<%# Eval("UserID") %>'
                                        CssClass="btn btn-view"
                                        CausesValidation="False"
                                        ToolTip="ดูประวัติการใช้งาน" />
                                    <asp:Button ID="btnToggleStatus" runat="server" 
                                        Text='<%# Convert.ToBoolean(Eval("IsActive")) ? "🚫 ปิดการใช้งาน" : "✅ เปิดการใช้งาน" %>'
                                        CommandName="ToggleStatus" 
                                        CommandArgument='<%# Eval("UserID") %>'
                                        CssClass="btn btn-toggle"
                                        CausesValidation="False"
                                        OnClientClick="return confirm('คุณแน่ใจหรือว่าต้องการเปลี่ยนสถานะผู้ใช้นี้?');"
                                        ToolTip="เปลี่ยนสถานะการใช้งาน" />
                                    <asp:Button ID="btnDelete" runat="server" 
                                        Text="🗑️ ลบ" 
                                        CommandName="DeleteUser" 
                                        CommandArgument='<%# Eval("UserID") %>'
                                        CssClass="btn btn-delete"
                                        CausesValidation="False"
                                        Visible='<%# Eval("Role").ToString() != "Admin" %>'
                                        OnClientClick="return confirm('คุณแน่ใจหรือว่าต้องการลบผู้ใช้นี้? การกระทำนี้ไม่สามารถย้อนกลับได้!');"
                                        ToolTip="ลบผู้ใช้" />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <PagerStyle CssClass="pager" />
                        <PagerSettings Mode="NumericFirstLast" PageButtonCount="5" FirstPageText="«« First" LastPageText="Last »»" />
                    </asp:GridView>
                </div>
            </div>

            <!-- User Logs Section -->
            <asp:Panel ID="pnlUserLogs" runat="server" Visible="false" CssClass="logs-section">
                <div class="logs-header">
                    <h2>
                        📋 ประวัติการใช้งาน - <asp:Label ID="lblSelectedUser" runat="server"></asp:Label>
                    </h2>
                    <asp:Button ID="btnCloseLogs" runat="server" Text="✖ ปิด" OnClick="btnCloseLogs_Click" 
                        CausesValidation="False" CssClass="btn-close-logs" />
                </div>
                
                <div class="table-wrapper">
                    <asp:GridView ID="gvLogs" runat="server" 
                        CssClass="users-table" 
                        AutoGenerateColumns="False"
                        AllowPaging="True"
                        PageSize="20"
                        OnPageIndexChanging="gvLogs_PageIndexChanging"
                        AllowSorting="True"
                        OnSorting="gvLogs_Sorting">
                        <Columns>
                            <asp:BoundField DataField="ActivityLogID" HeaderText="Log ID" SortExpression="ActivityLogID" />
                            <asp:BoundField DataField="CreatedDate" HeaderText="วันที่/เวลา" DataFormatString="{0:dd/MM/yyyy HH:mm:ss}" SortExpression="CreatedDate" />
                            <asp:BoundField DataField="ActivityType" HeaderText="ประเภทกิจกรรม" SortExpression="ActivityType" />
                            <asp:BoundField DataField="ActivityDescription" HeaderText="รายละเอียด" />
                            <asp:BoundField DataField="IPAddress" HeaderText="IP Address" />
                        </Columns>
                        <PagerStyle CssClass="pager" />
                        <PagerSettings Mode="NumericFirstLast" PageButtonCount="5" FirstPageText="«« First" LastPageText="Last »»" />
                    </asp:GridView>
                </div>
            </asp:Panel>

            <!-- Info Box -->
            <div class="info-box">
                <p>
                    <strong>💡 คำแนะนำ:</strong> 
                    คลิก "📋 Logs" เพื่อดูประวัติการใช้งาน • 
                    คลิก "🚫 ปิดการใช้งาน" เพื่อระงับบัญชีชั่วคราว • 
                    คลิก "🗑️ ลบ" เพื่อลบผู้ใช้ (เฉพาะ User เท่านั้น) • 
                    ไม่สามารถลบบัญชี Admin ได้ • 
                    คลิกที่ Header เพื่อเรียงลำดับข้อมูล
                </p>
            </div>
        </div>
    </form>
</body>
</html>