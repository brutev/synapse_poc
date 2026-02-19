import '../components/static_form/domain/static_form_models.dart';

final Map<String, StaticSectionSchema> staticModuleSchemas =
    <String, StaticSectionSchema>{
      'applicant_kyc': _buildSection(
        sectionId: 'applicant_kyc',
        title: 'Applicant KYC',
        prefix: 'applicant_kyc',
        totalFields: 28,
        cards: <_CardSeed>[
          _CardSeed(
            cardId: 'identity',
            title: 'Identity Details',
            targetCount: 10,
            fields: <StaticFieldSchema>[
              const StaticFieldSchema(
                fieldId: 'applicant_name',
                label: 'Applicant Name',
                type: StaticFieldType.text,
              ),
              const StaticFieldSchema(
                fieldId: 'pan_number',
                label: 'PAN Number',
                type: StaticFieldType.text,
              ),
              const StaticFieldSchema(
                fieldId: 'aadhaar_number',
                label: 'Aadhaar Number',
                type: StaticFieldType.number,
              ),
              const StaticFieldSchema(
                fieldId: 'kyc_verified',
                label: 'KYC Verified',
                type: StaticFieldType.dropdown,
                defaultOptions: <String>['Yes', 'No'],
              ),
              const StaticFieldSchema(
                fieldId: 'kyc_remarks',
                label: 'KYC Remarks',
                type: StaticFieldType.text,
              ),
            ],
          ),
          const _CardSeed(
            cardId: 'personal',
            title: 'Personal Details',
            targetCount: 9,
          ),
          const _CardSeed(
            cardId: 'address',
            title: 'Address Details',
            targetCount: 9,
          ),
        ],
      ),
      'collateral_details': _buildSection(
        sectionId: 'collateral_details',
        title: 'Collateral Details',
        prefix: 'collateral_details',
        totalFields: 70,
        cards: <_CardSeed>[
          _CardSeed(
            cardId: 'asset',
            title: 'Asset Information',
            targetCount: 35,
            fields: <StaticFieldSchema>[
              const StaticFieldSchema(
                fieldId: 'vehicle_type',
                label: 'Vehicle Type',
                type: StaticFieldType.dropdown,
                defaultOptions: <String>['Truck', 'Tipper', 'LCV'],
              ),
              const StaticFieldSchema(
                fieldId: 'vehicle_cost',
                label: 'Vehicle Cost',
                type: StaticFieldType.number,
              ),
              const StaticFieldSchema(
                fieldId: 'margin_percent',
                label: 'Margin %',
                type: StaticFieldType.number,
              ),
              const StaticFieldSchema(
                fieldId: 'loan_eligible',
                label: 'Loan Eligible Amount',
                type: StaticFieldType.number,
              ),
            ],
          ),
          const _CardSeed(
            cardId: 'vehicle_details',
            title: 'Vehicle Details',
            targetCount: 35,
          ),
        ],
      ),
      'viability_credit': _buildSection(
        sectionId: 'viability_credit',
        title: 'Viability & Credit',
        prefix: 'viability_credit',
        totalFields: 30,
        cards: <_CardSeed>[
          _CardSeed(
            cardId: 'income',
            title: 'Income Analysis',
            targetCount: 8,
            fields: <StaticFieldSchema>[
              const StaticFieldSchema(
                fieldId: 'monthly_income',
                label: 'Monthly Income',
                type: StaticFieldType.number,
              ),
              const StaticFieldSchema(
                fieldId: 'existing_emi',
                label: 'Existing EMI',
                type: StaticFieldType.number,
              ),
              const StaticFieldSchema(
                fieldId: 'foir_percent',
                label: 'FOIR %',
                type: StaticFieldType.number,
              ),
              const StaticFieldSchema(
                fieldId: 'credit_score',
                label: 'Credit Score',
                type: StaticFieldType.number,
              ),
              const StaticFieldSchema(
                fieldId: 'risk_band',
                label: 'Risk Band',
                type: StaticFieldType.dropdown,
                defaultOptions: <String>['Low', 'Medium', 'High'],
              ),
            ],
          ),
          const _CardSeed(
            cardId: 'foir',
            title: 'FOIR Analysis',
            targetCount: 7,
          ),
          const _CardSeed(
            cardId: 'credit_summary',
            title: 'Credit Summary',
            targetCount: 7,
          ),
          const _CardSeed(
            cardId: 'decision_inputs',
            title: 'Decision Inputs',
            targetCount: 8,
          ),
        ],
      ),
      'loan_terms': _buildSection(
        sectionId: 'loan_terms',
        title: 'Loan Terms, Charges & Payout',
        prefix: 'loan_terms',
        totalFields: 37,
        cards: <_CardSeed>[
          _CardSeed(
            cardId: 'terms',
            title: 'Loan Terms',
            targetCount: 37,
            fields: <StaticFieldSchema>[
              const StaticFieldSchema(
                fieldId: 'loan_amount',
                label: 'Loan Amount',
                type: StaticFieldType.number,
              ),
              const StaticFieldSchema(
                fieldId: 'tenure_months',
                label: 'Tenure (Months)',
                type: StaticFieldType.number,
              ),
              const StaticFieldSchema(
                fieldId: 'interest_rate',
                label: 'Interest Rate %',
                type: StaticFieldType.number,
              ),
              const StaticFieldSchema(
                fieldId: 'processing_fee',
                label: 'Processing Fee',
                type: StaticFieldType.number,
              ),
              const StaticFieldSchema(
                fieldId: 'net_disbursal',
                label: 'Net Disbursal',
                type: StaticFieldType.number,
              ),
            ],
          ),
        ],
      ),
      'co_applicant': _buildSection(
        sectionId: 'co_applicant',
        title: 'Co-Applicant',
        prefix: 'co_applicant',
        totalFields: 41,
        cards: <_CardSeed>[
          _CardSeed(
            cardId: 'co_profile',
            title: 'Co-Applicant Profile',
            targetCount: 11,
            fields: <StaticFieldSchema>[
              const StaticFieldSchema(
                fieldId: 'has_coapplicant',
                label: 'Has Co-Applicant?',
                type: StaticFieldType.dropdown,
                defaultOptions: <String>['Yes', 'No'],
              ),
              const StaticFieldSchema(
                fieldId: 'coapplicant_name',
                label: 'Co-Applicant Name',
                type: StaticFieldType.text,
              ),
              const StaticFieldSchema(
                fieldId: 'coapplicant_relationship',
                label: 'Relationship',
                type: StaticFieldType.dropdown,
              ),
            ],
          ),
          const _CardSeed(
            cardId: 'co_kyc',
            title: 'Co-Applicant KYC',
            targetCount: 10,
          ),
          const _CardSeed(
            cardId: 'co_income',
            title: 'Co-Applicant Income',
            targetCount: 10,
          ),
          const _CardSeed(
            cardId: 'co_address',
            title: 'Co-Applicant Address',
            targetCount: 10,
          ),
        ],
      ),
      'guarantor': _buildSection(
        sectionId: 'guarantor',
        title: 'Guarantor',
        prefix: 'guarantor',
        totalFields: 42,
        cards: <_CardSeed>[
          _CardSeed(
            cardId: 'guarantor_details',
            title: 'Guarantor Details',
            targetCount: 11,
            fields: <StaticFieldSchema>[
              const StaticFieldSchema(
                fieldId: 'has_guarantor',
                label: 'Has Guarantor?',
                type: StaticFieldType.dropdown,
                defaultOptions: <String>['Yes', 'No'],
              ),
              const StaticFieldSchema(
                fieldId: 'guarantor_name',
                label: 'Guarantor Name',
                type: StaticFieldType.text,
              ),
              const StaticFieldSchema(
                fieldId: 'guarantor_pan',
                label: 'Guarantor PAN',
                type: StaticFieldType.text,
              ),
            ],
          ),
          const _CardSeed(
            cardId: 'guarantor_kyc',
            title: 'Guarantor KYC',
            targetCount: 10,
          ),
          const _CardSeed(
            cardId: 'guarantor_financials',
            title: 'Guarantor Financials',
            targetCount: 10,
          ),
          const _CardSeed(
            cardId: 'guarantor_address',
            title: 'Guarantor Address',
            targetCount: 11,
          ),
        ],
      ),
      'additional_info': _buildSection(
        sectionId: 'additional_info',
        title: 'Additional Info',
        prefix: 'additional_info',
        totalFields: 44,
        cards: <_CardSeed>[
          _CardSeed(
            cardId: 'business_meta',
            title: 'Business Information',
            targetCount: 9,
            fields: <StaticFieldSchema>[
              const StaticFieldSchema(
                fieldId: 'business_vintage',
                label: 'Business Vintage (Years)',
                type: StaticFieldType.number,
              ),
              const StaticFieldSchema(
                fieldId: 'gst_available',
                label: 'GST Available',
                type: StaticFieldType.dropdown,
                defaultOptions: <String>['Yes', 'No'],
              ),
              const StaticFieldSchema(
                fieldId: 'gst_number',
                label: 'GST Number',
                type: StaticFieldType.text,
              ),
            ],
          ),
          const _CardSeed(
            cardId: 'operational_info',
            title: 'Operational Info',
            targetCount: 9,
          ),
          const _CardSeed(
            cardId: 'deviation_info',
            title: 'Deviation Info',
            targetCount: 9,
          ),
          const _CardSeed(
            cardId: 'reference_checks',
            title: 'Reference Checks',
            targetCount: 8,
          ),
          const _CardSeed(
            cardId: 'misc_info',
            title: 'Miscellaneous Info',
            targetCount: 9,
          ),
        ],
      ),
      'premises_verification': _buildSection(
        sectionId: 'premises_verification',
        title: 'Premises Verification',
        prefix: 'premises_verification',
        totalFields: 34,
        cards: <_CardSeed>[
          _CardSeed(
            cardId: 'pv_details',
            title: 'Premises Details',
            targetCount: 17,
            fields: <StaticFieldSchema>[
              const StaticFieldSchema(
                fieldId: 'premises_type',
                label: 'Premises Type',
                type: StaticFieldType.dropdown,
              ),
              const StaticFieldSchema(
                fieldId: 'verified_on',
                label: 'Verified On',
                type: StaticFieldType.date,
              ),
              const StaticFieldSchema(
                fieldId: 'premises_score',
                label: 'Premises Score',
                type: StaticFieldType.number,
              ),
            ],
          ),
          const _CardSeed(
            cardId: 'geo_and_photos',
            title: 'Geo & Photo Evidence',
            targetCount: 17,
          ),
        ],
      ),
      'banking_payments': _buildSection(
        sectionId: 'banking_payments',
        title: 'Banking & Payments',
        prefix: 'banking_payments',
        totalFields: 28,
        cards: <_CardSeed>[
          _CardSeed(
            cardId: 'banking',
            title: 'Primary Banking',
            targetCount: 7,
            fields: <StaticFieldSchema>[
              const StaticFieldSchema(
                fieldId: 'bank_name',
                label: 'Primary Bank',
                type: StaticFieldType.text,
              ),
              const StaticFieldSchema(
                fieldId: 'avg_balance',
                label: 'Average Balance',
                type: StaticFieldType.number,
              ),
              const StaticFieldSchema(
                fieldId: 'emi_mode',
                label: 'EMI Mode',
                type: StaticFieldType.dropdown,
              ),
            ],
          ),
          const _CardSeed(
            cardId: 'repayment_setup',
            title: 'Repayment Setup',
            targetCount: 7,
          ),
          const _CardSeed(
            cardId: 'bank_statement_analysis',
            title: 'Bank Statement Analysis',
            targetCount: 7,
          ),
          const _CardSeed(
            cardId: 'payment_controls',
            title: 'Payment Controls',
            targetCount: 7,
          ),
        ],
      ),
      'document_upload': _buildSection(
        sectionId: 'document_upload',
        title: 'Document Upload',
        prefix: 'document_upload',
        totalFields: 16,
        cards: <_CardSeed>[
          _CardSeed(
            cardId: 'docs',
            title: 'Upload Status',
            targetCount: 16,
            fields: <StaticFieldSchema>[
              const StaticFieldSchema(
                fieldId: 'kyc_uploaded',
                label: 'KYC Uploaded',
                type: StaticFieldType.dropdown,
                defaultOptions: <String>['Yes', 'No'],
              ),
              const StaticFieldSchema(
                fieldId: 'bank_statement_uploaded',
                label: 'Bank Statement Uploaded',
                type: StaticFieldType.dropdown,
                defaultOptions: <String>['Yes', 'No'],
              ),
              const StaticFieldSchema(
                fieldId: 'upload_remarks',
                label: 'Upload Remarks',
                type: StaticFieldType.text,
              ),
            ],
          ),
        ],
      ),
      're_cse_note': _buildSection(
        sectionId: 're_cse_note',
        title: 'RE / CSE Note',
        prefix: 're_cse_note',
        totalFields: 16,
        cards: <_CardSeed>[
          _CardSeed(
            cardId: 'notes',
            title: 'Notes',
            targetCount: 16,
            fields: <StaticFieldSchema>[
              const StaticFieldSchema(
                fieldId: 're_note',
                label: 'RE Note',
                type: StaticFieldType.text,
              ),
              const StaticFieldSchema(
                fieldId: 'cse_note',
                label: 'CSE Note',
                type: StaticFieldType.text,
              ),
              const StaticFieldSchema(
                fieldId: 'final_decision',
                label: 'Final Decision',
                type: StaticFieldType.dropdown,
                defaultOptions: <String>['Approve', 'Review', 'Reject'],
              ),
            ],
          ),
        ],
      ),
    };

