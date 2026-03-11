CREATE TABLE Skin_Cancer_Cohort AS
SELECT
    p.PatientID,
    p.Gender,
    p.Age,
    p.SkinType,
    p.FamilyHistoryCancer,
    d.DiagnosisCode,
    d.DiagnosisDescription,
    d.DiagnosisDate,
    COUNT(b.BiopsyID)       AS NumberOfBiopsies,
    MAX(e.EncounterDate)    AS MostRecentEncounter
FROM
    EHR_Patients            p
JOIN
    EHR_Diagnoses           d ON p.PatientID = d.PatientID
JOIN
    EHR_Encounters          e ON p.PatientID = e.PatientID
LEFT JOIN
    EHR_Procedures          b ON p.PatientID = b.PatientID
                             AND b.ProcedureCode IN ('11100','11101') -- skin biopsy CPT codes
WHERE
    d.DiagnosisCode IN (
        'C43%',   -- Malignant melanoma
        'C44%',   -- Other malignant neoplasms of skin
        'D03%',   -- Melanoma in situ
        'D04%'    -- Carcinoma in situ of skin
    )
    AND e.EncounterDate >= DATEADD(year, -5, GETDATE())
GROUP BY
    p.PatientID, p.Gender, p.Age, p.SkinType,
    p.FamilyHistoryCancer, d.DiagnosisCode,
    d.DiagnosisDescription, d.DiagnosisDate
HAVING
    COUNT(b.BiopsyID) >= 1;  -- At least one confirmed biopsy

-- Index for query performance
CREATE INDEX idx_skin_cancer_patient
    ON Skin_Cancer_Cohort (PatientID);

CREATE INDEX idx_skin_cancer_diagnosis
    ON Skin_Cancer_Cohort (DiagnosisCode, DiagnosisDate);
