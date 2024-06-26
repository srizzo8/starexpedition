class TechnologiesThreads{
  final int threadId;
  final String poster;
  final String threadTitle;
  final String threadContent;

  const TechnologiesThreads({
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