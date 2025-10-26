class TechnologiesRepliesToReplies{
  final int threadNumber;
  final String time;
  final String replier;
  final String replyContent;
  final Map<String, dynamic> originalReplyInfo;
  final int replyId;

  const TechnologiesRepliesToReplies({
    required this.threadNumber,
    required this.time,
    required this.replier,
    required this.replyContent,
    required this.originalReplyInfo,
    required this.replyId
  });

  toJson(){
    return{
      "threadNumber": threadNumber,
      "time": time,
      "replier": replier,
      "replyContent": replyContent,
      "originalReplyInfo": originalReplyInfo,
      "replyId": replyId
    };
  }
}
