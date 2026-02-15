class SaveDraftRequestModel {
  const SaveDraftRequestModel({
    required this.applicationId,
    required this.sectionId,
    required this.data,
  });

  final String applicationId;
  final String sectionId;
  final Map<String, dynamic> data;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'applicationId': applicationId,
      'sectionId': sectionId,
      'data': data,
    };
  }
}
