<%@ Page Title="Thanh Toán & Hóa Đơn" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Billing.aspx.cs" Inherits="HIS.Billing" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    
    <style type="text/css">
        /* CSS print invoice layout */
        @media print {
            body * {
                visibility: hidden;
            }
            #invoice-print-area, #invoice-print-area * {
                visibility: visible;
            }
            #invoice-print-area {
                position: absolute;
                left: 0;
                top: 0;
                width: 100%;
                background: white;
                color: black;
                padding: 20px;
                box-shadow: none;
                border: none;
            }
            .app-sidebar, .app-header, .app-content > *:not(#invoice-print-area), .btn-premium, .card-premium-header {
                display: none !important;
            }
            .app-wrapper {
                margin-left: 0 !important;
                width: 100% !important;
            }
        }

        .invoice-paper {
            background-color: var(--white);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 30px;
            box-shadow: var(--shadow-sm);
            font-family: 'Inter', sans-serif;
            color: #334155;
            position: relative;
        }

        .invoice-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            border-bottom: 2px solid var(--primary-bg);
            padding-bottom: 20px;
            margin-bottom: 20px;
        }

        .invoice-title {
            color: var(--primary);
            font-size: 24px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .invoice-meta {
            text-align: right;
            font-size: 13px;
            color: var(--text-muted);
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .invoice-section-title {
            font-size: 13px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: var(--primary);
            margin-bottom: 12px;
            border-left: 3px solid var(--primary);
            padding-left: 8px;
        }

        .invoice-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
            margin-bottom: 24px;
            background-color: var(--light-bg);
            padding: 15px;
            border-radius: 8px;
            font-size: 13.5px;
        }

        .invoice-grid-item {
            display: flex;
            gap: 8px;
        }

        .invoice-grid-label {
            font-weight: 600;
            color: var(--text-muted);
            min-width: 110px;
        }

        .invoice-total-section {
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            margin-top: 24px;
            padding-top: 16px;
            border-top: 2px solid var(--border);
            gap: 8px;
        }

        .invoice-total-row {
            display: flex;
            justify-content: flex-end;
            width: 100%;
            max-width: 300px;
            font-size: 14px;
        }

        .invoice-total-value {
            font-weight: 700;
            font-size: 20px;
            color: var(--primary-dark);
            text-align: right;
            flex-grow: 1;
        }
    </style>

    <div class="split-layout">
        
        <!-- Left Column: Unpaid Visits List -->
        <div class="card-premium">
            <div class="card-premium-header">
                <div class="card-premium-title">
                    <i class="fa-solid fa-clock text-primary" style="color: var(--primary);"></i>
                    <span>Bệnh Nhân Chờ Thu Phí</span>
                </div>
            </div>
            <div class="card-premium-body">
                <asp:GridView ID="gvUnpaidVisits" runat="server" AutoGenerateColumns="False" 
                    GridLines="None" CssClass="table-premium" DataKeyNames="VisitId"
                    OnSelectedIndexChanged="gvUnpaidVisits_SelectedIndexChanged">
                    <Columns>
                        <asp:BoundField DataField="PatientId" HeaderText="Mã BN">
                            <HeaderStyle Width="80px" />
                        </asp:BoundField>
                        <asp:BoundField DataField="FullName" HeaderText="Họ và Tên" />
                        <asp:BoundField DataField="DoctorName" HeaderText="Bác Sĩ Khám" />
                        <asp:CommandField ShowSelectButton="True" SelectText="<i class='fa-solid fa-chevron-right'></i> Chọn" 
                            ButtonType="Link" ControlStyle-CssClass="btn-premium btn-premium-primary btn-premium-sm" HeaderStyle-Width="90px">
                            <ControlStyle CssClass="btn-premium btn-premium-primary btn-premium-sm" style="font-size:11px; padding: 4px 10px; text-decoration:none; display:inline-flex; align-items:center; gap:4px;" />
                        </asp:CommandField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div style="text-align: center; padding: 40px 20px; color: var(--text-muted);">
                            <i class="fa-solid fa-square-check" style="font-size: 36px; margin-bottom: 12px; display: block; color: var(--success);"></i>
                            Hiện tại không có bệnh nhân nào chờ thanh toán viện phí.
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>

        <!-- Right Column: Billing & Payment detail / Invoice template -->
        <div>
            <!-- Case 1: No patient selected -->
            <asp:Panel ID="pnlNoBilling" runat="server" CssClass="card-premium" Visible="true">
                <div class="card-premium-body" style="text-align: center; padding: 80px 20px; color: var(--text-muted);">
                    <i class="fa-solid fa-file-invoice-dollar text-primary" style="font-size: 48px; color: var(--primary); margin-bottom: 16px;"></i>
                    <h3 style="font-weight: 700; color: var(--dark-sidebar); margin-bottom: 8px;">Chi Tiết Hóa Đơn Thu Viện Phí</h3>
                    <p style="max-width: 320px; margin: 0 auto;">Vui lòng chọn một bệnh nhân từ danh sách chờ thanh toán bên trái để hiển thị hóa đơn.</p>
                </div>
            </asp:Panel>

            <!-- Case 2: Selected patient billing details -->
            <asp:Panel ID="pnlBillingDetail" runat="server" Visible="false">
                <div id="invoice-print-area" class="invoice-paper">
                    
                    <!-- Print Header -->
                    <div class="invoice-header">
                        <div>
                            <div class="invoice-title">Hóa Đơn Thuốc Phòng Khám</div>
                            <div style="font-size:12px; color:var(--text-muted); margin-top:4px;">Hệ Thống Quản Lý Phòng Khám HIS Clinic</div>
                        </div>
                        <div class="invoice-meta">
                            <span><strong>Hóa đơn:</strong> HD-<%: Request.QueryString["VisitID"] ?? "0" %></span>
                            <span><strong>Ngày:</strong> <%: DateTime.Now.ToString("dd/MM/yyyy HH:mm") %></span>
                        </div>
                    </div>

                    <!-- Administrative Patient info -->
                    <div class="invoice-section-title">Thông Tin Bệnh Nhân</div>
                    <div class="invoice-grid">
                        <div class="invoice-grid-item">
                            <span class="invoice-grid-label">Mã bệnh nhân:</span>
                            <span><asp:Literal ID="litPatientCode" runat="server"></asp:Literal></span>
                        </div>
                        <div class="invoice-grid-item">
                            <span class="invoice-grid-label">Họ và Tên:</span>
                            <span style="font-weight:700;"><asp:Literal ID="litPatientName" runat="server"></asp:Literal></span>
                        </div>
                        <div class="invoice-grid-item">
                            <span class="invoice-grid-label">Ngày sinh:</span>
                            <span><asp:Literal ID="litPatientDOB" runat="server"></asp:Literal></span>
                        </div>
                        <div class="invoice-grid-item">
                            <span class="invoice-grid-label">Thẻ BHYT:</span>
                            <span><asp:Literal ID="litPatientInsurance" runat="server"></asp:Literal></span>
                        </div>
                        <div class="invoice-grid-item" style="grid-column: span 2;">
                            <span class="invoice-grid-label">Địa chỉ:</span>
                            <span><asp:Literal ID="litPatientAddress" runat="server"></asp:Literal></span>
                        </div>
                    </div>

                    <!-- Clinical Examination details -->
                    <div class="invoice-section-title">Nội Dung Khám Lâm Sàng</div>
                    <div class="invoice-grid">
                        <div class="invoice-grid-item">
                            <span class="invoice-grid-label">Bác sĩ khám:</span>
                            <span><asp:Literal ID="litDoctorName" runat="server"></asp:Literal></span>
                        </div>
                        <div class="invoice-grid-item">
                            <span class="invoice-grid-label">Phòng khám:</span>
                            <span><asp:Literal ID="litRoomNo" runat="server"></asp:Literal></span>
                        </div>
                        <div class="invoice-grid-item" style="grid-column: span 2;">
                            <span class="invoice-grid-label">Chẩn đoán:</span>
                            <span style="font-weight:600;"><asp:Literal ID="litDiagnosis" runat="server"></asp:Literal></span>
                        </div>
                        <div class="invoice-grid-item" style="grid-column: span 2;">
                            <span class="invoice-grid-label">Triệu chứng:</span>
                            <span><asp:Literal ID="litSymptoms" runat="server"></asp:Literal></span>
                        </div>
                    </div>

                    <!-- Prescribed medications details -->
                    <div class="invoice-section-title">Danh Mục Thuốc Kê Toa</div>
                    <asp:GridView ID="gvPrescribedDrugs" runat="server" AutoGenerateColumns="False" 
                        GridLines="None" CssClass="table-premium">
                        <Columns>
                            <asp:TemplateField HeaderText="STT">
                                <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                                <HeaderStyle Width="50px" />
                            </asp:TemplateField>
                            <asp:BoundField DataField="DrugName" HeaderText="Tên Thuốc" />
                            <asp:BoundField DataField="Quantity" HeaderText="SL" HeaderStyle-Width="50px" />
                            <asp:BoundField DataField="Unit" HeaderText="ĐVT" HeaderStyle-Width="55px" />
                            <asp:TemplateField HeaderText="Đơn Giá">
                                <ItemTemplate><%# Convert.ToDecimal(Eval("Price")).ToString("N0") %> đ</ItemTemplate>
                                <HeaderStyle Width="95px" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Thành Tiền">
                                <ItemTemplate><strong><%# Convert.ToDecimal(Eval("SubTotal")).ToString("N0") %> đ</strong></ItemTemplate>
                                <HeaderStyle Width="110px" />
                            </asp:TemplateField>
                            <asp:BoundField DataField="Dosage" HeaderText="Liều Dùng" HeaderStyle-Width="180px" />
                        </Columns>
                    </asp:GridView>

                    <!-- Total payment calculation -->
                    <div class="invoice-total-section">
                        <div class="invoice-total-row">
                            <span style="font-weight:600; color:var(--text-muted);">Tổng Cộng Tiền Thuốc:</span>
                            <span class="invoice-total-value">
                                <asp:Literal ID="litTotalAmount" runat="server">0đ</asp:Literal>
                            </span>
                        </div>
                    </div>
                </div>

                <!-- Page Actions (Hidden in Print Mode) -->
                <div style="text-align: right; margin-top: 24px; display: flex; gap: 12px; justify-content: flex-end;">
                    <button type="button" class="btn-premium btn-premium-secondary" onclick="window.print();">
                        <i class="fa-solid fa-print"></i> In Hóa Đơn (Ctrl+P)
                    </button>
                    <asp:Button ID="btnConfirmPayment" runat="server" Text="Xác Nhận Thanh Toán & Phát Thuốc" 
                        CssClass="btn-premium btn-premium-primary" OnClick="btnConfirmPayment_Click" />
                </div>
            </asp:Panel>
        </div>

    </div>
</asp:Content>
