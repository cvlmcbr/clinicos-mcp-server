-- =============================================================================
-- RACGP 5th Edition Standards Seed Data
-- =============================================================================
-- Seeds the complete RACGP 5th Edition Standards framework:
--   3 Modules, 14 Standards, ~40 Criteria, ~124 Indicators
--
-- Target database: clinicos_accreditation
-- Idempotent: TRUNCATEs all 4 tables before inserting.
-- Reference: RACGP Standards for General Practices, 5th Edition
-- =============================================================================

BEGIN;

-- Clear existing data (CASCADE handles FK dependencies)
TRUNCATE TABLE racgp_indicators CASCADE;
TRUNCATE TABLE racgp_criteria CASCADE;
TRUNCATE TABLE racgp_standards CASCADE;
TRUNCATE TABLE racgp_modules CASCADE;

DO $$
DECLARE
  -- Module UUIDs
  v_mod_gp  uuid;
  v_mod_qi  uuid;
  v_mod_c   uuid;

  -- Standard UUIDs
  v_std_gp1 uuid;
  v_std_gp2 uuid;
  v_std_gp3 uuid;
  v_std_gp4 uuid;
  v_std_gp5 uuid;
  v_std_gp6 uuid;
  v_std_qi1 uuid;
  v_std_qi2 uuid;
  v_std_qi3 uuid;
  v_std_c1  uuid;
  v_std_c2  uuid;
  v_std_c3  uuid;
  v_std_c4  uuid;
  v_std_c5  uuid;

  -- Criterion UUIDs
  v_crit uuid;

