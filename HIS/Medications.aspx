<%@ Page Title="Quản Lý Kho Thuốc" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Medications.aspx.cs" Inherits="HIS.Medications" %>

<%@ Register Assembly="DevExpress.Web.v21.2, Version=21.2.6.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %><asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style type="text/css">
        body, .app-content {
            background-color: var(--white) !important;
        }
        .app-content {
            padding-top: 0 !important;
            padding-bottom: 0 !important;
        }
        .card-premium {
            border: none !important;
            box-shadow: none !important;
            border-radius: 0 !important;
        }
        .card-premium-header {
            border-bottom: none !important;
            padding-left: 0 !important;
            padding-right: 0 !important;
        }
        .card-premium-body {
            padding-left: 0 !important;
            padding-right: 0 !important;
        }
        .med-layout-container {
            display: flex;
            gap: 24px;
            align-items: stretch;
            min-height: calc(100vh - 70px);
        }
        .med-main-content {
            flex: 1;
            min-width: 0;
            padding-top: 32px;
            padding-bottom: 32px;
        }
        .med-sidebar-content {
            width: 380px;
            flex-shrink: 0;
            border-left: 1px solid var(--border);
            padding-left: 24px;
            padding-top: 32px;
            padding-bottom: 32px;
        }
        .med-sticky-form {
            position: sticky;
            top: 102px;
        }
        @media (max-width: 1100px) {
            .med-layout-container {
                flex-direction: column-reverse;
                gap: 30px;
                min-height: auto;
            }
            .med-main-content {
                padding-top: 0;
            }
            .med-sidebar-content {
                width: 100%;
                border-left: none !important;
                padding-left: 0 !important;
                padding-top: 32px;
                padding-bottom: 0;
            }
            .med-sticky-form {
                position: static;
            }
        }
    </style>
    <asp:UpdatePanel ID="upMedications" runat="server">
        <ContentTemplate>
            <div class="med-layout-container">
                <!-- KHU VỰC DANH SÁCH THUỐC HIỆN CÓ (ĐẶT BÊN TRÁI, PHÌNH TO) -->
                <div class="med-main-content">
                    <div class="card-premium">
                        <div class="card-premium-header">
                            <div class="card-premium-title">
                                <i class="fa-solid fa-table-list text-primary" style="color: var(--primary);"></i>
                                <span>Danh Mục Thuốc Hiện Có</span>
                            </div>
                        </div>
                        <div class="card-premium-body" style="padding: 20px;">
                            <!-- Search Box -->
                            <div class="search-cluster">
                                <dx:ASPxTextBox ID="txtSearch" runat="server" Width="100%" Height="38px" NullText="Tìm theo tên thuốc..." Style="max-width: 360px !important;" />
                                <asp:Button ID="btnSearch" runat="server" Text="Tìm kiếm" CssClass="btn-premium btn-premium-secondary" OnClick="btnSearch_Click" />
                            </div>

                            <!-- GridView list -->
                            <dx:ASPxGridView ID="gvMedications" KeyFieldName="MedicationId" runat="server" AutoGenerateColumns="False" Width="100%" OnRowCommand="gvMedications_RowCommand" Settings-ShowBorder="False" OnDataBinding="gvMedications_DataBinding">
                                <SettingsPopup>
                                    <FilterControl AutoUpdatePosition="False"></FilterControl>
                                </SettingsPopup>
                                <Columns>
                                    <dx:GridViewDataTextColumn Caption="Mã Thuốc" FieldName="MedicationId" ShowInCustomizationForm="True" VisibleIndex="0" Width="90px">
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataTextColumn Caption="Tên Thuốc" FieldName="MedicationName" ShowInCustomizationForm="True" VisibleIndex="1">
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataTextColumn Caption="ĐVT" FieldName="Unit" ShowInCustomizationForm="True" VisibleIndex="2" Width="70px">
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataTextColumn Caption="Đơn Giá" FieldName="Price" ShowInCustomizationForm="True" VisibleIndex="3" Width="110px">
                                        <PropertiesTextEdit DisplayFormatString="{0:N0} đ">
                                        </PropertiesTextEdit>
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataTextColumn Caption="Tồn Kho" FieldName="StockQuantity" ShowInCustomizationForm="True" VisibleIndex="4" Width="90px">
                                    </dx:GridViewDataTextColumn>
                                    <dx:GridViewDataColumn Caption="Thao Tác" VisibleIndex="5" Width="120px">
                                        <DataItemTemplate>
                                            <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditMed" CommandArgument='<%# Eval("MedicationId") %>' Text="Sửa" Style="margin-right: 10px; color: var(--primary); font-weight: 600; text-decoration: none;" />
                                            <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteMed" CommandArgument='<%# Eval("MedicationId") %>' Text="Xóa" OnClientClick="return confirm('Ngài có chắc chắn muốn xóa thuốc này không?');" Style="color: var(--danger); font-weight: 600; text-decoration: none;" />
                                        </DataItemTemplate>
                                    </dx:GridViewDataColumn>
                                </Columns>
                            </dx:ASPxGridView>
                        </div>
                    </div>
                </div>

                <!-- KHU VỰC FORM THÊM / SỬA THUỐC (ĐẶT BÊN PHẢI NHƯ SIDEBAR) -->
                <div class="med-sidebar-content">
                    <div class="card-premium med-sticky-form">
                        <div class="card-premium-header">
                            <div class="card-premium-title">
                                <i class="fa-solid fa-prescription-bottle-medical text-primary" style="color: var(--primary);"></i>
                                <dx:ASPxLabel ID="lblFormTitle" runat="server" Text="Thêm Thuốc Mới Vào Danh Mục" Font-Bold="True" ForeColor="#0f172a" />
                            </div>
                        </div>
                        <div class="card-premium-body" style="padding: 20px;">
                            <asp:HiddenField ID="hfMedicationId" runat="server" Value="" />
                            
                            <dx:ASPxFormLayout ID="flMedication" runat="server" Width="100%" UseDefaultPaddings="false">
                                <SettingsItemCaptions Location="Top" />
                                <Items>
                                    <dx:LayoutItem Caption="Tên Thuốc" RequiredMarkDisplayMode="Required">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txtMedicationName" runat="server" Width="100%" Height="38px" NullText="Paracetamol 500mg">
                                                    <ValidationSettings ValidationGroup="vgMedication" Display="Dynamic" ErrorDisplayMode="Text" ErrorTextPosition="Bottom">
                                                        <RequiredField IsRequired="True" ErrorText="Vui lòng nhập tên thuốc!" />
                                                    </ValidationSettings>
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    
                                    <dx:LayoutItem Caption="Đơn Vị Tính" RequiredMarkDisplayMode="Required">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxTextBox ID="txtUnit" runat="server" Width="100%" Height="38px" NullText="Viên, Chai, Ống">
                                                    <ValidationSettings ValidationGroup="vgMedication" Display="Dynamic" ErrorDisplayMode="Text" ErrorTextPosition="Bottom">
                                                        <RequiredField IsRequired="True" ErrorText="Vui lòng nhập đơn vị!" />
                                                    </ValidationSettings>
                                                </dx:ASPxTextBox>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                    
                                    <dx:LayoutItem Caption="Đơn Giá (VNĐ)" RequiredMarkDisplayMode="Required">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxSpinEdit ID="txtPrice" runat="server" Width="100%" Height="38px" NullText="1500" MinValue="0" MaxValue="99999999" NumberType="Integer" AllowMouseWheel="false">
                                                    <ValidationSettings ValidationGroup="vgMedication" Display="Dynamic" ErrorDisplayMode="Text" ErrorTextPosition="Bottom">
                                                        <RequiredField IsRequired="True" ErrorText="Vui lòng nhập giá!" />
                                                    </ValidationSettings>
                                                </dx:ASPxSpinEdit>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>

                                    <dx:LayoutItem Caption="Số Lượng Tồn Kho" RequiredMarkDisplayMode="Required">
                                        <LayoutItemNestedControlCollection>
                                            <dx:LayoutItemNestedControlContainer runat="server">
                                                <dx:ASPxSpinEdit ID="txtStockQuantity" runat="server" Width="100%" Height="38px" NullText="1000" MinValue="0" MaxValue="999999" NumberType="Integer" AllowMouseWheel="false">
                                                    <ValidationSettings ValidationGroup="vgMedication" Display="Dynamic" ErrorDisplayMode="Text" ErrorTextPosition="Bottom">
                                                        <RequiredField IsRequired="True" ErrorText="Vui lòng nhập số lượng tồn kho!" />
                                                    </ValidationSettings>
                                                </dx:ASPxSpinEdit>
                                            </dx:LayoutItemNestedControlContainer>
                                        </LayoutItemNestedControlCollection>
                                    </dx:LayoutItem>
                                </Items>
                            </dx:ASPxFormLayout>

                            <div style="text-align: right; margin-top: 25px; display: flex; gap: 10px; justify-content: flex-end;">
                                <asp:Button ID="btnCancel" runat="server" Text="Hủy Bỏ" CssClass="btn-premium btn-premium-secondary" OnClick="btnCancel_Click" Visible="false" />
                                <asp:Button ID="btnSave" runat="server" Text="Lưu Thông Tin" CssClass="btn-premium btn-premium-primary" ValidationGroup="vgMedication" OnClick="btnSave_Click" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
