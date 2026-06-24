using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace HIS
{
    public partial class _Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDoctors();
                LoadStats();
                BindPatients();

                // Kiểm tra hiển thị thông báo thành công từ PRG redirect
                string successId = Request.QueryString["successId"];
                if (!string.IsNullOrEmpty(successId))
                {
                    litSuccessPatientId.Text = successId;
                    popupSuccess.ShowOnPageLoad = true;
                    ScriptManager.RegisterStartupScript(this, GetType(), "clearUrlQuery", "if(window.history.replaceState) { window.history.replaceState({}, document.title, window.location.pathname); }", true);
                }
            }
        }

        [System.Web.Services.WebMethod]
        public static List<PatientRegistration> GetPatientByPhone(string phone)
        {
            return DatabaseHelper.GetPatientsByPhone(phone);
        }

        private void LoadDoctors()
        {
            try
            {
                var doctors = DatabaseHelper.GetDoctors();
                ddlDoctors.DataSource = doctors;
                ddlDoctors.DataTextField = "DoctorName";
                ddlDoctors.DataValueField = "DoctorId";
                ddlDoctors.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading doctors: " + ex.Message);
            }
        }

        private void LoadStats()
        {
            try
            {
                var stats = DatabaseHelper.GetStats();
                litTotalPatients.Text = stats["TotalPatients"].ToString();
                litExamsToday.Text = stats["TotalExamsToday"].ToString();
                litOngoingExams.Text = stats["OngoingExams"].ToString();
                
                decimal revenue = Convert.ToDecimal(stats["TotalRevenue"]);
                litTotalRevenue.Text = revenue.ToString("N0") + "đ";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading stats: " + ex.Message);
            }
        }

        private void BindPatients(string search = "")
        {
            try
            {
                var list = DatabaseHelper.GetTodayRegisteredPatients();

                if (!string.IsNullOrWhiteSpace(search))
                {
                    string keyword = search.Trim().ToLower();
                    list = list.Where(p => 
                        p.PatientId.ToLower().Contains(keyword) || 
                        p.FullName.ToLower().Contains(keyword) || 
                        p.InsuranceCard.ToLower().Contains(keyword)
                    ).ToList();
                }

                gvPatients.DataSource = list;
                gvPatients.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error binding patients: " + ex.Message);
            }
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                try
                {
                    string phone = txtPhone.Text.Trim();
                    string fullName = txtFullName.Text.Trim();
                    DateTime dob = DateTime.Parse(txtBirthDate.Text);
                    string gender = rblGender.SelectedValue;
                    string insuranceCard = txtInsuranceCard.Text.Trim();
                    string address = txtAddress.Text.Trim();
                    int doctorId = Convert.ToInt32(ddlDoctors.SelectedValue);

                    string patientId = DatabaseHelper.RegisterPatient(fullName, dob, gender, insuranceCard, address, doctorId, phone);

                    // Redirect sang GET để tránh lỗi F5 gửi lại Form (Post-Redirect-Get Pattern)
                    Response.Redirect("~/Default?successId=" + patientId);
                }
                catch (Exception ex)
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "errorAlert", $"alert('Lỗi tiếp nhận bệnh nhân: {ex.Message}');", true);
                }
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            BindPatients(txtSearch.Text);
        }

        protected void txtAddress_TextChanged(object sender, EventArgs e)
        {

        }
    }
}