StaticSectionSchema _buildSection({
  required String sectionId,
  required String title,
  required String prefix,
  required int totalFields,
  required List<_CardSeed> cards,
}) {
  final List<StaticCardSchema> outputCards = <StaticCardSchema>[];
  int generatedCounter = 1;

  for (final _CardSeed card in cards) {
    final List<StaticFieldSchema> fields = List<StaticFieldSchema>.from(
      card.fields,
    );

    while (fields.length < card.targetCount) {
      fields.add(
        _generatedField(
          prefix: prefix,
          cardId: card.cardId,
          cardTitle: card.title,
          counter: generatedCounter,
        ),
      );
      generatedCounter += 1;
    }

    outputCards.add(
      StaticCardSchema(cardId: card.cardId, title: card.title, fields: fields),
    );
  }

  int currentCount = _countFields(outputCards);
  while (currentCount < totalFields && outputCards.isNotEmpty) {
    final StaticCardSchema targetCard = outputCards.last;
    outputCards.last.fields.add(
      _generatedField(
        prefix: prefix,
        cardId: targetCard.cardId,
        cardTitle: targetCard.title,
        counter: generatedCounter,
      ),
    );
    generatedCounter += 1;
    currentCount += 1;
  }

  return StaticSectionSchema(
    sectionId: sectionId,
    title: title,
    cards: outputCards,
  );
}

