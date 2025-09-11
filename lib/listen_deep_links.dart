import 'package:totheblessing/main.dart';
import 'package:uni_links/uni_links.dart';

void listenForDeepLinks() async {
  final initialUri = await getInitialUri();
  if (initialUri != null) {
    _handleUri(initialUri);
  }

  uriLinkStream.listen((Uri? uri) {
    if (uri != null) {
      _handleUri(uri);
    }
  }, onError: (err) {
    print('Link stream error: $err');
  });
}

void _handleUri(Uri uri) {
  print("DEBUG: Recebido deep link -> $uri");

  // Se não tiver segmentos no path, não força redirecionamento
  if (uri.pathSegments.isEmpty) {
    print("Deep link sem rota -> ignorando");
    return;
  }

  final String route = "/${uri.pathSegments.first}";
  final Map<String, String> queryParams = uri.queryParameters;

  // Evita mandar pro "/" (home) automaticamente
  if (route == "/") {
    print("Deep link apontando para '/' -> ignorando");
    return;
  }

  navigatorKey.currentState?.pushNamedAndRemoveUntil(
    route,
    arguments: queryParams,
    (route) => false,
  );
}
