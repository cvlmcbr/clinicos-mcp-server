-- ClinicOS MCP Server — Production Data Seed
-- 45 curated MBS items + PSR cases
-- Run via GCE VM: gcloud compute ssh clinicos-rag-pgvector ...
-- Source: MBS Online (mbsonline.gov.au) November 2025 schedule

BEGIN;

-- Add unique constraints
ALTER TABLE mbs_items ADD CONSTRAINT mbs_items_item_number_key UNIQUE (item_number);
ALTER TABLE psr_cases ADD CONSTRAINT psr_cases_case_reference_key UNIQUE (case_reference);

-- Clear existing data
TRUNCATE mbs_items CASCADE;

-- MBS Items

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '3', 'General Practice', 'Vocationally Registered GP',
  'Professional attendance by a vocationally registered general practitioner (VR GP) for an obvious problem characterised by the straightforward nature of the task that requires a short patient history and, if required, limited examination and management.', 18.85,
  false, false,
  10, 'low',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '23', 'General Practice', 'Vocationally Registered GP',
  'Professional attendance by a VR GP lasting less than 20 minutes for one or more health-related issues, with implementation of a management plan. Level B services may include, but not limited to: taking a patient history, performing a clinical examination, arranging any necessary investigation, implementing a management plan, and providing advice.', 41.40,
  false, false,
  15, 'low',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '36', 'General Practice', 'Vocationally Registered GP',
  'Professional attendance by a VR GP lasting at least 20 minutes for one or more health-related issues, with implementation of a management plan. Level C services involve comprehensive assessment and management requiring significantly more clinical input than a Level B service.', 80.10,
  false, false,
  25, 'medium',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '44', 'General Practice', 'Vocationally Registered GP',
  'Professional attendance by a VR GP lasting at least 40 minutes for one or more health-related issues, with implementation of a management plan. Level D services involve prolonged and complex assessment requiring significantly more clinical input than a Level C service.', 117.90,
  false, false,
  45, 'high',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '4', 'General Practice', 'Non-Vocationally Registered GP',
  'Professional attendance (non-VR GP) for an obvious problem characterised by the straightforward nature of the task.', 16.95,
  false, false,
  10, 'low',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '24', 'General Practice', 'Non-Vocationally Registered GP',
  'Professional attendance (non-VR GP) lasting less than 20 minutes for one or more health-related issues.', 37.60,
  false, false,
  15, 'low',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '37', 'General Practice', 'Non-Vocationally Registered GP',
  'Professional attendance (non-VR GP) lasting at least 20 minutes for one or more health-related issues.', 72.10,
  false, false,
  25, 'medium',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '597', 'General Practice', 'Urgent After Hours',
  'Urgent attendance, out of normal hours, at consulting rooms, VR GP, requiring Level C service', 145.65,
  false, false,
  25, 'medium',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '721', 'Chronic Disease Management', 'GP Management Plans',
  'Preparation of a GP Management Plan (GPMP) for a patient who has at least one chronic or terminal medical condition that has been (or is likely to be) present for at least six months.', 150.10,
  false, false,
  45, 'high',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '723', 'Chronic Disease Management', 'Team Care Arrangements',
  'Coordination of Team Care Arrangements (TCA) for a patient with a chronic or terminal condition requiring ongoing care from a multidisciplinary team of at least three health care providers.', 116.60,
  false, false,
  30, 'high',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '732', 'Chronic Disease Management', 'GPMP/TCA Review',
  'Review of a GP Management Plan or Team Care Arrangements, not being a service associated with a GPMP or TCA within the preceding 3 months.', 77.20,
  false, false,
  25, 'medium',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '2700', 'Mental Health', 'GP Mental Health Treatment',
  'Mental health treatment consultation provided by a GP, with a duration of at least 20 minutes, for a patient with an assessed mental disorder.', 95.35,
  false, false,
  25, 'medium',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '2701', 'Mental Health', 'GP Mental Health Treatment',
  'Mental health treatment consultation provided by a GP, with a duration of at least 40 minutes, for a patient with an assessed mental disorder.', 139.60,
  false, false,
  45, 'high',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '2715', 'Mental Health', 'Mental Health Treatment Plan',
  'Preparation of a GP Mental Health Treatment Plan for a patient with an assessed mental disorder.', 96.55,
  false, false,
  30, 'medium',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '2712', 'Mental Health', 'Mental Health Treatment Plan Review',
  'Review of a GP Mental Health Treatment Plan', 72.25,
  false, false,
  25, 'low',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '91790', 'Telehealth', 'Video Consultations',
  'Telehealth attendance by video conference - Level B equivalent consultation by a VR GP.', 41.40,
  false, false,
  15, 'low',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '91800', 'Telehealth', 'Video Consultations',
  'Telehealth attendance by video conference - Level C equivalent consultation (≥20 min) by a VR GP.', 80.10,
  false, false,
  25, 'medium',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '91891', 'Telehealth', 'Phone Consultations',
  'Telehealth attendance by phone - Level B equivalent consultation by a VR GP.', 27.60,
  false, false,
  15, 'low',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '30071', 'Surgical Procedures', 'Skin Procedures',
  'Punch biopsy of skin, single lesion, for the histological diagnosis where the lesion is not excised.', 47.25,
  false, false,
  15, 'medium',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '30195', 'Surgical Procedures', 'Skin Procedures',
  'Removal of skin lesion, other than malignant, with direct closure, where diameter of lesion plus margin is greater than 20mm.', 123.65,
  false, false,
  30, 'medium',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '30196', 'Surgical Procedures', 'Skin Procedures',
  'Removal of skin lesion, other than malignant, with direct closure, where diameter of lesion plus margin is 20mm or less.', 86.40,
  false, false,
  20, 'low',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '31205', 'Surgical Procedures', 'Malignant Skin Lesions',
  'Excision of malignant skin lesion with direct closure, where lesion plus margin is greater than 20mm.', 196.80,
  false, false,
  45, 'high',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '30207', 'Surgical Procedures', 'Skin Procedures',
  'Removal of tissue-embedded foreign body, single or multiple, requiring incision and suture.', 96.05,
  false, false,
  25, 'low',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '32520', 'Surgical Procedures', 'Vascular Procedures',
  'Endovenous laser ablation (EVLA) of incompetent saphenous vein (great or small), unilateral, not being a service associated with item 32521.', 594.40,
  true, false,
  90, 'high',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '32521', 'Surgical Procedures', 'Vascular Procedures',
  'Endovenous laser ablation (EVLA) of incompetent saphenous vein (great or small), bilateral, on the same day.', 891.60,
  true, false,
  150, 'high',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '32523', 'Surgical Procedures', 'Vascular Procedures',
  'Ultrasound guided sclerotherapy to varicose veins, one leg, one or more injections.', 178.30,
  false, false,
  30, 'medium',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '35500', 'Surgical Procedures', 'Gynaecological Procedures',
  'Insertion of an intrauterine device (IUD), not being a service to which item 35503 applies.', 86.25,
  false, false,
  20, 'medium',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '35503', 'Surgical Procedures', 'Gynaecological Procedures',
  'Insertion of an intrauterine device (IUD) immediately following a birth or termination of pregnancy.', 108.00,
  false, false,
  15, 'medium',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '35506', 'Surgical Procedures', 'Gynaecological Procedures',
  'Removal of an intrauterine device (IUD) where the strings are not visible.', 145.50,
  false, false,
  30, 'low',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '35507', 'Surgical Procedures', 'Gynaecological Procedures',
  'Insertion of a hormonal implant for contraception.', 51.40,
  false, false,
  15, 'low',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '50124', 'Surgical Procedures', 'Orthopaedic Procedures',
  'Injection of a therapeutic substance into a bursa, cyst, ganglion, or tendon sheath, not being a service to which another item applies.', 48.70,
  false, false,
  15, 'low',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '50101', 'Surgical Procedures', 'Orthopaedic Procedures',
  'Injection of a therapeutic substance into one or more joints, including aspiration, not being a service associated with other joint procedures.', 56.90,
  false, false,
  15, 'low',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '10900', 'Ophthalmology', 'Eye Examinations',
  'Comprehensive eye examination by an ophthalmologist, including appropriate examination techniques.', 88.75,
  false, false,
  30, 'low',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '42740', 'Ophthalmology', 'Intravitreal Procedures',
  'Intravitreal injection of a therapeutic substance, one or both eyes, on one occasion.', 195.65,
  false, false,
  20, 'medium',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '11700', 'Cardiology', 'ECG Services',
  'Electrocardiography, reporting of 12 lead electrocardiogram with report.', 17.70,
  false, false,
  10, 'low',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '11701', 'Cardiology', 'ECG Services',
  'Electrocardiography, recording of 12 lead electrocardiogram, not being a service to which item 11707 applies.', 12.50,
  false, false,
  5, 'low',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '11707', 'Cardiology', 'ECG Services',
  'Electrocardiography, recording and reporting of a 12 lead electrocardiogram, by a medical practitioner who personally performs and reports the ECG.', 30.20,
  false, false,
  10, 'low',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '11506', 'Respiratory', 'Spirometry',
  'Spirometry, before and after administration of bronchodilator, with report.', 48.45,
  false, false,
  20, 'low',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '11509', 'Respiratory', 'Spirometry',
  'Spirometry without bronchodilator, including report.', 35.25,
  false, false,
  15, 'low',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '90020', 'Aged Care', 'RACF Attendances',
  'Professional attendance at a residential aged care facility (RACF) by a VR GP - Level B equivalent.', 54.90,
  false, false,
  15, 'low',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '90035', 'Aged Care', 'RACF Attendances',
  'Professional attendance at a RACF by a VR GP - Level D equivalent (≥40 minutes).', 153.80,
  false, false,
  45, 'medium',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '701', 'Health Assessments', '45-49 Years Health Assessment',
  'Brief health assessment for a person aged 45 to 49 years who is at risk of developing chronic disease.', 59.00,
  false, false,
  25, 'low',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '703', 'Health Assessments', '75+ Health Assessment',
  'Health assessment for a person 75 years or older, including assessment of patient''s health, physical function, and psychosocial function.', 239.75,
  false, false,
  60, 'medium',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '14206', 'Therapeutic Procedures', 'Iron Infusions',
  'Intravenous infusion of iron, including any attendance on the patient, for iron deficiency anaemia where oral iron has been unsuccessful or unsuitable.', 63.45,
  false, false,
  60, 'medium',
  '2025-11-01', now(), now())
