<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="TravelJournal.Login" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Login - Travel Journal</title>
    <link href="Content/Css/Login.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="login-container">
            <!-- Header -->
            <div class="login-header">
                <div class="icon icon-travel"></div>
                <h1>Travel Journal</h1>
                <p>Welcome back! Login to continue your journey</p>
            </div>

            <!-- Body -->
            <div class="login-body">
                <!-- Error Message -->
                <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="error-message">
                    <asp:Label ID="lblMessage" runat="server"></asp:Label>
                </asp:Panel>

                <!-- Username -->
                <div class="form-group">
                    <label for="txtUsername">Username</label>
                    <div class="input-wrapper">
                        <span class="icon-user" style="position: absolute; left: 15px; top: 50%; transform: translateY(-50%); font-size: 18px;"></span>
                        <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" placeholder="Enter your username"></asp:TextBox>
                    </div>
                    <asp:RequiredFieldValidator ID="rfvUsername" runat="server" 
                        ControlToValidate="txtUsername" 
                        ErrorMessage="Required" 
                        CssClass="validation-error"
                        Display="Dynamic">
                    </asp:RequiredFieldValidator>
                </div>

                <!-- Password -->
                <div class="form-group">
                    <label for="txtPassword">Password</label>
                    <div class="input-wrapper">
                        <span class="icon-lock" style="position: absolute; left: 15px; top: 50%; transform: translateY(-50%); font-size: 18px;"></span>
                        <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control" placeholder="Enter your password"></asp:TextBox>
                    </div>
                    <asp:RequiredFieldValidator ID="rfvPassword" runat="server" 
                        ControlToValidate="txtPassword" 
                        ErrorMessage="Required" 
                        CssClass="validation-error"
                        Display="Dynamic">
                    </asp:RequiredFieldValidator>
                </div>

                <!-- Remember Me -->
                <div class="remember-me">
                    <input type="checkbox" id="chkRememberMe" />
                    <label for="chkRememberMe">Remember me</label>
                </div>

                <!-- Login Button -->
                <asp:Button ID="btnLogin" runat="server" Text="Login" OnClick="btnLogin_Click" CssClass="btn-login" />

                <!-- Divider -->
                <div class="divider">
                    <span>OR</span>
                </div>

                <!-- Register Link -->
                <div class="register-link">
                    <p>Don't have an account? <asp:HyperLink ID="hlRegister" runat="server" NavigateUrl="~/Register.aspx">Register here</asp:HyperLink></p>
                </div>
            </div>
        </div>
    </form>
</body>
</html>