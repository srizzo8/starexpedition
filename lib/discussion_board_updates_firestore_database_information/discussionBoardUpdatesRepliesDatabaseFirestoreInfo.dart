class DiscussionBoardUpdatesReplies{
  final int threadNumber;
  final String time;
  final String replier;
  final String replyContent;
  final Map<String, dynamic> theOriginalReplyInfo;

  const DiscussionBoardUpdatesReplies({
    required this.threadNumber,
    required this.time,
    required this.replier,
    required this.replyContent,
    required this.theOriginalReplyInfo,
  });

  toJson(){
    return{
      "threadNumber": threadNumber,
      "time": time,
      "replier": replier,
      "replyContent": replyContent,
      "theOriginalReplyInfo": theOriginalReplyInfo
    };
  }
}