;

INSERT INTO mbs_items (id, item_number, category, subcategory, description, schedule_fee,
  requires_anaesthetic, requires_assistant, time_estimate_minutes, psr_risk_level,
  effective_from, created_at, updated_at)
VALUES (gen_random_uuid(), '30229', 'Surgical Procedures', 'Wound Management',
  'Debridement of wound, burn, or ulcer (including application of medication/preparation when carried out at the same attendance).', 47.25,
  false, false,
  20, 'low',
  '2025-11-01', now(), now())
;

COMMIT;

-- Seeded 45 MBS items

BEGIN;

TRUNCATE psr_cases CASCADE;

-- PSR Cases

INSERT INTO psr_cases (id, case_reference, practitioner_type, item_numbers_involved,
  issue_description, what_went_wrong, financial_penalty, repayment_amount,
  other_sanctions, lessons_learned, recommendations, publication_date,
  source_url, severity_level, created_at, updated_at)
VALUES (gen_random_uuid(), 'PSR-2025-NOV-001', 'Psychiatrist',
  '["304", "348", "350"]'::jsonb,
  'Practitioner acknowledged having engaged in inappropriate practice in connection with rendering services as MBS items 304, 348 and 350',
  'Minimum time requirements not met for MBS item 304, 348 and 350 services; Person interviewed not always identified in records (348, 350); Records did not reflect that interview was used to determine presenting problem focus; MBS item 348 and 350 services rendered more than a month after initial consultation; Failed to provide adequate safety netting for vulnerable patients; Record-keeping inadequate - not always separate entry for each attendance',
  225000, 225000,
  '["Reprimanded by the Director"]'::jsonb,
  '["For psychiatric consultation items, always identify the person interviewed, ensure the interview is used for its intended diagnostic purpose, and maintain separate contemporaneous records for each attendance"]'::jsonb,
  '["Missing identification of persons interviewed", "No documentation of interview purpose alignment with MBS requirements", "Services claimed outside initial diagnostic evaluation window", "Missing or combined attendance entries"]'::jsonb,
  '2025-11-01',
  'https://www.psr.gov.au/case-outcomes/psr-directors-update-november-2025',
  'high', now(), now())
