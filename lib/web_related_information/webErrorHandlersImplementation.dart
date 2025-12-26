import 'webErrorHandlers.dart'
  if(dart.library.html) 'webErrorHandlersWeb.dart'
  if(dart.library.io) 'webErrorHandlersIo.dart';

export 'webErrorHandlers.dart';
