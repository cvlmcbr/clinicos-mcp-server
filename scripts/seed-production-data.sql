-- ============================================================================
-- ClinicOS MCP Server — Production Seed: MBS Items + PSR Cases
-- ============================================================================
--
-- Purpose:  Populate mbs_items and psr_cases tables with curated Australian
--           Medicare data sourced from MBS Online (Nov 2025 schedule) and
--           verified PSR Director's updates (2023-2025).
--
-- How to run:
--   psql -U <user> -d <database> -f scripts/seed-production-data.sql
--
--   Or via Cloud SQL Proxy:
--   psql "host=/cloudsql/<CONNECTION_NAME> dbname=<db> user=<user>" \
--        -f scripts/seed-production-data.sql
--
-- Idempotent: Uses INSERT ... ON CONFLICT DO UPDATE so it is safe to re-run.
-- ============================================================================

BEGIN;

-- ============================================================================
-- SECTION 1: MBS ITEMS (42 items)
-- Source: MBS Online — November 2025 Schedule
-- ============================================================================

INSERT INTO mbs_items (
  id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes,
  clinical_indication_required, documentation_requirements, common_errors,
  psr_risk_level, effective_from, effective_to, created_at, updated_at
) VALUES

-- ---------------------------------------------------------------------------
-- GP CONSULTATIONS
-- ---------------------------------------------------------------------------

(gen_random_uuid(), '3', 'General Practice', 'Vocationally Registered GP',
 'Professional attendance by a vocationally registered general practitioner (VR GP) for an obvious problem characterised by the straightforward nature of the task that requires a short patient history and, if required, limited examination and management.',
 18.85, false, false, 10,
 '["Obvious problem requiring short history"]'::jsonb,
 '{"required": ["Presenting complaint", "Brief assessment", "Management plan"], "recommended": ["Vital signs if relevant"], "examples": ["Prescription renewal for stable condition", "Simple wound dressing check"]}'::jsonb,
 '["Using Level A for complex problems", "Missing documentation of reason for attendance"]'::jsonb,
 'low', '2025-11-01', NULL, now(), now()),

(gen_random_uuid(), '23', 'General Practice', 'Vocationally Registered GP',
 'Professional attendance by a VR GP lasting less than 20 minutes for one or more health-related issues, with implementation of a management plan. Level B services may include, but not limited to: taking a patient history, performing a clinical examination, arranging any necessary investigation, implementing a management plan, and providing advice.',
 41.40, false, false, 15,
 '["Health-related issue requiring assessment"]'::jsonb,
 '{"required": ["Reason for attendance", "History", "Examination findings", "Assessment/Diagnosis", "Management plan"], "recommended": ["Vital signs", "Medications reviewed", "Follow-up arranged"], "examples": ["Follow-up for hypertension", "Acute respiratory infection", "Skin lesion assessment"]}'::jsonb,
 '["Billing Level B when consultation was <5 minutes (should use Level A)", "Inadequate documentation"]'::jsonb,
 'low', '2025-11-01', NULL, now(), now()),

(gen_random_uuid(), '36', 'General Practice', 'Vocationally Registered GP',
 'Professional attendance by a VR GP lasting at least 20 minutes for one or more health-related issues, with implementation of a management plan. Level C services involve comprehensive assessment and management requiring significantly more clinical input than a Level B service.',
 80.10, false, false, 25,
 '["Complex health issue requiring extended consultation"]'::jsonb,
 '{"required": ["Duration of consultation (≥20 min)", "Comprehensive history", "Thorough examination", "Complex assessment", "Detailed management plan"], "recommended": ["Time documented", "Multiple issues addressed", "Investigations ordered", "Referrals made"], "examples": ["New patient with multiple chronic conditions", "Complex mental health presentation", "Comprehensive health assessment"]}'::jsonb,
 '["Not documenting duration", "Billing Level C for simple problems", "Time not justified by documentation"]'::jsonb,
 'medium', '2025-11-01', NULL, now(), now()),

(gen_random_uuid(), '44', 'General Practice', 'Vocationally Registered GP',
 'Professional attendance by a VR GP lasting at least 40 minutes for one or more health-related issues, with implementation of a management plan. Level D services involve prolonged and complex assessment requiring significantly more clinical input than a Level C service.',
 117.90, false, false, 45,
 '["Highly complex health issue requiring prolonged consultation"]'::jsonb,
 '{"required": ["Duration documented (≥40 min)", "Extensive history", "Comprehensive examination", "Complex multi-system assessment", "Detailed management plan"], "recommended": ["Multiple problems addressed", "Care coordination", "Written referrals", "Patient education documented"], "examples": ["New patient with complex multimorbidity", "Comprehensive mental health crisis assessment", "Complex chronic disease review"]}'::jsonb,
 '["Duration not documented", "Complexity not justified", "Using for simple problems extended by patient chattiness"]'::jsonb,
 'high', '2025-11-01', NULL, now(), now()),

(gen_random_uuid(), '4', 'General Practice', 'Non-Vocationally Registered GP',
 'Professional attendance (non-VR GP) for an obvious problem characterised by the straightforward nature of the task.',
 16.95, false, false, 10,
 '["Simple presenting problem"]'::jsonb,
 '{"required": ["Presenting complaint", "Assessment", "Plan"], "recommended": [], "examples": []}'::jsonb,
 '[]'::jsonb,
 'low', '2025-11-01', NULL, now(), now()),

(gen_random_uuid(), '24', 'General Practice', 'Non-Vocationally Registered GP',
 'Professional attendance (non-VR GP) lasting less than 20 minutes for one or more health-related issues.',
 37.60, false, false, 15,
 '["Health issue requiring assessment"]'::jsonb,
 '{"required": ["History", "Examination", "Assessment", "Plan"], "recommended": [], "examples": []}'::jsonb,
 '[]'::jsonb,
 'low', '2025-11-01', NULL, now(), now()),

(gen_random_uuid(), '37', 'General Practice', 'Non-Vocationally Registered GP',
 'Professional attendance (non-VR GP) lasting at least 20 minutes for one or more health-related issues.',
 72.10, false, false, 25,
 '["Complex health issue"]'::jsonb,
 '{"required": ["Duration ≥20 min", "Comprehensive assessment", "Detailed plan"], "recommended": [], "examples": []}'::jsonb,
 '[]'::jsonb,
 'medium', '2025-11-01', NULL, now(), now()),

(gen_random_uuid(), '597', 'General Practice', 'Urgent After Hours',
 'Urgent attendance, out of normal hours, at consulting rooms, VR GP, requiring Level C service',
 145.65, false, false, 25,
 '["Urgent after-hours presentation"]'::jsonb,
 '{"required": ["Time of presentation", "Urgency documented", "After-hours justified", "Full Level C documentation"], "recommended": [], "examples": []}'::jsonb,
 '["Not documenting time", "Urgency not justified"]'::jsonb,
 'medium', '2025-11-01', NULL, now(), now()),

-- ---------------------------------------------------------------------------
-- CHRONIC DISEASE MANAGEMENT
-- ---------------------------------------------------------------------------

(gen_random_uuid(), '721', 'Chronic Disease Management', 'GP Management Plans',
 'Preparation of a GP Management Plan (GPMP) for a patient who has at least one chronic or terminal medical condition that has been (or is likely to be) present for at least six months.',
 150.10, false, false, 45,
 '["Chronic condition present ≥6 months", "Patient has complex care needs"]'::jsonb,
 '{"required": ["Identified chronic condition(s)", "Patient''s health care goals", "Treatment and services to be provided", "Actions to be taken by patient", "Arrangements for review", "Copy provided to patient"], "recommended": ["Allied health referrals", "Carer involvement", "Cultural considerations"], "examples": ["Type 2 diabetes with hypertension and obesity", "Chronic heart failure with multiple comorbidities"]}'::jsonb,
 '["Missing patient goals", "Not providing copy to patient", "Reviewing too frequently (<12 months)"]'::jsonb,
 'high', '2025-11-01', NULL, now(), now()),