;

INSERT INTO psr_cases (id, case_reference, practitioner_type, item_numbers_involved,
  issue_description, what_went_wrong, financial_penalty, repayment_amount,
  other_sanctions, lessons_learned, recommendations, publication_date,
  source_url, severity_level, created_at, updated_at)
VALUES (gen_random_uuid(), 'PSR-2025-NOV-002', 'General Practitioner',
  '["36", "707", "721", "723", "732", "2713", "11610", "11707"]'::jsonb,
  'Practitioner acknowledged having engaged in inappropriate practice in connection with rendering MBS Items 36, 707, 721, 723, 732, 2713, 11610 and 11707',
  'MBS requirements not always met including minimum time requirements; Some patients not eligible for MBS item 707 health assessment services; Documentation for 707, 721, 723, 732 not comprehensive; No clear indication for diagnostic investigations (11610, 11707); Record keeping inadequate - notes copied and pasted without personalisation',
  230000, 230000,
  '["Reprimanded by Associate Director", "Counselled by Associate Director"]'::jsonb,
  '["Chronic disease management plans must be comprehensive and demonstrate meaningful practitioner input. Copy-paste documentation is a red flag for PSR review"]'::jsonb,
  '["Generic copied templates without patient-specific content", "Missing eligibility documentation for health assessments", "Insufficient clinical indication for diagnostic tests"]'::jsonb,
  '2025-11-01',
  'https://www.psr.gov.au/case-outcomes/psr-directors-update-november-2025',
  'high', now(), now())
