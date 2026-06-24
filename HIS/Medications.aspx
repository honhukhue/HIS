<%@ Page Title="Quản Lý Kho Thuốc" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Medications.aspx.cs" Inherits="HIS.Medications" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="split-layout">
        
        <!-- Left Column: Add / Edit Medication Form -->
        <div class="card-premium">
            <div class="card-premium-header">
                <div class="card-premium-title">
                    <i class="fa-solid fa-prescription-bottle-medical text-primary" style="color: var(--primary);"></i>
                    <asp:Label ID="lblFormTitle" runat="server" Text="Thêm Thuốc Mới Vào Danh Mục"></asp:Label>
                </div>
            </div>
            <div class="card-premium-body">
                <asp:HiddenField ID="hfMedicationId" runat="server" Value="" />
                
                <div class="form-group">
                    <label class="form-label" for="txtMedicationName">Tên Thuốc <span style="color:var(--danger)">*</span></label>
                    <asp:TextBox ID="txtMedicationName" runat="server" CssClass="form-control-premium" placeholder="Ví dụ: Paracetamol 500mg"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rfvMedicationName" runat="server" ControlToValidate="txtMedicationName" 
                        ErrorMessage="Vui lòng nhập tên thuốc!" ForeColor="Red" Display="Dynamic" ValidationGroup="vgMedication" style="font-size: 12px; margin-top: 4px; display: block;"></asp:RequiredFieldValidator>
                </div>

                <div class="form-grid">
                    <div class="form-group">
                        <label class="form-label" for="txtUnit">Đơn Vị Tính <span style="color:var(--danger)">*</span></label>
                        <asp:TextBox ID="txtUnit" runat="server" CssClass="form-control-premium" placeholder="Ví dụ: Viên, Chai, Ống"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvUnit" runat="server" ControlToValidate="txtUnit" 
                            ErrorMessage="Vui lòng nhập đơn vị!" ForeColor="Red" Display="Dynamic" ValidationGroup="vgMedication" style="font-size: 12px; margin-top: 4px; display: block;"></asp:RequiredFieldValidator>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="txtPrice">Đơn Giá (VNĐ) <span style="color:var(--danger)">*</span></label>
                        <asp:TextBox ID="txtPrice" runat="server" CssClass="form-control-premium" TextMode="Number" placeholder="Ví dụ: 1500"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvPrice" runat="server" ControlToValidate="txtPrice" 
                            ErrorMessage="Vui lòng nhập giá!" ForeColor="Red" Display="Dynamic" ValidationGroup="vgMedication" style="font-size: 12px; margin-top: 4px; display: block;"></asp:RequiredFieldValidator>
                        <asp:RangeValidator ID="rvPrice" runat="server" ControlToValidate="txtPrice" MinimumValue="0" MaximumValue="99999999" Type="Double"
                            ErrorMessage="Giá phải lớn hơn hoặc bằng 0!" ForeColor="Red" Display="Dynamic" ValidationGroup="vgMedication" style="font-size: 12px; margin-top: 4px; display: block;"></asp:RangeValidator>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label" for="txtStockQuantity">Số Lượng Tồn Kho <span style="color:var(--danger)">*</span></label>
                    <asp:TextBox ID="txtStockQuantity" runat="server" CssClass="form-control-premium" TextMode="Number" placeholder="Ví dụ: 1000"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rfvStockQuantity" runat="server" ControlToValidate="txtStockQuantity" 
                        ErrorMessage="Vui lòng nhập số lượng tồn kho!" ForeColor="Red" Display="Dynamic" ValidationGroup="vgMedication" style="font-size: 12px; margin-top: 4px; display: block;"></asp:RequiredFieldValidator>
                    <asp:RangeValidator ID="rvStockQuantity" runat="server" ControlToValidate="txtStockQuantity" MinimumValue="0" MaximumValue="999999" Type="Integer"
                        ErrorMessage="Số lượng tồn kho phải là số nguyên >= 0!" ForeColor="Red" Display="Dynamic" ValidationGroup="vgMedication" style="font-size: 12px; margin-top: 4px; display: block;"></asp:RangeValidator>
                </div>

                <div style="text-align: right; margin-top: 25px; display: flex; gap: 10px; justify-content: flex-end;">
                    <asp:Button ID="btnCancel" runat="server" Text="Hủy Bỏ" CssClass="btn-premium btn-premium-secondary" OnClick="btnCancel_Click" Visible="false" />
                    <asp:Button ID="btnSave" runat="server" Text="Lưu Thông Tin" CssClass="btn-premium btn-premium-primary" 
                        ValidationGroup="vgMedication" OnClick="btnSave_Click" />
                </div>
            </div>
        </div>

        <!-- Right Column: Medication Catalog List -->
        <div class="card-premium">
            <div class="card-premium-header">
                <div class="card-premium-title">
                    <i class="fa-solid fa-table-list text-primary" style="color: var(--primary);"></i>
                    <span>Danh Mục Thuốc Hiện Có</span>
                </div>
            </div>
            <div class="card-premium-body">
                <!-- Search Box -->
                <div class="search-cluster">
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control-premium" placeholder="Tìm theo tên thuốc..."></asp:TextBox>
                    <asp:Button ID="btnSearch" runat="server" Text="Tìm kiếm" CssClass="btn-premium btn-premium-secondary" OnClick="btnSearch_Click" />
                </div>

                <!-- GridView list -->
                <asp:GridView ID="gvMedications" runat="server" AutoGenerateColumns="False" 
                    GridLines="None" CssClass="table-premium" DataKeyNames="MedicationId"
                    OnRowCommand="gvMedications_RowCommand">
                    <Columns>
                        <asp:BoundField DataField="MedicationId" HeaderText="Mã Thuốc">
                            <HeaderStyle Width="90px" />
                        </asp:BoundField>
                        <asp:BoundField DataField="MedicationName" HeaderText="Tên Thuốc" />
                        <asp:BoundField DataField="Unit" HeaderText="ĐVT">
                            <HeaderStyle Width="70px" />
                        </asp:BoundField>
                        <asp:TemplateField HeaderText="Đơn Giá">
                            <ItemTemplate>
                                <%# Convert.ToDecimal(Eval("Price")).ToString("N0") %> đ
                            </ItemTemplate>
                            <HeaderStyle Width="110px" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Tồn Kho">
                            <ItemTemplate>
                                <asp:PlaceHolder runat="server" Visible='<%# Convert.ToInt32(Eval("StockQuantity")) < 50 %>'>
                                    <span style="color: var(--danger); font-weight: 700;">
                                        <i class="fa-solid fa-triangle-exclamation"></i> <%# Eval("StockQuantity") %> (Sắp hết!)
                                    </span>
                                </asp:PlaceHolder>
                                <asp:PlaceHolder runat="server" Visible='<%# Convert.ToInt32(Eval("StockQuantity")) >= 50 %>'>
                                    <span><%# Eval("StockQuantity") %></span>
                                </asp:PlaceHolder>
                            </ItemTemplate>
                            <HeaderStyle Width="115px" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Thao Tác">
                            <ItemTemplate>
                                <asp:LinkButton ID="lnkEdit" runat="server" CommandName="EditMed" CommandArgument='<%# Eval("MedicationId") %>' 
                                    CssClass="text-primary" style="margin-right: 12px; font-weight:600; text-decoration:none;">
                                    <i class="fa-regular fa-pen-to-square"></i> Sửa
                                </asp:LinkButton>
                                <asp:LinkButton ID="lnkDelete" runat="server" CommandName="DeleteMed" CommandArgument='<%# Eval("MedicationId") %>' 
                                    OnClientClick="return confirm('Bạn có chắc chắn muốn xóa thuốc này khỏi danh mục?');"
                                    CssClass="text-danger" style="font-weight:600; text-decoration:none; color:var(--danger)">
                                    <i class="fa-regular fa-trash-can"></i> Xóa
                                </asp:LinkButton>
                            </ItemTemplate>
                            <HeaderStyle Width="140px" />
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div style="text-align: center; padding: 40px 20px; color: var(--text-muted);">
                            <i class="fa-solid fa-box-open" style="font-size: 36px; margin-bottom: 12px; display: block; color: var(--primary);"></i>
                            Không có thuốc nào trong danh mục.
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>

    </div>
</asp:Content>
