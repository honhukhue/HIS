using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace HIS
{
    public partial class Examination : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string visitIdStr = Request.QueryString["VisitID"];
                int visitId;
                if (int.TryParse(visitIdStr, out visitId))
                {
                    LoadPatientDetails(visitId);
                    LoadMedications();
                    
                    // Initialize clean prescription in ViewState
                    ViewState["CurrentPrescription"] = new List<PrescriptionItem>();
                    BindPrescription();
                }
                else
                {
                    pnlNoPatient.Visible = true;
                    pnlExamination.Visible = false;
                }
            }
        }

        private void LoadMedications()
        {
            try
            {
                var list = DatabaseHelper.GetMedications();
                cbMedication.DataSource = list;
                cbMedication.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading medications: " + ex.Message);
            }
        }

        private void LoadPatientDetails(int visitId)
        {
            var reg = DatabaseHelper.GetPatientDetailsByVisitId(visitId);
            if (reg != null)
            {
                pnlNoPatient.Visible = false;
                pnlExamination.Visible = true;

                litPatientCode.Text = reg.PatientId;
                litPatientName.Text = reg.FullName;
                
                int age = DateTime.Today.Year - reg.BirthDate.Year;
                if (reg.BirthDate.Date > DateTime.Today.AddYears(-age)) age--;
                litPatientAge.Text = $"{reg.BirthDate.ToString("dd/MM/yyyy")} ({age} tuổi)";
                
                litPatientGender.Text = reg.Gender;
                litPatientInsurance.Text = string.IsNullOrWhiteSpace(reg.InsuranceCard) ? "Không có BHYT" : reg.InsuranceCard;
                litPatientAddress.Text = string.IsNullOrWhiteSpace(reg.Address) ? "Chưa cập nhật" : reg.Address;

                // Load historical consultations based on the patient's ID
                LoadHistory(reg.PatientId);
            }
            else
            {
                pnlNoPatient.Visible = true;
                pnlExamination.Visible = false;
            }
        }

        private void LoadHistory(string patientId)
        {
            var history = DatabaseHelper.GetExaminationsByPatientId(patientId);
            if (history != null && history.Count > 0)
            {
                rptHistory.DataSource = history;
                rptHistory.DataBind();
                rptHistory.Visible = true;
                pnlNoHistory.Visible = false;
            }
            else
            {
                rptHistory.Visible = false;
                pnlNoHistory.Visible = true;
            }
        }

        // --- Prescription Grid Builder Logic ---

        private void BindPrescription()
        {
            var list = ViewState["CurrentPrescription"] as List<PrescriptionItem> ?? new List<PrescriptionItem>();
            gvPrescription.DataSource = list;
            gvPrescription.DataBind();
        }

        protected void btnAddDrug_Click(object sender, EventArgs e)
        {
            if (cbMedication.Value == null)
            {
                ScriptManager.RegisterStartupScript(upPrescription, upPrescription.GetType(), "alert", "alert('Vui lòng chọn thuốc từ danh mục!');", true);
                return;
            }

            int medId = Convert.ToInt32(cbMedication.Value);
            var medications = DatabaseHelper.GetMedications();
            var med = medications.FirstOrDefault(m => m.MedicationId == medId);
            
            if (med == null)
            {
                ScriptManager.RegisterStartupScript(upPrescription, upPrescription.GetType(), "alert", "alert('Không tìm thấy thuốc hợp lệ!');", true);
                return;
            }

            string drugName = med.MedicationName;
            string unit = med.Unit;

            int qty = 1;
            int.TryParse(txtQuantity.Text, out qty);
            if (qty <= 0) qty = 1;

            string dosage = txtDosage.Text.Trim();

            var list = ViewState["CurrentPrescription"] as List<PrescriptionItem> ?? new List<PrescriptionItem>();
            
            // Check if drug already added, if so, accumulate qty
            var existing = list.FirstOrDefault(d => d.DrugName.Equals(drugName, StringComparison.OrdinalIgnoreCase));
            if (existing != null)
            {
                existing.Quantity += qty;
            }
            else
            {
                list.Add(new PrescriptionItem
                {
                    DrugName = drugName,
                    Quantity = qty,
                    Unit = unit,
                    Dosage = dosage
                });
            }

            ViewState["CurrentPrescription"] = list;
            BindPrescription();

            // Clear inputs
            cbMedication.Value = null;
            cbMedication.Text = string.Empty;
            txtQuantity.Text = string.Empty;
            txtDosage.Text = string.Empty;

            cbMedication.Focus();
        }

        protected void gvPrescription_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            var list = ViewState["CurrentPrescription"] as List<PrescriptionItem> ?? new List<PrescriptionItem>();
            if (e.RowIndex >= 0 && e.RowIndex < list.Count)
            {
                list.RemoveAt(e.RowIndex);
                ViewState["CurrentPrescription"] = list;
                BindPrescription();
            }
        }

        // --- Save Examination Record ---

        protected void btnSaveExam_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                string visitIdStr = Request.QueryString["VisitID"];
                int visitId;
                if (!int.TryParse(visitIdStr, out visitId)) return;

                try
                {
                    var prescriptionList = ViewState["CurrentPrescription"] as List<PrescriptionItem> ?? new List<PrescriptionItem>();

                    string symptoms = txtSymptoms.Text.Trim();
                    string diagnosis = txtDiagnosis.Text.Trim();
                    string notes = txtNotes.Text.Trim();
                    if (!string.IsNullOrWhiteSpace(txtTreatment.Text))
                    {
                        // Add treatment to notes if present, since schema has Symptoms, Diagnosis, Notes
                        notes = $"Hướng ĐT: {txtTreatment.Text.Trim()}. {notes}".Trim();
                    }

                    DatabaseHelper.SaveExamination(visitId, symptoms, diagnosis, notes, prescriptionList);

                    // Redirect back to default patient list page
                    Response.Redirect("Default");
                }
                catch (Exception ex)
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "alert", $"alert('Lỗi khi lưu bệnh án: {ex.Message}');", true);
                }
            }
        }
    }
}