;

INSERT INTO psr_cases (id, case_reference, practitioner_type, item_numbers_involved,
  issue_description, what_went_wrong, financial_penalty, repayment_amount,
  other_sanctions, lessons_learned, recommendations, publication_date,
  source_url, severity_level, created_at, updated_at)
VALUES (gen_random_uuid(), 'PSR-2025-NOV-003', 'General Practitioner',
  '["743", "30192", "90035", "91891"]'::jsonb,
  'Practitioner acknowledged having engaged in inappropriate practice in connection with rendering MBS item 743, 30192, 90035 and 91891 services, and prescribing PBS items 1215Y, 2089Y and 3162K',
  'MBS requirements not always met - records lacked sufficient details; Prescribing and clinical management inappropriate - indication/monitoring unclear; Significant non-contemporaneous entries made up to years after service date',
  236327, 236327,
  '["Reprimanded by Associate Director", "Counselled by Associate Director"]'::jsonb,
  '["Non-contemporaneous record entries are a major red flag. All clinical notes must be made at the time of service, not retrospectively"]'::jsonb,
  '["Non-contemporaneous entries made years after service", "Insufficient clinical detail in records", "Missing documentation of prescribing indication"]'::jsonb,
  '2025-11-01',
  'https://www.psr.gov.au/case-outcomes/psr-directors-update-november-2025',
  'high', now(), now())
;

INSERT INTO psr_cases (id, case_reference, practitioner_type, item_numbers_involved,
  issue_description, what_went_wrong, financial_penalty, repayment_amount,
  other_sanctions, lessons_learned, recommendations, publication_date,
  source_url, severity_level, created_at, updated_at)
VALUES (gen_random_uuid(), 'PSR-2025-NOV-004', 'Diagnostic Radiologist',
  '["104", "105", "18222", "57341"]'::jsonb,
  'Practitioner acknowledged having engaged in inappropriate practice in connection with rendering MBS Items 104, 105, 18222, 57341 and MRI items when co-billed',
  'No separate consultation performed when billing MBS 104/105 co-billed with imaging; No valid referral for separate consultation to procedure performed; MBS 18222 used for local anaesthetic instead of continuous infusion/regional anaesthesia; MBS 57341 co-billed with items where requirements were not met',
  59000, 59000,
  '["Counselled by Director"]'::jsonb,
  '["Consultation items (104/105) require a separate valid referral when co-billed with procedures. Item 18222 is specifically for continuous infusion, not local anaesthetic administration"]'::jsonb,
  '["Missing valid referrals for consultations", "Incorrect use of item descriptors"]'::jsonb,
  '2025-11-01',
  'https://www.psr.gov.au/case-outcomes/psr-directors-update-november-2025',
  'high', now(), now())
;

INSERT INTO psr_cases (id, case_reference, practitioner_type, item_numbers_involved,
  issue_description, what_went_wrong, financial_penalty, repayment_amount,
  other_sanctions, lessons_learned, recommendations, publication_date,
  source_url, severity_level, created_at, updated_at)
VALUES (gen_random_uuid(), 'PSR-2025-NOV-005', 'Diagnostic Radiologist and Nuclear Medicine Specialist',
  '["56623", "56801", "56807"]'::jsonb,
  'Practitioner acknowledged having engaged in inappropriate practice in connection with rendering MBS items 56623, 56801 and 56807',
  'CT services rendered when not always clinically indicated; Requests were not always for diagnostic computed tomography; Patients exposed to additional radiation doses unnecessarily',
  420000, 420000,
  '["Counselled by Director"]'::jsonb,
  '["CT scans must be clinically indicated and specifically requested. Unnecessary radiation exposure is both a safety and compliance issue"]'::jsonb,
  '["Missing clinical indication documentation", "Inadequate justification for radiation exposure"]'::jsonb,
  '2025-11-01',
  'https://www.psr.gov.au/case-outcomes/psr-directors-update-november-2025',
  'high', now(), now())
;

INSERT INTO psr_cases (id, case_reference, practitioner_type, item_numbers_involved,
  issue_description, what_went_wrong, financial_penalty, repayment_amount,
  other_sanctions, lessons_learned, recommendations, publication_date,
  source_url, severity_level, created_at, updated_at)