(gen_random_uuid(), '723', 'Chronic Disease Management', 'Team Care Arrangements',
 'Coordination of Team Care Arrangements (TCA) for a patient with a chronic or terminal condition requiring ongoing care from a multidisciplinary team of at least three health care providers.',
 116.60, false, false, 30,
 '["Chronic condition", "Need for multidisciplinary care", "At least 3 providers identified"]'::jsonb,
 '{"required": ["Treatment goals", "Actions to be taken by providers", "At least 2 collaborating providers identified (3 total including GP)", "Arrangements for review", "Copy to patient and collaborating providers"], "recommended": ["Allied health referrals included"], "examples": ["Diabetes requiring podiatry, dietitian, and optometrist", "Heart failure requiring physio, dietitian, and cardiologist"]}'::jsonb,
 '["Less than 3 providers", "No contact with collaborating providers", "Not sending copies"]'::jsonb,
 'high', '2025-11-01', NULL, now(), now()),

(gen_random_uuid(), '732', 'Chronic Disease Management', 'GPMP/TCA Review',
 'Review of a GP Management Plan or Team Care Arrangements, not being a service associated with a GPMP or TCA within the preceding 3 months.',
 77.20, false, false, 25,
 '["Existing GPMP or TCA", "Review indicated", "≥3 months since last GPMP/TCA/Review"]'::jsonb,
 '{"required": ["Reference to original plan", "Assessment of progress against goals", "Any changes to plan", "Updated goals if required", "Date of original plan and any previous reviews"], "recommended": ["Allied health reports reviewed", "Patient feedback incorporated"], "examples": ["Annual review of diabetes care plan", "Post-hospitalisation GPMP review"]}'::jsonb,
 '["Review within 3 months of GPMP/TCA", "No reference to original plan", "No documented changes or progress"]'::jsonb,
 'medium', '2025-11-01', NULL, now(), now()),

-- ---------------------------------------------------------------------------
-- MENTAL HEALTH
-- ---------------------------------------------------------------------------

(gen_random_uuid(), '2700', 'Mental Health', 'GP Mental Health Treatment',
 'Mental health treatment consultation provided by a GP, with a duration of at least 20 minutes, for a patient with an assessed mental disorder.',
 95.35, false, false, 25,
 '["Assessed mental disorder", "Treatment consultation (not initial assessment)"]'::jsonb,
 '{"required": ["Mental health diagnosis/disorder", "Duration of consultation (≥20 min)", "Treatment provided (psychotherapy/CBT/other)", "Progress assessment", "Safety assessment"], "recommended": ["Mental state examination", "PHQ-9 or K10 scores", "Medication review"], "examples": ["Depression treatment session", "Anxiety management consultation"]}'::jsonb,
 '["No documented mental disorder", "Using for initial assessment", "Duration not documented"]'::jsonb,
 'medium', '2025-11-01', NULL, now(), now()),

(gen_random_uuid(), '2701', 'Mental Health', 'GP Mental Health Treatment',
 'Mental health treatment consultation provided by a GP, with a duration of at least 40 minutes, for a patient with an assessed mental disorder.',
 139.60, false, false, 45,
 '["Assessed mental disorder", "Extended treatment consultation"]'::jsonb,
 '{"required": ["Mental health diagnosis", "Duration (≥40 min)", "Extended therapeutic intervention", "Progress and safety assessment"], "recommended": ["Suicide risk assessment", "Treatment response", "Crisis plan"], "examples": ["Extended CBT session", "Complex trauma-focused therapy"]}'::jsonb,
 '["Duration not met", "Therapeutic intervention not documented"]'::jsonb,
 'high', '2025-11-01', NULL, now(), now()),

(gen_random_uuid(), '2715', 'Mental Health', 'Mental Health Treatment Plan',
 'Preparation of a GP Mental Health Treatment Plan for a patient with an assessed mental disorder.',
 96.55, false, false, 30,
 '["Mental disorder requiring treatment plan", "Access to rebated psychological services"]'::jsonb,
 '{"required": ["Mental health assessment", "Diagnosis documented", "Treatment plan with goals", "Referral to appropriate provider", "Review arrangements", "Copy provided to patient"], "recommended": ["Severity assessment", "Risk assessment", "Support systems identified"], "examples": ["MHTP for depression with referral to psychologist", "Anxiety treatment plan for CBT services"]}'::jsonb,
 '["Missing diagnosis", "No treatment goals", "Not providing copy to patient"]'::jsonb,
 'medium', '2025-11-01', NULL, now(), now()),

(gen_random_uuid(), '2712', 'Mental Health', 'Mental Health Treatment Plan Review',
 'Review of a GP Mental Health Treatment Plan',
 72.25, false, false, 25,
 '["Existing MHTP requiring review"]'::jsonb,
 '{"required": ["Reference to original MHTP", "Progress against goals", "Updated plan if needed", "Review of allied health reports"], "recommended": ["Risk re-assessment", "Medication review"], "examples": ["6-month MHTP review", "Review after completion of psychology sessions"]}'::jsonb,
 '["No original MHTP", "No progress documentation"]'::jsonb,
 'low', '2025-11-01', NULL, now(), now()),

-- ---------------------------------------------------------------------------
-- TELEHEALTH
-- ---------------------------------------------------------------------------

(gen_random_uuid(), '91790', 'Telehealth', 'Video Consultations',
 'Telehealth attendance by video conference - Level B equivalent consultation by a VR GP.',
 41.40, false, false, 15,
 '["Video consultation clinically appropriate", "Patient consent for telehealth"]'::jsonb,
 '{"required": ["Mode: Video consultation documented", "Patient identification verified", "Telehealth consent obtained", "Standard Level B documentation", "Follow-up arrangements"], "recommended": ["Platform used", "Technical issues noted", "In-person follow-up if needed"], "examples": ["Video follow-up for chronic condition", "Initial assessment via telehealth"]}'::jsonb,
 '["Not documenting video modality", "No consent documented", "Using when face-to-face required"]'::jsonb,
 'low', '2025-11-01', NULL, now(), now()),

(gen_random_uuid(), '91800', 'Telehealth', 'Video Consultations',
 'Telehealth attendance by video conference - Level C equivalent consultation (≥20 min) by a VR GP.',
 80.10, false, false, 25,
 '["Complex issue suitable for video", "Extended video consultation"]'::jsonb,
 '{"required": ["Video modality documented", "Duration ≥20 min", "Standard Level C documentation", "Consent"], "recommended": [], "examples": ["Extended mental health video consultation", "Complex diabetes review via video"]}'::jsonb,
 '["Duration not documented", "Complexity not justified for telehealth"]'::jsonb,
 'medium', '2025-11-01', NULL, now(), now()),

(gen_random_uuid(), '91891', 'Telehealth', 'Phone Consultations',
 'Telehealth attendance by phone - Level B equivalent consultation by a VR GP.',
 27.60, false, false, 15,
 '["Phone consultation clinically appropriate", "Video not available/suitable"]'::jsonb,
 '{"required": ["Mode: Phone consultation documented", "Patient identification verified", "Reason video not used (if applicable)", "Standard consultation documentation"], "recommended": ["Follow-up arrangements", "In-person if required"], "examples": ["Phone follow-up for results", "Telephone medication review"]}'::jsonb,
 '["Using phone when video or in-person required", "Not documenting phone modality"]'::jsonb,
 'low', '2025-11-01', NULL, now(), now()),

-- ---------------------------------------------------------------------------
-- SKIN PROCEDURES
-- ---------------------------------------------------------------------------

(gen_random_uuid(), '30071', 'Surgical Procedures', 'Skin Procedures',
 'Punch biopsy of skin, single lesion, for the histological diagnosis where the lesion is not excised.',
 47.25, false, false, 15,
 '["Suspicious lesion requiring histological diagnosis", "Lesion not suitable for excision"]'::jsonb,
 '{"required": ["Clinical indication for biopsy", "Description of lesion (size, location, appearance)", "Punch biopsy size used", "Site documented", "Post-procedure instructions", "Histopathology request sent"], "recommended": ["Photograph of lesion", "Differential diagnosis", "Consent documented"], "examples": ["3mm punch biopsy of 8mm pigmented lesion on right shoulder for melanoma exclusion"]}'::jsonb,
 '["Billing when lesion was excised (use excision item instead)", "Missing lesion description", "No histopathology request documented"]'::jsonb,
 'medium', '2025-11-01', NULL, now(), now()),

