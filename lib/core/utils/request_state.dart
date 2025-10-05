enum RequestStatus { loading, success, failed, init }

extension RequestStatusExtension on RequestStatus {
  // Convert enum to a string
  String toMap() {
    return toString().split('.').last; // Extract the enum name
  }

  // Convert a string to an enum
}

extension RequestStatusExtensionString on String {
  RequestStatus toRequestStatus() {
    return RequestStatus.values.firstWhere(
      (e) => e.toString().split('.').last == this,
      orElse: () => RequestStatus.init, // Default value
    );
  }
}