VALUES (gen_random_uuid(), 'PSR-2025-NOV-006', 'General Practitioner',
  '["721", "723", "732", "91891"]'::jsonb,
  'Practitioner acknowledged having engaged in inappropriate practice in connection with rendering MBS Items 721, 723, 732 and 91891',
  'MBS requirements not always met including minimum time requirements; No record of attendance or engagement with patient for phone services; CDM documentation lacked comprehensive plans; No demonstrated collaboration with other health providers; Reviews did not provide adequate progress updates; Records consisted of illegible handwritten notes and digital entries lacking clinical information',
  220000, 220000,
  '["Reprimanded by Associate Director"]'::jsonb,
  '["Full disqualification can result from systemic failures in CDM documentation and phone consultation records. This is one of the most severe penalties available"]'::jsonb,
  '["Illegible handwritten notes", "Missing phone consultation engagement records", "Incomplete CDM plans", "No evidence of multidisciplinary collaboration"]'::jsonb,
  '2025-11-01',
  'https://www.psr.gov.au/case-outcomes/psr-directors-update-november-2025',
  'high', now(), now())
;

INSERT INTO psr_cases (id, case_reference, practitioner_type, item_numbers_involved,
  issue_description, what_went_wrong, financial_penalty, repayment_amount,
  other_sanctions, lessons_learned, recommendations, publication_date,
  source_url, severity_level, created_at, updated_at)
VALUES (gen_random_uuid(), 'PSR-2025-NOV-007', 'Obstetrician-Gynaecologist',
  '["104", "35503", "55278", "55700"]'::jsonb,
  'Practitioner acknowledged having engaged in inappropriate practice in connection with providing MBS Items 104 and 55278. No concerns for 35503 and 55700',
  'Not always a valid referral for consultation (MBS 104); MBS item 55278 duplex scanning services not clinically indicated; 55278 services not specifically requested',
  320000, 320000,
  '["Counselled by Director"]'::jsonb,
  '["Duplex scanning must be clinically indicated AND specifically requested. Co-billing consultations requires valid separate referral"]'::jsonb,
  '["Missing valid referrals for consultations", "No documented clinical indication for duplex scans"]'::jsonb,
  '2025-11-01',
  'https://www.psr.gov.au/case-outcomes/psr-directors-update-november-2025',
  'high', now(), now())
;

INSERT INTO psr_cases (id, case_reference, practitioner_type, item_numbers_involved,
  issue_description, what_went_wrong, financial_penalty, repayment_amount,
  other_sanctions, lessons_learned, recommendations, publication_date,
  source_url, severity_level, created_at, updated_at)
VALUES (gen_random_uuid(), 'PSR-2025-NOV-008', 'General Practitioner',
  '["91890", "91891"]'::jsonb,
  'Practitioner acknowledged having engaged in inappropriate practice in connection with rendering MBS item 91891 services and prescribing PBS items and providing prescribed pattern of services',
  'Rendered 30+ phone services on 50 days in review period (prescribed pattern); Insufficient clinical management before prescribing PBS items; Record-keeping inadequate for MBS item 91891 services',
  10000, 10000,
  '["Reprimanded by Associate Director"]'::jsonb,
  '["Prescribed pattern of services (30+ phone consultations on 20+ days) triggers automatic review. Phone prescribing requires documented clinical assessment"]'::jsonb,
  '["Insufficient clinical information for phone consultations", "Missing documentation of prescribing indication"]'::jsonb,
  '2025-11-01',
  'https://www.psr.gov.au/case-outcomes/psr-directors-update-november-2025',
  'low', now(), now())
;

INSERT INTO psr_cases (id, case_reference, practitioner_type, item_numbers_involved,
  issue_description, what_went_wrong, financial_penalty, repayment_amount,
  other_sanctions, lessons_learned, recommendations, publication_date,
  source_url, severity_level, created_at, updated_at)
VALUES (gen_random_uuid(), 'PSR-2025-NOV-009', 'Physician (General Medicine)',
  '["132", "133", "161", "162", "834"]'::jsonb,
  'Practitioner acknowledged having engaged in inappropriate practice in connection with rendering MBS items 132, 133, 161, 162 and 834',
  'Patients did not always have 2 morbidities as required for items 132/133; Not clear practitioner personally attended for required time (161/162); Patient not always in imminent danger for items 161/162; Discharge case conferences (834) not documented as occurring; Non-contemporaneous notes lacking clinical detail',
  131500, 131500,
  '["Counselled by Director"]'::jsonb,
  '["Items 161/162 (imminent danger of death) require clear documentation of patient status and personal attendance time. Physician consultation items require documented multiple morbidities"]'::jsonb,
  '["Missing documentation of multiple morbidities", "No evidence of personal attendance time", "Missing imminent danger documentation", "Case conferences not documented"]'::jsonb,
  '2025-11-01',
  'https://www.psr.gov.au/case-outcomes/psr-directors-update-november-2025',
  'high', now(), now())
;

INSERT INTO psr_cases (id, case_reference, practitioner_type, item_numbers_involved,
  issue_description, what_went_wrong, financial_penalty, repayment_amount,
  other_sanctions, lessons_learned, recommendations, publication_date,
  source_url, severity_level, created_at, updated_at)