(gen_random_uuid(), '30195', 'Surgical Procedures', 'Skin Procedures',
 'Removal of skin lesion, other than malignant, with direct closure, where diameter of lesion plus margin is greater than 20mm.',
 123.65, false, false, 30,
 '["Non-malignant lesion", "Lesion + margin >20mm"]'::jsonb,
 '{"required": ["Clinical diagnosis", "Lesion size documented", "Margin taken", "Total specimen size (>20mm)", "Closure method", "Histopathology sent"], "recommended": ["Photo before/after", "Consent", "Suture type/number"], "examples": ["Excision of 15mm sebaceous cyst with 5mm margins, direct closure"]}'::jsonb,
 '["Total size ≤20mm (use smaller excision item)", "Missing dimensions"]'::jsonb,
 'medium', '2025-11-01', NULL, now(), now()),

(gen_random_uuid(), '30196', 'Surgical Procedures', 'Skin Procedures',
 'Removal of skin lesion, other than malignant, with direct closure, where diameter of lesion plus margin is 20mm or less.',
 86.40, false, false, 20,
 '["Non-malignant lesion", "Lesion + margin ≤20mm"]'::jsonb,
 '{"required": ["Clinical diagnosis", "Lesion size", "Margin", "Total size ≤20mm", "Closure", "Histopathology"], "recommended": ["Photo", "Consent"], "examples": ["Excision of 10mm mole with 3mm margins"]}'::jsonb,
 '["Size >20mm (use 30195 instead)"]'::jsonb,
 'low', '2025-11-01', NULL, now(), now()),

(gen_random_uuid(), '31205', 'Surgical Procedures', 'Malignant Skin Lesions',
 'Excision of malignant skin lesion with direct closure, where lesion plus margin is greater than 20mm.',
 196.80, false, false, 45,
 '["Confirmed or suspected malignancy", "Appropriate surgical margin"]'::jsonb,
 '{"required": ["Pre-operative diagnosis (malignancy confirmed or highly suspected)", "Lesion dimensions", "Surgical margin width", "Total excision size >20mm", "Specimen orientation marked", "Histopathology"], "recommended": ["Clinical photos", "Mapping if multiple lesions", "Consent with margin discussion"], "examples": ["Wide excision of 15mm BCC with 5mm margin, total 25mm"]}'::jsonb,
 '["No malignancy confirmation", "Margins not documented", "Size <20mm"]'::jsonb,
 'high', '2025-11-01', NULL, now(), now()),

(gen_random_uuid(), '30207', 'Surgical Procedures', 'Skin Procedures',
 'Removal of tissue-embedded foreign body, single or multiple, requiring incision and suture.',
 96.05, false, false, 25,
 '["Foreign body requiring surgical removal"]'::jsonb,
 '{"required": ["Nature of foreign body", "Location", "Imaging if used", "Removal method", "Wound closure"], "recommended": ["X-ray/ultrasound results", "Photo of removed object"], "examples": ["Removal of glass fragment from plantar foot under local anaesthetic"]}'::jsonb,
 '[]'::jsonb,
 'low', '2025-11-01', NULL, now(), now()),

-- ---------------------------------------------------------------------------
-- VASCULAR PROCEDURES
-- ---------------------------------------------------------------------------

(gen_random_uuid(), '32520', 'Surgical Procedures', 'Vascular Procedures',
 'Endovenous laser ablation (EVLA) of incompetent saphenous vein (great or small), unilateral, not being a service associated with item 32521.',
 594.40, true, false, 90,
 '["Symptomatic varicose veins with saphenous incompetence", "Duplex ultrasound confirming reflux", "Failed conservative management (compression therapy)"]'::jsonb,
 '{"required": ["Clinical symptoms documented", "Pre-operative duplex findings (reflux >0.5s)", "Failed conservative treatment documented", "Informed consent with risks/benefits", "Procedure details (vein treated, laser settings, length ablated)", "Post-procedure duplex/instructions"], "recommended": ["CEAP classification", "Pre-procedure photos", "Compression therapy duration documented"], "examples": ["EVLA of incompetent GSV from SFJ to knee, 1470nm laser, 80J/cm energy delivery"]}'::jsonb,
 '["Missing pre-operative duplex documentation", "No evidence of failed conservative management", "Bilateral procedure claimed as two unilateral (use 32521 for bilateral)"]'::jsonb,
 'high', '2025-11-01', NULL, now(), now()),

(gen_random_uuid(), '32521', 'Surgical Procedures', 'Vascular Procedures',
 'Endovenous laser ablation (EVLA) of incompetent saphenous vein (great or small), bilateral, on the same day.',
 891.60, true, false, 150,
 '["Bilateral symptomatic saphenous incompetence", "Pre-operative duplex bilateral"]'::jsonb,
 '{"required": ["Bilateral symptoms documented", "Bilateral pre-operative duplex", "Conservative management failed bilaterally", "Bilateral procedure details"], "recommended": ["Bilateral photos", "Staged approach considered/rejected"], "examples": ["Bilateral GSV ablation in single session"]}'::jsonb,
 '["Claiming two 32520 items instead", "One side not documented"]'::jsonb,
 'high', '2025-11-01', NULL, now(), now()),

(gen_random_uuid(), '32523', 'Surgical Procedures', 'Vascular Procedures',
 'Ultrasound guided sclerotherapy to varicose veins, one leg, one or more injections.',
 178.30, false, false, 30,
 '["Varicose veins suitable for sclerotherapy", "Ultrasound guidance required"]'::jsonb,
 '{"required": ["Indication for sclerotherapy", "Veins treated documented", "Sclerosant type and concentration", "Volume injected", "Post-procedure compression instructions"], "recommended": ["Ultrasound images", "Post-procedure ultrasound"], "examples": ["UGS to GSV tributaries with 1% STS"]}'::jsonb,
 '["Not using ultrasound guidance", "Cosmetic veins not covered"]'::jsonb,
 'medium', '2025-11-01', NULL, now(), now()),

-- ---------------------------------------------------------------------------
-- GYNAECOLOGY
-- ---------------------------------------------------------------------------

(gen_random_uuid(), '35500', 'Surgical Procedures', 'Gynaecological Procedures',
 'Insertion of an intrauterine device (IUD), not being a service to which item 35503 applies.',
 86.25, false, false, 20,
 '["Contraception required", "Appropriate candidate for IUD"]'::jsonb,
 '{"required": ["Clinical indication", "Counselling documented (risks, benefits, alternatives)", "Consent obtained", "Type of IUD inserted", "Procedure details", "Post-insertion instructions", "Follow-up arranged"], "recommended": ["Pregnancy test result", "STI screening if indicated"], "examples": ["Mirena IUD insertion for contraception and menorrhagia"]}'::jsonb,
 '["Missing counselling documentation", "No consent documented"]'::jsonb,
 'medium', '2025-11-01', NULL, now(), now()),

(gen_random_uuid(), '35503', 'Surgical Procedures', 'Gynaecological Procedures',
 'Insertion of an intrauterine device (IUD) immediately following a birth or termination of pregnancy.',
 108.00, false, false, 15,
 '["Post-partum or post-termination", "IUD contraception planned"]'::jsonb,
 '{"required": ["Timing (post-partum/post-termination)", "Counselling and consent", "IUD type", "Immediate insertion documented"], "recommended": ["Delivery/termination date"], "examples": ["Immediate post-partum Mirena insertion following vaginal delivery"]}'::jsonb,
 '["Not immediately post-delivery (use 35500 instead)"]'::jsonb,
 'medium', '2025-11-01', NULL, now(), now()),

(gen_random_uuid(), '35506', 'Surgical Procedures', 'Gynaecological Procedures',
 'Removal of an intrauterine device (IUD) where the strings are not visible.',
 145.50, false, false, 30,
 '["IUD removal required", "Strings not visible on speculum examination"]'::jsonb,
 '{"required": ["Indication for removal", "Documented invisible strings", "Retrieval method", "Successful removal confirmed"], "recommended": ["Ultrasound if location uncertain", "Histology if tissue removed"], "examples": ["IUD retrieval with alligator forceps - strings not visible"]}'::jsonb,
 '["Using when strings are visible (use other item)"]'::jsonb,
 'low', '2025-11-01', NULL, now(), now()),

