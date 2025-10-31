<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Profile.aspx.cs" Inherits="TravelJournal.Profile" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>My Profile - Travel Journal</title>
    <!-- Custom CSS -->
    <link href="~/Content/Css/Profile.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <!-- Navigation -->
            <div class="nav-container">
                <div class="nav-links">
                    <asp:HyperLink ID="hlDashboard" runat="server" NavigateUrl="~/Pages/User/Dashboard.aspx">🏠 Dashboard</asp:HyperLink>
                    <asp:Panel ID="pnlAdminLink" runat="server" Visible="false" style="display:inline;">
                        <asp:HyperLink ID="hlUserManagement" runat="server" NavigateUrl="~/Pages/Admin/AdminUsers.aspx">👥 User Management</asp:HyperLink>
                        <asp:HyperLink ID="hlAdmin" runat="server" NavigateUrl="~/Pages/Admin/LocationStatistics.aspx">📊 Location Stats</asp:HyperLink>
                    </asp:Panel>
                    <asp:LinkButton ID="lnkLogout" runat="server" OnClick="lnkLogout_Click" CausesValidation="False">⏻ Logout</asp:LinkButton>
                </div>
            </div>

            <!-- Profile Header -->
            <div class="profile-header">
                <div class="profile-image-container">
                    <!-- Profile Image or Avatar -->
                    <asp:Image ID="imgProfile" runat="server" CssClass="profile-image" Visible="false" />
                    <asp:Panel ID="pnlDefaultAvatar" runat="server" CssClass="default-avatar">
                        <asp:Label ID="lblAvatarInitial" runat="server"></asp:Label>
                    </asp:Panel>
                    
                    <!-- Upload Section -->
                    <div class="upload-section">
                        <asp:FileUpload ID="fuProfileImage" runat="server" />
                        <br /><br />
                        <asp:Button ID="btnUploadImage" runat="server" Text="📸 อัปโหลดรูปภาพ" 
                            OnClick="btnUploadImage_Click" CssClass="btn btn-secondary" CausesValidation="False" />
                    </div>
                </div>

                <div class="profile-info">
                    <h1>👤 <asp:Label ID="lblProfileName" runat="server"></asp:Label></h1>
                    <p><strong>👨‍💼 Username:</strong> <asp:Label ID="lblUsername" runat="server"></asp:Label></p>
                    <p><strong>📧 Email:</strong> <asp:Label ID="lblEmail" runat="server"></asp:Label></p>
                    <p><strong>📅 สมาชิกตั้งแต่:</strong> <asp:Label ID="lblMemberSince" runat="server"></asp:Label></p>
                    <p><strong>🕐 เข้าสู่ระบบล่าสุด:</strong> <asp:Label ID="lblLastLogin" runat="server"></asp:Label></p>
                </div>
            </div>

            <!-- Statistics -->
            <div class="stats-box">
                <div class="stat-item">
                    <div class="stat-number">
                        <asp:Label ID="lblTotalEntries" runat="server">0</asp:Label>
                    </div>
                    <div class="stat-label">✈️ บันทึกการเดินทาง</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number">
                        <asp:Label ID="lblTotalLocations" runat="server">0</asp:Label>
                    </div>
                    <div class="stat-label">📍 สถานที่ที่ไปแล้ว</div>
                </div>
            </div>

            <!-- Edit Profile Section -->
            <div class="section">
                <h3>✏️ แก้ไขข้อมูลส่วนตัว</h3>
                
                <asp:Label ID="lblMessage" runat="server" CssClass="message-success"></asp:Label>
                
                <table class="form-table">
                    <tr>
                        <td><strong>ชื่อ-นามสกุล:</strong></td>
                        <td>
                            <asp:TextBox ID="txtFullName" runat="server" placeholder="กรอกชื่อ-นามสกุล"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvFullName" runat="server" 
                                ControlToValidate="txtFullName" 
                                ErrorMessage="*" 
                                ForeColor="Red"
                                CssClass="validator">
                            </asp:RequiredFieldValidator>
                        </td>
                    </tr>
                    <tr>
                        <td><strong>อีเมล:</strong></td>
                        <td>
                            <asp:TextBox ID="txtEmail" runat="server" placeholder="example@email.com"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvEmail" runat="server" 
                                ControlToValidate="txtEmail" 
                                ErrorMessage="*" 
                                ForeColor="Red"
                                CssClass="validator">
                            </asp:RequiredFieldValidator>
                            <asp:RegularExpressionValidator ID="revEmail" runat="server"
                                ControlToValidate="txtEmail"
                                ErrorMessage="รูปแบบอีเมลไม่ถูกต้อง"
                                ValidationExpression="^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$"
                                ForeColor="Red"
                                Display="Dynamic">
                            </asp:RegularExpressionValidator>
                        </td>
                    </tr>
                    <tr>
                        <td><strong>วันเกิด:</strong></td>
                        <td>
                            <asp:TextBox ID="txtDateOfBirth" runat="server" TextMode="Date"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2" align="center">
                            <br />
                            <asp:Button ID="btnUpdateProfile" runat="server" Text="💾 บันทึกข้อมูล" 
                                OnClick="btnUpdateProfile_Click" CssClass="btn btn-primary" />
                        </td>
                    </tr>
                </table>
            </div>

            <!-- My Locations Section -->
            <div class="section">
                <h3>🗺️ สถานที่ที่ฉันเคยไป (<asp:Label ID="lblLocationCount" runat="server">0</asp:Label> แห่ง)</h3>
                
                <asp:Repeater ID="rptLocations" runat="server" OnItemCommand="rptLocations_ItemCommand">
                    <HeaderTemplate>
                        <div class="locations-grid">
                    </HeaderTemplate>
                    <ItemTemplate>
                        <div class="location-card">
                            <asp:Button ID="btnDeleteLocation" runat="server" 
                                Text="🗑️" 
                                CommandName="DeleteLocation"
                                CommandArgument='<%# Eval("LocationID") %>'
                                OnClientClick="return confirm('ต้องการลบสถานที่นี้และบันทึกทั้งหมดที่เกี่ยวข้องหรือไม่?');"
                                CausesValidation="False"
                                CssClass="delete-location-btn"
                                ToolTip="ลบสถานที่" />
                            
                            <h4><%# Eval("LocationName") %></h4>
                            
                            <p><strong>📍 ที่อยู่:</strong> <%# Eval("City") %>, <%# Eval("Country") %></p>
                            <p><strong>🏷️ หมวดหมู่:</strong> <%# Eval("Category") %></p>
                            <p><strong>🔢 จำนวนครั้งที่ไป:</strong> <%# Eval("VisitCount") %> ครั้ง</p>
                            <p><strong>⭐ คะแนนเฉลี่ย:</strong> <%# Eval("AvgRating", "{0:F1}") %> / 5</p>
                            <p><strong>📅 ไปล่าสุดเมื่อ:</strong> <%# Eval("LastVisitDate", "{0:dd/MM/yyyy}") %></p>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate>
                        </div>
                    </FooterTemplate>
                </asp:Repeater>

                <asp:Label ID="lblNoLocations" runat="server" 
                    Text="คุณยังไม่มีสถานที่ที่บันทึกไว้ เริ่มเพิ่มบันทึกการเดินทางของคุณได้เลย! ✈️" 
                    Visible="false" 
                    CssClass="no-locations-message">
                </asp:Label>
            </div>

            <!-- Additional Info Section (Optional) -->
            <div class="section" style="background: linear-gradient(135deg, #f8f9ff 0%, #fff 100%); border: 2px solid #667eea;">
                <h3>💡 เคล็ดลับ</h3>
                <p style="color: #555; line-height: 1.8; margin: 0;">
                    <strong>🎯 การใช้งาน:</strong> คลิกที่แผนที่ใน Dashboard เพื่อเลือกพิกัดของสถานที่ที่คุณต้องการบันทึก 
                    คุณสามารถให้คะแนนและเพิ่มรายละเอียดการเดินทางของคุณได้<br/><br/>
                    <strong>📸 รูปภาพโปรไฟล์:</strong> อัปโหลดรูปภาพของคุณเพื่อทำให้โปรไฟล์ดูน่าสนใจมากขึ้น<br/><br/>
                    <strong>🌟 คะแนน:</strong> สีของ marker บนแผนที่จะเปลี่ยนตามคะแนนที่คุณให้ (5⭐ = เขียว, 1⭐ = แดง)
                </p>
            </div>
        </div>
    </form>
</body>
</html>