class EvaluateRequestModel {
  const EvaluateRequestModel({
    required this.applicationId,
    required this.phase,
    required this.context,
    required this.sectionData,
  });

  final String applicationId;
  final String phase;
  final Map<String, dynamic> context;
  final Map<String, dynamic> sectionData;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'applicationId': applicationId,
      'phase': phase,
      'context': context,
      'sectionData': sectionData,
    };
  }
}
