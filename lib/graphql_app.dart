import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQlApp extends StatelessWidget {
  final ValueNotifier<GraphQLClient> client;
  static const String readRepos =
      """query ReadRepositories(\$nRepositories: Int!) {
    viewer {
      repositories(last: \$nRepositories) {
        nodes {
          id
          name
          viewerHasStarred
        }
      }
    }
  }""";

  GraphQlApp({this.client});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
        client: client,
        child: CacheProvider(
            child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: Query(
                  options: QueryOptions(
                    documentNode: gql(readRepos),
                    variables: {
                      'nRepositories': 50,
                    },
                    pollInterval: 10,
                  ),
                  builder: (QueryResult result,
                      {VoidCallback refetch, FetchMore fetchMore}) {
                    if (result.hasException) {
                      return Text(result.exception.toString());
                    }
                    if (result.loading) {
                      return Text('Loading');
                    }

                    List repositories =
                        result.data['viewer']['repositories']['nodes'];
                    final Map search = result.data['search'];
                    Map pageInfo;
                    if (search != null) {
                      pageInfo = search['pageInfo'] ?? null;
                    }
                    FetchMoreOptions opts;
                    if (search != null && pageInfo != null) {
                      final String fetchMoreCursor = pageInfo['endCursor'];
                      opts = FetchMoreOptions(
                        updateQuery: (previousResultData, fetchMoreResultData) {
                          final List<dynamic> repos = [
                            ...previousResultData['search']['nodes']
                                as List<dynamic>,
                            ...fetchMoreResultData['search']['nodes']
                                as List<dynamic>
                          ];
                          fetchMoreResultData['search']['nodes'] = repos;

                          return fetchMoreResultData;
                        },
                        variables: {'cursor': fetchMoreCursor},
                      );
                    }

                    return ListView.builder(
                      itemCount: repositories.length,
                      itemBuilder: (ctx, index) {
                        final repo = repositories[index];
                        if (index != repositories.length - 1) {
                          return Text(repo['name']);
                        } else {
                          return Column(
                            children: [
                              Text(repo['name']),
                              if (opts != null)
                                RaisedButton(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text("Load More"),
                                    ],
                                  ),
                                  onPressed: () {
                                    fetchMore(opts);
                                  },
                                )
                            ],
                          );
                        }
                      },
                    );
                  }),
            ),
          ),
        )));
  }
}