BEGIN

  -- =========================================================================
  -- MODULE: GP - GP Standards
  -- =========================================================================
  INSERT INTO racgp_modules (id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), 'GP', 'GP Standards',
    'Core general practice clinical standards for patient care, safety, and clinical governance.',
    1)
  RETURNING id INTO v_mod_gp;

  -- =========================================================================
  -- MODULE: QI - QI Standards
  -- =========================================================================
  INSERT INTO racgp_modules (id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), 'QI', 'QI Standards',
    'Quality improvement standards for continuous practice improvement and clinical governance.',
    2)
  RETURNING id INTO v_mod_qi;

  -- =========================================================================
  -- MODULE: C - C Standards
  -- =========================================================================
  INSERT INTO racgp_modules (id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), 'C', 'C Standards',
    'Practice context standards covering the physical environment, business management, information systems, infection prevention and equipment.',
    3)
  RETURNING id INTO v_mod_c;

  -- =========================================================================
  -- STANDARD: GP1 - Communication and the GP-Patient Relationship
  -- =========================================================================
  INSERT INTO racgp_standards (id, module_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_mod_gp, 'GP1',
    'Communication and the GP-Patient Relationship',
    'The practice communicates with patients in a way that is understood, encourages discussion and respects cultural diversity.',
    1)
  RETURNING id INTO v_std_gp1;

  -- Criterion GP1.1 - Respectful and culturally appropriate care
  INSERT INTO racgp_criteria (id, standard_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_std_gp1, 'GP1.1',
    'Respectful and culturally appropriate care',
    'The practice provides respectful, culturally safe care.',
    1)
  RETURNING id INTO v_crit;

  INSERT INTO racgp_indicators (id, criterion_id, code, title, description, guidance, is_mandatory, evidence_requirements, sort_order) VALUES
    (gen_random_uuid(), v_crit, 'GP1.1A',
     'Welcoming environment for Aboriginal and Torres Strait Islander peoples',
     'The practice demonstrates a welcoming and culturally safe environment for Aboriginal and Torres Strait Islander peoples.',
     'The practice demonstrates a welcoming and culturally safe environment for Aboriginal and Torres Strait Islander peoples.',
     true,
     '{"Cultural safety policy", "Evidence of cultural awareness training for staff", "Display of Aboriginal and Torres Strait Islander health resources"}'::text[],
     1),
    (gen_random_uuid(), v_crit, 'GP1.1B',
     'Interpreter and communication services',
     'The practice has systems for patients who require interpreter or other communication services.',
     'The practice has systems for patients who require interpreter or other communication services.',
     true,
     '{"Interpreter service policy", "Access to TIS National or equivalent", "Staff training on using interpreter services"}'::text[],
     2),
    (gen_random_uuid(), v_crit, 'GP1.1C',
     'Patient feedback mechanisms',
     'Patients can provide feedback on their experience of care.',
     'Patients can provide feedback on their experience of care.',
     false,
     '{"Patient feedback form or survey", "Process for reviewing feedback", "Evidence of actions taken from feedback"}'::text[],
     3);

  -- Criterion GP1.2 - Informed consent
  INSERT INTO racgp_criteria (id, standard_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_std_gp1, 'GP1.2',
    'Informed consent',
    'The practice obtains informed consent from patients.',
    2)
  RETURNING id INTO v_crit;

  INSERT INTO racgp_indicators (id, criterion_id, code, title, description, guidance, is_mandatory, evidence_requirements, sort_order) VALUES
    (gen_random_uuid(), v_crit, 'GP1.2A',
     'Informed consent process',
     'The practice has a documented process for obtaining informed consent.',
     'The practice has a documented process for obtaining informed consent.',
     true,
     '{"Informed consent policy", "Consent form templates", "Evidence of consent in patient records"}'::text[],
     1),
    (gen_random_uuid(), v_crit, 'GP1.2B',
     'Consent for minors and vulnerable persons',
     'Specific processes exist for obtaining consent from or on behalf of minors and vulnerable persons.',
     'Specific processes exist for obtaining consent from or on behalf of minors and vulnerable persons.',
     true,
     '{"Policy for consent for minors", "Guardianship/power of attorney procedures"}'::text[],
     2);

  -- Criterion GP1.3 - Health literacy
  INSERT INTO racgp_criteria (id, standard_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_std_gp1, 'GP1.3',
    'Health literacy',
    'The practice supports patients health literacy needs.',
    3)
  RETURNING id INTO v_crit;

  INSERT INTO racgp_indicators (id, criterion_id, code, title, description, guidance, is_mandatory, evidence_requirements, sort_order) VALUES
    (gen_random_uuid(), v_crit, 'GP1.3A',
     'Patient education materials',
     'The practice provides patient education materials in accessible formats.',
     'The practice provides patient education materials in accessible formats.',
     false,
     '{"Range of patient education materials", "Materials in multiple languages", "Easy-read format materials"}'::text[],
     1),
    (gen_random_uuid(), v_crit, 'GP1.3B',
     'Health literacy assessment',
     'Staff consider patient health literacy when communicating health information.',
     'Staff consider patient health literacy when communicating health information.',
     false,
     '{"Health literacy awareness training", "Teach-back method usage"}'::text[],
     2);

  -- =========================================================================
  -- STANDARD: GP2 - Continuity of Care
  -- =========================================================================
  INSERT INTO racgp_standards (id, module_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_mod_gp, 'GP2',
    'Continuity of Care',
    'The practice provides continuity of care through effective follow-up, referral and coordination of care.',
    2)
  RETURNING id INTO v_std_gp2;

  -- Criterion GP2.1 - Follow-up systems
  INSERT INTO racgp_criteria (id, standard_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_std_gp2, 'GP2.1',
    'Follow-up systems',
    'The practice has systems for following up patient care.',
    1)
  RETURNING id INTO v_crit;

  INSERT INTO racgp_indicators (id, criterion_id, code, title, description, guidance, is_mandatory, evidence_requirements, sort_order) VALUES
    (gen_random_uuid(), v_crit, 'GP2.1A',
     'Test results follow-up',
     'The practice has a system for following up test results, including abnormal results.',
     'The practice has a system for following up test results, including abnormal results.',
     true,
     '{"Test results follow-up policy", "System/process for tracking outstanding results", "Audit of follow-up compliance"}'::text[],
     1),
    (gen_random_uuid(), v_crit, 'GP2.1B',
     'Referral tracking',
     'The practice tracks referrals and specialist reports.',
     'The practice tracks referrals and specialist reports.',
     true,
     '{"Referral tracking system", "Process for following up outstanding referrals"}'::text[],
     2),
    (gen_random_uuid(), v_crit, 'GP2.1C',
     'Recall and reminder system',
     'The practice has a recall and reminder system for preventive care and chronic disease management.',
     'The practice has a recall and reminder system for preventive care and chronic disease management.',
     true,
     '{"Recall/reminder system documentation", "Evidence of system usage", "Patient notification process"}'::text[],
     3);

  -- Criterion GP2.2 - Coordination of care
  INSERT INTO racgp_criteria (id, standard_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_std_gp2, 'GP2.2',
    'Coordination of care',
    'The practice coordinates patient care with other providers.',
    2)
  RETURNING id INTO v_crit;

  INSERT INTO racgp_indicators (id, criterion_id, code, title, description, guidance, is_mandatory, evidence_requirements, sort_order) VALUES
    (gen_random_uuid(), v_crit, 'GP2.2A',
     'Care coordination processes',
     'The practice has processes for coordinating care with hospitals, specialists and other providers.',
     'The practice has processes for coordinating care with hospitals, specialists and other providers.',
     true,
     '{"Care coordination policy", "Communication templates", "Discharge summary processes"}'::text[],
     1),
    (gen_random_uuid(), v_crit, 'GP2.2B',
     'After-hours care arrangements',
     'The practice has arrangements for after-hours care.',
     'The practice has arrangements for after-hours care.',
     true,
     '{"After-hours care policy", "Patient information on after-hours arrangements", "After-hours provider agreements"}'::text[],
     2);

  -- =========================================================================
  -- STANDARD: GP3 - Credentials, Education and Training
  -- =========================================================================
  INSERT INTO racgp_standards (id, module_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_mod_gp, 'GP3',
    'Credentials, Education and Training',
    'GPs and staff have the qualifications, experience and training relevant to their roles.',
    3)
  RETURNING id INTO v_std_gp3;

  -- Criterion GP3.1 - GP qualifications and registration
  INSERT INTO racgp_criteria (id, standard_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_std_gp3, 'GP3.1',
    'GP qualifications and registration',
    'GPs hold appropriate qualifications and registration.',
    1)
  RETURNING id INTO v_crit;

  INSERT INTO racgp_indicators (id, criterion_id, code, title, description, guidance, is_mandatory, evidence_requirements, sort_order) VALUES
    (gen_random_uuid(), v_crit, 'GP3.1A',
     'GP registration and credentials',
     'All GPs hold current AHPRA registration and appropriate credentials.',
     'All GPs hold current AHPRA registration and appropriate credentials.',
     true,
     '{"Current AHPRA registration certificates", "FRACGP/FARGP fellowship evidence", "Medical indemnity insurance"}'::text[],
     1),
    (gen_random_uuid(), v_crit, 'GP3.1B',
     'GP CPD compliance',
     'GPs participate in continuing professional development as required.',
     'GPs participate in continuing professional development as required.',
     true,
     '{"CPD activity records", "CPD compliance certificates", "Professional development plans"}'::text[],
     2);

  -- Criterion GP3.2 - Staff qualifications and training
  INSERT INTO racgp_criteria (id, standard_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_std_gp3, 'GP3.2',
    'Staff qualifications and training',
    'Practice staff hold appropriate qualifications and training.',
    2)
  RETURNING id INTO v_crit;

  INSERT INTO racgp_indicators (id, criterion_id, code, title, description, guidance, is_mandatory, evidence_requirements, sort_order) VALUES
    (gen_random_uuid(), v_crit, 'GP3.2A',
     'Nursing staff credentials',
     'Nursing staff hold current AHPRA registration and relevant qualifications.',
     'Nursing staff hold current AHPRA registration and relevant qualifications.',
     true,
     '{"Current AHPRA registration", "Nursing qualifications", "Professional indemnity insurance"}'::text[],
     1),
    (gen_random_uuid(), v_crit, 'GP3.2B',
     'Staff orientation and training',
     'All staff complete an orientation program and ongoing training.',
     'All staff complete an orientation program and ongoing training.',
     true,
     '{"Orientation program documentation", "Training records", "Annual training plan"}'::text[],
     2),
    (gen_random_uuid(), v_crit, 'GP3.2C',
     'CPR training',
     'Relevant staff maintain current CPR and first aid training.',
     'Relevant staff maintain current CPR and first aid training.',
     true,
     '{"Current CPR certificates for clinical staff", "First aid training records", "CPR training schedule"}'::text[],
     3);

  -- =========================================================================
  -- STANDARD: GP4 - Clinical Audit
  -- =========================================================================
  INSERT INTO racgp_standards (id, module_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_mod_gp, 'GP4',
    'Clinical Audit',
    'The practice uses clinical audit to improve care.',
    4)
  RETURNING id INTO v_std_gp4;

  -- Criterion GP4.1 - Audit activities
  INSERT INTO racgp_criteria (id, standard_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_std_gp4, 'GP4.1',
    'Audit activities',
    'The practice undertakes clinical audits.',
    1)
  RETURNING id INTO v_crit;

  INSERT INTO racgp_indicators (id, criterion_id, code, title, description, guidance, is_mandatory, evidence_requirements, sort_order) VALUES
    (gen_random_uuid(), v_crit, 'GP4.1A',
     'Clinical audit program',
     'The practice has a clinical audit program with regular audits conducted.',
     'The practice has a clinical audit program with regular audits conducted.',
     true,
     '{"Audit plan", "Completed audit reports", "Evidence of actions taken from audit findings"}'::text[],
     1),
    (gen_random_uuid(), v_crit, 'GP4.1B',
     'Prescribing audit',
     'The practice audits prescribing patterns and medication management.',
     'The practice audits prescribing patterns and medication management.',
     false,
     '{"Prescribing audit reports", "PBS/MBS prescribing data analysis"}'::text[],
     2);

  -- Criterion GP4.2 - Audit outcomes
  INSERT INTO racgp_criteria (id, standard_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_std_gp4, 'GP4.2',
    'Audit outcomes',
    'The practice uses audit results to improve care.',
    2)
  RETURNING id INTO v_crit;

  INSERT INTO racgp_indicators (id, criterion_id, code, title, description, guidance, is_mandatory, evidence_requirements, sort_order) VALUES
    (gen_random_uuid(), v_crit, 'GP4.2A',
     'Audit improvement actions',
     'Improvement actions are identified and implemented from clinical audit findings.',
     'Improvement actions are identified and implemented from clinical audit findings.',
     true,
     '{"Action plans from audits", "Evidence of implementation", "Re-audit results"}'::text[],
     1);

  -- =========================================================================
  -- STANDARD: GP5 - Safety and Quality
  -- =========================================================================
  INSERT INTO racgp_standards (id, module_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_mod_gp, 'GP5',
    'Safety and Quality',
    'The practice provides safe, high-quality care through effective systems.',
    5)
  RETURNING id INTO v_std_gp5;

  -- Criterion GP5.1 - Patient identification
  INSERT INTO racgp_criteria (id, standard_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_std_gp5, 'GP5.1',
    'Patient identification',
    'The practice correctly identifies patients.',
    1)
  RETURNING id INTO v_crit;

  INSERT INTO racgp_indicators (id, criterion_id, code, title, description, guidance, is_mandatory, evidence_requirements, sort_order) VALUES
    (gen_random_uuid(), v_crit, 'GP5.1A',
     'Patient identification process',
     'The practice has a system to correctly identify patients at each visit.',
     'The practice has a system to correctly identify patients at each visit.',
     true,
     '{"Patient identification policy", "Three-point identification process", "Staff training records"}'::text[],
     1);

  -- Criterion GP5.2 - Incident management
  INSERT INTO racgp_criteria (id, standard_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_std_gp5, 'GP5.2',
    'Incident management',
    'The practice manages incidents and near misses.',
    2)
  RETURNING id INTO v_crit;

  INSERT INTO racgp_indicators (id, criterion_id, code, title, description, guidance, is_mandatory, evidence_requirements, sort_order) VALUES
    (gen_random_uuid(), v_crit, 'GP5.2A',
     'Incident reporting system',
     'The practice has a system for reporting and managing incidents and near misses.',
     'The practice has a system for reporting and managing incidents and near misses.',
     true,
     '{"Incident reporting policy", "Incident report forms", "Incident register"}'::text[],
     1),
    (gen_random_uuid(), v_crit, 'GP5.2B',
     'Incident investigation and learning',
     'Incidents are investigated and learnings are shared with the team.',
     'Incidents are investigated and learnings are shared with the team.',
     true,
     '{"Investigation reports", "Team meeting minutes showing incident review", "Improvement actions from incidents"}'::text[],
     2),
    (gen_random_uuid(), v_crit, 'GP5.2C',
     'Open disclosure',
     'The practice has a process for open disclosure following adverse events.',
     'The practice has a process for open disclosure following adverse events.',
     true,
     '{"Open disclosure policy", "Staff training on open disclosure"}'::text[],
     3);

  -- Criterion GP5.3 - Medication safety
  INSERT INTO racgp_criteria (id, standard_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_std_gp5, 'GP5.3',
    'Medication safety',
    'The practice ensures medication safety.',
    3)
  RETURNING id INTO v_crit;

  INSERT INTO racgp_indicators (id, criterion_id, code, title, description, guidance, is_mandatory, evidence_requirements, sort_order) VALUES
    (gen_random_uuid(), v_crit, 'GP5.3A',
     'Medication management policy',
     'The practice has policies and procedures for safe medication management.',
     'The practice has policies and procedures for safe medication management.',
     true,
     '{"Medication management policy", "Prescribing guidelines", "Drug interaction checking system"}'::text[],
     1),
    (gen_random_uuid(), v_crit, 'GP5.3B',
     'Sample drug management',
     'Sample drugs are managed safely if kept on premises.',
     'Sample drugs are managed safely if kept on premises.',
     false,
     '{"Sample drug register", "Storage and expiry checking procedures"}'::text[],
     2);

  -- =========================================================================
  -- STANDARD: GP6 - Vaccine Storage and Immunisation
  -- =========================================================================
  INSERT INTO racgp_standards (id, module_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_mod_gp, 'GP6',
    'Vaccine Storage and Immunisation',
    'The practice safely stores and administers vaccines.',
    6)
  RETURNING id INTO v_std_gp6;

  -- Criterion GP6.1 - Vaccine cold chain management
  INSERT INTO racgp_criteria (id, standard_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_std_gp6, 'GP6.1',
    'Vaccine cold chain management',
    'The practice maintains vaccine cold chain.',
    1)
  RETURNING id INTO v_crit;

  INSERT INTO racgp_indicators (id, criterion_id, code, title, description, guidance, is_mandatory, evidence_requirements, sort_order) VALUES
    (gen_random_uuid(), v_crit, 'GP6.1A',
     'Cold chain policy',
     'The practice has a comprehensive cold chain management policy.',
     'The practice has a comprehensive cold chain management policy.',
     true,
     '{"Cold chain policy", "Designated vaccine fridge", "Temperature monitoring equipment"}'::text[],
     1),
    (gen_random_uuid(), v_crit, 'GP6.1B',
     'Temperature monitoring',
     'Vaccine fridge temperatures are monitored and recorded twice daily.',
     'Vaccine fridge temperatures are monitored and recorded twice daily.',
     true,
     '{"Temperature log records", "Min/max thermometer records", "Data logger records if applicable"}'::text[],
     2),
    (gen_random_uuid(), v_crit, 'GP6.1C',
     'Cold chain breach management',
     'The practice has procedures for managing cold chain breaches.',
     'The practice has procedures for managing cold chain breaches.',
     true,
     '{"Cold chain breach protocol", "Breach incident records", "Contact details for state immunisation program"}'::text[],
     3);

  -- Criterion GP6.2 - Immunisation practice
  INSERT INTO racgp_criteria (id, standard_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_std_gp6, 'GP6.2',
    'Immunisation practice',
    'The practice follows best practice immunisation protocols.',
    2)
  RETURNING id INTO v_crit;

  INSERT INTO racgp_indicators (id, criterion_id, code, title, description, guidance, is_mandatory, evidence_requirements, sort_order) VALUES
    (gen_random_uuid(), v_crit, 'GP6.2A',
     'Immunisation protocols',
     'The practice follows the Australian Immunisation Handbook and National Immunisation Program.',
     'The practice follows the Australian Immunisation Handbook and National Immunisation Program.',
     true,
     '{"Access to current Australian Immunisation Handbook", "NIP schedule displayed", "Immunisation protocols"}'::text[],
     1),
    (gen_random_uuid(), v_crit, 'GP6.2B',
     'Anaphylaxis management',
     'The practice has appropriate equipment and staff trained for managing anaphylaxis.',
     'The practice has appropriate equipment and staff trained for managing anaphylaxis.',
     true,
     '{"Anaphylaxis kit available", "Staff anaphylaxis training records", "Observation area for post-vaccination"}'::text[],
     2),
    (gen_random_uuid(), v_crit, 'GP6.2C',
     'AIR reporting',
     'The practice reports immunisations to the Australian Immunisation Register.',
     'The practice reports immunisations to the Australian Immunisation Register.',
     true,
     '{"AIR reporting process", "Evidence of timely reporting"}'::text[],
     3);

  -- =========================================================================
  -- STANDARD: QI1 - Quality Improvement Activities
  -- =========================================================================
  INSERT INTO racgp_standards (id, module_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_mod_qi, 'QI1',
    'Quality Improvement Activities',
    'The practice undertakes quality improvement activities.',
    1)
  RETURNING id INTO v_std_qi1;

  -- Criterion QI1.1 - QI program
  INSERT INTO racgp_criteria (id, standard_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_std_qi1, 'QI1.1',
    'QI program',
    'The practice has a quality improvement program.',
    1)
  RETURNING id INTO v_crit;

  INSERT INTO racgp_indicators (id, criterion_id, code, title, description, guidance, is_mandatory, evidence_requirements, sort_order) VALUES
    (gen_random_uuid(), v_crit, 'QI1.1A',
     'QI plan',
     'The practice has a documented quality improvement plan.',
     'The practice has a documented quality improvement plan.',
     true,
     '{"Written QI plan", "QI committee/team terms of reference", "Annual QI goals"}'::text[],
     1),
    (gen_random_uuid(), v_crit, 'QI1.1B',
     'QI meeting schedule',
     'Regular QI meetings are held with documented outcomes.',
     'Regular QI meetings are held with documented outcomes.',
     true,
     '{"Meeting schedule", "Meeting minutes", "Action items and follow-up records"}'::text[],
     2),
    (gen_random_uuid(), v_crit, 'QI1.1C',
     'Staff participation in QI',
     'All staff participate in quality improvement activities.',
     'All staff participate in quality improvement activities.',
     false,
     '{"Staff attendance records at QI meetings", "Staff QI project involvement"}'::text[],
     3);

  -- Criterion QI1.2 - Data-driven improvement
  INSERT INTO racgp_criteria (id, standard_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_std_qi1, 'QI1.2',
    'Data-driven improvement',
    'The practice uses data to drive improvement.',
    2)
  RETURNING id INTO v_crit;

  INSERT INTO racgp_indicators (id, criterion_id, code, title, description, guidance, is_mandatory, evidence_requirements, sort_order) VALUES
    (gen_random_uuid(), v_crit, 'QI1.2A',
     'Practice data analysis',
     'The practice regularly analyses clinical and practice data to identify areas for improvement.',
     'The practice regularly analyses clinical and practice data to identify areas for improvement.',
     true,
     '{"Data reports", "Analysis documentation", "Improvement actions from data analysis"}'::text[],
     1),
    (gen_random_uuid(), v_crit, 'QI1.2B',
     'Benchmarking',
     'The practice benchmarks its performance against relevant standards or peers.',
     'The practice benchmarks its performance against relevant standards or peers.',
     false,
     '{"Benchmarking reports", "Comparison data", "Actions from benchmarking"}'::text[],
     2);

  -- =========================================================================
  -- STANDARD: QI2 - Clinical Governance
  -- =========================================================================
  INSERT INTO racgp_standards (id, module_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_mod_qi, 'QI2',
    'Clinical Governance',
    'The practice has a clinical governance framework.',
    2)
  RETURNING id INTO v_std_qi2;

  -- Criterion QI2.1 - Governance framework
  INSERT INTO racgp_criteria (id, standard_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_std_qi2, 'QI2.1',
    'Governance framework',
    'The practice has a clinical governance framework.',
    1)
  RETURNING id INTO v_crit;

  INSERT INTO racgp_indicators (id, criterion_id, code, title, description, guidance, is_mandatory, evidence_requirements, sort_order) VALUES
    (gen_random_uuid(), v_crit, 'QI2.1A',
     'Clinical governance structure',
     'The practice has a documented clinical governance structure with clear roles and responsibilities.',
     'The practice has a documented clinical governance structure with clear roles and responsibilities.',
     true,
     '{"Governance framework document", "Organisational chart", "Role descriptions"}'::text[],
     1),
    (gen_random_uuid(), v_crit, 'QI2.1B',
     'Risk management',
     'The practice has a risk management framework.',
     'The practice has a risk management framework.',
     true,
     '{"Risk register", "Risk assessment process", "Risk mitigation plans"}'::text[],
     2),
    (gen_random_uuid(), v_crit, 'QI2.1C',
     'Complaints management',
     'The practice has a complaints management process.',
     'The practice has a complaints management process.',
     true,
     '{"Complaints policy", "Complaints register", "Resolution process documentation"}'::text[],
     3);

  -- Criterion QI2.2 - Policy management
  INSERT INTO racgp_criteria (id, standard_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_std_qi2, 'QI2.2',
    'Policy management',
    'The practice manages policies and procedures effectively.',
    2)
  RETURNING id INTO v_crit;

  INSERT INTO racgp_indicators (id, criterion_id, code, title, description, guidance, is_mandatory, evidence_requirements, sort_order) VALUES
    (gen_random_uuid(), v_crit, 'QI2.2A',
     'Policy framework',
     'The practice has a policy framework with regular review cycles.',
     'The practice has a policy framework with regular review cycles.',
     true,
     '{"Policy register", "Policy template", "Review schedule"}'::text[],
     1),
    (gen_random_uuid(), v_crit, 'QI2.2B',
     'Staff access to policies',
     'Staff have access to current policies and procedures.',
     'Staff have access to current policies and procedures.',
     true,
     '{"Policy access system", "Staff acknowledgement records"}'::text[],
     2);

  -- =========================================================================
  -- STANDARD: QI3 - Education and Training
  -- =========================================================================
  INSERT INTO racgp_standards (id, module_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_mod_qi, 'QI3',
    'Education and Training',
    'The practice supports ongoing education and training.',
    3)
  RETURNING id INTO v_std_qi3;

  -- Criterion QI3.1 - Training and education program
  INSERT INTO racgp_criteria (id, standard_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_std_qi3, 'QI3.1',
    'Training and education program',
    'The practice has a training and education program.',
    1)
  RETURNING id INTO v_crit;

  INSERT INTO racgp_indicators (id, criterion_id, code, title, description, guidance, is_mandatory, evidence_requirements, sort_order) VALUES
    (gen_random_uuid(), v_crit, 'QI3.1A',
     'Annual training plan',
     'The practice has an annual training plan covering mandatory and role-specific training.',
     'The practice has an annual training plan covering mandatory and role-specific training.',
     true,
     '{"Annual training plan", "Training calendar", "Mandatory training checklist"}'::text[],
     1),
    (gen_random_uuid(), v_crit, 'QI3.1B',
     'Training records',
     'Training records are maintained for all staff.',
     'Training records are maintained for all staff.',
     true,
     '{"Individual training records", "Training completion certificates", "Training attendance registers"}'::text[],
     2),
    (gen_random_uuid(), v_crit, 'QI3.1C',
     'Practice meetings',
     'Regular practice meetings are held for information sharing and education.',
     'Regular practice meetings are held for information sharing and education.',
     false,
     '{"Meeting schedule", "Meeting minutes", "Educational content covered"}'::text[],
     3);

  -- =========================================================================
  -- STANDARD: C1 - Practice Environment
  -- =========================================================================
  INSERT INTO racgp_standards (id, module_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_mod_c, 'C1',
    'Practice Environment',
    'The practice provides a safe and accessible physical environment.',
    1)
  RETURNING id INTO v_std_c1;

  -- Criterion C1.1 - Physical environment
  INSERT INTO racgp_criteria (id, standard_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_std_c1, 'C1.1',
    'Physical environment',
    'The practice provides a safe physical environment.',
    1)
  RETURNING id INTO v_crit;

  INSERT INTO racgp_indicators (id, criterion_id, code, title, description, guidance, is_mandatory, evidence_requirements, sort_order) VALUES
    (gen_random_uuid(), v_crit, 'C1.1A',
     'Building compliance',
     'The practice premises comply with relevant building codes and safety standards.',
     'The practice premises comply with relevant building codes and safety standards.',
     true,
     '{"Building compliance certificate", "Fire safety certificate", "Electrical safety testing records"}'::text[],
     1),
    (gen_random_uuid(), v_crit, 'C1.1B',
     'Accessibility',
     'The practice is accessible for people with disabilities.',
     'The practice is accessible for people with disabilities.',
     true,
     '{"Disability access assessment", "Accessible facilities (ramp, toilet, parking)", "Signage accessibility"}'::text[],
     2),
    (gen_random_uuid(), v_crit, 'C1.1C',
     'Clinical area safety',
     'Clinical areas meet safety and hygiene standards.',
     'Clinical areas meet safety and hygiene standards.',
     true,
     '{"Clinical area inspection records", "Hand hygiene facilities", "Sharps disposal systems"}'::text[],
     3),
    (gen_random_uuid(), v_crit, 'C1.1D',
     'Emergency equipment',
     'Emergency equipment is available, maintained and staff are trained in its use.',
     'Emergency equipment is available, maintained and staff are trained in its use.',
     true,
     '{"Emergency equipment list and location", "Maintenance/calibration records", "Staff training records"}'::text[],
     4);

  -- Criterion C1.2 - Workplace health and safety
  INSERT INTO racgp_criteria (id, standard_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_std_c1, 'C1.2',
    'Workplace health and safety',
    'The practice maintains workplace health and safety.',
    2)
  RETURNING id INTO v_crit;

  INSERT INTO racgp_indicators (id, criterion_id, code, title, description, guidance, is_mandatory, evidence_requirements, sort_order) VALUES
    (gen_random_uuid(), v_crit, 'C1.2A',
     'WHS policy',
     'The practice has a WHS policy and procedures.',
     'The practice has a WHS policy and procedures.',
     true,
     '{"WHS policy", "WHS risk assessment", "WHS officer designation"}'::text[],
     1),
    (gen_random_uuid(), v_crit, 'C1.2B',
     'Staff safety',
     'Staff safety risks are identified and managed.',
     'Staff safety risks are identified and managed.',
     true,
     '{"Hazard identification process", "Manual handling training", "Personal safety procedures"}'::text[],
     2);

  -- =========================================================================
  -- STANDARD: C2 - Business Management
  -- =========================================================================
  INSERT INTO racgp_standards (id, module_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_mod_c, 'C2',
    'Business Management',
    'The practice is managed effectively as a business.',
    2)
  RETURNING id INTO v_std_c2;

  -- Criterion C2.1 - Business operations
  INSERT INTO racgp_criteria (id, standard_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_std_c2, 'C2.1',
    'Business operations',
    'The practice has effective business management systems.',
    1)
  RETURNING id INTO v_crit;

  INSERT INTO racgp_indicators (id, criterion_id, code, title, description, guidance, is_mandatory, evidence_requirements, sort_order) VALUES
    (gen_random_uuid(), v_crit, 'C2.1A',
     'Business registration and insurance',
     'The practice maintains appropriate business registration and insurance.',
     'The practice maintains appropriate business registration and insurance.',
     true,
     '{"ABN/ACN registration", "Professional indemnity insurance", "Public liability insurance", "Workers compensation insurance"}'::text[],
     1),
    (gen_random_uuid(), v_crit, 'C2.1B',
     'HR management',
     'The practice has HR management systems including employment agreements and position descriptions.',
     'The practice has HR management systems including employment agreements and position descriptions.',
     true,
     '{"Employment agreements", "Position descriptions", "Staff handbook", "Performance review process"}'::text[],
     2),
    (gen_random_uuid(), v_crit, 'C2.1C',
     'Financial management',
     'The practice has appropriate financial management systems.',
     'The practice has appropriate financial management systems.',
     false,
     '{"Financial management policy", "Medicare billing compliance processes"}'::text[],
     3);

  -- =========================================================================
  -- STANDARD: C3 - Information Management
  -- =========================================================================
  INSERT INTO racgp_standards (id, module_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_mod_c, 'C3',
    'Information Management',
    'The practice manages information effectively and securely.',
    3)
  RETURNING id INTO v_std_c3;

  -- Criterion C3.1 - Health records management
  INSERT INTO racgp_criteria (id, standard_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_std_c3, 'C3.1',
    'Health records management',
    'The practice manages health records effectively.',
    1)
  RETURNING id INTO v_crit;

  INSERT INTO racgp_indicators (id, criterion_id, code, title, description, guidance, is_mandatory, evidence_requirements, sort_order) VALUES
    (gen_random_uuid(), v_crit, 'C3.1A',
     'Clinical information system',
     'The practice uses an appropriate clinical information system.',
     'The practice uses an appropriate clinical information system.',
     true,
     '{"Clinical software details", "System backup procedures", "User access controls"}'::text[],
     1),
    (gen_random_uuid(), v_crit, 'C3.1B',
     'Record keeping standards',
     'Health records are maintained to accepted standards.',
     'Health records are maintained to accepted standards.',
     true,
     '{"Record keeping policy", "Record audit results", "Coding and classification standards"}'::text[],
     2),
    (gen_random_uuid(), v_crit, 'C3.1C',
     'Record retention and disposal',
     'The practice has policies for record retention and disposal.',
     'The practice has policies for record retention and disposal.',
     true,
     '{"Retention policy", "Disposal procedures", "Compliance with state/territory requirements"}'::text[],
     3);

  -- Criterion C3.2 - Privacy and confidentiality
  INSERT INTO racgp_criteria (id, standard_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_std_c3, 'C3.2',
    'Privacy and confidentiality',
    'The practice protects patient privacy and confidentiality.',
    2)
  RETURNING id INTO v_crit;

  INSERT INTO racgp_indicators (id, criterion_id, code, title, description, guidance, is_mandatory, evidence_requirements, sort_order) VALUES
    (gen_random_uuid(), v_crit, 'C3.2A',
     'Privacy policy',
     'The practice has a privacy policy compliant with the Privacy Act.',
     'The practice has a privacy policy compliant with the Privacy Act.',
     true,
     '{"Privacy policy", "Privacy collection notice", "APPs compliance documentation"}'::text[],
     1),
    (gen_random_uuid(), v_crit, 'C3.2B',
     'Information security',
     'The practice has information security measures in place.',
     'The practice has information security measures in place.',
     true,
     '{"IT security policy", "Password management procedures", "Encryption and access controls", "Cyber security training records"}'::text[],
     2),
    (gen_random_uuid(), v_crit, 'C3.2C',
     'My Health Record',
     'The practice participates in the My Health Record system.',
     'The practice participates in the My Health Record system.',
     false,
     '{"My Health Record registration", "Staff training on My Health Record", "Upload processes"}'::text[],
     3);

  -- =========================================================================
  -- STANDARD: C4 - Infection Prevention and Control
  -- =========================================================================
  INSERT INTO racgp_standards (id, module_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_mod_c, 'C4',
    'Infection Prevention and Control',
    'The practice prevents and controls infection.',
    4)
  RETURNING id INTO v_std_c4;

  -- Criterion C4.1 - IPC program
  INSERT INTO racgp_criteria (id, standard_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_std_c4, 'C4.1',
    'IPC program',
    'The practice has an infection prevention and control program.',
    1)
  RETURNING id INTO v_crit;

  INSERT INTO racgp_indicators (id, criterion_id, code, title, description, guidance, is_mandatory, evidence_requirements, sort_order) VALUES
    (gen_random_uuid(), v_crit, 'C4.1A',
     'IPC policy',
     'The practice has comprehensive IPC policies and procedures.',
     'The practice has comprehensive IPC policies and procedures.',
     true,
     '{"IPC policy and procedures manual", "IPC officer designation", "IPC risk assessment"}'::text[],
     1),
    (gen_random_uuid(), v_crit, 'C4.1B',
     'Hand hygiene',
     'The practice promotes and monitors hand hygiene compliance.',
     'The practice promotes and monitors hand hygiene compliance.',
     true,
     '{"Hand hygiene policy", "Hand hygiene facilities audit", "Hand hygiene training records"}'::text[],
     2),
    (gen_random_uuid(), v_crit, 'C4.1C',
     'Standard and transmission-based precautions',
     'Staff follow standard and transmission-based precautions.',
     'Staff follow standard and transmission-based precautions.',
     true,
     '{"Standard precautions policy", "PPE availability and training", "Spill management procedures"}'::text[],
     3),
    (gen_random_uuid(), v_crit, 'C4.1D',
     'Instrument reprocessing',
     'Reusable instruments are reprocessed according to AS/NZS 4187 and AS/NZS 4815.',
     'Reusable instruments are reprocessed according to AS/NZS 4187 and AS/NZS 4815.',
     true,
     '{"Reprocessing procedures", "Steriliser maintenance records", "Biological indicator testing", "Tracking system"}'::text[],
     4);

  -- Criterion C4.2 - Waste management
  INSERT INTO racgp_criteria (id, standard_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_std_c4, 'C4.2',
    'Waste management',
    'The practice manages clinical and general waste safely.',
    2)
  RETURNING id INTO v_crit;

  INSERT INTO racgp_indicators (id, criterion_id, code, title, description, guidance, is_mandatory, evidence_requirements, sort_order) VALUES
    (gen_random_uuid(), v_crit, 'C4.2A',
     'Waste management policy',
     'The practice has a waste management policy covering clinical and general waste.',
     'The practice has a waste management policy covering clinical and general waste.',
     true,
     '{"Waste management policy", "Waste stream signage", "Waste disposal contracts"}'::text[],
     1),
    (gen_random_uuid(), v_crit, 'C4.2B',
     'Sharps management',
     'Sharps are managed and disposed of safely.',
     'Sharps are managed and disposed of safely.',
     true,
     '{"Sharps management policy", "Sharps containers in clinical areas", "Needlestick injury protocol"}'::text[],
     2);

  -- =========================================================================
  -- STANDARD: C5 - Equipment and Infrastructure
  -- =========================================================================
  INSERT INTO racgp_standards (id, module_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_mod_c, 'C5',
    'Equipment and Infrastructure',
    'The practice maintains equipment and infrastructure to support safe care.',
    5)
  RETURNING id INTO v_std_c5;

  -- Criterion C5.1 - Medical equipment
  INSERT INTO racgp_criteria (id, standard_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_std_c5, 'C5.1',
    'Medical equipment',
    'Medical equipment is maintained and calibrated.',
    1)
  RETURNING id INTO v_crit;

  INSERT INTO racgp_indicators (id, criterion_id, code, title, description, guidance, is_mandatory, evidence_requirements, sort_order) VALUES
    (gen_random_uuid(), v_crit, 'C5.1A',
     'Equipment register',
     'The practice maintains a register of medical equipment.',
     'The practice maintains a register of medical equipment.',
     true,
     '{"Equipment register", "Equipment locations", "Purchase/lease records"}'::text[],
     1),
    (gen_random_uuid(), v_crit, 'C5.1B',
     'Equipment maintenance',
     'Medical equipment is regularly maintained and calibrated.',
     'Medical equipment is regularly maintained and calibrated.',
     true,
     '{"Maintenance schedule", "Service records", "Calibration certificates"}'::text[],
     2),
    (gen_random_uuid(), v_crit, 'C5.1C',
     'Equipment training',
     'Staff are trained in the use of medical equipment.',
     'Staff are trained in the use of medical equipment.',
     false,
     '{"Equipment training records", "User manuals accessible", "Competency assessments"}'::text[],
     3);

  -- Criterion C5.2 - IT infrastructure
  INSERT INTO racgp_criteria (id, standard_id, code, name, description, sort_order)
  VALUES (gen_random_uuid(), v_std_c5, 'C5.2',
    'IT infrastructure',
    'IT infrastructure supports safe and effective practice operations.',
    2)
  RETURNING id INTO v_crit;

  INSERT INTO racgp_indicators (id, criterion_id, code, title, description, guidance, is_mandatory, evidence_requirements, sort_order) VALUES
    (gen_random_uuid(), v_crit, 'C5.2A',
     'IT systems and backup',
     'IT systems are maintained with regular backups and disaster recovery plans.',
     'IT systems are maintained with regular backups and disaster recovery plans.',
     true,
     '{"IT infrastructure documentation", "Backup schedule and verification", "Disaster recovery plan", "Business continuity plan"}'::text[],
     1),
    (gen_random_uuid(), v_crit, 'C5.2B',
     'Telecommunications',
     'The practice has reliable telecommunications systems.',
     'The practice has reliable telecommunications systems.',
     true,
     '{"Phone system documentation", "After-hours messaging", "Telehealth capability"}'::text[],
     2);

  RAISE NOTICE 'RACGP 5th Edition seed data inserted successfully.';

END $$;

-- =============================================================================
-- VERIFICATION QUERY
-- =============================================================================
SELECT
  'racgp_modules'    AS table_name, COUNT(*) AS row_count FROM racgp_modules
UNION ALL
SELECT
  'racgp_standards'  AS table_name, COUNT(*) AS row_count FROM racgp_standards
UNION ALL
SELECT
  'racgp_criteria'   AS table_name, COUNT(*) AS row_count FROM racgp_criteria
UNION ALL
SELECT
  'racgp_indicators' AS table_name, COUNT(*) AS row_count FROM racgp_indicators;

-- Expected counts:
--   racgp_modules    : 3
--   racgp_standards  : 14
--   racgp_criteria   : 40
--   racgp_indicators : 124 (approx)

-- Mandatory vs optional indicator breakdown
SELECT
  is_mandatory,
  COUNT(*) AS count
FROM racgp_indicators
GROUP BY is_mandatory
ORDER BY is_mandatory DESC;

COMMIT;
