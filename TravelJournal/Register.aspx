<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="TravelJournal.Register" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Register - Travel Journal</title>
    <link href="Content/Css/Register.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="register-container">
            <!-- Header -->
            <div class="register-header">
                <div class="icon icon-register"></div>
                <h1>Create Account</h1>
                <p>Join Travel Journal and start your adventure</p>
            </div>

            <!-- Body -->
            <div class="register-body">
                <!-- Message -->
                <asp:Panel ID="pnlMessage" runat="server" Visible="false">
                    <asp:Label ID="lblMessage" runat="server"></asp:Label>
                </asp:Panel>

                <!-- Username -->
                <div class="form-group">
                    <label for="txtUsername">Username</label>
                    <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" placeholder="Choose a username"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rfvUsername" runat="server" 
                        ControlToValidate="txtUsername" 
                        ErrorMessage="Username is required" 
                        CssClass="validation-error"
                        Display="Dynamic">
                    </asp:RequiredFieldValidator>
                </div>

                <!-- Email -->
                <div class="form-group">
                    <label for="txtEmail">Email</label>
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="Enter your email"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rfvEmail" runat="server" 
                        ControlToValidate="txtEmail" 
                        ErrorMessage="Email is required" 
                        CssClass="validation-error"
                        Display="Dynamic">
                    </asp:RequiredFieldValidator>
                    <asp:RegularExpressionValidator ID="revEmail" runat="server" 
                        ControlToValidate="txtEmail" 
                        ErrorMessage="Invalid email format" 
                        CssClass="validation-error"
                        ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
                        Display="Dynamic">
                    </asp:RegularExpressionValidator>
                </div>

                <!-- Password -->
                <div class="form-group">
                    <label for="txtPassword">Password</label>
                    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control" placeholder="Create a password"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rfvPassword" runat="server" 
                        ControlToValidate="txtPassword" 
                        ErrorMessage="Password is required" 
                        CssClass="validation-error"
                        Display="Dynamic">
                    </asp:RequiredFieldValidator>
                </div>

                <!-- Confirm Password -->
                <div class="form-group">
                    <label for="txtConfirmPassword">Confirm Password</label>
                    <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" CssClass="form-control" placeholder="Confirm your password"></asp:TextBox>
                    <asp:CompareValidator ID="cvPassword" runat="server" 
                        ControlToValidate="txtConfirmPassword" 
                        ControlToCompare="txtPassword"
                        ErrorMessage="Passwords do not match" 
                        CssClass="validation-error"
                        Display="Dynamic">
                    </asp:CompareValidator>
                </div>

                <!-- Full Name -->
                <div class="form-group">
                    <label for="txtFullName">Full Name</label>
                    <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" placeholder="Enter your full name"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rfvFullName" runat="server" 
                        ControlToValidate="txtFullName" 
                        ErrorMessage="Full name is required" 
                        CssClass="validation-error"
                        Display="Dynamic">
                    </asp:RequiredFieldValidator>
                </div>

                <!-- Register Button -->
                <asp:Button ID="btnRegister" runat="server" Text="Create Account" OnClick="btnRegister_Click" CssClass="btn-register" />

                <!-- Divider -->
                <div class="divider">
                    <span>OR</span>
                </div>

                <!-- Login Link -->
                <div class="login-link">
                    <p>Already have an account? <asp:HyperLink ID="hlLogin" runat="server" NavigateUrl="~/Login.aspx">Login here</asp:HyperLink></p>
                </div>
            </div>
        </div>
    </form>
</body>
</html>