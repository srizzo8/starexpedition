class DiscussionBoardUpdatesThreads{
  final int threadId;
  final String poster;
  final String threadTitle;
  final String threadContent;
  final Map<String, List<String>> replies;

  const DiscussionBoardUpdatesThreads({
    required this.threadId,
    required this.poster,
    required this.threadTitle,
    required this.threadContent,
    required this.replies,
  });

  toJson(){
    return{
      "threadId": threadId,
      "poster": poster,
      "threadTitle": threadTitle,
      "threadContent": threadContent,
      "replies": replies
    };
  }
}