(gen_random_uuid(), '35507', 'Surgical Procedures', 'Gynaecological Procedures',
 'Insertion of a hormonal implant for contraception.',
 51.40, false, false, 15,
 '["Contraception required", "Suitable for implant"]'::jsonb,
 '{"required": ["Counselling documented", "Consent", "Insertion site", "Implant details", "Follow-up"], "recommended": ["Pregnancy test"], "examples": ["Implanon NXT insertion in non-dominant arm"]}'::jsonb,
 '["Missing counselling documentation"]'::jsonb,
 'low', '2025-11-01', NULL, now(), now()),

-- ---------------------------------------------------------------------------
-- ORTHOPAEDIC / MUSCULOSKELETAL
-- ---------------------------------------------------------------------------

(gen_random_uuid(), '50124', 'Surgical Procedures', 'Orthopaedic Procedures',
 'Injection of a therapeutic substance into a bursa, cyst, ganglion, or tendon sheath, not being a service to which another item applies.',
 48.70, false, false, 15,
 '["Inflammatory/degenerative condition", "Therapeutic injection indicated"]'::jsonb,
 '{"required": ["Clinical diagnosis", "Site of injection", "Therapeutic substance and dose", "Technique (landmark/ultrasound guided)", "Post-procedure instructions"], "recommended": ["Response to previous injections", "Imaging if available"], "examples": ["Corticosteroid injection to trochanteric bursa for bursitis", "Trigger finger injection to A1 pulley"]}'::jsonb,
 '["Wrong site documented", "Missing diagnosis"]'::jsonb,
 'low', '2025-11-01', NULL, now(), now()),

(gen_random_uuid(), '50101', 'Surgical Procedures', 'Orthopaedic Procedures',
 'Injection of a therapeutic substance into one or more joints, including aspiration, not being a service associated with other joint procedures.',
 56.90, false, false, 15,
 '["Joint pathology", "Therapeutic injection indicated"]'::jsonb,
 '{"required": ["Joint(s) treated", "Clinical indication", "Aspiration performed (if applicable)", "Substance injected with dose", "Technique used"], "recommended": ["Aspirate appearance", "Volume aspirated", "Imaging guidance"], "examples": ["Knee joint injection with 40mg Kenacort for osteoarthritis"]}'::jsonb,
 '["Multiple joints billed separately when done in one attendance"]'::jsonb,
 'low', '2025-11-01', NULL, now(), now()),

-- ---------------------------------------------------------------------------
-- OPHTHALMOLOGY
-- ---------------------------------------------------------------------------

(gen_random_uuid(), '10900', 'Ophthalmology', 'Eye Examinations',
 'Comprehensive eye examination by an ophthalmologist, including appropriate examination techniques.',
 88.75, false, false, 30,
 '["Eye condition requiring specialist assessment"]'::jsonb,
 '{"required": ["Visual acuity", "Slit lamp examination", "Fundoscopy/ophthalmoscopy", "Intraocular pressure", "Diagnosis and management plan"], "recommended": ["Visual fields if indicated", "OCT if available", "Colour vision"], "examples": ["Comprehensive assessment for suspected glaucoma"]}'::jsonb,
 '["Incomplete examination documented"]'::jsonb,
 'low', '2025-11-01', NULL, now(), now()),

(gen_random_uuid(), '42740', 'Ophthalmology', 'Intravitreal Procedures',
 'Intravitreal injection of a therapeutic substance, one or both eyes, on one occasion.',
 195.65, false, false, 20,
 '["AMD, diabetic macular oedema, or other approved indication"]'::jsonb,
 '{"required": ["Diagnosis requiring intravitreal therapy", "Drug injected", "Eye(s) treated", "Sterile technique documented", "Post-procedure IOP check", "Follow-up arranged"], "recommended": ["OCT findings", "Visual acuity pre/post"], "examples": ["Intravitreal Eylea for wet AMD right eye"]}'::jsonb,
 '["Missing sterile technique documentation", "Off-label use not justified"]'::jsonb,
 'medium', '2025-11-01', NULL, now(), now()),

-- ---------------------------------------------------------------------------
-- CARDIOLOGY / ECG
-- ---------------------------------------------------------------------------

(gen_random_uuid(), '11700', 'Cardiology', 'ECG Services',
 'Electrocardiography, reporting of 12 lead electrocardiogram with report.',
 17.70, false, false, 10,
 '["Cardiac symptoms or risk factors"]'::jsonb,
 '{"required": ["Indication for ECG", "12-lead ECG performed", "Interpretation documented", "Clinical correlation"], "recommended": ["Comparison with previous ECG", "Rhythm strip interpretation"], "examples": ["12-lead ECG for chest pain - normal sinus rhythm, no ischaemic changes"]}'::jsonb,
 '["No interpretation provided", "Missing clinical indication"]'::jsonb,
 'low', '2025-11-01', NULL, now(), now()),

(gen_random_uuid(), '11701', 'Cardiology', 'ECG Services',
 'Electrocardiography, recording of 12 lead electrocardiogram, not being a service to which item 11707 applies.',
 12.50, false, false, 5,
 '["Recording for interpretation by another provider"]'::jsonb,
 '{"required": ["ECG recorded", "Sent for interpretation"], "recommended": [], "examples": ["ECG recording for cardiologist interpretation"]}'::jsonb,
 '["Claiming both recording and interpretation"]'::jsonb,
 'low', '2025-11-01', NULL, now(), now()),

(gen_random_uuid(), '11707', 'Cardiology', 'ECG Services',
 'Electrocardiography, recording and reporting of a 12 lead electrocardiogram, by a medical practitioner who personally performs and reports the ECG.',
 30.20, false, false, 10,
 '["Cardiac assessment"]'::jsonb,
 '{"required": ["ECG personally performed", "ECG personally reported", "Full interpretation in notes"], "recommended": [], "examples": ["ECG performed and interpreted in-house for atrial fibrillation assessment"]}'::jsonb,
 '["Not personally performing the ECG", "Claiming with 11700 or 11701"]'::jsonb,
 'low', '2025-11-01', NULL, now(), now()),

-- ---------------------------------------------------------------------------
-- RESPIRATORY / SPIROMETRY
-- ---------------------------------------------------------------------------

(gen_random_uuid(), '11506', 'Respiratory', 'Spirometry',
 'Spirometry, before and after administration of bronchodilator, with report.',
 48.45, false, false, 20,
 '["Respiratory symptoms", "Diagnosis or monitoring of lung disease"]'::jsonb,
 '{"required": ["Indication for spirometry", "Pre-bronchodilator results (FEV1, FVC, ratio)", "Bronchodilator given (type, dose)", "Post-bronchodilator results", "Interpretation with clinical correlation"], "recommended": ["Comparison with previous tests", "Quality criteria met"], "examples": ["Spirometry showing obstructive pattern with significant reversibility - COPD with bronchodilator response"]}'::jsonb,
 '["Missing post-bronchodilator results", "No interpretation"]'::jsonb,
 'low', '2025-11-01', NULL, now(), now()),

(gen_random_uuid(), '11509', 'Respiratory', 'Spirometry',
 'Spirometry without bronchodilator, including report.',
 35.25, false, false, 15,
 '["Screening or monitoring when bronchodilator testing not required"]'::jsonb,
 '{"required": ["Indication", "FEV1, FVC, ratio", "Interpretation"], "recommended": ["Comparison with predicted values"], "examples": ["Pre-operative spirometry screening"]}'::jsonb,
 '["Should have done bronchodilator testing for diagnosis"]'::jsonb,
 'low', '2025-11-01', NULL, now(), now()),

-- ---------------------------------------------------------------------------
-- AGED CARE
-- ---------------------------------------------------------------------------

