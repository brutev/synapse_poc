class SubmitRequestModel {
  const SubmitRequestModel({required this.applicationId});

  final String applicationId;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'applicationId': applicationId};
  }
}