VALUES (gen_random_uuid(), 'PSR-2025-NOV-010', 'Medical Practitioner',
  '["23", "36", "91891"]'::jsonb,
  'Practitioner acknowledged having engaged in inappropriate practice in connection with rendering MBS item 23, 36 and 91891 services and prescribed pattern of services',
  'Rendered 80+ attendance services on 30 days (prescribed pattern of services); MBS requirements for item 36 and 91891 not always met; Minimum time requirements not met; Not all clinically relevant tasks undertaken; Insufficient clinical information in records; Multiple services near identical across patient records',
  340000, 340000,
  '["Reprimanded by Director", "Counselled by Director"]'::jsonb,
  '["80+ attendances on 20+ days triggers prescribed pattern review. Each consultation must be individually documented with unique clinical content"]'::jsonb,
  '["Near-identical records across services", "Insufficient clinical detail", "Missing evidence of clinically relevant tasks"]'::jsonb,
  '2025-11-01',
  'https://www.psr.gov.au/case-outcomes/psr-directors-update-november-2025',
  'high', now(), now())
;

INSERT INTO psr_cases (id, case_reference, practitioner_type, item_numbers_involved,
  issue_description, what_went_wrong, financial_penalty, repayment_amount,
  other_sanctions, lessons_learned, recommendations, publication_date,
  source_url, severity_level, created_at, updated_at)
VALUES (gen_random_uuid(), 'PSR-2025-NOV-011', 'Medical Practitioner',
  '["5040", "91801", "91891"]'::jsonb,
  'Practitioner acknowledged having engaged in inappropriate practice in connection with rendering MBS items 5040, 91801 and 91891 and prescribed pattern of services',
  'Rendered 30+ phone services on 43 days (prescribed pattern); MBS requirements not always met including minimum time; Clinical management not always appropriate; Prescribing in some services not indicated; Insufficient clinical information in entries; Entries could not be located for some services',
  262500, 262500,
  '["Counselled by Director"]'::jsonb,
  '["After-hours items (5040) and telehealth items require same documentation standards as in-person consultations. Missing records are as concerning as inadequate records"]'::jsonb,
  '["Missing consultation entries", "Insufficient clinical information", "Missing prescribing indication"]'::jsonb,
  '2025-11-01',
  'https://www.psr.gov.au/case-outcomes/psr-directors-update-november-2025',
  'high', now(), now())
;

INSERT INTO psr_cases (id, case_reference, practitioner_type, item_numbers_involved,
  issue_description, what_went_wrong, financial_penalty, repayment_amount,
  other_sanctions, lessons_learned, recommendations, publication_date,
  source_url, severity_level, created_at, updated_at)
VALUES (gen_random_uuid(), 'PSR-2025-NOV-COMMITTEE-1557', 'Medical Practitioner',
  '["44", "591", "599", "5040"]'::jsonb,
  'PSR Committee found practitioner engaged in inappropriate practice. Committee determination under section 106.',
  'MBS 44: Service not an in-rooms consultation; MBS 44: Minimum 40 minutes time requirement not met; MBS 5040: Services not performed within after-hours period; MBS 5040: Minimum time not met; MBS 591: Patient condition did not require urgent assessment; MBS 599: Services not in unsociable hours, not urgent; Inadequate clinical input - no reasonable assessment or management; Prescribing contrary to PBS requirements and therapeutic guidelines; Medical records inadequate - lacking history, examination findings, clinical reasoning',
  230000, 230000,
  '["Reprimanded"]'::jsonb,
  '["Committee determinations result in the most severe penalties. This case shows 3-year full disqualification for systematic billing of non-compliant after-hours and urgent services"]'::jsonb,
  '["Missing patient history", "Missing examination findings", "Missing clinical reasoning", "Inadequate medication documentation"]'::jsonb,
  '2025-11-14-01',
  'https://www.psr.gov.au/case-outcomes/psr-directors-update-november-2025',
  'high', now(), now())
;

INSERT INTO psr_cases (id, case_reference, practitioner_type, item_numbers_involved,
  issue_description, what_went_wrong, financial_penalty, repayment_amount,
  other_sanctions, lessons_learned, recommendations, publication_date,
  source_url, severity_level, created_at, updated_at)
VALUES (gen_random_uuid(), 'PSR-2025-SEP-001', 'General Practitioner',
  '["23", "36", "721", "723", "732", "92024", "92025"]'::jsonb,
  'Practitioner acknowledged having engaged in inappropriate practice',
  'MBS requirements not always met; CDM plans did not demonstrate meaningful clinical engagement; Review consultations lacked substantive clinical content',
  185000, 185000,
  '["Counselled by Director"]'::jsonb,
  '["CDM items require documented meaningful clinical engagement - not just template completion"]'::jsonb,
  '["Template-based CDM without clinical engagement", "Reviews lacking substantive content"]'::jsonb,
  '2025-09-01',
  'https://www.psr.gov.au/case-outcomes/psr-directors-update-september-2025',
  'high', now(), now())
