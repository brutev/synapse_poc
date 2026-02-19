class AppConstants {
  const AppConstants._();

  static const int requestTimeoutSeconds = 30;
}

class ModuleTileConfig {
  const ModuleTileConfig({
    required this.sectionId,
    required this.code,
    required this.title,
    required this.stage,
  });

  final String sectionId;
  final String code;
  final String title;
  final String stage;
}

const List<ModuleTileConfig> loanModules = <ModuleTileConfig>[
  ModuleTileConfig(
    sectionId: 'applicant_kyc',
    code: 'T1',
    title: 'Applicant KYC',
    stage: 'Pre-Sanction',
  ),
  ModuleTileConfig(
    sectionId: 'collateral_details',
    code: 'T2',
    title: 'Collateral Details',
    stage: 'Pre-Sanction',
  ),
  ModuleTileConfig(
    sectionId: 'viability_credit',
    code: 'T3',
    title: 'Viability & Credit',
    stage: 'Pre-Sanction',
  ),
  ModuleTileConfig(
    sectionId: 'loan_terms',
    code: 'T4',
    title: 'Loan Terms, Charges & Payout',
    stage: 'Pre-Sanction',
  ),
  ModuleTileConfig(
    sectionId: 'co_applicant',
    code: 'T5',
    title: 'Co-Applicant',
    stage: 'Post-Sanction',
  ),
  ModuleTileConfig(
    sectionId: 'guarantor',
    code: 'T6',
    title: 'Guarantor',
    stage: 'Post-Sanction',
  ),
  ModuleTileConfig(
    sectionId: 'additional_info',
    code: 'T7',
    title: 'Additional Info',
    stage: 'Post-Sanction',
  ),
  ModuleTileConfig(
    sectionId: 'premises_verification',
    code: 'T8',
    title: 'Premises Verification',
    stage: 'Post-Sanction',
  ),
  ModuleTileConfig(
    sectionId: 'banking_payments',
    code: 'T9',
    title: 'Banking & Payments',
    stage: 'Post-Sanction',
  ),
  ModuleTileConfig(
    sectionId: 'document_upload',
    code: 'T10',
    title: 'Document Upload',
    stage: 'Post-Sanction',
  ),
  ModuleTileConfig(
    sectionId: 're_cse_note',
    code: 'T11',
    title: 'RE / CSE Note',
    stage: 'Post-Sanction',
  ),
];