(gen_random_uuid(), '90020', 'Aged Care', 'RACF Attendances',
 'Professional attendance at a residential aged care facility (RACF) by a VR GP - Level B equivalent.',
 54.90, false, false, 15,
 '["RACF resident requiring medical review"]'::jsonb,
 '{"required": ["Facility name documented", "Reason for attendance", "History and examination", "Assessment", "Management plan", "Communication with nursing staff"], "recommended": ["Medication review", "Advance care planning status"], "examples": ["RACF review for urinary symptoms - UTI diagnosed"]}'::jsonb,
 '["Not a RACF (use standard item)", "Missing facility documentation"]'::jsonb,
 'low', '2025-11-01', NULL, now(), now()),

(gen_random_uuid(), '90035', 'Aged Care', 'RACF Attendances',
 'Professional attendance at a RACF by a VR GP - Level D equivalent (≥40 minutes).',
 153.80, false, false, 45,
 '["Complex RACF resident", "Extended consultation required"]'::jsonb,
 '{"required": ["Duration ≥40 min documented", "Facility name", "Complex assessment documented", "Comprehensive management plan", "Multidisciplinary communication"], "recommended": ["Family conference if conducted", "ACP discussion", "Medication reconciliation"], "examples": ["Complex end-of-life care planning discussion with resident and family"]}'::jsonb,
 '["Duration not documented", "Complexity not justified"]'::jsonb,
 'medium', '2025-11-01', NULL, now(), now()),

-- ---------------------------------------------------------------------------
-- HEALTH ASSESSMENTS
-- ---------------------------------------------------------------------------

(gen_random_uuid(), '701', 'Health Assessments', '45-49 Years Health Assessment',
 'Brief health assessment for a person aged 45 to 49 years who is at risk of developing chronic disease.',
 59.00, false, false, 25,
 '["Age 45-49", "At risk of chronic disease (Aboriginal/Torres Strait Islander, or with risk factors)"]'::jsonb,
 '{"required": ["Age confirmed 45-49", "Risk factor documented", "Cardiovascular risk assessment", "Lifestyle assessment", "Results communicated to patient", "Follow-up plan"], "recommended": ["Absolute CVD risk calculated", "Diabetes screening", "Lifestyle advice"], "examples": ["Health assessment for 47yo with family history diabetes and hypertension"]}'::jsonb,
 '["Age outside 45-49 range", "Risk factor not documented"]'::jsonb,
 'low', '2025-11-01', NULL, now(), now()),

(gen_random_uuid(), '703', 'Health Assessments', '75+ Health Assessment',
 'Health assessment for a person 75 years or older, including assessment of patient''s health, physical function, and psychosocial function.',
 239.75, false, false, 60,
 '["Age 75+", "Annual health assessment"]'::jsonb,
 '{"required": ["Comprehensive assessment documented", "Physical function assessment", "Psychosocial function assessment", "Medication review", "Immunisation status", "Care plan developed with patient"], "recommended": ["Falls risk assessment", "Cognition screening", "Social supports reviewed"], "examples": ["Annual 75+ health assessment for 78yo - falls risk identified, medication changes made"]}'::jsonb,
 '["Not comprehensive enough", "Within 12 months of previous 703"]'::jsonb,
 'medium', '2025-11-01', NULL, now(), now()),

-- ---------------------------------------------------------------------------
-- MISCELLANEOUS PROCEDURES
-- ---------------------------------------------------------------------------

(gen_random_uuid(), '14206', 'Therapeutic Procedures', 'Iron Infusions',
 'Intravenous infusion of iron, including any attendance on the patient, for iron deficiency anaemia where oral iron has been unsuccessful or unsuitable.',
 63.45, false, false, 60,
 '["Iron deficiency anaemia confirmed", "Oral iron failed or contraindicated"]'::jsonb,
 '{"required": ["Iron deficiency anaemia confirmed (ferritin, iron studies)", "Reason oral iron not suitable", "Iron formulation and dose", "Monitoring during infusion", "Observation period completed"], "recommended": ["Pre-infusion weight", "Test dose if applicable", "Follow-up bloods arranged"], "examples": ["Ferinject 1000mg infusion for iron deficiency anaemia, oral iron intolerant"]}'::jsonb,
 '["No evidence of failed oral iron", "Iron studies not confirming deficiency"]'::jsonb,
 'medium', '2025-11-01', NULL, now(), now()),

(gen_random_uuid(), '30229', 'Surgical Procedures', 'Wound Management',
 'Debridement of wound, burn, or ulcer (including application of medication/preparation when carried out at the same attendance).',
 47.25, false, false, 20,
 '["Wound, burn or ulcer requiring debridement"]'::jsonb,
 '{"required": ["Wound type and location", "Indication for debridement", "Debridement technique", "Wound description post-debridement", "Dressing applied"], "recommended": ["Wound measurements", "Photo documentation"], "examples": ["Sharp debridement of sloughy venous ulcer, Aquacel dressing applied"]}'::jsonb,
 '["Debridement not clearly documented"]'::jsonb,
 'low', '2025-11-01', NULL, now(), now())

ON CONFLICT (item_number) DO UPDATE SET
  category                    = EXCLUDED.category,
  subcategory                 = EXCLUDED.subcategory,
  description                 = EXCLUDED.description,
  schedule_fee                = EXCLUDED.schedule_fee,
  requires_anaesthetic        = EXCLUDED.requires_anaesthetic,
  requires_assistant          = EXCLUDED.requires_assistant,
  time_estimate_minutes       = EXCLUDED.time_estimate_minutes,
  clinical_indication_required = EXCLUDED.clinical_indication_required,
  documentation_requirements  = EXCLUDED.documentation_requirements,
  common_errors               = EXCLUDED.common_errors,
  psr_risk_level              = EXCLUDED.psr_risk_level,
  effective_from              = EXCLUDED.effective_from,
  effective_to                = EXCLUDED.effective_to,
  updated_at                  = now();


-- ============================================================================
-- SECTION 2: PSR CASES (21 verified cases)
-- Source: PSR Director's Updates 2023-2025 (psr.gov.au)
-- ============================================================================

INSERT INTO psr_cases (
  id, case_reference, practitioner_type, item_numbers_involved,
  issue_description, what_went_wrong, financial_penalty, repayment_amount,
  other_sanctions, lessons_learned, recommendations,
  publication_date, source_url, severity_level, created_at, updated_at
) VALUES

-- ---------------------------------------------------------------------------
-- NOVEMBER 2025 CASES
-- ---------------------------------------------------------------------------

(gen_random_uuid(), 'PSR-2025-NOV-001', 'Psychiatrist',
 '["304", "348", "350"]'::jsonb,
 'Minimum time requirements not met for MBS item 304, 348 and 350 services. Person interviewed not always identified in records. Records did not reflect that interview was used to determine presenting problem focus.',
 'Practitioner failed to meet minimum time requirements for psychiatric consultation items, did not identify persons interviewed, and maintained inadequate records without separate entries for each attendance. Services were rendered more than a month after initial consultation without documented justification.',
 225000, 225000,
 '["Reprimanded by the Director", "Disqualified from providing MBS item 343, 345, 347, 349, 91875, 91876, 91877, 91878, 91883 and 91884 services for 12 months"]'::jsonb,
 '["For psychiatric consultation items, always identify the person interviewed", "Ensure the interview is used for its intended diagnostic purpose", "Maintain separate contemporaneous records for each attendance", "Meet minimum time requirements and document duration"]'::jsonb,
 '["Document identity of every person interviewed", "Maintain separate clinical entry for each attendance", "Time-stamp all entries", "Ensure services are rendered within appropriate diagnostic evaluation window"]'::jsonb,
 '2025-11-01', 'https://www.psr.gov.au/case-outcomes/psr-directors-update-november-2025',
 'critical', now(), now()),

(gen_random_uuid(), 'PSR-2025-NOV-002', 'General Practitioner',
 '["36", "707", "721", "723", "732", "2713", "11610", "11707"]'::jsonb,
 'MBS requirements not always met including minimum time requirements. Some patients not eligible for MBS item 707 health assessment services. Documentation for 707, 721, 723, 732 not comprehensive. No clear indication for diagnostic investigations.',
 'Copy-paste documentation without personalisation across multiple patients. CDM plans lacked meaningful practitioner input. Health assessments billed for ineligible patients. Diagnostic tests ordered without documented clinical indication.',
 230000, 230000,
 '["Reprimanded by Associate Director", "Counselled by Associate Director", "Disqualified from providing MBS item 2713 services for 12 months"]'::jsonb,
 '["CDM plans must be comprehensive and demonstrate meaningful practitioner input", "Copy-paste documentation is a red flag for PSR review", "Verify patient eligibility before billing health assessments", "Document clinical indication for all diagnostic investigations"]'::jsonb,
 '["Individualise every clinical record", "Verify eligibility criteria before billing", "Document clinical reasoning for all investigations", "Review CDM documentation against MBS requirements"]'::jsonb,
 '2025-11-01', 'https://www.psr.gov.au/case-outcomes/psr-directors-update-november-2025',
 'critical', now(), now()),