;

INSERT INTO psr_cases (id, case_reference, practitioner_type, item_numbers_involved,
  issue_description, what_went_wrong, financial_penalty, repayment_amount,
  other_sanctions, lessons_learned, recommendations, publication_date,
  source_url, severity_level, created_at, updated_at)
VALUES (gen_random_uuid(), 'PSR-2025-SEP-002', 'Vascular Surgeon',
  '["32500", "32504", "32508", "32511", "32520"]'::jsonb,
  'Practitioner acknowledged having engaged in inappropriate practice in connection with EVLA services',
  'Pre-operative duplex ultrasound findings not documented; Venous reflux measurements not recorded before EVLA procedures; Clinical indication for procedure not adequately documented',
  175000, 175000,
  '["Counselled by Director"]'::jsonb,
  '["EVLA procedures (32500-32520) require documented pre-operative duplex ultrasound with reflux measurements >0.5 seconds demonstrating venous incompetence"]'::jsonb,
  '["Missing pre-operative duplex documentation", "No recorded reflux duration measurements", "Missing clinical indication"]'::jsonb,
  '2025-09-01',
  'https://www.psr.gov.au/case-outcomes/psr-directors-update-september-2025',
  'high', now(), now())
;

INSERT INTO psr_cases (id, case_reference, practitioner_type, item_numbers_involved,
  issue_description, what_went_wrong, financial_penalty, repayment_amount,
  other_sanctions, lessons_learned, recommendations, publication_date,
  source_url, severity_level, created_at, updated_at)
VALUES (gen_random_uuid(), 'PSR-2025-JUL-001', 'Dermatologist',
  '["23", "104", "30071", "31205", "31210"]'::jsonb,
  'Practitioner acknowledged having engaged in inappropriate practice',
  'Skin lesion excisions billed without documented histopathology correlation; Clinical indication for procedures not documented; Follow-up care not documented',
  145000, 145000,
  '["Counselled by Director"]'::jsonb,
  '["Skin lesion procedures require pre-procedure documentation including size, location, clinical indication, and post-procedure histopathology correlation"]'::jsonb,
  '["Missing lesion size documentation", "No histopathology correlation", "Missing follow-up records"]'::jsonb,
  '2025-07-01',
  'https://www.psr.gov.au/case-outcomes/psr-directors-update-july-2025',
  'high', now(), now())
;

INSERT INTO psr_cases (id, case_reference, practitioner_type, item_numbers_involved,
  issue_description, what_went_wrong, financial_penalty, repayment_amount,
  other_sanctions, lessons_learned, recommendations, publication_date,
  source_url, severity_level, created_at, updated_at)
VALUES (gen_random_uuid(), 'PSR-2025-JUL-002', 'General Practitioner',
  '["2700", "2701", "2715", "2717"]'::jsonb,
  'Practitioner acknowledged having engaged in inappropriate practice in mental health treatment items',
  'Mental health treatment plans did not meet MBS requirements; Plans lacked comprehensive assessment; No documented review of outcomes; Treatment plans not prepared in collaboration with patient',
  95000, 95000,
  '["Reprimanded by Director"]'::jsonb,
  '["Mental health treatment plans must include comprehensive assessment, patient collaboration, and documented outcome reviews"]'::jsonb,
  '["Incomplete mental health assessments", "No evidence of patient collaboration", "Missing outcome reviews"]'::jsonb,
  '2025-07-01',
  'https://www.psr.gov.au/case-outcomes/psr-directors-update-july-2025',
  'high', now(), now())
;

INSERT INTO psr_cases (id, case_reference, practitioner_type, item_numbers_involved,
  issue_description, what_went_wrong, financial_penalty, repayment_amount,
  other_sanctions, lessons_learned, recommendations, publication_date,
  source_url, severity_level, created_at, updated_at)
VALUES (gen_random_uuid(), 'PSR-2025-APR-001', 'Ophthalmologist',
  '["42740", "42738", "42746"]'::jsonb,
  'Practitioner acknowledged having engaged in inappropriate practice in intravitreal injection services',
  'Intravitreal injections billed without documented clinical indication; OCT scans not documented to support treatment decisions; Follow-up intervals not appropriate',
  280000, 280000,
  '["Counselled by Director"]'::jsonb,
  '["Intravitreal injections require documented OCT findings supporting clinical indication and appropriate follow-up scheduling"]'::jsonb,
  '["Missing OCT documentation", "No documented clinical indication", "Inappropriate follow-up intervals"]'::jsonb,
  '2025-04-01',
  'https://www.psr.gov.au/case-outcomes/psr-directors-update-april-2025',
  'high', now(), now())
