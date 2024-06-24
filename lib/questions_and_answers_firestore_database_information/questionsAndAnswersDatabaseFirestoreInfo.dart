class QuestionsAndAnswersThreads{
  final int threadId;
  final String poster;
  final String threadTitle;
  final String threadContent;

  const QuestionsAndAnswersThreads({
    required this.threadId,
    required this.poster,
    required this.threadTitle,
    required this.threadContent,
  });

  toJson(){
    return{
      "threadId": threadId,
      "poster": poster,
      "threadTitle": threadTitle,
      "threadContent": threadContent,
    };
  }
}