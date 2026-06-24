using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Linq;
using System.Web;

namespace HIS
{
    public class Doctor
    {
        public int DoctorId { get; set; }
        public string DoctorName { get; set; }
        public string Specialty { get; set; }
        public string RoomNo { get; set; }
    }

    public class PatientRegistration
    {
        public int VisitId { get; set; }
        public string PatientId { get; set; }
        public string FullName { get; set; }
        public DateTime BirthDate { get; set; }
        public string Gender { get; set; }
        public string InsuranceCard { get; set; }
        public string Address { get; set; }
        public string DoctorName { get; set; }
        public string RoomNo { get; set; }
        public string Status { get; set; }
        public DateTime VisitDate { get; set; }
    }

    public class PrescriptionItem
    {
        public string DrugName { get; set; }
        public int Quantity { get; set; }
        public string Unit { get; set; }
        public string Dosage { get; set; }
    }

    public class MedicalExamination
    {
        public string Id { get; set; }
        public string PatientId { get; set; }
        public string DoctorName { get; set; }
        public DateTime ExamDate { get; set; }
        public string Symptoms { get; set; }
        public string Diagnosis { get; set; }
        public string Treatment { get; set; }
        public string Notes { get; set; }
        public string Status { get; set; } // "Ongoing", "Completed"
        public List<PrescriptionItem> Prescription { get; set; } = new List<PrescriptionItem>();
    }

    public class Medication
    {
        public int MedicationId { get; set; }
        public string MedicationName { get; set; }
        public string Unit { get; set; }
        public decimal Price { get; set; }
        public int StockQuantity { get; set; }
    }

    public class BillingDrugItem
    {
        public int MedicationId { get; set; }
        public string DrugName { get; set; }
        public int Quantity { get; set; }
        public string Unit { get; set; }
        public decimal Price { get; set; }
        public string Dosage { get; set; }
        public decimal SubTotal => Quantity * Price;
    }

    public class BillingDetail
    {
        public int VisitId { get; set; }
        public string PatientId { get; set; }
        public string FullName { get; set; }
        public DateTime BirthDate { get; set; }
        public string Gender { get; set; }
        public string InsuranceCard { get; set; }
        public string Address { get; set; }
        public string DoctorName { get; set; }
        public string RoomNo { get; set; }
        public string Diagnosis { get; set; }
        public string Symptoms { get; set; }
        public string Notes { get; set; }
        public List<BillingDrugItem> Drugs { get; set; } = new List<BillingDrugItem>();
        public decimal TotalAmount => Drugs.Sum(d => d.SubTotal);
    }

    public static class DatabaseHelper
    {
        private static readonly string ConnString = ConfigurationManager.ConnectionStrings["HISConnection"].ConnectionString;

        // --- Doctor APIs ---

