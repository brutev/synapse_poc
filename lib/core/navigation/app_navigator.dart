import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../components/form_engine/presentation/pages/dynamic_form_page.dart';
import '../../features/additional_info/presentation/pages/additional_info_page.dart';
import '../../features/applicant_kyc/presentation/pages/applicant_kyc_page.dart';
import '../../features/banking_payments/presentation/pages/banking_payments_page.dart';
import '../../features/co_applicant/presentation/pages/co_applicant_page.dart';
import '../../features/collateral_details/presentation/pages/collateral_details_page.dart';
import '../../features/document_upload/presentation/pages/document_upload_page.dart';
import '../../features/guarantor/presentation/pages/guarantor_page.dart';
import '../../features/loan_terms/presentation/pages/loan_terms_page.dart';
import '../../features/premises_verification/presentation/pages/premises_verification_page.dart';
import '../../features/re_cse_note/presentation/pages/re_cse_note_page.dart';
import '../../features/viability_credit/presentation/pages/viability_credit_page.dart';
import '../common_pages/dashboard_page.dart';
import '../common_pages/leads_page.dart';
import '../common_pages/module_board_page.dart';
import '../common_pages/page_not_found_page.dart';
import '../common_pages/proposals_page.dart';
import 'module_route_resolver.dart';

class AppNavigator {
  const AppNavigator._();

  static GoRouter createRouter() {
    return GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const DashboardPage(),
        ),
        GoRoute(
          path: '/leads',
          builder: (BuildContext context, GoRouterState state) =>
              const LeadsPage(),
        ),
        GoRoute(
          path: '/proposals',
          builder: (BuildContext context, GoRouterState state) =>
              const ProposalsPage(),
        ),
        GoRoute(
          path: '/proposal/:applicationId/modules',
          builder: (BuildContext context, GoRouterState state) {
            final String applicationId =
                state.pathParameters['applicationId'] ?? '';
            return ModuleBoardPage(applicationId: applicationId);
          },
        ),
        GoRoute(
          path: '/proposal/:applicationId/module/:moduleId',
          builder: (BuildContext context, GoRouterState state) {
            final String moduleId = state.pathParameters['moduleId'] ?? '';
            final String applicationId =
                state.pathParameters['applicationId'] ?? '';
            final ModuleRendererType renderer = ModuleRouteResolver.resolve(
              moduleId,
            );

            if (renderer == ModuleRendererType.dynamicUi) {
              return DynamicFormPage(
                applicationId: applicationId,
                sectionId: moduleId,
              );
            }

            switch (moduleId) {
              case 'applicant_kyc':
                return ApplicantKycPage(applicationId: applicationId);
              case 'collateral_details':
                return CollateralDetailsPage(applicationId: applicationId);
              case 'viability_credit':
                return ViabilityCreditPage(applicationId: applicationId);
              case 'loan_terms':
                return LoanTermsPage(applicationId: applicationId);
              case 'co_applicant':
                return CoApplicantPage(applicationId: applicationId);
              case 'guarantor':
                return GuarantorPage(applicationId: applicationId);
              case 'additional_info':
                return AdditionalInfoPage(applicationId: applicationId);
              case 'premises_verification':
                return PremisesVerificationPage(applicationId: applicationId);
              case 'banking_payments':
                return BankingPaymentsPage(applicationId: applicationId);
              case 'document_upload':
                return DocumentUploadPage(applicationId: applicationId);
              case 're_cse_note':
                return ReCseNotePage(applicationId: applicationId);
              default:
                return DynamicFormPage(
                  applicationId: applicationId,
                  sectionId: moduleId,
                );
            }
          },
        ),
      ],
      errorBuilder: (BuildContext context, GoRouterState state) =>
          const PageNotFoundPage(),
    );
  }
}
