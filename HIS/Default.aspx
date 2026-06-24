<%@ Page Title="Quản Lý Bệnh Nhân" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="HIS._Default" %>
<%@ Register Assembly="DevExpress.Web.v21.2, Version=21.2.6.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

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

    <!-- Main Content - Full Page List -->
    <div class="card-premium">
        <div class="card-premium-header">
            <div class="card-premium-title">
                <i class="fa-solid fa-rectangle-list text-primary" style="color: var(--primary);"></i>
                <span>Danh Sách Tiếp Nhận Trong Ngày</span>
            </div>
            <div>
                <button type="button" class="btn-premium btn-premium-primary" onclick="popupRegister.Show();">
                    <i class="fa-solid fa-user-plus"></i> Thêm Bệnh Nhân
                </button>
            </div>
        </div>
        <div class="card-premium-body">
            <!-- Search cluster -->
            <asp:Panel ID="pnlSearch" runat="server" DefaultButton="btnSearch">
                <div class="search-cluster">
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control-premium" placeholder="Tìm theo Mã BN, Tên hoặc BHYT..."></asp:TextBox>
                    <asp:Button ID="btnSearch" runat="server" Text="Tìm kiếm" CssClass="btn-premium btn-premium-secondary" OnClick="btnSearch_Click" CausesValidation="false" />
                </div>
            </asp:Panel>

                <asp:GridView ID="gvPatients" runat="server" AutoGenerateColumns="False" 
                    GridLines="None" CssClass="table-premium" DataKeyNames="VisitId">
                    <Columns>
                        <asp:BoundField DataField="QueueNo" HeaderText="STT">
                            <HeaderStyle Width="50px" />
                        </asp:BoundField>
                        <asp:BoundField DataField="PatientId" HeaderText="Mã BN">
                            <HeaderStyle Width="80px" />
                        </asp:BoundField>
                        <asp:BoundField DataField="FullName" HeaderText="Họ và Tên">
                            <HeaderStyle Width="350px" />
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
                        <asp:TemplateField HeaderText="Giờ Tiếp Nhận">
                            <ItemTemplate>
                                <%# Convert.ToDateTime(Eval("VisitDate")).ToString("HH:mm dd/MM/yyyy") %>
                            </ItemTemplate>
                            <HeaderStyle Width="130px" />
                        </asp:TemplateField>
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
                            <HeaderStyle Width="160px" />
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

    <!-- DevExpress Success Dialog Modal -->
    <dx:ASPxPopupControl ID="popupSuccess" runat="server" ClientInstanceName="popupSuccess"
        HeaderText="Tiếp Nhận Thành Công" Width="380px" CloseAction="CloseButton" CloseOnEscape="true" 
        Modal="true" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter"
        AllowDragging="True" ShowFooter="False" Theme="Moderno" CssClass="dx-popup-center-premium"
        ShowOnPageLoad="false">
        <ContentCollection>
            <dx:PopupControlContentControl runat="server">
                <div style="text-align: center; padding: 10px 5px;">
                    <div style="color: #10b981; font-size: 44px; margin-bottom: 12px;">
                        <i class="fa-solid fa-circle-check"></i>
                    </div>
                    <p style="color: #64748b; font-size: 14px; margin-bottom: 16px; line-height: 1.4;">
                        Bệnh nhân đã được tiếp nhận và phân phòng khám thành công.
                    </p>
                    
                    <div style="background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 12px; margin-bottom: 20px; display: inline-block; min-width: 220px;">
                        <span style="font-size: 12px; color: #64748b; display: block; margin-bottom: 4px;">MÃ BỆNH NHÂN</span>
                        <strong style="font-size: 16px; color: #0f766e; letter-spacing: 0.5px;">
                            <asp:Literal ID="litSuccessPatientId" runat="server"></asp:Literal>
                        </strong>
                    </div>
                    
                    <div style="margin-top: 10px;">
                        <button type="button" class="btn-premium btn-premium-primary" style="width: 100%; max-width: 150px;" onclick="popupSuccess.Hide();">Đồng ý</button>
                    </div>
                </div>
            </dx:PopupControlContentControl>
        </ContentCollection>
    </dx:ASPxPopupControl>

    <!-- Script AJAX Suggestion & Autofill Patient by Phone -->
    <script type="text/javascript">
        function searchPatientByPhone(phoneVal) {
            var val = phoneVal.trim();
            var box = document.getElementById('phone-suggestions');
            
            if (val.length < 3) {
                if (box) box.style.display = 'none';
                return;
            }

            $.ajax({
                type: "POST",
                url: "Default.aspx/GetPatientByPhone",
                data: JSON.stringify({ phone: val }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var list = response.d;
                    if (list && list.length > 0) {
                        var html = '';
                        list.forEach(function (p) {
                            var birthDateStr = '';
                            var displayDOB = '';
                            if (p.BirthDate) {
                                var dateTicks = parseInt(p.BirthDate.replace(/\/Date\((.*?)\)\//gi, "$1"));
                                var dateObj = new Date(dateTicks);
                                var year = dateObj.getFullYear();
                                var month = ("0" + (dateObj.getMonth() + 1)).slice(-2);
                                var day = ("0" + dateObj.getDate()).slice(-2);
                                birthDateStr = year + "-" + month + "-" + day;
                                displayDOB = day + "/" + month + "/" + year;
                            }

                            var addressEscaped = (p.Address || '').replace(/'/g, "\\'");
                            var nameEscaped = (p.FullName || '').replace(/'/g, "\\'");

                            html += '<div class="suggestion-item-premium" onclick="selectPatient(\'' + 
                                nameEscaped + '\', \'' + 
                                birthDateStr + '\', \'' + 
                                p.Gender + '\', \'' + 
                                p.InsuranceCard + '\', \'' + 
                                addressEscaped + '\', \'' +
                                p.Phone + '\')">';
                            html += '<i class="fa-solid fa-user-clock"></i>';
                            html += '<div class="suggestion-item-info">';
                            html += '<div class="suggestion-item-name">' + p.FullName + '</div>';
                            html += '<div class="suggestion-item-meta">Mã BN: ' + p.PatientId + ' • Ngày sinh: ' + displayDOB + '</div>';
                            html += '</div></div>';
                        });
                        box.innerHTML = html;
                        box.style.display = 'block';
                    } else {
                        box.style.display = 'none';
                    }
                },
                error: function (xhr, status, error) {
                    console.error("AJAX Error: " + error);
                }
            });
        }

        function selectPatient(fullName, birthDate, gender, insurance, address, phone) {
            $('#<%= txtPhone.ClientID %>').val(phone);
            $('#<%= txtFullName.ClientID %>').val(fullName);
            $('#<%= txtBirthDate.ClientID %>').val(birthDate);
            
            var rbl = $('#<%= rblGender.ClientID %> input');
            rbl.each(function() {
                if ($(this).val() === gender) {
                    $(this).prop('checked', true);
                } else {
                    $(this).prop('checked', false);
                }
            });

            $('#<%= txtInsuranceCard.ClientID %>').val(insurance);
            $('#<%= txtAddress.ClientID %>').val(address);

            // Ẩn gợi ý
            document.getElementById('phone-suggestions').style.display = 'none';
        }

        $(document).click(function (e) {
            if (!$(e.target).closest('#phone-suggestions, #<%= txtPhone.ClientID %>').length) {
                $('#phone-suggestions').hide();
            }
        });
    </script>

    <!-- DevExpress Patient Registration Dialog -->
    <dx:ASPxPopupControl ID="popupRegister" runat="server" ClientInstanceName="popupRegister"
        HeaderText="Đăng Ký Khám & Tiếp Đón Bệnh Nhân" Width="850px" CloseAction="CloseButton" CloseOnEscape="true" 
        Modal="true" PopupHorizontalAlign="WindowCenter" PopupVerticalAlign="WindowCenter"
        AllowDragging="True" ShowFooter="False" Theme="Moderno" CssClass="dx-popup-center-premium popup-register-width"
        ShowOnPageLoad="false">
        <ContentCollection>
            <dx:PopupControlContentControl runat="server">
                <div style="padding: 10px 5px;">
                    <asp:Panel ID="pnlRegister" runat="server" DefaultButton="btnRegister" autocomplete="off">
                        
                        <div class="form-group" style="position: relative;">
                            <label class="form-label" for="txtPhone">Số Điện Thoại <span style="color:var(--danger)">*</span></label>
                            <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control-premium" placeholder="Nhập số điện thoại..." autocomplete="off" oninput="searchPatientByPhone(this.value)"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvPhone" runat="server" ControlToValidate="txtPhone" 
                                ErrorMessage="Vui lòng nhập số điện thoại!" ForeColor="Red" Display="Dynamic" ValidationGroup="vgRegister" style="font-size: 12px; margin-top: 4px; display: block;"></asp:RequiredFieldValidator>
                            <div id="phone-suggestions" class="suggestions-box-premium" style="display: none;"></div>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="txtFullName">Họ và Tên Bệnh Nhân <span style="color:var(--danger)">*</span></label>
                            <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control-premium" placeholder="Nhập họ và tên đầy đủ" autocomplete="off"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvFullName" runat="server" ControlToValidate="txtFullName" 
                                ErrorMessage="Vui lòng nhập họ tên!" ForeColor="Red" Display="Dynamic" ValidationGroup="vgRegister" style="font-size: 12px; margin-top: 4px; display: block;"></asp:RequiredFieldValidator>
                        </div>

                        <div class="form-grid">
                            <div class="form-group">
                                <label class="form-label" for="txtBirthDate">Ngày Sinh <span style="color:var(--danger)">*</span></label>
                                <asp:TextBox ID="txtBirthDate" runat="server" CssClass="form-control-premium" TextMode="Date" autocomplete="off"></asp:TextBox>
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
                                <asp:TextBox ID="txtInsuranceCard" runat="server" CssClass="form-control-premium" placeholder="Ví dụ: GD479088012345" autocomplete="off"></asp:TextBox>
                            </div>

                            <div class="form-group">
                                <label class="form-label" for="ddlDoctors">Bác Sĩ Chỉ Định Khám <span style="color:var(--danger)">*</span></label>
                                <asp:DropDownList ID="ddlDoctors" runat="server" CssClass="form-control-premium"></asp:DropDownList>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="txtAddress">Địa Chỉ</label>
                            <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control-premium" TextMode="MultiLine" Rows="2" placeholder="Số nhà, tên đường, khu vực..." OnTextChanged="txtAddress_TextChanged" autocomplete="off"></asp:TextBox>
                        </div>

                        <div style="text-align: right; margin-top: 15px; display: flex; justify-content: flex-end; gap: 10px;">
                            <button type="button" class="btn-premium btn-premium-secondary" onclick="popupRegister.Hide();">Hủy bỏ</button>
                            <asp:Button ID="btnRegister" runat="server" Text="Đăng Ký & Phân Phòng" CssClass="btn-premium btn-premium-primary" 
                                ValidationGroup="vgRegister" OnClick="btnRegister_Click" />
                        </div>
                    </asp:Panel>
                </div>
            </dx:PopupControlContentControl>
        </ContentCollection>
    </dx:ASPxPopupControl>
</asp:Content>
