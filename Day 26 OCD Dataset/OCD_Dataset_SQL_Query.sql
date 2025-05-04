Select * from healthproject.dbo.ocd_patient_dataset;

-- 1. Count & PCT of F vs M that have OCD & Average Obession Score by gender
		with gender_data as(
		Select Gender, 
		count(Patient_ID) as patient_count,
		Avg(Y_BOCS_Score_Obsessions) As avg_obsession_score
		From healthproject..ocd_patient_dataset
		Group by Gender
		)
		Select 
		SUM(case when Gender = 'Female' then patient_count else 0 end) as femala_count,
		SUM(case when Gender = 'Male' then patient_count else 0 end) as male_count,

		(SUM(case when Gender = 'Female' then patient_count else 0 end)/
			(SUM(case when Gender = 'Female' then patient_count else 0 end)+ SUM(case when Gender = 'Male' then patient_count else 0 end))*100) as female_per,
		
		SUM(case when Gender = 'Male' then patient_count else 0 end)/
			(SUM(case when Gender = 'Female' then patient_count else 0 end)+ SUM(case when Gender = 'Male' then patient_count else 0 end)) as male_percentage
		From gender_data;




-- 2. Count & average Obsession Score by Ethicities that have OCD
	Select Ethnicity,
	count(Patient_ID) as patient_count,
	Avg(Y_BOCS_Score_Obsessions) as avg_obs_score
	From healthproject..ocd_patient_dataset
	Group by Ethnicity
	Order by patient_count DESC;



-- 3. Number of people diagosed MoM

	SELECT 
    CAST(DATEFROMPARTS(YEAR(OCD_Diagnosis_Date), MONTH(OCD_Diagnosis_Date), 1) AS DATE) AS month_name,
    COUNT(Patient_ID) AS total_patient
	FROM healthproject..ocd_patient_dataset
	GROUP BY CAST(DATEFROMPARTS(YEAR(OCD_Diagnosis_Date), MONTH(OCD_Diagnosis_Date), 1) AS DATE)
	ORDER BY month_name;



	select YEAR(OCD_Diagnosis_Date) as year_name, MONTH(OCD_Diagnosis_Date) as month_name,
	count(Patient_ID) as total_patient
	From healthproject..ocd_patient_dataset
	group by YEAR(OCD_Diagnosis_Date), MONTH(OCD_Diagnosis_Date)
	order by 1,2


-- 4. What is the most common Obsesssion Type (Count) & its respective average Obsession Score


	Select Obsession_Type,
		count(Obsession_Type) as count_obsession_type,
		Avg(Y_BOCS_Score_Obsessions) as Avg_Obsession_Score
	From healthproject..ocd_patient_dataset
	Group by Obsession_Type
	Order by count_obsession_type DESC;



-- 5. What is the most common Compulsion Type (count) & its respective average Obession Score

	Select Compulsion_Type,
		count(Patient_ID) as total_patient,
		Avg(Y_BOCS_Score_Obsessions) as Avg_Obsession_Score,
		Avg(Y_BOCS_Score_Compulsions) as Avg_Compulsions_Score
	From healthproject..ocd_patient_dataset
	Group by Compulsion_Type
	Order by total_patient DESC;