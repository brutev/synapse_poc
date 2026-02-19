enum ModuleRendererType { staticUi, dynamicUi }

class ModuleRouteResolver {
  const ModuleRouteResolver._();

  static const Map<String, ModuleRendererType> rendererBySection =
      <String, ModuleRendererType>{
        'applicant_kyc': ModuleRendererType.staticUi,
        'collateral_details': ModuleRendererType.staticUi,
        'viability_credit': ModuleRendererType.staticUi,
        'loan_terms': ModuleRendererType.staticUi,
        'co_applicant': ModuleRendererType.staticUi,
        'guarantor': ModuleRendererType.staticUi,
        'additional_info': ModuleRendererType.staticUi,
        'premises_verification': ModuleRendererType.staticUi,
        'banking_payments': ModuleRendererType.staticUi,
        'document_upload': ModuleRendererType.staticUi,
        're_cse_note': ModuleRendererType.staticUi,
      };

  static ModuleRendererType resolve(String sectionId) {
    return rendererBySection[sectionId] ?? ModuleRendererType.dynamicUi;
  }
}
