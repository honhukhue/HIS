using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace HIS
{
    public partial class Medications : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindMedications();
            }
        }

        private void BindMedications(string search = "")
        {
            try
            {
                var list = DatabaseHelper.GetMedications(search);
                gvMedications.DataSource = list;
                gvMedications.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error binding medications: " + ex.Message);
                ScriptManager.RegisterStartupScript(this, GetType(), "errorAlert", $"alert('Lỗi khi tải danh sách thuốc: {ex.Message}');", true);
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            BindMedications(txtSearch.Text);
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                try
                {
                    string name = txtMedicationName.Text.Trim();
                    string unit = txtUnit.Text.Trim();
                    decimal price = Convert.ToDecimal(txtPrice.Text);
                    int stock = Convert.ToInt32(txtStockQuantity.Text);

                    if (string.IsNullOrEmpty(hfMedicationId.Value))
                    {
                        // Add new medication
                        DatabaseHelper.AddMedication(name, unit, price, stock);
                        ScriptManager.RegisterStartupScript(this, GetType(), "successAlert", "alert('Thêm thuốc mới thành công!');", true);
                    }
                    else
                    {
                        // Update existing medication
                        int id = Convert.ToInt32(hfMedicationId.Value);
                        DatabaseHelper.UpdateMedication(id, name, unit, price, stock);
                        ScriptManager.RegisterStartupScript(this, GetType(), "successAlert", "alert('Cập nhật thông tin thuốc thành công!');", true);
                    }

                    ClearForm();
                    BindMedications();
                }
                catch (Exception ex)
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "errorAlert", $"alert('Lỗi lưu thông tin thuốc: {ex.Message}');", true);
                }
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            ClearForm();
        }

        protected void gvMedications_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int medId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "EditMed")
            {
                try
                {
                    var medications = DatabaseHelper.GetMedications();
                    var med = medications.FirstOrDefault(m => m.MedicationId == medId);
                    if (med != null)
                    {
                        hfMedicationId.Value = med.MedicationId.ToString();
                        txtMedicationName.Text = med.MedicationName;
                        txtUnit.Text = med.Unit;
                        txtPrice.Text = Convert.ToInt32(med.Price).ToString();
                        txtStockQuantity.Text = med.StockQuantity.ToString();

                        lblFormTitle.Text = "Cập Nhật Thông Tin Thuốc (Mã: " + medId + ")";
                        btnSave.Text = "Cập Nhật";
                        btnCancel.Visible = true;
                    }
                }
                catch (Exception ex)
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "errorAlert", $"alert('Lỗi tải thông tin thuốc cần sửa: {ex.Message}');", true);
                }
            }
            else if (e.CommandName == "DeleteMed")
            {
                try
                {
                    DatabaseHelper.DeleteMedication(medId);
                    ScriptManager.RegisterStartupScript(this, GetType(), "successAlert", "alert('Xóa thuốc khỏi danh mục thành công!');", true);
                    ClearForm();
                    BindMedications();
                }
                catch (Exception ex)
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "errorAlert", $"alert('Lỗi khi xóa thuốc (Có thể thuốc đã tồn tại trong đơn thuốc đã kê): {ex.Message}');", true);
                }
            }
        }

        private void ClearForm()
        {
            hfMedicationId.Value = string.Empty;
            txtMedicationName.Text = string.Empty;
            txtUnit.Text = string.Empty;
            txtPrice.Text = string.Empty;
            txtStockQuantity.Text = string.Empty;
            
            lblFormTitle.Text = "Thêm Thuốc Mới Vào Danh Mục";
            btnSave.Text = "Lưu Thông Tin";
            btnCancel.Visible = false;
        }
    }
}
