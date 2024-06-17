class DiscussionBoardUpdatesRepliesToReplies{
  final int threadNumber;
  final String time;
  final String replier;
  final String replyContent;
  final int replyId;

  const DiscussionBoardUpdatesRepliesToReplies({
    required this.threadNumber,
    required this.time,
    required this.replier,
    required this.replyContent,
    required this.replyId,
  });

  toJson(){
    return{
      "threadNumber": threadNumber,
      "time": time,
      "replier": replier,
      "replyContent": replyContent,
      "replyId": replyId,
    };
  }
}
