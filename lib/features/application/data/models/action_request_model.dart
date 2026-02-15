class ActionRequestModel {
  const ActionRequestModel({
    required this.applicationId,
    required this.actionId,
    required this.payload,
  });

  final String applicationId;
  final String actionId;
  final Map<String, dynamic> payload;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'applicationId': applicationId,
      'actionId': actionId,
      'payload': payload,
    };
  }
}
