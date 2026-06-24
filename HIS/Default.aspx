<%@ Page Title="Quản Lý Bệnh Nhân" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="HIS._Default" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Quick Statistics Metrics -->
    <div class="metrics-grid">
        <div class="metric-card">
            <div>
                <div class="metric-label">Tiếp Nhận Hôm Nay</div>
                <div class="metric-value">
                    <asp:Literal ID="litTotalPatients" runat="server">0</asp:Literal>
                </div>
            </div>
            <div class="metric-icon-box metric-primary">
                <i class="fa-solid fa-users"></i>
            </div>
        </div>
        <div class="metric-card">
            <div>
                <div class="metric-label">Đã Khám Hôm Nay</div>
                <div class="metric-value">
                    <asp:Literal ID="litExamsToday" runat="server">0</asp:Literal>
                </div>
            </div>
            <div class="metric-icon-box metric-success">
                <i class="fa-solid fa-calendar-check"></i>
            </div>
        </div>
        <div class="metric-card">
            <div>
                <div class="metric-label">Bệnh Nhân Chờ Khám</div>
                <div class="metric-value">
                    <asp:Literal ID="litOngoingExams" runat="server">0</asp:Literal>
                </div>
            </div>
            <div class="metric-icon-box metric-warning">
                <i class="fa-solid fa-stethoscope"></i>
            </div>
        </div>
        <div class="metric-card">
            <div>
                <div class="metric-label">Doanh Thu Hôm Nay</div>
                <div class="metric-value">
                    <asp:Literal ID="litTotalRevenue" runat="server">0đ</asp:Literal>
                </div>
            </div>
            <div class="metric-icon-box metric-danger">
                <i class="fa-solid fa-hand-holding-dollar"></i>
            </div>
        </div>
    </div>

    <!-- Main Content Split columns -->
    <div class="split-layout">
        
        <!-- Left Column: Patient Registration -->
        <div class="card-premium">
            <div class="card-premium-header">
                <div class="card-premium-title">
                    <i class="fa-solid fa-user-plus text-primary" style="color: var(--primary);"></i>
                    <span>Đăng Ký Khám & Tiếp Đón</span>
                </div>
            </div>
            <div class="card-premium-body">
                <asp:Panel ID="pnlRegister" runat="server" DefaultButton="btnRegister">
                    
                    <div class="form-group">
                        <label class="form-label" for="txtFullName">Họ và Tên Bệnh Nhân <span style="color:var(--danger)">*</span></label>
                        <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control-premium" placeholder="Nhập họ và tên đầy đủ"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvFullName" runat="server" ControlToValidate="txtFullName" 
                            ErrorMessage="Vui lòng nhập họ tên!" ForeColor="Red" Display="Dynamic" ValidationGroup="vgRegister" style="font-size: 12px; margin-top: 4px; display: block;"></asp:RequiredFieldValidator>
                    </div>

                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label" for="txtBirthDate">Ngày Sinh <span style="color:var(--danger)">*</span></label>
                            <asp:TextBox ID="txtBirthDate" runat="server" CssClass="form-control-premium" TextMode="Date"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvBirthDate" runat="server" ControlToValidate="txtBirthDate" 
                                ErrorMessage="Vui lòng chọn ngày sinh!" ForeColor="Red" Display="Dynamic" ValidationGroup="vgRegister" style="font-size: 12px; margin-top: 4px; display: block;"></asp:RequiredFieldValidator>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Giới Tính <span style="color:var(--danger)">*</span></label>
                            <asp:RadioButtonList ID="rblGender" runat="server" RepeatDirection="Horizontal" CssClass="radio-list-premium">
                                <asp:ListItem Selected="True" Value="Nam">Nam</asp:ListItem>
                                <asp:ListItem Value="Nữ">Nữ</asp:ListItem>
                            </asp:RadioButtonList>
                        </div>
                    </div>

                    <div class="form-grid">
                        <div class="form-group">
                            <label class="form-label" for="txtInsuranceCard">Thẻ BHYT (Nếu có)</label>
                            <asp:TextBox ID="txtInsuranceCard" runat="server" CssClass="form-control-premium" placeholder="Ví dụ: GD479088012345"></asp:TextBox>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="ddlDoctors">Bác Sĩ Chỉ Định Khám <span style="color:var(--danger)">*</span></label>
                            <asp:DropDownList ID="ddlDoctors" runat="server" CssClass="form-control-premium"></asp:DropDownList>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="txtAddress">Địa Chỉ</label>
                        <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control-premium" TextMode="MultiLine" Rows="2" placeholder="Số nhà, tên đường, khu vực..." OnTextChanged="txtAddress_TextChanged"></asp:TextBox>
                    </div>

                    <div style="text-align: right; margin-top: 15px;">
                        <asp:Button ID="btnRegister" runat="server" Text="Đăng Ký & Phân Phòng" CssClass="btn-premium btn-premium-primary" 
                            ValidationGroup="vgRegister" OnClick="btnRegister_Click" />
                    </div>
                </asp:Panel>
            </div>
        </div>

        <!-- Right Column: Patients list -->
        <div class="card-premium">
            <div class="card-premium-header">
                <div class="card-premium-title">
                    <i class="fa-solid fa-rectangle-list text-primary" style="color: var(--primary);"></i>
                    <span>Danh Sách Tiếp Nhận Trong Ngày</span>
                </div>
            </div>
            <div class="card-premium-body">
                <!-- Search cluster -->
                <div class="search-cluster">
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control-premium" placeholder="Tìm theo Mã BN, Tên hoặc BHYT..."></asp:TextBox>
                    <asp:Button ID="btnSearch" runat="server" Text="Tìm kiếm" CssClass="btn-premium btn-premium-secondary" OnClick="btnSearch_Click" />
                </div>

                <asp:GridView ID="gvPatients" runat="server" AutoGenerateColumns="False" 
                    GridLines="None" CssClass="table-premium" DataKeyNames="VisitId">
                    <Columns>
                        <asp:BoundField DataField="PatientId" HeaderText="Mã BN">
                            <HeaderStyle Width="80px" />
                        </asp:BoundField>
                        <asp:BoundField DataField="FullName" HeaderText="Họ và Tên">
                            <HeaderStyle Width="140px" />
                        </asp:BoundField>
                        <asp:TemplateField HeaderText="Ngày Sinh">
                            <ItemTemplate>
                                <%# Convert.ToDateTime(Eval("BirthDate")).ToString("dd/MM/yyyy") %>
                            </ItemTemplate>
                            <HeaderStyle Width="95px" />
                        </asp:TemplateField>
                        <asp:BoundField DataField="Gender" HeaderText="Phái">
                            <HeaderStyle Width="50px" />
                        </asp:BoundField>
                        <asp:BoundField DataField="DoctorName" HeaderText="Bác Sĩ Khám" />
                        <asp:TemplateField HeaderText="Trạng Thái">
                            <ItemTemplate>
                                <asp:PlaceHolder runat="server" Visible='<%# Eval("Status").ToString() == "Chờ khám" %>'>
                                    <span class="badge-premium badge-warning">Chờ khám</span>
                                </asp:PlaceHolder>
                                <asp:PlaceHolder runat="server" Visible='<%# Eval("Status").ToString() == "Đã khám" %>'>
                                    <span class="badge-premium badge-success">Đã khám</span>
                                </asp:PlaceHolder>
                                <asp:PlaceHolder runat="server" Visible='<%# Eval("Status").ToString() == "Đã thanh toán" %>'>
                                    <span class="badge-premium badge-info">Đã thanh toán</span>
                                </asp:PlaceHolder>
                            </ItemTemplate>
                            <HeaderStyle Width="90px" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Thao Tác">
                            <ItemTemplate>
                                <asp:PlaceHolder runat="server" Visible='<%# Eval("Status").ToString() == "Chờ khám" %>'>
                                    <a href='Examination?VisitID=<%# Eval("VisitId") %>' class="btn-premium btn-premium-primary btn-premium-sm">
                                        <i class="fa-solid fa-stethoscope"></i> Khám
                                    </a>
                                </asp:PlaceHolder>
                                <asp:PlaceHolder runat="server" Visible='<%# Eval("Status").ToString() == "Đã khám" %>'>
                                    <a href='Billing?VisitID=<%# Eval("VisitId") %>' class="btn-premium btn-premium-secondary btn-premium-sm" style="color:var(--warning); border-color:var(--warning);">
                                        <i class="fa-solid fa-file-invoice-dollar"></i> Viện phí
                                    </a>
                                </asp:PlaceHolder>
                                <asp:PlaceHolder runat="server" Visible='<%# Eval("Status").ToString() == "Đã thanh toán" %>'>
                                    <span style="color: var(--text-muted); font-size: 12px; font-style: italic;">
                                        <i class="fa-solid fa-check-double" style="color:var(--success)"></i> Hoàn thành
                                    </span>
                                </asp:PlaceHolder>
                            </ItemTemplate>
                            <HeaderStyle Width="110px" />
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div style="text-align: center; padding: 40px 20px; color: var(--text-muted);">
                            <i class="fa-regular fa-folder-open" style="font-size: 36px; margin-bottom: 12px; display: block; color: var(--primary);"></i>
                            Không tìm thấy hồ sơ tiếp nhận nào trong ngày hôm nay.
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>

    </div>
</asp:Content>
