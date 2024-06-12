class DiscussionBoardUpdatesReplies{
  final int threadNumber;
  final String time;
  final String replier;
  final String replyContent;

  const DiscussionBoardUpdatesReplies({
    required this.threadNumber,
    required this.time,
    required this.replier,
    required this.replyContent,
  });

  toJson(){
    return{
      "threadNumber": threadNumber,
      "time": time,
      "replier": replier,
      "replyContent": replyContent,
    };
  }
}