(gen_random_uuid(), 'PSR-2025-NOV-003', 'General Practitioner',
 '["743", "30192", "90035", "91891"]'::jsonb,
 'MBS requirements not always met - records lacked sufficient details. Prescribing and clinical management inappropriate - indication/monitoring unclear. Significant non-contemporaneous entries made up to years after service date.',
 'Non-contemporaneous record entries were made years after services were provided. Clinical records lacked sufficient detail to support billing. PBS prescribing occurred without documented indication or adequate monitoring.',
 236327, 236327,
 '["Reprimanded by Associate Director", "Counselled by Associate Director", "Disqualified from providing MBS item 743 services for 24 months and MBS item 91891 and 30192 services for 12 months"]'::jsonb,
 '["Non-contemporaneous record entries are a major red flag", "All clinical notes must be made at the time of service", "Document prescribing indication and monitoring plan for all PBS items"]'::jsonb,
 '["Complete clinical notes at time of service", "Never backdate or retrospectively create records", "Document prescribing indication for every PBS item", "Establish monitoring protocols for ongoing prescriptions"]'::jsonb,
 '2025-11-01', 'https://www.psr.gov.au/case-outcomes/psr-directors-update-november-2025',
 'critical', now(), now()),

(gen_random_uuid(), 'PSR-2025-NOV-004', 'Diagnostic Radiologist',
 '["104", "105", "18222", "57341"]'::jsonb,
 'No separate consultation performed when billing MBS 104/105 co-billed with imaging. No valid referral for separate consultation. MBS 18222 used for local anaesthetic instead of continuous infusion/regional anaesthesia.',
 'Consultation items (104/105) were co-billed with imaging procedures without performing a separate consultation or having a valid separate referral. Item 18222 was incorrectly used for local anaesthetic administration instead of its intended purpose of continuous infusion or regional anaesthesia.',
 59000, 59000,
 '["Counselled by Director"]'::jsonb,
 '["Consultation items 104/105 require a separate valid referral when co-billed with procedures", "Item 18222 is specifically for continuous infusion, not local anaesthetic administration", "Understand item descriptors before billing"]'::jsonb,
 '["Verify separate referral exists before co-billing consultations", "Review MBS item descriptors carefully", "Do not use procedure items outside their defined scope"]'::jsonb,
 '2025-11-01', 'https://www.psr.gov.au/case-outcomes/psr-directors-update-november-2025',
 'medium', now(), now()),

(gen_random_uuid(), 'PSR-2025-NOV-005', 'Diagnostic Radiologist and Nuclear Medicine Specialist',
 '["56623", "56801", "56807"]'::jsonb,
 'CT services rendered when not always clinically indicated. Requests were not always for diagnostic computed tomography. Patients exposed to additional radiation doses unnecessarily.',
 'CT scans were performed without adequate clinical indication, exposing patients to unnecessary radiation. Requests did not always specify diagnostic CT, raising questions about clinical justification for the imaging performed.',
 420000, 420000,
 '["Counselled by Director"]'::jsonb,
 '["CT scans must be clinically indicated and specifically requested", "Unnecessary radiation exposure is both a safety and compliance issue", "Radiologists have a duty to question inappropriate imaging requests"]'::jsonb,
 '["Verify clinical indication before performing CT", "Document justification for radiation exposure", "Question and reject inappropriate imaging requests", "Follow ARPANSA radiation protection guidelines"]'::jsonb,
 '2025-11-01', 'https://www.psr.gov.au/case-outcomes/psr-directors-update-november-2025',
 'high', now(), now()),

(gen_random_uuid(), 'PSR-2025-NOV-006', 'General Practitioner',
 '["721", "723", "732", "91891"]'::jsonb,
 'MBS requirements not always met including minimum time requirements. No record of attendance or engagement with patient for phone services. CDM documentation lacked comprehensive plans. No demonstrated collaboration with other health providers.',
 'Systemic failures across CDM documentation and phone consultation records. Illegible handwritten notes and digital entries lacking clinical information. No evidence of multidisciplinary collaboration for Team Care Arrangements. Phone consultations had no documented patient engagement.',
 220000, 220000,
 '["Reprimanded by Associate Director", "Fully disqualified from providing any MBS item services for a period of 36 months"]'::jsonb,
 '["Full disqualification can result from systemic failures in CDM documentation", "Phone consultations require same documentation standards as in-person", "TCA requires documented evidence of multidisciplinary collaboration", "Illegible notes are as problematic as missing notes"]'::jsonb,
 '["Maintain legible, comprehensive clinical records", "Document patient engagement for every phone consultation", "Evidence multidisciplinary collaboration for TCA", "Use digital records with structured templates"]'::jsonb,
 '2025-11-01', 'https://www.psr.gov.au/case-outcomes/psr-directors-update-november-2025',
 'critical', now(), now()),

(gen_random_uuid(), 'PSR-2025-NOV-007', 'Obstetrician-Gynaecologist',
 '["104", "35503", "55278", "55700"]'::jsonb,
 'Not always a valid referral for consultation (MBS 104). MBS item 55278 duplex scanning services not clinically indicated. 55278 services not specifically requested.',
 'Duplex scanning (55278) was performed without clinical indication and without being specifically requested. Consultation items were billed without valid separate referrals. The practitioner was cleared on items 35503 and 55700.',
 320000, 320000,
 '["Counselled by Director"]'::jsonb,
 '["Duplex scanning must be clinically indicated AND specifically requested", "Co-billing consultations requires valid separate referral", "Investigations must be clinically justified, not routine"]'::jsonb,
 '["Ensure valid referral for every consultation billed", "Document clinical indication for all imaging", "Only perform investigations when clinically indicated", "Maintain clear documentation of request source"]'::jsonb,
 '2025-11-01', 'https://www.psr.gov.au/case-outcomes/psr-directors-update-november-2025',
 'high', now(), now()),

(gen_random_uuid(), 'PSR-2025-NOV-008', 'General Practitioner',
 '["91890", "91891"]'::jsonb,
 'Rendered 30+ phone services on 50 days in review period (prescribed pattern). Insufficient clinical management before prescribing PBS items. Record-keeping inadequate for MBS item 91891 services.',
 'Prescribed pattern of services triggered review: 30+ phone consultations on 50 separate days. PBS items were prescribed via phone without sufficient clinical management or documented assessment. Clinical records for phone consultations were inadequate.',
 10000, 10000,
 '["Reprimanded by Associate Director"]'::jsonb,
 '["Prescribed pattern of services (30+ phone consultations on 20+ days) triggers automatic review", "Phone prescribing requires documented clinical assessment", "Telehealth records must meet same standards as in-person"]'::jsonb,
 '["Monitor your own billing patterns for prescribed pattern thresholds", "Document full clinical assessment for phone prescriptions", "Maintain comprehensive records for all telehealth services"]'::jsonb,
 '2025-11-01', 'https://www.psr.gov.au/case-outcomes/psr-directors-update-november-2025',
 'medium', now(), now()),

(gen_random_uuid(), 'PSR-2025-NOV-009', 'Physician (General Medicine)',
 '["132", "133", "161", "162", "834"]'::jsonb,
 'Patients did not always have 2 morbidities as required for items 132/133. Not clear practitioner personally attended for required time. Patient not always in imminent danger for items 161/162. Discharge case conferences not documented.',
 'Physician consultation items were billed without documented multiple morbidities. Items 161/162 (imminent danger of death) were used without clear documentation of patient status. Personal attendance time was not evidenced. Case conferences (834) were billed without documentation of occurrence.',
 131500, 131500,
 '["Counselled by Director"]'::jsonb,
 '["Items 161/162 require clear documentation of imminent danger and personal attendance time", "Physician consultation items require documented multiple morbidities", "Case conferences must be documented as actually occurring"]'::jsonb,
 '["Document multiple morbidities for physician consultation items", "Record personal attendance time clearly", "Only use emergency items when criteria genuinely met", "Document case conferences with attendees and outcomes"]'::jsonb,
 '2025-11-01', 'https://www.psr.gov.au/case-outcomes/psr-directors-update-november-2025',
 'high', now(), now()),

