// TODO Implement this library.
class FeedbackStorage {
  static final FeedbackStorage _singleton = FeedbackStorage._internal();
  final List<Map<String, dynamic>> _submittedFeedbacks = [];

  factory FeedbackStorage() {
    return _singleton;
  }

  FeedbackStorage._internal();

  List<Map<String, dynamic>> get feedbacks => _submittedFeedbacks;

  void addFeedback(Map<String, dynamic> feedback) {
    _submittedFeedbacks.add(feedback);
  }
}