        public static List<Doctor> GetDoctors()
        {
            var list = new List<Doctor>();
            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                conn.Open();
                string query = "SELECT DoctorID, DoctorName, Specialty, RoomNo FROM Doctors ORDER BY DoctorID ASC";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        list.Add(new Doctor
                        {
                            DoctorId = Convert.ToInt32(rdr["DoctorID"]),
                            DoctorName = rdr["DoctorName"].ToString(),
                            Specialty = rdr["Specialty"].ToString(),
                            RoomNo = rdr["RoomNo"].ToString()
                        });
                    }
                }
            }
            return list;
        }

        // --- Registration APIs calling Stored Procedures ---

        public static string RegisterPatient(string fullName, DateTime dob, string gender, string insuranceCard, string address, int doctorId)
        {
            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("sp_RegisterPatient", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@FullName", fullName);
                    cmd.Parameters.AddWithValue("@DOB", dob.Date);
                    cmd.Parameters.AddWithValue("@Gender", gender);
                    cmd.Parameters.AddWithValue("@InsuranceCard", string.IsNullOrWhiteSpace(insuranceCard) ? (object)DBNull.Value : insuranceCard.Trim());
                    cmd.Parameters.AddWithValue("@Address", string.IsNullOrWhiteSpace(address) ? (object)DBNull.Value : address.Trim());
                    cmd.Parameters.AddWithValue("@DoctorID", doctorId);

                    SqlParameter outParam = new SqlParameter("@NewPatientID", SqlDbType.VarChar, 20)
                    {
                        Direction = ParameterDirection.Output
                    };
                    cmd.Parameters.Add(outParam);

                    cmd.ExecuteNonQuery();
                    return outParam.Value.ToString();
                }
            }
        }

        public static List<PatientRegistration> GetTodayRegisteredPatients()
        {
            var list = new List<PatientRegistration>();
            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("sp_GetTodayRegisteredPatients", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            list.Add(new PatientRegistration
                            {
                                VisitId = Convert.ToInt32(rdr["VisitID"]),
                                PatientId = rdr["PatientID"].ToString(),
                                FullName = rdr["FullName"].ToString(),
                                BirthDate = Convert.ToDateTime(rdr["DOB"]),
                                Gender = rdr["Gender"].ToString(),
                                InsuranceCard = rdr["InsuranceCard"] == DBNull.Value ? "" : rdr["InsuranceCard"].ToString(),
                                Address = rdr["Address"] == DBNull.Value ? "" : rdr["Address"].ToString(),
                                DoctorName = rdr["DoctorName"].ToString(),
                                RoomNo = rdr["RoomNo"].ToString(),
                                Status = rdr["Status"].ToString(),
                                VisitDate = Convert.ToDateTime(rdr["VisitDate"])
                            });
                        }
                    }
                }
            }
            return list;
        }

        public static PatientRegistration GetPatientDetailsByVisitId(int visitId)
        {
            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                conn.Open();
                string query = @"
                    SELECT 
                        V.VisitID, P.PatientID, P.FullName, P.DOB, P.Gender, P.InsuranceCard, P.Address, 
                        D.DoctorName, D.RoomNo, V.Status, V.VisitDate
                    FROM Visits V
                    INNER JOIN Patients P ON V.PatientID = P.PatientID
                    INNER JOIN Doctors D ON V.DoctorID = D.DoctorID
                    WHERE V.VisitID = @VisitID";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@VisitID", visitId);
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            return new PatientRegistration
                            {
                                VisitId = Convert.ToInt32(rdr["VisitID"]),
                                PatientId = rdr["PatientID"].ToString(),
                                FullName = rdr["FullName"].ToString(),
                                BirthDate = Convert.ToDateTime(rdr["DOB"]),
                                Gender = rdr["Gender"].ToString(),
                                InsuranceCard = rdr["InsuranceCard"] == DBNull.Value ? "" : rdr["InsuranceCard"].ToString(),
                                Address = rdr["Address"] == DBNull.Value ? "" : rdr["Address"].ToString(),
                                DoctorName = rdr["DoctorName"].ToString(),
                                RoomNo = rdr["RoomNo"].ToString(),
                                Status = rdr["Status"].ToString(),
                                VisitDate = Convert.ToDateTime(rdr["VisitDate"])
                            };
                        }
                    }
                }
            }
            return null;
        }

        // --- Examination APIs ---

        public static List<MedicalExamination> GetExaminationsByPatientId(string patientId)
        {
            var list = new List<MedicalExamination>();
            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                conn.Open();

                string queryExams = @"
                    SELECT e.ExamID, v.PatientID, d.DoctorName, e.ExamDate, e.Symptoms, e.Diagnosis, e.Notes, v.Status
                    FROM Examinations e
                    INNER JOIN Visits v ON e.VisitID = v.VisitID
                    INNER JOIN Doctors d ON v.DoctorID = d.DoctorID
                    WHERE v.PatientID = @PatientID
                    ORDER BY e.ExamDate DESC";

                using (SqlCommand cmd = new SqlCommand(queryExams, conn))
                {
                    cmd.Parameters.AddWithValue("@PatientID", patientId);
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            list.Add(new MedicalExamination
                            {
                                Id = rdr["ExamID"].ToString(),
                                PatientId = rdr["PatientID"].ToString(),
                                DoctorName = rdr["DoctorName"].ToString(),
                                ExamDate = Convert.ToDateTime(rdr["ExamDate"]),
                                Symptoms = rdr["Symptoms"] == DBNull.Value ? "" : rdr["Symptoms"].ToString(),
                                Diagnosis = rdr["Diagnosis"].ToString(),
                                Treatment = "", 
                                Notes = rdr["Notes"] == DBNull.Value ? "" : rdr["Notes"].ToString(),
                                Status = rdr["Status"] == DBNull.Value ? "" : rdr["Status"].ToString(),
                                Prescription = new List<PrescriptionItem>()
                            });
                        }
                    }
                }

                foreach (var exam in list)
                {
                    int examId = Convert.ToInt32(exam.Id);
                    string queryPres = @"
                        SELECT pd.UsageInstructions, pd.Quantity, m.MedicationName, m.Unit
                        FROM PrescriptionDetails pd
                        INNER JOIN Prescriptions p ON pd.PrescriptionID = p.PrescriptionID
                        INNER JOIN Medications m ON pd.MedicationID = m.MedicationID
                        WHERE p.ExamID = @ExamID";

                    using (SqlCommand cmd = new SqlCommand(queryPres, conn))
                    {
                        cmd.Parameters.AddWithValue("@ExamID", examId);
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            while (rdr.Read())
                            {
                                exam.Prescription.Add(new PrescriptionItem
                                {
                                    DrugName = rdr["MedicationName"].ToString(),
                                    Quantity = Convert.ToInt32(rdr["Quantity"]),
                                    Unit = rdr["Unit"].ToString(),
                                    Dosage = rdr["UsageInstructions"].ToString()
                                });
                            }
                        }
                    }
                }
            }
            return list;
        }

        public static void SaveExamination(int visitId, string symptoms, string diagnosis, string notes, List<PrescriptionItem> prescription)
        {
            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                conn.Open();
                using (SqlTransaction trans = conn.BeginTransaction())
                {
                    try
                    {
                        // 1. Get DoctorID from the Visit
                        int doctorId = 1;
                        using (SqlCommand cmdDoctor = new SqlCommand("SELECT DoctorID FROM Visits WHERE VisitID = @VisitID", conn, trans))
                        {
                            cmdDoctor.Parameters.AddWithValue("@VisitID", visitId);
                            object dId = cmdDoctor.ExecuteScalar();
                            if (dId != null && dId != DBNull.Value)
                            {
                                doctorId = Convert.ToInt32(dId);
                            }
                        }

                        // 2. Insert into Examinations
                        SqlCommand cmdExam = new SqlCommand(@"
                            INSERT INTO Examinations (VisitID, Symptoms, Diagnosis, Notes, ExamDate) 
                            VALUES (@VisitID, @Symptoms, @Diagnosis, @Notes, GETDATE());
                            SELECT SCOPE_IDENTITY();", conn, trans);
                        cmdExam.Parameters.AddWithValue("@VisitID", visitId);
                        cmdExam.Parameters.AddWithValue("@Symptoms", string.IsNullOrWhiteSpace(symptoms) ? DBNull.Value : (object)symptoms.Trim());
                        cmdExam.Parameters.AddWithValue("@Diagnosis", diagnosis.Trim());
                        cmdExam.Parameters.AddWithValue("@Notes", string.IsNullOrWhiteSpace(notes) ? DBNull.Value : (object)notes.Trim());
                        
                        int examId = Convert.ToInt32(cmdExam.ExecuteScalar());

                        // 3. Update Status in Visits to "Đã khám"
                        SqlCommand cmdUpdateVisit = new SqlCommand(@"
                            UPDATE Visits SET Status = N'Đã khám' WHERE VisitID = @VisitID", conn, trans);
                        cmdUpdateVisit.Parameters.AddWithValue("@VisitID", visitId);
                        cmdUpdateVisit.ExecuteNonQuery();

                        // 4. Save Prescription if items exist
                        if (prescription != null && prescription.Count > 0)
                        {
                            SqlCommand cmdPres = new SqlCommand(@"
                                INSERT INTO Prescriptions (ExamID, DoctorID, CreatedAt) 
                                VALUES (@ExamID, @DoctorID, GETDATE());
                                SELECT SCOPE_IDENTITY();", conn, trans);
                            cmdPres.Parameters.AddWithValue("@ExamID", examId);
                            cmdPres.Parameters.AddWithValue("@DoctorID", doctorId);

                            int presId = Convert.ToInt32(cmdPres.ExecuteScalar());

                            foreach (var drug in prescription)
                            {
                                int medicationId = GetOrCreateMedicationId(drug.DrugName, drug.Unit, conn, trans);

                                SqlCommand cmdDetail = new SqlCommand(@"
                                    INSERT INTO PrescriptionDetails (PrescriptionID, MedicationID, Quantity, UsageInstructions) 
                                    VALUES (@PrescriptionID, @MedicationID, @Quantity, @UsageInstructions);", conn, trans);
                                cmdDetail.Parameters.AddWithValue("@PrescriptionID", presId);
                                cmdDetail.Parameters.AddWithValue("@MedicationID", medicationId);
                                cmdDetail.Parameters.AddWithValue("@Quantity", drug.Quantity);
                                cmdDetail.Parameters.AddWithValue("@UsageInstructions", string.IsNullOrWhiteSpace(drug.Dosage) ? "" : drug.Dosage.Trim());
                                cmdDetail.ExecuteNonQuery();
                            }
                        }

                        trans.Commit();
                    }
                    catch (Exception)
                    {
                        trans.Rollback();
                        throw;
                    }
                }
            }
        }

        private static int GetOrCreateMedicationId(string drugName, string unit, SqlConnection conn, SqlTransaction trans)
        {
            string queryCheck = "SELECT MedicationID FROM Medications WHERE MedicationName = @Name";
            using (SqlCommand cmdCheck = new SqlCommand(queryCheck, conn, trans))
            {
                cmdCheck.Parameters.AddWithValue("@Name", drugName);
                object val = cmdCheck.ExecuteScalar();
                if (val != null && val != DBNull.Value)
                {
                    return Convert.ToInt32(val);
                }
            }

            string queryInsert = @"
                INSERT INTO Medications (MedicationName, Unit, Price, StockQuantity) 
                VALUES (@Name, @Unit, 0.0, 1000);
                SELECT SCOPE_IDENTITY();";
            using (SqlCommand cmdInsert = new SqlCommand(queryInsert, conn, trans))
            {
                cmdInsert.Parameters.AddWithValue("@Name", drugName);
                cmdInsert.Parameters.AddWithValue("@Unit", string.IsNullOrWhiteSpace(unit) ? "Viên" : unit);
                return Convert.ToInt32(cmdInsert.ExecuteScalar());
            }
        }

        // --- Statistics APIs ---

        public static Dictionary<string, object> GetStats()
        {
            var stats = new Dictionary<string, object>
            {
                { "TotalPatients", 0 },
                { "TotalExamsToday", 0 },
                { "OngoingExams", 0 },
                { "CompletedExams", 0 },
                { "TotalRevenue", 0.0m }
            };

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnString))
                {
                    conn.Open();

                    // Total registered today
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Visits WHERE CAST(VisitDate AS DATE) = CAST(GETDATE() AS DATE)", conn))
                    {
                        stats["TotalPatients"] = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    // Total exams today
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Examinations WHERE CAST(ExamDate AS DATE) = CAST(GETDATE() AS DATE)", conn))
                    {
                        stats["TotalExamsToday"] = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    // Waiting today ("Chờ khám")
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Visits WHERE Status = N'Chờ khám' AND CAST(VisitDate AS DATE) = CAST(GETDATE() AS DATE)", conn))
                    {
                        stats["OngoingExams"] = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    // Completed today ("Đã khám" or "Đã thanh toán")
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Visits WHERE Status IN (N'Đã khám', N'Đã thanh toán') AND CAST(VisitDate AS DATE) = CAST(GETDATE() AS DATE)", conn))
                    {
                        stats["CompletedExams"] = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    // Total Revenue today
                    string revQuery = @"
                        SELECT ISNULL(SUM(CAST(pd.Quantity AS DECIMAL(18,2)) * m.Price), 0.0)
                        FROM PrescriptionDetails pd
                        INNER JOIN Prescriptions p ON pd.PrescriptionID = p.PrescriptionID
                        INNER JOIN Examinations e ON p.ExamID = e.ExamID
                        INNER JOIN Visits v ON e.VisitID = v.VisitID
                        INNER JOIN Medications m ON pd.MedicationID = m.MedicationID
                        WHERE v.Status = N'Đã thanh toán' 
                          AND CAST(v.VisitDate AS DATE) = CAST(GETDATE() AS DATE)";
                    using (SqlCommand cmd = new SqlCommand(revQuery, conn))
                    {
                        stats["TotalRevenue"] = Convert.ToDecimal(cmd.ExecuteScalar());
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error calculating DB stats: " + ex.Message);
            }

            return stats;
        }

        // --- Medications Management APIs ---

        public static List<Medication> GetMedications(string search = "")
        {
            var list = new List<Medication>();
            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                conn.Open();
                string query = "SELECT MedicationID, MedicationName, Unit, Price, StockQuantity FROM Medications";
                if (!string.IsNullOrWhiteSpace(search))
                {
                    query += " WHERE MedicationName LIKE @Search";
                }
                query += " ORDER BY MedicationName ASC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (!string.IsNullOrWhiteSpace(search))
                    {
                        cmd.Parameters.AddWithValue("@Search", "%" + search.Trim() + "%");
                    }
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            list.Add(new Medication
                            {
                                MedicationId = Convert.ToInt32(rdr["MedicationID"]),
                                MedicationName = rdr["MedicationName"].ToString(),
                                Unit = rdr["Unit"].ToString(),
                                Price = Convert.ToDecimal(rdr["Price"]),
                                StockQuantity = Convert.ToInt32(rdr["StockQuantity"])
                            });
                        }
                    }
                }
            }
            return list;
        }

        public static void AddMedication(string name, string unit, decimal price, int stock)
        {
            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                conn.Open();
                string query = @"
                    INSERT INTO Medications (MedicationName, Unit, Price, StockQuantity) 
                    VALUES (@Name, @Unit, @Price, @Stock)";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Name", name.Trim());
                    cmd.Parameters.AddWithValue("@Unit", unit.Trim());
                    cmd.Parameters.AddWithValue("@Price", price);
                    cmd.Parameters.AddWithValue("@Stock", stock);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        public static void UpdateMedication(int id, string name, string unit, decimal price, int stock)
        {
            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                conn.Open();
                string query = @"
                    UPDATE Medications 
                    SET MedicationName = @Name, Unit = @Unit, Price = @Price, StockQuantity = @Stock 
                    WHERE MedicationID = @ID";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@ID", id);
                    cmd.Parameters.AddWithValue("@Name", name.Trim());
                    cmd.Parameters.AddWithValue("@Unit", unit.Trim());
                    cmd.Parameters.AddWithValue("@Price", price);
                    cmd.Parameters.AddWithValue("@Stock", stock);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        public static void DeleteMedication(int id)
        {
            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                conn.Open();
                string query = "DELETE FROM Medications WHERE MedicationID = @ID";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@ID", id);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        // --- Billing APIs ---

        public static List<PatientRegistration> GetUnpaidVisits()
        {
            var list = new List<PatientRegistration>();
            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                conn.Open();
                // Visits that are "Đã khám"
                string query = @"
                    SELECT 
                        V.VisitID, P.PatientID, P.FullName, P.DOB, P.Gender, P.InsuranceCard, P.Address, 
                        D.DoctorName, D.RoomNo, V.Status, V.VisitDate
                    FROM Visits V
                    INNER JOIN Patients P ON V.PatientID = P.PatientID
                    INNER JOIN Doctors D ON V.DoctorID = D.DoctorID
                    WHERE V.Status = N'Đã khám'
                    ORDER BY V.VisitDate DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        list.Add(new PatientRegistration
                        {
                            VisitId = Convert.ToInt32(rdr["VisitID"]),
                            PatientId = rdr["PatientID"].ToString(),
                            FullName = rdr["FullName"].ToString(),
                            BirthDate = Convert.ToDateTime(rdr["DOB"]),
                            Gender = rdr["Gender"].ToString(),
                            InsuranceCard = rdr["InsuranceCard"] == DBNull.Value ? "" : rdr["InsuranceCard"].ToString(),
                            Address = rdr["Address"] == DBNull.Value ? "" : rdr["Address"].ToString(),
                            DoctorName = rdr["DoctorName"].ToString(),
                            RoomNo = rdr["RoomNo"].ToString(),
                            Status = rdr["Status"].ToString(),
                            VisitDate = Convert.ToDateTime(rdr["VisitDate"])
                        });
                    }
                }
            }
            return list;
        }

        public static BillingDetail GetBillingDetails(int visitId)
        {
            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                conn.Open();
                string query = @"
                    SELECT 
                        V.VisitID, P.PatientID, P.FullName, P.DOB, P.Gender, P.InsuranceCard, P.Address, 
                        D.DoctorName, D.RoomNo, E.Diagnosis, E.Symptoms, E.Notes
                    FROM Visits V
                    INNER JOIN Patients P ON V.PatientID = P.PatientID
                    INNER JOIN Doctors D ON V.DoctorID = D.DoctorID
                    INNER JOIN Examinations E ON V.VisitID = E.VisitID
                    WHERE V.VisitID = @VisitID";

                BillingDetail bill = null;
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@VisitID", visitId);
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            bill = new BillingDetail
                            {
                                VisitId = Convert.ToInt32(rdr["VisitID"]),
                                PatientId = rdr["PatientID"].ToString(),
                                FullName = rdr["FullName"].ToString(),
                                BirthDate = Convert.ToDateTime(rdr["DOB"]),
                                Gender = rdr["Gender"].ToString(),
                                InsuranceCard = rdr["InsuranceCard"] == DBNull.Value ? "" : rdr["InsuranceCard"].ToString(),
                                Address = rdr["Address"] == DBNull.Value ? "" : rdr["Address"].ToString(),
                                DoctorName = rdr["DoctorName"].ToString(),
                                RoomNo = rdr["RoomNo"].ToString(),
                                Diagnosis = rdr["Diagnosis"].ToString(),
                                Symptoms = rdr["Symptoms"] == DBNull.Value ? "" : rdr["Symptoms"].ToString(),
                                Notes = rdr["Notes"] == DBNull.Value ? "" : rdr["Notes"].ToString()
                            };
                        }
                    }
                }

                if (bill != null)
                {
                    // Fetch prescription details and calculate subtotal/price
                    string queryDrugs = @"
                        SELECT pd.MedicationID, m.MedicationName, pd.Quantity, m.Unit, m.Price, pd.UsageInstructions
                        FROM PrescriptionDetails pd
                        INNER JOIN Prescriptions p ON pd.PrescriptionID = p.PrescriptionID
                        INNER JOIN Examinations e ON p.ExamID = e.ExamID
                        INNER JOIN Medications m ON pd.MedicationID = m.MedicationID
                        WHERE e.VisitID = @VisitID";

                    using (SqlCommand cmd = new SqlCommand(queryDrugs, conn))
                    {
                        cmd.Parameters.AddWithValue("@VisitID", visitId);
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            while (rdr.Read())
                            {
                                bill.Drugs.Add(new BillingDrugItem
                                {
                                    MedicationId = Convert.ToInt32(rdr["MedicationID"]),
                                    DrugName = rdr["MedicationName"].ToString(),
                                    Quantity = Convert.ToInt32(rdr["Quantity"]),
                                    Unit = rdr["Unit"].ToString(),
                                    Price = Convert.ToDecimal(rdr["Price"]),
                                    Dosage = rdr["UsageInstructions"].ToString()
                                });
                            }
                        }
                    }
                }

                return bill;
            }
        }

        public static void ProcessPayment(int visitId)
        {
            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                conn.Open();
                using (SqlTransaction trans = conn.BeginTransaction())
                {
                    try
                    {
                        // 1. Update status of the Visit to "Đã thanh toán"
                        string queryUpdateVisit = "UPDATE Visits SET Status = N'Đã thanh toán' WHERE VisitID = @VisitID";
                        using (SqlCommand cmd = new SqlCommand(queryUpdateVisit, conn, trans))
                        {
                            cmd.Parameters.AddWithValue("@VisitID", visitId);
                            cmd.ExecuteNonQuery();
                        }

                        // 2. Retrieve prescribed medications and quantities for this visit
                        string queryDrugs = @"
                            SELECT pd.MedicationID, pd.Quantity
                            FROM PrescriptionDetails pd
                            INNER JOIN Prescriptions p ON pd.PrescriptionID = p.PrescriptionID
                            INNER JOIN Examinations e ON p.ExamID = e.ExamID
                            WHERE e.VisitID = @VisitID";

                        var drugDeductions = new List<Tuple<int, int>>();
                        using (SqlCommand cmd = new SqlCommand(queryDrugs, conn, trans))
                        {
                            cmd.Parameters.AddWithValue("@VisitID", visitId);
                            using (SqlDataReader rdr = cmd.ExecuteReader())
                            {
                                while (rdr.Read())
                                {
                                    drugDeductions.Add(new Tuple<int, int>(
                                        Convert.ToInt32(rdr["MedicationID"]),
                                        Convert.ToInt32(rdr["Quantity"])
                                    ));
                                }
                            }
                        }

                        // 3. Deduct stock for each medication
                        foreach (var item in drugDeductions)
                        {
                            string queryDeduct = @"
                                UPDATE Medications 
                                SET StockQuantity = CASE WHEN StockQuantity >= @Qty THEN StockQuantity - @Qty ELSE 0 END
                                WHERE MedicationID = @MedID";
                            using (SqlCommand cmd = new SqlCommand(queryDeduct, conn, trans))
                            {
                                cmd.Parameters.AddWithValue("@Qty", item.Item2);
                                cmd.Parameters.AddWithValue("@MedID", item.Item1);
                                cmd.ExecuteNonQuery();
                            }
                        }

                        trans.Commit();
                    }
                    catch (Exception)
                    {
                        trans.Rollback();
                        throw;
                    }
                }
            }
        }
    }
}