StaticFieldSchema _generatedField({
  required String prefix,
  required String cardId,
  required String cardTitle,
  required int counter,
}) {
  final String fieldId =
      '${prefix}_${cardId}_field_${counter.toString().padLeft(3, '0')}';
  final int mode = counter % 5;

  if (mode == 0) {
    return StaticFieldSchema(
      fieldId: fieldId,
      label: _labelFromContext(prefix, cardTitle, counter),
      type: StaticFieldType.dropdown,
      defaultOptions: const <String>['Option A', 'Option B', 'Option C'],
    );
  }
  if (mode == 1) {
    return StaticFieldSchema(
      fieldId: fieldId,
      label: _labelFromContext(prefix, cardTitle, counter),
      type: StaticFieldType.text,
    );
  }
  if (mode == 2) {
    return StaticFieldSchema(
      fieldId: fieldId,
      label: _labelFromContext(prefix, cardTitle, counter),
      type: StaticFieldType.number,
    );
  }
  if (mode == 3) {
    return StaticFieldSchema(
      fieldId: fieldId,
      label: _labelFromContext(prefix, cardTitle, counter),
      type: StaticFieldType.date,
    );
  }

  return StaticFieldSchema(
    fieldId: fieldId,
    label: _labelFromContext(prefix, cardTitle, counter),
    type: StaticFieldType.text,
  );
}

String _labelFromContext(String prefix, String cardTitle, int counter) {
  final String pretty = prefix
      .split('_')
      .map(
        (String part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
  return '$pretty - $cardTitle Field $counter';
}

int _countFields(List<StaticCardSchema> cards) {
  int total = 0;
  for (final StaticCardSchema card in cards) {
    total += card.fields.length;
  }
  return total;
}

class _CardSeed {
  const _CardSeed({
    required this.cardId,
    required this.title,
    required this.targetCount,
    this.fields = const <StaticFieldSchema>[],
  });

  final String cardId;
  final String title;
  final int targetCount;
  final List<StaticFieldSchema> fields;
}
