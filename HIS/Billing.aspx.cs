using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace HIS
{
    public partial class Billing : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindUnpaidVisits();
                
                string visitIdStr = Request.QueryString["VisitID"];
                int visitId;
                if (int.TryParse(visitIdStr, out visitId))
                {
                    LoadBillingDetails(visitId);
                }
                else
                {
                    pnlNoBilling.Visible = true;
                    pnlBillingDetail.Visible = false;
                }
            }
        }

        private void BindUnpaidVisits()
        {
            try
            {
                var list = DatabaseHelper.GetUnpaidVisits();
                gvUnpaidVisits.DataSource = list;
                gvUnpaidVisits.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error binding unpaid list: " + ex.Message);
                ScriptManager.RegisterStartupScript(this, GetType(), "errorAlert", $"alert('Lỗi tải danh sách chờ thanh toán: {ex.Message}');", true);
            }
        }

        private void LoadBillingDetails(int visitId)
        {
            try
            {
                var bill = DatabaseHelper.GetBillingDetails(visitId);
                if (bill != null)
                {
                    pnlNoBilling.Visible = false;
                    pnlBillingDetail.Visible = true;

                    litPatientCode.Text = bill.PatientId;
                    litPatientName.Text = bill.FullName;
                    
                    int age = DateTime.Today.Year - bill.BirthDate.Year;
                    if (bill.BirthDate.Date > DateTime.Today.AddYears(-age)) age--;
                    litPatientDOB.Text = $"{bill.BirthDate.ToString("dd/MM/yyyy")} ({age} tuổi)";
                    
                    litPatientInsurance.Text = string.IsNullOrWhiteSpace(bill.InsuranceCard) ? "Không có BHYT" : bill.InsuranceCard;
                    litPatientAddress.Text = string.IsNullOrWhiteSpace(bill.Address) ? "Chưa cập nhật" : bill.Address;
                    
                    litDoctorName.Text = bill.DoctorName;
                    litRoomNo.Text = bill.RoomNo;
                    litDiagnosis.Text = bill.Diagnosis;
                    litSymptoms.Text = string.IsNullOrWhiteSpace(bill.Symptoms) ? "Không ghi nhận" : bill.Symptoms;

                    // Bind prescribed medications
                    gvPrescribedDrugs.DataSource = bill.Drugs;
                    gvPrescribedDrugs.DataBind();

                    litTotalAmount.Text = bill.TotalAmount.ToString("N0") + " đ";
                }
                else
                {
                    pnlNoBilling.Visible = true;
                    pnlBillingDetail.Visible = false;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading bill details: " + ex.Message);
                ScriptManager.RegisterStartupScript(this, GetType(), "errorAlert", $"alert('Lỗi khi tải chi tiết hóa đơn: {ex.Message}');", true);
            }
        }

        protected void gvUnpaidVisits_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (gvUnpaidVisits.SelectedDataKey != null)
            {
                int visitId = Convert.ToInt32(gvUnpaidVisits.SelectedDataKey.Value);
                Response.Redirect($"Billing?VisitID={visitId}");
            }
        }

        protected void btnConfirmPayment_Click(object sender, EventArgs e)
        {
            string visitIdStr = Request.QueryString["VisitID"];
            int visitId;
            if (int.TryParse(visitIdStr, out visitId))
            {
                try
                {
                    // 1. Confirm billing transaction and update DB
                    DatabaseHelper.ProcessPayment(visitId);

                    // 2. Alert success and redirect to clear billing page
                    string script = "alert('Thanh toán hóa đơn viện phí và phát thuốc thành công! Số lượng thuốc tồn kho đã được cập nhật.'); window.location='Billing';";
                    ScriptManager.RegisterStartupScript(this, GetType(), "paymentSuccess", script, true);
                }
                catch (Exception ex)
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "errorAlert", $"alert('Lỗi xử lý thanh toán: {ex.Message}');", true);
                }
            }
        }
    }
}
