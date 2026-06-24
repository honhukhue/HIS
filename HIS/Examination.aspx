<%@ Page Title="Phòng Khám & Kê Đơn" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Examination.aspx.cs" Inherits="HIS.Examination" %>
<%@ Register Assembly="DevExpress.Web.v21.2, Version=21.2.6.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    
    <!-- Case 1: No patient selected -->
    <asp:Panel ID="pnlNoPatient" runat="server" CssClass="card-premium" Visible="true">
        <div class="card-premium-body" style="text-align: center; padding: 60px 20px;">
            <i class="fa-solid fa-user-injured text-primary" style="font-size: 48px; color: var(--primary); margin-bottom: 16px;"></i>
            <h3 style="font-weight: 700; color: var(--dark-sidebar); margin-bottom: 8px;">Chưa Chọn Bệnh Nhân Khám</h3>
            <p style="color: var(--text-muted); margin-bottom: 24px; max-width: 450px; margin-left: auto; margin-right: auto;">
                Vui lòng quay lại danh sách bệnh nhân để tiếp nhận và chọn bệnh nhân thực hiện khám lâm sàng.
            </p>
            <a href="Default" class="btn-premium btn-premium-primary">
                <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách
            </a>
        </div>
    </asp:Panel>

    <!-- Case 2: Patient selected, show exam form -->
    <asp:Panel ID="pnlExamination" runat="server" Visible="false">
        
        <!-- Patient Info Summary Strip -->
        <div class="patient-profile-strip">
            <div class="profile-item">
                <span class="profile-item-label">Mã bệnh nhân</span>
                <span class="profile-item-value"><asp:Literal ID="litPatientCode" runat="server"></asp:Literal></span>
            </div>
            <div class="profile-item">
                <span class="profile-item-label">Họ và Tên</span>
                <span class="profile-item-value" style="color: var(--primary);"><asp:Literal ID="litPatientName" runat="server"></asp:Literal></span>
            </div>
            <div class="profile-item">
                <span class="profile-item-label">Ngày sinh (Tuổi)</span>
                <span class="profile-item-value"><asp:Literal ID="litPatientAge" runat="server"></asp:Literal></span>
            </div>
            <div class="profile-item">
                <span class="profile-item-label">Giới tính</span>
                <span class="profile-item-value"><asp:Literal ID="litPatientGender" runat="server"></asp:Literal></span>
            </div>
            <div class="profile-item">
                <span class="profile-item-label">Thẻ BHYT</span>
                <span class="profile-item-value"><asp:Literal ID="litPatientInsurance" runat="server"></asp:Literal></span>
            </div>
            <div class="profile-item" style="flex-grow: 1;">
                <span class="profile-item-label">Địa chỉ</span>
                <span class="profile-item-value"><asp:Literal ID="litPatientAddress" runat="server"></asp:Literal></span>
            </div>
        </div>

        <div class="split-layout">
            
            <!-- Left Column: Current consultation details & prescription -->
            <div style="display: flex; flex-direction: column; gap: 24px;">
                
                <!-- Clinical Examination Card -->
                <div class="card-premium">
                    <div class="card-premium-header">
                        <div class="card-premium-title">
                            <i class="fa-solid fa-file-medical text-primary" style="color: var(--primary);"></i>
                            <span>Thông Tin Khám Bệnh Lâm Sàng</span>
                        </div>
                    </div>
                    <div class="card-premium-body">
                        <div class="form-group">
                            <label class="form-label" for="txtSymptoms">Triệu chứng lâm sàng <span style="color:var(--danger)">*</span></label>
                            <asp:TextBox ID="txtSymptoms" runat="server" CssClass="form-control-premium" TextMode="MultiLine" Rows="2" placeholder="Ví dụ: Sốt nhẹ, ho có đờm, đau ngực..."></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvSymptoms" runat="server" ControlToValidate="txtSymptoms" 
                                ErrorMessage="Vui lòng nhập triệu chứng!" ForeColor="Red" Display="Dynamic" ValidationGroup="vgSaveExam" style="font-size: 12px; margin-top: 4px; display: block;"></asp:RequiredFieldValidator>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="txtDiagnosis">Chẩn đoán bệnh <span style="color:var(--danger)">*</span></label>
                            <asp:TextBox ID="txtDiagnosis" runat="server" CssClass="form-control-premium" placeholder="Nhập chẩn đoán y khoa chính xác"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvDiagnosis" runat="server" ControlToValidate="txtDiagnosis" 
                                ErrorMessage="Vui lòng nhập chẩn đoán!" ForeColor="Red" Display="Dynamic" ValidationGroup="vgSaveExam" style="font-size: 12px; margin-top: 4px; display: block;"></asp:RequiredFieldValidator>
                        </div>

                        <div class="form-grid">
                            <div class="form-group">
                                <label class="form-label" for="txtTreatment">Hướng điều trị</label>
                                <asp:TextBox ID="txtTreatment" runat="server" CssClass="form-control-premium" placeholder="Uống thuốc, nghỉ ngơi, khám tai mũi họng..."></asp:TextBox>
                            </div>
                            <div class="form-group">
                                <label class="form-label" for="txtNotes">Ghi chú thêm</label>
                                <asp:TextBox ID="txtNotes" runat="server" CssClass="form-control-premium" placeholder="Lời khuyên bác sĩ..."></asp:TextBox>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Prescription Card -->
                <div class="card-premium">
                    <div class="card-premium-header">
                        <div class="card-premium-title">
                            <i class="fa-solid fa-pills text-primary" style="color: var(--primary);"></i>
                            <span>Kê Đơn Thuốc Phòng Khám</span>
                        </div>
                    </div>
                    <div class="card-premium-body">
                        
                        <!-- AJAX support for adding drugs dynamically without page reload -->
                        <asp:UpdatePanel ID="upPrescription" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                
                                <div class="form-grid" style="align-items: flex-end; gap: 12px; margin-bottom: 20px;">
                                    <div class="form-group" style="margin-bottom: 0; flex: 3;">
                                        <label class="form-label" for="cbMedication">Tên thuốc (Chọn từ danh mục)</label>
                                        <dx:ASPxComboBox ID="cbMedication" runat="server" ClientInstanceName="cbMedication"
                                            CssClass="form-control-premium" Width="100%" DropDownStyle="DropDownList"
                                            IncrementalFilteringMode="Contains" ValueField="MedicationId" TextField="MedicationName"
                                            NullText="Gõ tên thuốc để tìm kiếm..." ValueType="System.Int32" Theme="Moderno">
                                        </dx:ASPxComboBox>
                                    </div>
                                    <div class="form-group" style="margin-bottom: 0; flex: 1;">
                                        <label class="form-label" for="txtQuantity">Số Lượng</label>
                                        <asp:TextBox ID="txtQuantity" runat="server" CssClass="form-control-premium" placeholder="10" TextMode="Number"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="form-group" style="display: flex; gap: 12px; align-items: flex-end;">
                                    <div style="flex: 1;">
                                        <label class="form-label" for="txtDosage">Liều dùng & Hướng dẫn</label>
                                        <asp:TextBox ID="txtDosage" runat="server" CssClass="form-control-premium" placeholder="Ví dụ: Uống 2 lần/ngày, sáng tối sau ăn"></asp:TextBox>
                                    </div>
                                    <asp:Button ID="btnAddDrug" runat="server" Text="Thêm Thuốc" CssClass="btn-premium btn-premium-secondary" 
                                        OnClick="btnAddDrug_Click" />
                                </div>

                                <div style="margin-top: 24px;">
                                    <h4 style="font-weight: 600; font-size: 13px; color: var(--text-muted); margin-bottom: 12px;">Đơn thuốc hiện tại:</h4>
                                    
                                    <asp:GridView ID="gvPrescription" runat="server" AutoGenerateColumns="False" 
                                        GridLines="None" CssClass="table-premium" OnRowDeleting="gvPrescription_RowDeleting" DataKeyNames="DrugName">
                                        <Columns>
                                            <asp:TemplateField HeaderText="STT">
                                                <ItemTemplate>
                                                    <%# Container.DataItemIndex + 1 %>
                                                </ItemTemplate>
                                                <HeaderStyle Width="50px" />
                                            </asp:TemplateField>
                                            <asp:BoundField DataField="DrugName" HeaderText="Tên Thuốc" />
                                            <asp:BoundField DataField="Quantity" HeaderText="SL" HeaderStyle-Width="50px" />
                                            <asp:BoundField DataField="Unit" HeaderText="Đơn vị" HeaderStyle-Width="60px" />
                                            <asp:BoundField DataField="Dosage" HeaderText="Cách Dùng" />
                                            <asp:TemplateField HeaderText="Thao Tác" HeaderStyle-Width="60px">
                                                <ItemTemplate>
                                                    <asp:LinkButton ID="lnkDelete" runat="server" CommandName="Delete" 
                                                        CssClass="text-danger" style="color:var(--danger); font-weight:600; text-decoration:none;">Xóa</asp:LinkButton>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                        <EmptyDataTemplate>
                                            <div style="text-align: center; padding: 20px; color: var(--text-muted); font-style: italic;">
                                                Chưa có thuốc nào trong đơn thuốc này.
                                            </div>
                                        </EmptyDataTemplate>
                                    </asp:GridView>
                                </div>

                            </ContentTemplate>
                            <Triggers>
                                <asp:AsyncPostBackTrigger ControlID="btnAddDrug" EventName="Click" />
                            </Triggers>
                        </asp:UpdatePanel>

                    </div>
                </div>

                <!-- Save consultation Actions -->
                <div style="text-align: right; display: flex; gap: 12px; justify-content: flex-end; margin-bottom: 30px;">
                    <a href="Default" class="btn-premium btn-premium-secondary">Hủy Khám</a>
                    <asp:Button ID="btnSaveExam" runat="server" Text="Lưu & Hoàn Thành Khám" CssClass="btn-premium btn-premium-primary" 
                        ValidationGroup="vgSaveExam" OnClick="btnSaveExam_Click" />
                </div>

            </div>

            <!-- Right Column: Medical History Timeline -->
            <div class="card-premium">
                <div class="card-premium-header">
                    <div class="card-premium-title">
                        <i class="fa-solid fa-clock-rotate-left text-primary" style="color: var(--primary);"></i>
                        <span>Lịch Sử Khám Bệnh Trước Đây</span>
                    </div>
                </div>
                <div class="card-premium-body" style="max-height: 700px; overflow-y: auto;">
                    
                    <asp:Repeater ID="rptHistory" runat="server">
                        <ItemTemplate>
                            <div class="timeline-item">
                                <div class="timeline-marker"></div>
                                <div class="timeline-content">
                                    <div class="timeline-date">
                                        <%# Convert.ToDateTime(Eval("ExamDate")).ToString("dd/MM/yyyy HH:mm") %> - <%# Eval("DoctorName") %>
                                    </div>
                                    <div class="timeline-title">
                                        <%# Eval("Diagnosis") %>
                                    </div>
                                    <div class="timeline-body">
                                        <p><strong>Triệu chứng:</strong> <%# Eval("Symptoms") %></p>
                                        <%# (!string.IsNullOrWhiteSpace(Eval("Notes").ToString())) ? "<p><strong>Ghi chú:</strong> " + Eval("Notes") + "</p>" : "" %>
                                        
                                        <!-- Sub prescription list -->
                                        <div style="margin-top: 10px; border-top: 1px dashed var(--border); padding-top: 8px;">
                                            <span style="font-size:11px; font-weight:600; color:var(--text-muted);">ĐƠN THUỐC:</span>
                                            <ul style="list-style:none; font-size:12px; margin-top:4px; padding-left:0; display:flex; flex-direction:column; gap:2px;">
                                                <asp:Repeater ID="rptPrescriptionSub" runat="server" DataSource='<%# Eval("Prescription") %>'>
                                                    <ItemTemplate>
                                                        <li style="color:var(--text-main);">
                                                            <i class="fa-solid fa-circle-chevron-right" style="font-size:8px; color:var(--primary); margin-right:4px;"></i>
                                                            <strong><%# Eval("DrugName") %></strong> - <%# Eval("Quantity") %> <%# Eval("Unit") %> (<%# Eval("Dosage") %>)
                                                        </li>
                                                    </ItemTemplate>
                                                </asp:Repeater>
                                                <asp:PlaceHolder runat="server" Visible='<%# Eval("Prescription") == null || ((System.Collections.ICollection)Eval("Prescription")).Count == 0 %>'>
                                                    <li style="font-style:italic; color:var(--text-muted); font-size:11px;">Không có thuốc kê đơn</li>
                                                </asp:PlaceHolder>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                    
                    <asp:Panel ID="pnlNoHistory" runat="server" style="text-align: center; padding: 40px 10px; color: var(--text-muted);">
                        <i class="fa-regular fa-calendar-times" style="font-size: 36px; margin-bottom: 12px; display: block;"></i>
                        Chưa có lịch sử khám bệnh trước đây cho bệnh nhân này.
                    </asp:Panel>

                </div>
            </div>

        </div>

    </asp:Panel>
</asp:Content>