(gen_random_uuid(), 'PSR-2025-NOV-010', 'Medical Practitioner',
 '["23", "36", "91891"]'::jsonb,
 'Rendered 80+ attendance services on 30 days (prescribed pattern of services). MBS requirements for item 36 and 91891 not always met. Minimum time requirements not met. Multiple services near identical across patient records.',
 'Prescribed pattern of 80+ attendances on 30 days triggered review. Consultation records were near-identical across patients (copy-paste). Minimum time requirements for Level C consultations were not met. Insufficient clinical information and clinically relevant tasks were not undertaken.',
 340000, 340000,
 '["Reprimanded by Director", "Counselled by Director", "Disqualified from providing MBS item 91891 services for 12 months"]'::jsonb,
 '["80+ attendances on 20+ days triggers prescribed pattern review", "Each consultation must be individually documented with unique clinical content", "Near-identical records are strong evidence of inappropriate practice"]'::jsonb,
 '["Individualise every consultation record", "Monitor daily attendance numbers", "Ensure each record reflects the unique clinical encounter", "Do not use templates without substantial personalisation"]'::jsonb,
 '2025-11-01', 'https://www.psr.gov.au/case-outcomes/psr-directors-update-november-2025',
 'critical', now(), now()),

(gen_random_uuid(), 'PSR-2025-NOV-011', 'Medical Practitioner',
 '["5040", "91801", "91891"]'::jsonb,
 'Rendered 30+ phone services on 43 days (prescribed pattern). MBS requirements not always met including minimum time. Clinical management not always appropriate. Prescribing in some services not indicated.',
 'Prescribed pattern of 30+ phone services on 43 days. After-hours items (5040) and telehealth items were billed without meeting documentation standards. Some consultation entries could not be located at all. Prescribing occurred without documented clinical indication.',
 262500, 262500,
 '["Counselled by Director", "Disqualified from providing MBS item 91891 services for 12 months"]'::jsonb,
 '["After-hours items (5040) and telehealth items require same documentation standards as in-person", "Missing records are as concerning as inadequate records", "Maintain retrievable records for every service billed"]'::jsonb,
 '["Apply same documentation standards to all service types", "Ensure records are retrievable and complete", "Document clinical indication for all prescriptions", "Monitor phone consultation volumes"]'::jsonb,
 '2025-11-01', 'https://www.psr.gov.au/case-outcomes/psr-directors-update-november-2025',
 'critical', now(), now()),

(gen_random_uuid(), 'PSR-2025-NOV-COMMITTEE-1557', 'Medical Practitioner',
 '["44", "591", "599", "5040"]'::jsonb,
 'Committee determination: MBS 44 not an in-rooms consultation, minimum 40 min not met. MBS 5040 services not in after-hours period, minimum time not met. MBS 591 patient not urgent. MBS 599 services not in unsociable hours. Prescribing contrary to PBS requirements.',
 'PSR Committee found systematic inappropriate billing of after-hours and urgent items. Level D consultations were not conducted in-rooms and did not meet 40-minute minimum. After-hours items were billed during normal hours. Urgent items were used for non-urgent presentations. Medical records lacked history, examination findings, and clinical reasoning.',
 230000, 230000,
 '["Reprimanded", "Fully disqualified from rendering MBS item services for a period of 3 years"]'::jsonb,
 '["Committee determinations result in the most severe penalties", "3-year full disqualification for systematic non-compliance", "After-hours and urgent items have strict timing and acuity requirements", "Complete medical records are fundamental to clinical practice"]'::jsonb,
 '["Never bill after-hours items during normal hours", "Only use urgent items for genuinely urgent presentations", "Maintain complete medical records for every attendance", "Understand that committee determinations carry maximum penalties"]'::jsonb,
 '2025-11-14', 'https://www.psr.gov.au/case-outcomes/psr-directors-update-november-2025',
 'critical', now(), now()),

-- ---------------------------------------------------------------------------
-- SEPTEMBER 2025 CASES
-- ---------------------------------------------------------------------------

(gen_random_uuid(), 'PSR-2025-SEP-001', 'General Practitioner',
 '["23", "36", "721", "723", "732", "92024", "92025"]'::jsonb,
 'MBS requirements not always met. CDM plans did not demonstrate meaningful clinical engagement. Review consultations lacked substantive clinical content.',
 'CDM items were billed with template-based plans that lacked meaningful clinical engagement. Review consultations did not contain substantive clinical content demonstrating genuine patient reassessment.',
 185000, 185000,
 '["Counselled by Director", "Disqualified from 721, 723, 732 for 12 months"]'::jsonb,
 '["CDM items require documented meaningful clinical engagement - not just template completion", "Reviews must demonstrate genuine reassessment of patient progress"]'::jsonb,
 '["Personalise every CDM plan with patient-specific goals", "Document meaningful clinical engagement in every review", "Move beyond template completion to genuine care planning"]'::jsonb,
 '2025-09-01', 'https://www.psr.gov.au/case-outcomes/psr-directors-update-september-2025',
 'high', now(), now()),

(gen_random_uuid(), 'PSR-2025-SEP-002', 'Vascular Surgeon',
 '["32500", "32504", "32508", "32511", "32520"]'::jsonb,
 'Pre-operative duplex ultrasound findings not documented. Venous reflux measurements not recorded before EVLA procedures. Clinical indication for procedure not adequately documented.',
 'EVLA procedures were performed without documented pre-operative duplex ultrasound findings. Venous reflux measurements (required to be >0.5 seconds) were not recorded. The clinical indication for vascular procedures was not adequately documented to support MBS billing.',
 175000, 175000,
 '["Counselled by Director"]'::jsonb,
 '["EVLA procedures (32500-32520) require documented pre-operative duplex ultrasound", "Reflux measurements >0.5 seconds must be recorded", "Clinical indication must be clearly documented before any vascular procedure"]'::jsonb,
 '["Always document pre-operative duplex with reflux duration", "Record CEAP classification", "Document failed conservative management", "Maintain photographic evidence where possible"]'::jsonb,
 '2025-09-01', 'https://www.psr.gov.au/case-outcomes/psr-directors-update-september-2025',
 'high', now(), now()),

-- ---------------------------------------------------------------------------
-- JULY 2025 CASES
-- ---------------------------------------------------------------------------

(gen_random_uuid(), 'PSR-2025-JUL-001', 'Dermatologist',
 '["23", "104", "30071", "31205", "31210"]'::jsonb,
 'Skin lesion excisions billed without documented histopathology correlation. Clinical indication for procedures not documented. Follow-up care not documented.',
 'Skin procedures were billed without documenting pre-procedure lesion details (size, location, clinical indication). Histopathology results were not correlated with clinical diagnosis. Follow-up care after skin procedures was not documented.',
 145000, 145000,
 '["Counselled by Director"]'::jsonb,
 '["Skin lesion procedures require pre-procedure documentation including size, location, clinical indication", "Post-procedure histopathology correlation is essential", "Follow-up care must be documented"]'::jsonb,
 '["Document lesion size, location, and clinical indication before every procedure", "Correlate histopathology results in follow-up notes", "Schedule and document follow-up appointments", "Photograph lesions before excision"]'::jsonb,
 '2025-07-01', 'https://www.psr.gov.au/case-outcomes/psr-directors-update-july-2025',
 'high', now(), now()),

