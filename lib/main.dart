import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'graphql_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final HttpLink gitHubLink = HttpLink(uri: 'https://api.github.com/graphql');
  final AuthLink authLink = AuthLink(
    getToken: () async => 'Bearer 72059609815271f227d4e0364d1e73c33211d982',
  );
  final Link link = authLink.concat(gitHubLink);
  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      cache: NormalizedInMemoryCache(
        dataIdFromObject: typenameDataIdFromObject,
      ),
      link: link,
    ),
  );
  runApp(GraphQlApp(client: client));
}