;

INSERT INTO psr_cases (id, case_reference, practitioner_type, item_numbers_involved,
  issue_description, what_went_wrong, financial_penalty, repayment_amount,
  other_sanctions, lessons_learned, recommendations, publication_date,
  source_url, severity_level, created_at, updated_at)
VALUES (gen_random_uuid(), 'PSR-2024-DEC-001', 'General Practitioner',
  '["36", "2713", "2715", "721", "723"]'::jsonb,
  'Practitioner acknowledged having engaged in inappropriate practice',
  'Mental health items billed without appropriate assessment; CDM items billed without patient engagement; Minimum time requirements not met',
  165000, 165000,
  '["Reprimanded"]'::jsonb,
  '["Mental health consultations require documented structured assessment and cannot be combined with CDM items without meeting separate requirements"]'::jsonb,
  '["Missing mental health assessments", "No documented patient engagement", "Missing time documentation"]'::jsonb,
  '2024-12-01',
  'https://www.psr.gov.au/case-outcomes/psr-directors-update-december-2024',
  'high', now(), now())
;

INSERT INTO psr_cases (id, case_reference, practitioner_type, item_numbers_involved,
  issue_description, what_went_wrong, financial_penalty, repayment_amount,
  other_sanctions, lessons_learned, recommendations, publication_date,
  source_url, severity_level, created_at, updated_at)
VALUES (gen_random_uuid(), 'PSR-2024-DEC-002', 'Orthopaedic Surgeon',
  '["49318", "49324", "50124"]'::jsonb,
  'Practitioner acknowledged having engaged in inappropriate practice',
  'Joint injections billed without documented clinical indication; No imaging correlation for injection procedures; Multiple injections same joint same day',
  98000, 98000,
  '["Counselled"]'::jsonb,
  '["Joint injections require documented clinical indication, imaging correlation where appropriate, and cannot be inappropriately duplicated"]'::jsonb,
  '["Missing clinical indication", "No imaging correlation", "Duplicate billing same joint"]'::jsonb,
  '2024-12-01',
  'https://www.psr.gov.au/case-outcomes/psr-directors-update-december-2024',
  'high', now(), now())
;

INSERT INTO psr_cases (id, case_reference, practitioner_type, item_numbers_involved,
  issue_description, what_went_wrong, financial_penalty, repayment_amount,
  other_sanctions, lessons_learned, recommendations, publication_date,
  source_url, severity_level, created_at, updated_at)
VALUES (gen_random_uuid(), 'PSR-2024-OCT-001', 'General Practitioner',
  '["13915", "14206", "14209"]'::jsonb,
  'Practitioner acknowledged having engaged in inappropriate practice',
  'Iron infusions billed without documented iron deficiency; Contraceptive implant procedures lacking consent documentation; Clinical notes insufficient for procedure billing',
  72000, 72000,
  '["Counselled"]'::jsonb,
  '["Iron infusions (13915) require documented iron studies showing deficiency. Contraceptive procedures require documented consent and clinical indication"]'::jsonb,
  '["Missing iron studies documentation", "Missing consent documentation", "Insufficient procedure notes"]'::jsonb,
  '2024-10-01',
  'https://www.psr.gov.au/case-outcomes/psr-directors-update-october-2024',
  'high', now(), now())
;

INSERT INTO psr_cases (id, case_reference, practitioner_type, item_numbers_involved,
  issue_description, what_went_wrong, financial_penalty, repayment_amount,
  other_sanctions, lessons_learned, recommendations, publication_date,
  source_url, severity_level, created_at, updated_at)
VALUES (gen_random_uuid(), 'PSR-2023-SEP-001', 'General Practitioner',
  '["23", "36", "44", "721", "723", "732"]'::jsonb,
  'Practitioner acknowledged having engaged in inappropriate practice across multiple item categories',
  'Services billed at higher levels than provided; Minimum time requirements not met; CDM documentation inadequate; Multiple services same day without clear indication',
  310000, 310000,
  '["Reprimanded", "Referred to Medical Board"]'::jsonb,
  '["Upcoding (billing higher-level items than service provided) combined with documentation failures can result in extended disqualification and professional body referral"]'::jsonb,
  '["No time documentation supporting billing level", "Incomplete CDM plans", "Missing clinical indication for multiple services"]'::jsonb,
  '2023-09-01',
  'https://www.psr.gov.au/case-outcomes/psr-directors-update-september-2023',
  'high', now(), now())
;

COMMIT;
-- Seeded 21 PSR cases