(gen_random_uuid(), 'PSR-2025-JUL-002', 'General Practitioner',
 '["2700", "2701", "2715", "2717"]'::jsonb,
 'Mental health treatment plans did not meet MBS requirements. Plans lacked comprehensive assessment. No documented review of outcomes. Treatment plans not prepared in collaboration with patient.',
 'Mental health treatment plans were prepared without comprehensive assessment and without documented patient collaboration. Treatment outcomes were not reviewed or documented. Plans did not meet the MBS requirements for structured assessment and goal-setting.',
 95000, 95000,
 '["Reprimanded by Director", "Disqualified from 2700, 2701 items for 6 months"]'::jsonb,
 '["Mental health treatment plans must include comprehensive assessment", "Patient collaboration in plan development must be documented", "Outcome reviews are mandatory for ongoing mental health treatment"]'::jsonb,
 '["Complete structured mental health assessment for every MHTP", "Document patient involvement in treatment planning", "Review and document treatment outcomes at each follow-up", "Use validated assessment tools (PHQ-9, K10) for objective measurement"]'::jsonb,
 '2025-07-01', 'https://www.psr.gov.au/case-outcomes/psr-directors-update-july-2025',
 'high', now(), now()),

-- ---------------------------------------------------------------------------
-- APRIL 2025 CASES
-- ---------------------------------------------------------------------------

(gen_random_uuid(), 'PSR-2025-APR-001', 'Ophthalmologist',
 '["42740", "42738", "42746"]'::jsonb,
 'Intravitreal injections billed without documented clinical indication. OCT scans not documented to support treatment decisions. Follow-up intervals not appropriate.',
 'Intravitreal injection procedures were billed without documented OCT findings supporting clinical indication. Treatment decisions were not supported by imaging evidence. Follow-up intervals between injections were not clinically appropriate.',
 280000, 280000,
 '["Counselled by Director"]'::jsonb,
 '["Intravitreal injections require documented OCT findings supporting clinical indication", "Appropriate follow-up scheduling is part of compliant practice", "Treatment decisions must be supported by objective imaging evidence"]'::jsonb,
 '["Document OCT findings before every intravitreal injection decision", "Record visual acuity pre and post procedure", "Follow evidence-based treatment intervals", "Maintain imaging records supporting treatment decisions"]'::jsonb,
 '2025-04-01', 'https://www.psr.gov.au/case-outcomes/psr-directors-update-april-2025',
 'high', now(), now()),

-- ---------------------------------------------------------------------------
-- DECEMBER 2024 CASES
-- ---------------------------------------------------------------------------

(gen_random_uuid(), 'PSR-2024-DEC-001', 'General Practitioner',
 '["36", "2713", "2715", "721", "723"]'::jsonb,
 'Mental health items billed without appropriate assessment. CDM items billed without patient engagement. Minimum time requirements not met.',
 'Mental health consultations (2713, 2715) were billed without documented structured assessment. CDM items were billed without evidence of patient engagement in care planning. Minimum time requirements for Level C consultations and mental health items were not met.',
 165000, 165000,
 '["Reprimanded", "Disqualified from 2713, 2715 for 12 months"]'::jsonb,
 '["Mental health consultations require documented structured assessment", "CDM items cannot be combined with mental health items without meeting separate requirements for each", "Time-based items require documented duration"]'::jsonb,
 '["Document structured assessment for every mental health consultation", "Ensure patient engagement is evidenced in CDM plans", "Record consultation duration for all time-based items", "Understand co-billing rules between CDM and mental health items"]'::jsonb,
 '2024-12-01', 'https://www.psr.gov.au/case-outcomes/psr-directors-update-december-2024',
 'high', now(), now()),

(gen_random_uuid(), 'PSR-2024-DEC-002', 'Orthopaedic Surgeon',
 '["49318", "49324", "50124"]'::jsonb,
 'Joint injections billed without documented clinical indication. No imaging correlation for injection procedures. Multiple injections same joint same day.',
 'Joint injection procedures were billed without documented clinical indication or imaging correlation. Multiple injections to the same joint on the same day were billed inappropriately. The lack of imaging evidence made it impossible to verify clinical necessity.',
 98000, 98000,
 '["Counselled"]'::jsonb,
 '["Joint injections require documented clinical indication and imaging correlation where appropriate", "Multiple injections to the same joint on the same day cannot be inappropriately duplicated"]'::jsonb,
 '["Document clinical indication for every injection procedure", "Correlate with imaging where available", "Do not duplicate injection billing for the same joint", "Consider ultrasound guidance documentation"]'::jsonb,
 '2024-12-01', 'https://www.psr.gov.au/case-outcomes/psr-directors-update-december-2024',
 'medium', now(), now()),

-- ---------------------------------------------------------------------------
-- OCTOBER 2024 CASES
-- ---------------------------------------------------------------------------

(gen_random_uuid(), 'PSR-2024-OCT-001', 'General Practitioner',
 '["13915", "14206", "14209"]'::jsonb,
 'Iron infusions billed without documented iron deficiency. Contraceptive implant procedures lacking consent documentation. Clinical notes insufficient for procedure billing.',
 'Iron infusion items were billed without documented iron studies confirming iron deficiency anaemia. Contraceptive procedures were performed without documented consent. Clinical notes were insufficient to support the procedures billed.',
 72000, 72000,
 '["Counselled"]'::jsonb,
 '["Iron infusions require documented iron studies showing deficiency", "Contraceptive procedures require documented consent and clinical indication", "Procedure notes must be comprehensive enough to support billing"]'::jsonb,
 '["Confirm and document iron deficiency before infusion", "Obtain and document informed consent for all procedures", "Write comprehensive procedure notes at time of service", "Include pre-procedure investigations in clinical record"]'::jsonb,
 '2024-10-01', 'https://www.psr.gov.au/case-outcomes/psr-directors-update-october-2024',
 'medium', now(), now()),

-- ---------------------------------------------------------------------------
-- SEPTEMBER 2023 CASES
-- ---------------------------------------------------------------------------

(gen_random_uuid(), 'PSR-2023-SEP-001', 'General Practitioner',
 '["23", "36", "44", "721", "723", "732"]'::jsonb,
 'Services billed at higher levels than provided (upcoding). Minimum time requirements not met. CDM documentation inadequate. Multiple services same day without clear indication.',
 'Systematic upcoding of consultation levels - billing Level C and D for services that only warranted Level B. No time documentation to support higher-level billing. CDM plans were incomplete. Multiple services were billed on the same day without clear clinical indication for each separate service.',
 310000, 310000,
 '["Reprimanded", "Referred to Medical Board", "Disqualified from all MBS services for 18 months"]'::jsonb,
 '["Upcoding combined with documentation failures can result in extended disqualification and professional body referral", "This is among the most severe outcomes possible", "Time documentation is essential for all time-based items"]'::jsonb,
 '["Bill only the consultation level actually provided", "Document time for every time-based item", "Complete all CDM plan components", "Justify each service when billing multiple items same day", "Understand that referral to Medical Board is a possible outcome"]'::jsonb,
 '2023-09-01', 'https://www.psr.gov.au/case-outcomes/psr-directors-update-september-2023',
 'critical', now(), now())

ON CONFLICT (case_reference) DO UPDATE SET
  practitioner_type       = EXCLUDED.practitioner_type,
  item_numbers_involved   = EXCLUDED.item_numbers_involved,
  issue_description       = EXCLUDED.issue_description,
  what_went_wrong         = EXCLUDED.what_went_wrong,
  financial_penalty        = EXCLUDED.financial_penalty,
  repayment_amount        = EXCLUDED.repayment_amount,
  other_sanctions         = EXCLUDED.other_sanctions,
  lessons_learned         = EXCLUDED.lessons_learned,
  recommendations         = EXCLUDED.recommendations,
  publication_date        = EXCLUDED.publication_date,
  source_url              = EXCLUDED.source_url,
  severity_level          = EXCLUDED.severity_level,
  updated_at              = now();

COMMIT;

-- ============================================================================
-- POST-SEED VERIFICATION
-- ============================================================================

DO $$
DECLARE
  mbs_count integer;
  psr_count integer;
BEGIN
  SELECT count(*) INTO mbs_count FROM mbs_items;
  SELECT count(*) INTO psr_count FROM psr_cases;
  RAISE NOTICE '--- Seed verification ---';
  RAISE NOTICE 'mbs_items: % rows', mbs_count;
  RAISE NOTICE 'psr_cases: % rows', psr_count;
END $$;
